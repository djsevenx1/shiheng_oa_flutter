import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/data/repository/notice_repository.dart';
import '../../../app/routes/app_pages.dart';

class NoticeController extends GetxController {
  final NoticeRepository _repo = NoticeRepository();

  final notices = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final currentPage = 1.obs;
  final unreadCount = 0.obs;
  final selectedTabIndex = 0.obs;

  bool isRead(String id) => _repo.isRead(id);

  @override
  void onInit() {
    super.onInit();
    loadInitial();
  }

  @override
  void onReady() {
    super.onReady();
    refreshUnread();
  }

  Future<void> loadInitial() async {
    isLoading.value = true;
    currentPage.value = 1;
    hasMore.value = true;
    notices.clear();
    await _load();
    isLoading.value = false;
  }

  Future<void> refreshList() async {
    currentPage.value = 1;
    hasMore.value = true;
    notices.clear();
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
    final type = selectedTabIndex.value == 1 ? 'unread' : 'all';
    final result = await _repo.getNoticeList(
      page: currentPage.value,
      pageSize: 20,
      type: type,
    );
    if (result['success'] == true) {
      final list = (result['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      notices.addAll(list);
      final total = (result['total'] as int?) ?? 0;
      hasMore.value = notices.length < total;
    }
  }

  Future<void> refreshUnread() async {
    unreadCount.value = await _repo.getUnreadCount();
  }

  void switchTab(int index) {
    selectedTabIndex.value = index;
    refreshList();
    if (index == 0) refreshUnread();
  }

  Future<void> openDetail(Map<String, dynamic> notice) async {
    final id = notice['id']?.toString() ?? '';
    if (id.isEmpty) return;
    final result = await Get.toNamed(
      Routes.NOTICE_DETAIL,
      arguments: {'id': id, 'title': notice['title']?.toString() ?? '通知详情'},
    );
    if (result == true) {
      refreshUnread();
    }
  }

  Future<void> markAllRead() async {
    final ok = await _repo.markAllRead();
    if (ok) {
      Get.snackbar('提示', '已全部标记为已读', snackPosition: SnackPosition.BOTTOM);
      unreadCount.value = 0;
      refreshList();
    }
  }
}
