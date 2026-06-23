import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/home_controller.dart';
import 'tabs/dashboard_tab.dart';
import 'tabs/workflow_tab.dart';
import 'tabs/report_tab.dart';
import 'tabs/more_tab.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          DashboardTab(),
          WorkflowTab(),
          ReportTab(),
          MoreTab(),
        ],
      ),
      bottomNavigationBar: Obx(() => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(Icons.home_rounded, '首页', 0),
                _buildNavItem(Icons.assignment_rounded, '流程', 1),
                _buildNavItem(Icons.insert_chart_rounded, '报表', 2),
                _buildNavItem(Icons.apps_rounded, '更多', 3),
              ],
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = controller.currentIndex.value == index;
    return GestureDetector(
      onTap: () => controller.changePage(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24.w,
              color: isSelected ? AppTheme.primaryColor : AppTheme.gray400,
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppTheme.primaryColor : AppTheme.gray400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
