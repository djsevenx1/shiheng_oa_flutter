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

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['proId'] != null) {
      proId.value = args['proId'];
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
    try {
      final result = await _repository.getWorkflowDetail(proId.value);
      if (result['success'] == true) {
        workflowDetail.value = result['data'] ?? {};
        logs.value = result['data']?['logs'] ?? [];
        formData.value = result['data']?['formData'] ?? {};
      } else {
        // /* MOCK-DISABLED */;  // mock disabled
      }
    } catch (e) {
      // /* MOCK-DISABLED */;  // mock disabled
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approve() async {
    if (commentController.text.trim().isEmpty) {
      Get.snackbar('提示', '请输入审批意见', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading.value = true;
    try {
      final result = await _repository.approveWorkflow(proId.value, {
        'flagPositive': true,
        'message': commentController.text.trim(),
      });
      if (result['success'] == true) {
        Get.snackbar('成功', '审批已通过', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.success, colorText: Colors.white);
        Get.back(result: {'refresh': true});
      } else {
        Get.snackbar('失败', result['message'] ?? '审批失败', snackPosition: SnackPosition.BOTTOM,
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
      final result = await _repository.approveWorkflow(proId.value, {
        'flagPositive': false,
        'message': commentController.text.trim(),
      });
      if (result['success'] == true) {
        Get.snackbar('成功', '已拒绝', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.warning, colorText: Colors.white);
        Get.back(result: {'refresh': true});
      } else {
        Get.snackbar('失败', result['message'] ?? '操作失败', snackPosition: SnackPosition.BOTTOM);
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
    workflowDetail.value = {
      'id': proId.value,
      'name': '请假申请',
      'moduleName': '请假流程',
      'state': 1,
      'creatorName': '张三',
      'createdDate': '2024-01-15 09:30',
      'currentNodeName': '部门经理审批',
    };
    formData.value = {
      '请假类型': '事假',
      '开始日期': '2024-01-16',
      '结束日期': '2024-01-17',
      '请假天数': '2天',
      '请假原因': '家中有事需要处理',
      '附件': '无',
    };
    logs.value = [
      {
        'userName': '张三',
        'action': '发起申请',
        'message': '申请事假2天',
        'date': '2024-01-15 09:30',
        'flagPositive': true,
      },
      {
        'userName': '李四',
        'action': '组长审批',
        'message': '同意',
        'date': '2024-01-15 10:15',
        'flagPositive': true,
      },
    ];
  }
}
