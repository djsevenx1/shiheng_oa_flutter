import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/work_report_controller.dart';

class WorkReportView extends GetView<WorkReportController> {
  const WorkReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('工作汇报'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48.h),
          child: Container(
            color: Colors.white,
            child: Obx(() => Row(
                  children: [
                    _tab(0, '我发起的'),
                    _tab(1, '我收到的'),
                  ],
                )),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.WORK_REPORT_SUBMIT),
        icon: const Icon(Icons.edit),
        label: const Text('写汇报'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.amber.shade50,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16.w, color: Colors.amber.shade800),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    '演示模块：老 OA 未提供工作汇报接口，显示示例数据。',
                    style: TextStyle(fontSize: 12.sp, color: Colors.amber.shade800),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = controller.selectedTab.value == 0 ? controller.myReports : controller.receivedReports;
              if (list.isEmpty) {
                return Center(
                  child: Text('暂无汇报', style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary)),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.loadList,
                child: ListView.separated(
                  padding: EdgeInsets.all(16.w),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final r = list[index];
                    return _buildCard(r);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _tab(int i, String label) {
    return Obx(() {
      final selected = controller.selectedTab.value == i;
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
              child: Text(label,
                  style: TextStyle(
                    color: selected ? AppTheme.primaryColor : AppTheme.textSecondary,
                    fontSize: 15.sp,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  )),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildCard(Map<String, dynamic> r) {
    final title = r['title']?.toString() ?? '无标题';
    final time = controller.formatDate(r['createTime'] ?? r['submitTime']);
    final type = r['type']?.toString() ?? 'daily';
    final typeLabel = {'daily': '日报', 'weekly': '周报', 'monthly': '月报'}[type] ?? '汇报';
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
                child: Text(typeLabel, style: TextStyle(fontSize: 11.sp, color: AppTheme.primaryColor)),
              ),
              const Spacer(),
              Text(time, style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary)),
            ],
          ),
          SizedBox(height: 8.h),
          Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
