import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/auth_repository.dart';
import '../../../app/data/repository/workflow_repository.dart';
import '../../../app/themes/app_theme.dart';

class FormFieldSchema {
  final String name;
  final String label;
  final String type; // text, number, date, datetime, textarea, select, radio, checkbox, file, user, detail
  final String ctrl; // 老 OA ctrl: sequence/current/info/user/logs/...
  final bool required;
  final String? placeholder;
  final List<Map<String, dynamic>>? options;
  final dynamic defaultValue;
  final String? helpText;
  final String? validation;
  final List<Map<String, dynamic>>? fields; // 明细子表子字段

  FormFieldSchema({
    required this.name,
    required this.label,
    required this.type,
    this.ctrl = 'text',
    this.required = false,
    this.placeholder,
    this.options,
    this.defaultValue,
    this.helpText,
    this.validation,
    this.fields,
  });

  /// 是否自动填字段（不让用户编辑）
  bool get isAutoFill => ['sequence', 'current', 'info', 'logs', 'name', 'department'].contains(ctrl);
}

class WorkflowFormController extends GetxController {
  final _repository = WorkflowRepository();

  final isLoading = false.obs;
  final modId = 0.obs;
  final appKey = ''.obs;
  final moduleName = ''.obs;
  final formFields = <FormFieldSchema>[].obs;
  final formData = <String, dynamic>{}.obs;
  final formKey = GlobalKey<FormState>();
  final isSubmitting = false.obs;
  final selectedApprovers = <String>{}.obs;
  final detailRows = <String, List<Map<String, dynamic>>>{}.obs;
  final errorMessage = RxnString();

  // 文本输入控制器（每个字段一个，用于自动填值后更新 UI）
  final textControllers = <String, TextEditingController>{}.obs;

