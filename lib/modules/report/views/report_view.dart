import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/report_controller.dart';

class ReportView extends GetView<ReportController> {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('报表中心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadReports(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.mods.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.insert_chart_outlined, size: 64.w, color: AppTheme.gray300),
                SizedBox(height: 16.h),
                Text('暂无报表', style: TextStyle(fontSize: 14.sp, color: AppTheme.textTertiary)),
              ],
            ),
          );
        }
        // 按 cats 分组显示
        final cats = controller.categories;
        return RefreshIndicator(
          onRefresh: controller.loadReports,
          child: ListView.builder(
            padding: EdgeInsets.symmetric(vertical: 8.h),
            itemCount: cats.isNotEmpty ? cats.length : 1,
            itemBuilder: (_, i) {
              if (cats.isNotEmpty) {
                final cat = cats[i];
                final catId = cat['id']?.toString() ?? '';
                final catName = cat['name']?.toString() ?? '未分类';
                final catMods = controller.mods
                    .where((m) => m['catId']?.toString() == catId || m['categoryId']?.toString() == catId)
                    .toList();
                if (catMods.isEmpty) return const SizedBox.shrink();
                return _catSection(catName, catMods);
              }
              return _catSection('全部报表', controller.mods);
            },
          ),
        );
      }),
    );
  }

  Widget _catSection(String title, List<Map<String, dynamic>> mods) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Text(
            title,
            style: TextStyle(fontSize: 13.sp, color: AppTheme.textTertiary, fontWeight: FontWeight.w500),
          ),
        ),
        ...mods.map((m) => ListTile(
              leading: Icon(Icons.bar_chart, color: AppTheme.primaryColor, size: 20.w),
              title: Text(m['name']?.toString() ?? m['moduleName']?.toString() ?? '(无标题)',
                style: TextStyle(fontSize: 14.sp)),
              trailing: Icon(Icons.chevron_right, color: AppTheme.gray400),
              onTap: () {
                // TODO: 跳转报表详情
                Get.snackbar('提示', '报表功能开发中: ${m['name'] ?? m['id']}');
              },
            )),
        Divider(height: 8.h),
      ],
    );
  }
}
