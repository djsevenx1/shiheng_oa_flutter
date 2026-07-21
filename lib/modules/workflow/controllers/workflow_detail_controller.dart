import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/workflow_repository.dart';
import '../../../app/themes/app_theme.dart';

class WorkflowDetailController extends GetxController {
  final _repository = WorkflowRepository();

  final isLoading = false.obs;
  final proId = 0.obs;
  final workflowDetail = <String, dynamic>{}.obs;
  final logs = <dynamic>[].obs;
  final formData = <String, dynamic>{}.obs;
  final commentController = TextEditingController();
  final approvalAction = ''.obs; // 'approve', 'reject', 'read'
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['proId'] != null) {
      final raw = args['proId'];
      proId.value = raw is int ? raw : int.tryParse(raw.toString()) ?? 0;
      loadDetail();
    }
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  Future<void> loadDetail() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      // 老 OA 流程详情走 /oa/pro/init/:proId
      final result = await _repository.getWorkflowDetail(proId.value);
      if (result['success'] == true) {
        final data = (result['data'] as Map?)?.cast<String, dynamic>() ?? {};
        // 格式化顶层 createdDate（后端返回毫秒时间戳，字段名是驼峰 createdDate）
        _formatTimestampField(data, 'createdDate');
        _formatTimestampField(data, 'lastDate');
        workflowDetail.value = data;
        // logs 在顶层
        final rawLogs = (data['logs'] as List?) ?? [];
        logs.value = rawLogs.map((log) {
          final m = Map<String, dynamic>.from(log as Map);
          // 格式化 log 的 createdDate 时间戳
          _formatTimestampField(m, 'createdDate');
          return m;
        }).toList();
        // formData 过滤掉 logs/mx 等非显示字段，格式化时间戳
        final rawFormData = (data['formData'] as Map?)?.cast<String, dynamic>() ?? {};
        formData.value = Map<String, dynamic>.from(rawFormData);
        // 移除非显示字段
        formData.removeWhere((k, v) => k == 'logs' || k == 'mx' || k == 'id' || k == 'status' || k == 'proId');
        // 格式化 formData 里的时间戳字段（created_date, rq 等下划线字段名）
        for (final key in ['created_date', 'rq', 'last_date']) {
          if (formData.containsKey(key)) {
            _formatTimestampField(formData, key);
          }
        }
      } else {
        errorMessage.value = result['message']?.toString() ?? '加载详情失败';
      }
    } catch (e) {
      errorMessage.value = '加载详情异常: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// 格式化时间戳字段（毫秒 → yyyy-MM-dd HH:mm）
  void _formatTimestampField(Map<String, dynamic> map, String key) {
    final v = map[key];
    if (v is int && v > 100000000000) {
      final dt = DateTime.fromMillisecondsSinceEpoch(v);
      map[key] = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (v is String && v.length > 10) {
      map[key] = v.substring(0, v.length > 16 ? 16 : v.length);
    }
  }

  /// actionId 转中文操作名
  String getActionName(dynamic actionId) {
    final id = actionId is int ? actionId : int.tryParse(actionId?.toString() ?? '') ?? 0;
    switch (id) {
      case 1: return '发起';
      case 2: return '同意';
      case 3: return '拒绝';
      case 4: return '转交';
      case 11: return '加签';
      case -1: return '撤回';
      default: return '审批';
    }
  }

  /// actionId 判断是否通过
  bool isActionPositive(dynamic actionId) {
    final id = actionId is int ? actionId : int.tryParse(actionId?.toString() ?? '') ?? 0;
    return id == 1 || id == 2 || id == 4 || id == 11;
  }

  Future<void> approve() async {
    if (commentController.text.trim().isEmpty) {
      Get.snackbar('提示', '请输入审批意见', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading.value = true;
    try {
      final result = await _repository.approveWorkflow(
        proId: proId.value,
        result: 'pass',
        comment: commentController.text.trim(),
      );
      if (result['success'] == true) {
        Get.snackbar('成功', '审批已通过', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.success, colorText: Colors.white);
        Get.back(result: {'refresh': true});
      } else {
        Get.snackbar('失败', result['message']?.toString() ?? '审批失败', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.danger, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('错误', '网络错误', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reject() async {
    if (commentController.text.trim().isEmpty) {
      Get.snackbar('提示', '请输入拒绝原因', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading.value = true;
    try {
      final result = await _repository.approveWorkflow(
        proId: proId.value,
        result: 'reject',
        comment: commentController.text.trim(),
      );
      if (result['success'] == true) {
        Get.snackbar('成功', '已拒绝', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.warning, colorText: Colors.white);
        Get.back(result: {'refresh': true});
      } else {
        Get.snackbar('失败', result['message']?.toString() ?? '操作失败', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('错误', '网络错误', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  String getStateName(int state) {
    switch (state) {
      case 0: return '未提交';
      case 1: return '审批中';
      case 2: return '已结束';
      case -1: return '被拒绝';
      case -2: return '被撤回';
      default: return '未知';
    }
  }

  Color getStateColor(int state) {
    switch (state) {
      case 0: return AppTheme.warning;
      case 1: return AppTheme.info;
      case 2: return AppTheme.success;
      case -1: case -2: return AppTheme.danger;
      default: return AppTheme.gray500;
    }
  }

  void _loadMockDetail() {
    // [MOCK-DISABLED] 不再加载假数据；后端失败时显示错误状态
  }
}
