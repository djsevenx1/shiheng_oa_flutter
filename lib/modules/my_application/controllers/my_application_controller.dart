import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/data/repository/my_application_repository.dart';

class MyApplicationController extends GetxController {
  final MyApplicationRepository _repo = MyApplicationRepository();

  final applications = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final currentPage = 1.obs;
  final selectedTabIndex = 0.obs;

  static const statuses = ['running', 'finished', 'rejected'];
  static const statusLabels = ['进行中', '已完成', '已驳回'];

  String get currentStatus => statuses[selectedTabIndex.value];

  @override
  void onInit() {
    super.onInit();
    loadInitial();
  }

  Future<void> loadInitial() async {
    isLoading.value = true;
    currentPage.value = 1;
    hasMore.value = true;
    applications.clear();
    await _load();
    isLoading.value = false;
  }

  Future<void> refreshList() async {
    currentPage.value = 1;
    hasMore.value = true;
    applications.clear();
    await _load();
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    currentPage.value++;
    await _load();
    isLoadingMore.value = false;
  }

  Future<void> _load() async {
    final result = await _repo.getMyApplications(
      page: currentPage.value,
      pageSize: 20,
      status: currentStatus,
    );
    if (result['success'] == true) {
      final list = (result['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      applications.addAll(list);
      final total = (result['total'] as int?) ?? 0;
      hasMore.value = applications.length < total;
    }
  }

  void switchTab(int index) {
    selectedTabIndex.value = index;
    loadInitial();
  }

  Future<void> cancel(String id) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('撤销申请'),
        content: const Text('确定要撤销该申请吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('取消')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('确定')),
        ],
      ),
    );
    if (confirm != true) return;
    final result = await _repo.cancelApplication(id);
    if (result['success'] == true) {
      Get.snackbar('提示', '已撤销', snackPosition: SnackPosition.BOTTOM);
      refreshList();
    } else {
      Get.snackbar('撤销失败', result['message'] ?? '', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> urge(String id) async {
    final result = await _repo.urge(id);
    if (result['success'] == true) {
      Get.snackbar('提示', '已催办', snackPosition: SnackPosition.BOTTOM);
    } else {
      Get.snackbar('催办失败', result['message'] ?? '', snackPosition: SnackPosition.BOTTOM);
    }
  }

  String formatTime(dynamic t) {
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
