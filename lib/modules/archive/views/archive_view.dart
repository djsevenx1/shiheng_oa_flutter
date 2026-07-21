import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../controllers/archive_controller.dart';

/// 知识文档/档案页面
/// 对应老 App 的 archive 模块（modules/archive/archiveList.tpl.html）
class ArchiveView extends GetView<ArchiveController> {
  const ArchiveView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('知识文档')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return _buildMessageState(
            icon: Icons.error_outline,
            message: controller.errorMessage.value!,
            color: AppTheme.danger,
          );
        }
        if (controller.categories.isEmpty) {
          return _buildMessageState(
            icon: Icons.folder_off_outlined,
            message: controller.infoMessage.value ?? '暂无档案',
            color: AppTheme.gray400,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.loadCategories,
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.categories.length,
            itemBuilder: (context, index) {
              final item = controller.categories[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.folder_outlined, color: AppTheme.primaryColor, size: 22.w),
                  ),
                  title: Text(
                    item['name']?.toString() ?? '(未命名)',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
                  ),
                  subtitle: item['count'] != null
                      ? Text('共 ${item['count']} 项', style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary))
                      : null,
                  trailing: Icon(Icons.chevron_right, color: AppTheme.gray400, size: 20.w),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildMessageState({required IconData icon, required String message, required Color color}) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56.w, color: color),
            SizedBox(height: 16.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary),
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: controller.loadCategories,
              child: const Text('刷新'),
            ),
          ],
        ),
      ),
    );
  }
}
