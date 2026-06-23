import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/themes/app_theme.dart';
import '../controllers/notice_controller.dart';

class NoticeView extends GetView<NoticeController> {
  const NoticeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('通知公告'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() => controller.unreadCount.value > 0
              ? TextButton(
                  onPressed: controller.markAllRead,
                  child: const Text('全部已读', style: TextStyle(color: Colors.white)),
                )
              : const SizedBox.shrink()),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.h),
          child: Container(
            color: Colors.white,
            child: Obx(() => Row(
                  children: [
                    _tabButton(0, '全部'),
                    _tabButton(1, '未读'),
                  ],
                )),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notices.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.notices.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.notifications_none, size: 64.w, color: AppTheme.gray300),
                SizedBox(height: 16.h),
                Text('暂无通知', style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.refreshList,
          child: NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100) {
                controller.loadMore();
              }
              return false;
            },
            child: ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: controller.notices.length + 1,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                if (index == controller.notices.length) {
                  return Obx(() => Padding(
                        padding: EdgeInsets.all(16.w),
                        child: Center(
                          child: Text(
                            controller.hasMore.value ? '加载中...' : '没有更多了',
                            style: TextStyle(color: AppTheme.textTertiary, fontSize: 13.sp),
                          ),
                        ),
                      ));
                }
                final n = controller.notices[index];
                final id = n['id']?.toString() ?? '';
                final isRead = controller.selectedTabIndex.value == 1 ? false : controller.isRead(id);
                return _noticeCard(n, isRead: isRead);
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _tabButton(int index, String label) {
    return Obx(() {
      final selected = controller.selectedTabIndex.value == index;
      return Expanded(
        child: InkWell(
          onTap: () => controller.switchTab(index),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: selected ? AppTheme.primaryColor : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  color: selected ? AppTheme.primaryColor : AppTheme.textSecondary,
                  fontSize: 15.sp,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _noticeCard(Map<String, dynamic> n, {required bool isRead}) {
    final title = n['title']?.toString() ?? '';
    final summary = n['summary']?.toString() ?? n['content']?.toString() ?? '';
    final publisher = n['publisher']?.toString() ?? n['author']?.toString() ?? '';
    final time = _formatTime(n['publishTime'] ?? n['createTime']);
    final type = n['type']?.toString() ?? '通知';
    return InkWell(
      onTap: () => controller.openDetail(n),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(type, style: TextStyle(fontSize: 11.sp, color: AppTheme.primaryColor)),
                ),
                SizedBox(width: 8.w),
                if (!isRead)
                  Container(
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                const Spacer(),
                Text(time, style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary)),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            if (summary.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary),
              ),
            ],
            if (publisher.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text('发布人: $publisher', style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary)),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(dynamic t) {
    if (t == null) return '';
    DateTime dt;
    if (t is int) {
      dt = DateTime.fromMillisecondsSinceEpoch(t);
    } else if (t is String) {
      dt = DateTime.tryParse(t) ?? DateTime.now();
    } else {
      return t.toString();
    }
    final now = DateTime.now();
    if (dt.year == now.year) {
      return DateFormat('MM-dd HH:mm').format(dt);
    }
    return DateFormat('yyyy-MM-dd').format(dt);
  }
}
