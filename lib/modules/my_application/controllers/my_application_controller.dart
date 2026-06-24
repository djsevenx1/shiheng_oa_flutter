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
  final errorMessage = RxnString();

  /// 三个 tab：待我审批、进行中、已完成
  /// 对应后端: todo / running / done
  static const tabKeys = ['todo', 'running', 'done'];
  static const tabLabels = ['待我审批', '进行中', '已完成'];

  String get currentTabKey => tabKeys[selectedTabIndex.value];

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
    errorMessage.value = null;
    await _load();
    isLoading.value = false;
  }

  Future<void> refreshList() async {
    currentPage.value = 1;
    hasMore.value = true;
    applications.clear();
    errorMessage.value = null;
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
    final result = await _repo.getListByTab(
      currentTabKey,
      limit: 20,
      offset: (currentPage.value - 1) * 20,
    );
    if (result['success'] == true) {
      final list = (result['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      applications.addAll(list);
      final count = (result['count'] as int?) ?? 0;
      hasMore.value = applications.length < count;
      errorMessage.value = null;
    } else {
      errorMessage.value = result['message']?.toString();
      hasMore.value = false;
    }
  }

  void switchTab(int index) {
    selectedTabIndex.value = index;
    loadInitial();
  }

  Future<void> approve(String id, {required bool pass, String comment = ''}) async {
    final result = await _repo.approveWorkflow(
      proId: id,
      result: pass ? 'pass' : 'reject',
      comment: comment,
    );
    if (result['success'] == true) {
      Get.snackbar('提示', pass ? '已同意' : '已驳回', snackPosition: SnackPosition.BOTTOM);
      refreshList();
    } else {
      Get.snackbar('操作失败', result['message']?.toString() ?? '', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> withdraw(String id) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('撤回流程'),
        content: const Text('确定要撤回该流程吗？'),
        actions: [
          TextButton(onPressed: () => Get.back(result: false), child: const Text('取消')),
          TextButton(onPressed: () => Get.back(result: true), child: const Text('确定')),
        ],
      ),
    );
    if (confirm != true) return;
    final result = await _repo.withdraw(id);
    if (result['success'] == true) {
      Get.snackbar('提示', '已撤回', snackPosition: SnackPosition.BOTTOM);
      refreshList();
    } else {
      Get.snackbar('撤回失败', result['message']?.toString() ?? '', snackPosition: SnackPosition.BOTTOM);
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
