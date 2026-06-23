import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/data/repository/notice_repository.dart';
import '../../../app/themes/app_theme.dart';

class NoticeDetailController extends GetxController {
  final NoticeRepository _repo = NoticeRepository();

  final Map<String, dynamic> args = (Get.arguments as Map?)?.cast<String, dynamic>() ?? {};
  final notice = Rxn<Map<String, dynamic>>();
  final isLoading = false.obs;

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
    } else {
      Get.snackbar('提示', result['message'] ?? '加载失败', snackPosition: SnackPosition.BOTTOM);
    }
  }
}

class NoticeDetailView extends StatelessWidget {
  const NoticeDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(NoticeDetailController());
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Text(c.args['title']?.toString() ?? '通知详情'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final n = c.notice.value;
        if (n == null) {
          return const Center(child: Text('加载失败'));
        }
        final title = n['title']?.toString() ?? '';
        final content = n['content']?.toString() ?? '';
        final publisher = n['publisher']?.toString() ?? n['author']?.toString() ?? '系统';
        final time = n['publishTime']?.toString() ?? n['createTime']?.toString() ?? '';
        final attachments = (n['attachments'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Container(
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
