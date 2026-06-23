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
        title: const Text('消息通知'),
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
      body: Column(
        children: [
          // 错误条：失败时显示红色提示
          Obx(() => controller.errorMessage.value == null
              ? const SizedBox.shrink()
              : Container(
                  width: double.infinity,
                  color: Colors.red.shade50,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 18),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          controller.errorMessage.value ?? '',
                          style: TextStyle(fontSize: 12.sp, color: Colors.red.shade700),
                        ),
                      ),
                      TextButton(
                        onPressed: controller.refreshList,
                        child: const Text('重试', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                )),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return Obx(() {
      if (controller.isLoading.value && controller.notices.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.notices.isEmpty && controller.errorMessage.value == null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.notifications_none, size: 64.w, color: AppTheme.gray300),
              SizedBox(height: 16.h),
              Text(
                controller.selectedTabIndex.value == 1 ? '暂无未读消息' : '暂无消息',
                style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary),
              ),
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
                          controller.isLoadingMore.value
                              ? '加载中...'
                              : (controller.hasMore.value ? '上拉加载更多' : '没有更多了'),
                          style: TextStyle(color: AppTheme.textTertiary, fontSize: 13.sp),
                        ),
                      ),
                    ));
              }
              final n = controller.notices[index];
              return _noticeCard(n);
            },
          ),
        ),
      );
    });
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

  Widget _noticeCard(Map<String, dynamic> n) {
    final title = n['title']?.toString() ?? n['subject']?.toString() ?? '消息';
    final summary = n['summary']?.toString() ?? n['content']?.toString() ?? '';
    final publisher = n['publisher']?.toString() ?? n['senderName']?.toString() ?? n['author']?.toString() ?? '';
    final time = _formatTime(n['publishTime'] ?? n['createTime'] ?? n['sendTime']);
    final isRead = controller.isItemRead(n);
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
                if (!isRead)
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                if (!isRead) SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: isRead ? FontWeight.w400 : FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(time, style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary)),
              ],
            ),
            if (summary.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary),
              ),
            ],
            if (publisher.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text('来自: $publisher', style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary)),
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

class NoticeDetailView extends StatelessWidget {
  const NoticeDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    // 用 tag 隔离 detail 的 controller（不与列表共享）
    final c = Get.put(NoticeDetailController(), tag: 'detail');
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(c.args['title']?.toString() ?? '消息详情'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.errorMessage.value != null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 64.w, color: Colors.red.shade300),
                  SizedBox(height: 16.h),
                  Text(c.errorMessage.value ?? '加载失败', textAlign: TextAlign.center),
                  SizedBox(height: 16.h),
                  ElevatedButton(onPressed: c.loadDetail, child: const Text('重试')),
                ],
              ),
            ),
          );
        }
        final n = c.notice.value;
        if (n == null) {
          return const Center(child: Text('加载失败'));
        }
        final title = n['title']?.toString() ?? n['subject']?.toString() ?? '';
        final content = n['content']?.toString() ?? n['body']?.toString() ?? '';
        final publisher = n['publisher']?.toString() ?? n['senderName']?.toString() ?? '系统';
        final time = n['publishTime']?.toString() ?? n['createTime']?.toString() ?? '';
        final attachments = (n['attachments'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '$publisher  ·  ${_formatTime(time)}',
                      style: TextStyle(fontSize: 13.sp, color: AppTheme.textTertiary),
                    ),
                    SizedBox(height: 16.h),
                    Divider(color: AppTheme.dividerColor, height: 1.h),
                    SizedBox(height: 16.h),
                    Text(content, style: TextStyle(fontSize: 15.sp, color: AppTheme.textPrimary, height: 1.6)),
                    if (attachments.isNotEmpty) ...[
                      SizedBox(height: 24.h),
                      Text('附件', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      SizedBox(height: 8.h),
                      ...attachments.map((a) => ListTile(
                            leading: const Icon(Icons.attach_file),
                            title: Text(a['name']?.toString() ?? '附件'),
                            subtitle: Text(a['size']?.toString() ?? ''),
                            onTap: () {
                              Get.snackbar('提示', '附件下载功能待接入', snackPosition: SnackPosition.BOTTOM);
                            },
                          )),
                    ],
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: _ReplyBox(onSubmit: c.submitReply),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _formatTime(String t) {
    if (t.isEmpty) return '';
    try {
      final dt = DateTime.parse(t);
      return DateFormat('yyyy-MM-dd HH:mm').format(dt);
    } catch (_) {
      return t;
    }
  }
}

class _ReplyBox extends StatefulWidget {
  const _ReplyBox({required this.onSubmit});
  final ValueChanged<String> onSubmit;

  @override
  State<_ReplyBox> createState() => _ReplyBoxState();
}

class _ReplyBoxState extends State<_ReplyBox> {
  final TextEditingController _ctrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('回复', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 8.h),
        TextField(
          controller: _ctrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: '输入回复内容',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
            isDense: true,
          ),
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: _submitting
                ? null
                : () async {
                    if (_ctrl.text.trim().isEmpty) return;
                    setState(() => _submitting = true);
                    await widget.onSubmit(_ctrl.text);
                    if (mounted) {
                      setState(() {
                        _ctrl.clear();
                        _submitting = false;
                      });
                    }
                  },
            child: Text(_submitting ? '发送中...' : '发送'),
          ),
        ),
      ],
    );
  }
}