  // 保存 schema 加载结果中的 module 对象和 groupId（提交时需要）
  Map<String, dynamic>? _moduleObj;
  int? _groupId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['modId'] != null) {
      modId.value = args['modId'] is int ? args['modId'] as int : int.tryParse(args['modId'].toString()) ?? 0;
      if (args['moduleName'] != null) {
        moduleName.value = args['moduleName'].toString();
      }
      loadFormSchema();
    } else {
      errorMessage.value = '缺少 modId 参数';
    }
  }

  @override
  void onClose() {
    for (final ctrl in textControllers.values) {
      ctrl.dispose();
    }
    super.onClose();
  }

  Future<void> loadFormSchema() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _repository.getFormSchema(modId.value);
      if (result['success'] == true) {
        final data = (result['data'] as Map?)?.cast<String, dynamic>() ?? {};
        if (moduleName.value.isEmpty) {
          moduleName.value = data['moduleName']?.toString() ?? '流程表单';
        }
        appKey.value = data['appKey']?.toString() ?? '';
        // 保存 module 对象（提交时需要传给 /oa/pro/handle）
        _moduleObj = (data['module'] is Map) ? Map<String, dynamic>.from(data['module'] as Map) : null;
        // 获取当前用户 groupId
        _groupId = await _getCurrentGroupId();
        final fieldsJson = (data['fields'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        formFields.value = fieldsJson.map((json) {
          // 老 OA: flagDetail=true 是明细表，需用 'detail' 类型渲染
          String type = json['type']?.toString() ?? 'text';
          if (json['flagDetail'] == true) type = 'detail';
          return FormFieldSchema(
            name: json['name'] ?? '',
            label: json['label'] ?? '',
            type: type,
            ctrl: json['ctrl']?.toString() ?? 'text',
            required: json['required'] ?? false,
            placeholder: json['placeholder']?.toString(),
            options: (json['options'] as List?)?.cast<Map<String, dynamic>>(),
            defaultValue: json['defaultValue'],
            helpText: json['helpText']?.toString(),
            fields: (json['fields'] is List) ? (json['fields'] as List).cast<Map<String, dynamic>>() : null,
          );
        }).toList();
        if (formFields.isEmpty) {
        errorMessage.value = '该流程未配置表单字段（后端 schema 为空）';
      }
        // 先为所有 text/number 字段创建 TextEditingController
        for (final f in formFields) {
          if (f.type == 'text' || f.type == 'number' || f.type == 'textarea') {
            getTextController(f.name);
          }
        }
        // 自动填 sequence / current / info / logs 字段
        await _autoFillFields();
      } else {
        errorMessage.value = result['message']?.toString() ?? '加载表单失败';
      }
    } catch (e) {
      errorMessage.value = '加载表单异常: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void updateField(String name, dynamic value) {
    formData[name] = value;
  }

  /// 获取当前用户 groupId
  Future<int?> _getCurrentGroupId() async {
    try {
      final auth = AuthRepository();
      final res = await auth.getCurrentUser();
      if (res['success'] == true && res['data'] is Map) {
        final u = res['data'] as Map;
        final gid = u['groupId'];
        if (gid is int) return gid;
        if (gid != null) return int.tryParse(gid.toString());
      }
    } catch (_) {}
    return null;
  }

  /// 自动填 sequence / current / info / logs 字段
  Future<void> _autoFillFields() async {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final timeStr = '$dateStr ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    String? currentUserId;
    String? currentUserName;
    String? currentUserDept;
    try {
      final auth = AuthRepository();
      final res = await auth.getCurrentUser();
      debugPrint('[autoFill] getCurrentUser result: $res');
      Map? u;
      if (res['success'] == true && res['data'] is Map) {
        u = res['data'] as Map;
      } else if (res is Map && res['data'] is Map) {
        u = res['data'] as Map;
      } else if (res is Map && res['id'] != null) {
        u = res;
      }
      if (u != null) {
        currentUserId = u['id']?.toString();
        currentUserName = u['name']?.toString()
            ?? u['loginName']?.toString()
            ?? u['userName']?.toString()
            ?? u['user']?.toString();
        currentUserDept = u['groupName']?.toString()
            ?? u['department']?.toString()
            ?? u['deptName']?.toString()
            ?? u['dept']?.toString();
        debugPrint('[autoFill] user: id=$currentUserId name=$currentUserName dept=$currentUserDept');
      } else {
        debugPrint('[autoFill] getCurrentUser returned no user data');
      }
    } catch (e) {
      debugPrint('[autoFill] getCurrentUser error: $e');
    }

    for (final f in formFields) {
      if (!f.isAutoFill) continue;
      switch (f.ctrl) {
        case 'sequence':
          formData[f.name] = 'AUTO_${now.millisecondsSinceEpoch.toString().substring(7)}';
          break;
        case 'current':
        case 'date':
        case 'datetime':
          formData[f.name] = f.ctrl == 'date' ? dateStr : timeStr;
          break;
        case 'info':
        case 'name':
          if (f.label.contains('部门') || f.label.contains('department')) {
            formData[f.name] = currentUserDept ?? '';
          } else {
            formData[f.name] = currentUserId ?? currentUserName ?? '';
          }
          break;
        case 'logs':
          // 批准人 — 审批日志，新建时为空
          formData[f.name] = '';
          break;
      }
    }
    // 触发 formFields 重建（formData 改了 view 才会刷新）
    if (formFields.isNotEmpty) {
      formFields.refresh();
    }
    // 更新文本控制器，让 TextFormField 显示自动填的值
    debugPrint('[autoFill] formData after fill: ${formData.toString()}');
    debugPrint('[autoFill] textControllers keys: ${textControllers.keys.toList()}');
    for (final entry in formData.entries) {
      final ctrl = textControllers[entry.key];
      if (ctrl != null) {
        ctrl.text = entry.value?.toString() ?? '';
        debugPrint('[autoFill] set controller ${entry.key} = ${ctrl.text}');
      } else {
        debugPrint('[autoFill] no controller for ${entry.key}');
      }
    }
  }

  /// 获取或创建字段的 TextEditingController
  TextEditingController getTextController(String fieldName) {
    return textControllers.putIfAbsent(fieldName, () => TextEditingController());
  }

  void toggleApprover(String name) {
    if (selectedApprovers.contains(name)) {
      selectedApprovers.remove(name);
    } else {
      selectedApprovers.add(name);
    }
  }

  /// 明细行操作
  void addDetailRow(String parentName) {
    final list = List<Map<String, dynamic>>.from(detailRows[parentName] ?? []);
    list.add({});
    detailRows[parentName] = list;
  }

  void removeDetailRow(String parentName, int index) {
    final list = List<Map<String, dynamic>>.from(detailRows[parentName] ?? []);
    if (index < list.length) {
      list.removeAt(index);
      detailRows[parentName] = list;
    }
  }

  void updateDetailCell(String parentName, int rowIndex, String key, dynamic value) {
    final list = List<Map<String, dynamic>>.from(detailRows[parentName] ?? []);
    if (rowIndex < list.length) {
      final row = Map<String, dynamic>.from(list[rowIndex]);
      row[key] = value;
      list[rowIndex] = row;
      detailRows[parentName] = list;
    }
  }

  Future<void> submit() async {
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      Get.snackbar('提示', '请填写完整表单', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.warning, colorText: Colors.white);
      return;
    }
    if (formFields.isEmpty) {
      Get.snackbar('提示', '表单字段未加载', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSubmitting.value = true;
    try {
      // 把明细合并到 formData，移除前端显示用的 __name 缓存字段
      final data = <String, dynamic>{};
      formData.forEach((k, v) {
        if (!k.endsWith('__name')) data[k] = v;
      });
      detailRows.forEach((key, rows) {
        data[key] = rows;
      });
      final result = await _repository.submitWorkflow(
        modId: modId.value,
        formData: data,
        appKey: appKey.value,
        name: moduleName.value,
        module: _moduleObj,
        proId: null, // 新建流程
        groupId: _groupId,
        flagPositive: null, // 新建流程
      );
      if (result['success'] == true) {
        // 老 App 提交成功后显示审批人信息然后跳转
        final msg = result['message']?.toString() ?? '流程已发起，等待审批';
        Get.snackbar('提交成功', msg, snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.success, colorText: Colors.white,
            duration: const Duration(seconds: 2));
        // 等待 1.5 秒让用户看到提示，然后返回首页（跳过中间页）
        await Future.delayed(const Duration(milliseconds: 1500));
        Get.until((route) => Get.currentRoute == '/home');
      } else {
        Get.snackbar('提交失败', result['message']?.toString() ?? '请稍后再试',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.danger, colorText: Colors.white,
            duration: const Duration(seconds: 4));
      }
    } catch (e) {
      Get.snackbar('提交失败', '异常: $e', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.danger, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }
}
