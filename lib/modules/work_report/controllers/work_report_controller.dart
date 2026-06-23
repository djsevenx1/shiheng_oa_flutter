import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/data/repository/work_report_repository.dart';

class WorkReportController extends GetxController {
  final WorkReportRepository _repo = WorkReportRepository();

  final myReports = <Map<String, dynamic>>[].obs;
  final receivedReports = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final selectedTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadList();
  }

  Future<void> loadList() async {
    isLoading.value = true;
    if (selectedTab.value == 0) {
      final result = await _repo.getMyReports();
      if (result['success'] == true && result['data'] is Map) {
        final list = (result['data']['data'] as List?) ?? (result['data'] as List?) ?? [];
        myReports.value = list.cast<Map<String, dynamic>>();
      }
    } else {
      final result = await _repo.getReceivedReports();
      if (result['success'] == true && result['data'] is Map) {
        final list = (result['data']['data'] as List?) ?? (result['data'] as List?) ?? [];
        receivedReports.value = list.cast<Map<String, dynamic>>();
      }
    }
    isLoading.value = false;
  }

  void switchTab(int i) {
    selectedTab.value = i;
    loadList();
  }

  String formatDate(dynamic t) {
    if (t == null) return '';
    DateTime dt;
    if (t is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(t);
    } else if (t is String) {
      dt = DateTime.tryParse(t) ?? DateTime.now();
    } else {
      return t.toString();
    }
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  }
}

class WorkReportSubmitController extends GetxController {
  final WorkReportRepository _repo = WorkReportRepository();

  final titleController = TextEditingController();
  final content = ''.obs;
  final type = 'daily'.obs;
  final recipients = <String>[].obs;
  final isSubmitting = false.obs;

  @override
  void onClose() {
    titleController.dispose();
    super.onClose();
  }

  void setType(String t) => type.value = t;

  void setContent(String json) => content.value = json;

  void toggleRecipient(String userId) {
    if (recipients.contains(userId)) {
      recipients.remove(userId);
    } else {
      recipients.add(userId);
    }
  }

  Future<bool> submit() async {
    if (titleController.text.trim().isEmpty) {
      Get.snackbar('提示', '请输入标题', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    if (content.value.isEmpty) {
      Get.snackbar('提示', '请输入汇报内容', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
    isSubmitting.value = true;
    final result = await _repo.submit(
      title: titleController.text.trim(),
      content: content.value,
      type: type.value,
      recipients: recipients.toList(),
    );
    isSubmitting.value = false;
    if (result['success'] == true) {
      Get.snackbar('提示', '已提交', snackPosition: SnackPosition.BOTTOM);
      return true;
    }
    Get.snackbar('提交失败', result['message'] ?? '', snackPosition: SnackPosition.BOTTOM);
    return false;
  }
}
