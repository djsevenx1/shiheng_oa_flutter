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
  final errorMessage = RxnString();

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
    errorMessage.value = null;
    await _load();
    isLoading.value = false;
  }

  Future<void> refreshList() async {
    currentPage.value = 1;
    hasMore.value = true;
    notices.clear();
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
    final unreadOnly = selectedTabIndex.value == 1;
    final result = await _repo.getNoticeList(
      page: currentPage.value,
      pageSize: 20,
      unreadOnly: unreadOnly,
    );
    if (result['success'] == true) {
      final list = (result['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      notices.addAll(list);
      final count = (result['count'] as int?) ?? 0;
      hasMore.value = notices.length < count;
      errorMessage.value = null;
    } else {
      errorMessage.value = result['message']?.toString();
      hasMore.value = false;
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
      refreshList();
    }
  }

  Future<void> markAllRead() async {
    isLoading.value = true;
    final ok = await _repo.markAllRead();
    isLoading.value = false;
    if (ok) {
      Get.snackbar('提示', '已全部标记为已读', snackPosition: SnackPosition.BOTTOM);
      unreadCount.value = 0;
      refreshList();
    } else {
      Get.snackbar('失败', '标记已读失败', snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// 用 server 端 isRead 字段判断（兼容：0/未读, 1/已读）
  bool isItemRead(Map<String, dynamic> n) {
    final v = n['isRead'];
    if (v is bool) return v;
    if (v is num) return v.toInt() != 0;
    if (v is String) return v == '1' || v.toLowerCase() == 'true';
    return false;
  }
}

class NoticeDetailController extends GetxController {
  final NoticeRepository _repo = NoticeRepository();

  final Map<String, dynamic> args = (Get.arguments as Map?)?.cast<String, dynamic>() ?? {};
  final notice = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadDetail();
  }

  Future<void> loadDetail() async {
    final id = args['id']?.toString() ?? '';
    if (id.isEmpty) return;
    isLoading.value = true;
    final result = await _repo.getNoticeDetail(id);
    isLoading.value = false;
    if (result['success'] == true) {
      notice.value = (result['data'] as Map?)?.cast<String, dynamic>();
      // 把标记已读的结果回传给列表（true 表示有更新）
      Get.back(result: true);
    } else {
      errorMessage.value = result['message']?.toString();
    }
  }

  void submitReply(String content) {
    final id = args['id']?.toString() ?? '';
    if (id.isEmpty || content.trim().isEmpty) return;
    _repo.reply(id: id, content: content.trim()).then((result) {
      if (result['success'] == true) {
        Get.snackbar('提示', '回复成功', snackPosition: SnackPosition.BOTTOM);
        loadDetail();
      } else {
        Get.snackbar('失败', result['message']?.toString() ?? '回复失败', snackPosition: SnackPosition.BOTTOM);
      }
    });
  }
}
