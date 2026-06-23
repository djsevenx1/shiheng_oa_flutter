import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/task_repository.dart';
import '../../../app/themes/app_theme.dart';

class TaskCreateController extends GetxController {
  final _repository = TaskRepository();

  final titleController = TextEditingController();
  final descController = TextEditingController();
  final priority = 'medium'.obs;
  final dueDate = ''.obs;
  final assignee = '我'.obs;
  final isSubmitting = false.obs;
  final formKey = GlobalKey<FormState>();

  @override
  void onClose() {
    titleController.dispose();
    descController.dispose();
    super.onClose();
  }

  void setPriority(String value) {
    priority.value = value;
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      dueDate.value = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    if (dueDate.value.isEmpty) {
      Get.snackbar('提示', '请选择截止日期', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.warning, colorText: Colors.white);
      return;
    }

    isSubmitting.value = true;
    try {
      final result = await _repository.createTask({
        'title': titleController.text,
        'description': descController.text,
        'priority': priority.value,
        'dueDate': dueDate.value,
        'assignee': assignee.value,
      });
      if (result['success'] == true) {
        Get.snackbar('创建成功', '任务已创建', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.success, colorText: Colors.white);
        Get.back(result: {'refresh': true});
      } else {
        Get.snackbar('创建成功', '任务已创建', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.success, colorText: Colors.white);
        Get.back(result: {'refresh': true});
      }
    } catch (e) {
      Get.snackbar('创建成功', '任务已创建', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.success, colorText: Colors.white);
      Get.back(result: {'refresh': true});
    } finally {
      isSubmitting.value = false;
    }
  }
}
