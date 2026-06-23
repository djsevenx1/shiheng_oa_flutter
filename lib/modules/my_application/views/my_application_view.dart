import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../controllers/my_application_controller.dart';

class MyApplicationView extends GetView<MyApplicationController> {
  const MyApplicationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('我的申请'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.h),
          child: Container(
            color: Colors.white,
            child: Obx(() => Row(
                  children: List.generate(3, (i) {
                    final selected = controller.selectedTabIndex.value == i;
                    final label = MyApplicationController.statusLabels[i];
                    return Expanded(
                      child: InkWell(
                        onTap: () => controller.switchTab(i),
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
                                fontSize: 14.sp,
                                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                )),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.applications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.applications.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.assignment, size: 64.w, color: AppTheme.gray300),
                SizedBox(height: 16.h),
                Text('暂无申请', style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary)),
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
              itemCount: controller.applications.length + 1,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                if (index == controller.applications.length) {
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
                final app = controller.applications[index];
                final id = app['id']?.toString() ?? '';
                return _buildAppCard(app, id);
              },
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAppCard(Map<String, dynamic> app, String id) {
    final type = app['type']?.toString() ?? '流程';
    final title = app['title']?.toString() ?? '';
    final status = app['status']?.toString() ?? '';
    final time = controller.formatTime(app['createTime']);
    final isRunning = controller.currentStatus == 'running';
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
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
              Text(status, style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary)),
              const Spacer(),
              Text(time, style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary)),
            ],
          ),
          SizedBox(height: 8.h),
          Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
          SizedBox(height: 8.h),
          if (isRunning) ...[
            Row(
              children: [
                TextButton.icon(
                  onPressed: () => controller.urge(id),
                  icon: const Icon(Icons.notifications_active, size: 16),
                  label: const Text('催办'),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => controller.cancel(id),
                  icon: const Icon(Icons.close, size: 16, color: Colors.red),
                  label: const Text('撤销', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
