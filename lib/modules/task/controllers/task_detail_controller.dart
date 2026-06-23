import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/task_repository.dart';
import '../../../app/themes/app_theme.dart';

class TaskDetailController extends GetxController {
  final _repository = TaskRepository();

  final isLoading = false.obs;
  final taskId = 0.obs;
  final task = <String, dynamic>{}.obs;
  final commentController = TextEditingController();
  final comments = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['taskId'] != null) {
      taskId.value = args['taskId'];
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
      final result = await _repository.getTaskDetail(taskId.value);
      if (result['success'] == true) {
        task.value = result['data'] ?? {};
      } else {
        _loadMock();
      }
    } catch (e) {
      _loadMock();
    } finally {
      isLoading.value = false;
    }
  }

  void addComment() {
    if (commentController.text.trim().isEmpty) return;
    comments.insert(0, {
      'user': '我',
      'content': commentController.text.trim(),
      'date': DateTime.now().toString().substring(0, 19),
    });
    commentController.clear();
    Get.snackbar('已添加', '评论已发布', snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.success, colorText: Colors.white);
  }

  void _loadMock() {
    task.value = {
      'id': taskId.value,
      'title': '完成控制器硬件测试',
      'description': '对新一批控制器进行硬件功能测试，包括电源测试、通信测试、可靠性测试等，并记录详细测试结果。\n\n测试完成后需提交测试报告，报告应包含测试环境、测试方法、测试数据、问题分析等内容。',
      'status': 'doing',
      'priority': 'high',
      'assignee': '张工',
      'creator': '张经理',
      'dueDate': '2024-01-20',
      'createdDate': '2024-01-15',
      'progress': 60,
    };
    comments.value = [
      {
        'user': '张经理',
        'content': '请加快进度，下周一前完成',
        'date': '2024-01-16 09:30',
      },
      {
        'user': '张工',
        'content': '已开始测试，目前已完成60%',
        'date': '2024-01-17 14:20',
      },
    ];
  }
}
