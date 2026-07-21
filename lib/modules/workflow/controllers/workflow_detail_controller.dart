import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/workflow_repository.dart';
import '../../../app/themes/app_theme.dart';

class WorkflowDetailController extends GetxController {
  final _repository = WorkflowRepository();

  final isLoading = false.obs;
  final proId = 0.obs;
  final workflowDetail = <String, dynamic>{}.obs;
  final logs = <Map<String, dynamic>>[].obs;
  final formData = <String, dynamic>{}.obs;
  final commentController = TextEditingController();
  final errorMessage = RxnString();

  // tableSchema 解析结果
  final mainFields = <Map<String, dynamic>>[].obs;  // 主表字段（非明细）
  final detailFields = <Map<String, dynamic>>[].obs; // 明细子字段定义
  final mxItems = <Map<String, dynamic>>[].obs;      // 明细数据行
  final isHandleMode = false.obs; // true=待处理(可审批) false=历史(只读)

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['proId'] != null) {
      final raw = args['proId'];
      proId.value = raw is int ? raw : int.tryParse(raw.toString()) ?? 0;
      isHandleMode.value = args['handle'] == true;
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
      final result = await _repository.getWorkflowDetail(proId.value);
      if (result['success'] == true) {
        final data = (result['data'] as Map?)?.cast<String, dynamic>() ?? {};
        _formatTimestampField(data, 'createdDate');
        _formatTimestampField(data, 'lastDate');
        workflowDetail.value = data;

        // 解析 tableSchema
        var ts = data['tableSchema'];
        if (ts is String) {
          ts = jsonDecode(ts);
        }
        if (ts is List) {
          mainFields.clear();
          detailFields.clear();
          for (final f in ts) {
            final field = Map<String, dynamic>.from(f as Map);
            if (field['flagDetail'] == true) {
              final subs = field['fields'];
              if (subs is List) {
                for (final s in subs) {
                  detailFields.add(Map<String, dynamic>.from(s as Map));
                }
              }
            } else {
              mainFields.add(field);
            }
          }
        }

        // 解析 formData
        final rawFormData = (data['formData'] as Map?)?.cast<String, dynamic>() ?? {};
        formData.value = Map<String, dynamic>.from(rawFormData);
        for (final key in ['created_date', 'rq', 'last_date']) {
          if (formData.containsKey(key)) {
            _formatTimestampField(formData, key);
          }
        }

        // 解析 mx（明细数据行）
        final mx = formData['mx'];
        if (mx is List) {
          mxItems.value = mx.map((m) {
            final item = Map<String, dynamic>.from(m as Map);
            for (final key in ['created_date', 'xqrq', 'rq']) {
              if (item.containsKey(key)) {
                _formatTimestampField(item, key);
              }
            }
            return item;
          }).toList();
        } else {
          mxItems.clear();
        }

        // 解析 logs
        final rawLogs = (data['logs'] as List?) ?? [];
        logs.value = rawLogs.map((log) {
          final m = Map<String, dynamic>.from(log as Map);
          _formatTimestampField(m, 'createdDate');
          return m;
        }).toList();
      } else {
        errorMessage.value = result['message']?.toString() ?? '加载详情失败';
      }
    } catch (e) {
      errorMessage.value = '加载详情异常: $e';
    } finally {
      isLoading.value = false;
    }
  }

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

  bool isActionPositive(dynamic actionId) {
    final id = actionId is int ? actionId : int.tryParse(actionId?.toString() ?? '') ?? 0;
    return id == 1 || id == 2 || id == 4 || id == 11;
  }

  /// 获取字段显示值
  String getFieldValue(Map<String, dynamic> field) {
    final id = field['id']?.toString() ?? '';
    final ctrl = field['ctrl']?.toString() ?? '';
    final value = formData[id];

    if (ctrl == 'logs') {
      final names = <String>[];
      for (final log in logs) {
        final name = log['name']?.toString();
        if (name != null && name.isNotEmpty) names.add(name);
      }
      return names.join(', ');
    }

    if (value == null) return '';
    return value.toString();
  }

  String getDetailValue(Map<String, dynamic> mxItem, Map<String, dynamic> field) {
    final id = field['id']?.toString() ?? '';
    final value = mxItem[id];
    if (value == null) return '';
    return value.toString();
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
        // 提交成功后，重新加载详情验证是否真的生效
        await loadDetail();
        // 检查流程状态：如果 state 变了（不再是审批中），或者 logs 新增了记录，说明真的成功了
        final newState = workflowDetail['state'];
        final logCount = logs.length;
        if (newState == 2) {
          // 流程已结束
          Get.snackbar('成功', '审批已通过，流程已结束', snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppTheme.success, colorText: Colors.white);
          Get.back(result: {'refresh': true});
        } else if (logCount > 0) {
          // 还有审批记录，说明提交生效了
          Get.snackbar('成功', '审批已通过', snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppTheme.success, colorText: Colors.white);
          Get.back(result: {'refresh': true});
        } else {
          // 重新加载后没变化，可能提交没生效
          Get.snackbar('失败', '网络错误，请重试', snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppTheme.danger, colorText: Colors.white);
        }
      } else {
        Get.snackbar('失败', '网络错误，请重试', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.danger, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('失败', '网络错误，请重试', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.danger, colorText: Colors.white);
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
        // 提交成功后，重新加载详情验证
        await loadDetail();
        final newState = workflowDetail['state'];
        if (newState == -1 || newState == 2) {
          // 流程被拒绝或已结束
          Get.snackbar('成功', '已拒绝', snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppTheme.warning, colorText: Colors.white);
          Get.back(result: {'refresh': true});
        } else {
          Get.snackbar('成功', '已拒绝', snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppTheme.warning, colorText: Colors.white);
          Get.back(result: {'refresh': true});
        }
      } else {
        Get.snackbar('失败', '网络错误，请重试', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.danger, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('失败', '网络错误，请重试', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.danger, colorText: Colors.white);
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

  /// 编辑明细行
  void updateMxItem(int index, Map<String, dynamic> values) {
    if (index < mxItems.length) {
      final item = Map<String, dynamic>.from(mxItems[index]);
      item.addAll(values);
      mxItems[index] = item;
      mxItems.refresh();
      formData['mx'] = mxItems.toList();
    }
  }

  /// 新增明细行
  void addMxItem() {
    final newItem = <String, dynamic>{};
    for (final f in detailFields) {
      final id = f['id']?.toString() ?? f['name']?.toString() ?? '';
      if (id.isNotEmpty) newItem[id] = '';
    }
    mxItems.add(newItem);
    formData['mx'] = mxItems.toList();
  }

  /// 删除明细行
  void removeMxItem(int index) {
    if (index < mxItems.length) {
      mxItems.removeAt(index);
      formData['mx'] = mxItems.toList();
    }
  }
}
