import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/themes/app_theme.dart';
import '../../controllers/home_controller.dart';

class MoreTab extends GetView<HomeController> {
  const MoreTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('更多'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildMenuSection('业务模块', [
            _MenuItem(Icons.people_outline, 'CRM', Colors.blue, Routes.CRM),
            _MenuItem(Icons.location_on_outlined, '考勤签到', Colors.orange, Routes.ATTENDANCE),
            _MenuItem(Icons.map_outlined, '地图', Colors.green, Routes.MAP),
            _MenuItem(Icons.folder_copy_outlined, '项目管理', Colors.purple, Routes.PROJECT),
          ]),
          SizedBox(height: 16.h),
          _buildMenuSection('系统', [
            _MenuItem(Icons.settings_outlined, '设置', Colors.grey, '/settings'),
            _MenuItem(Icons.help_outline, '帮助', Colors.teal, '/help'),
            _MenuItem(Icons.info_outline, '关于', Colors.indigo, '/about'),
          ]),
          SizedBox(height: 32.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: ElevatedButton.icon(
              onPressed: controller.logout,
              icon: const Icon(Icons.logout),
              label: const Text('退出登录'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger.withOpacity(0.1),
                foregroundColor: AppTheme.danger,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection(String title, List<_MenuItem> items) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          Divider(height: 1.h, color: AppTheme.gray200, indent: 16.w),
          ...items.map((item) => ListTile(
            leading: Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(item.icon, color: item.color, size: 20.w),
            ),
            title: Text(
              item.label,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppTheme.textPrimary,
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: AppTheme.gray400, size: 20.w),
            onTap: () {
              if (item.route != null) {
                Get.toNamed(item.route!);
              }
            },
          )),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final String? route;

  _MenuItem(this.icon, this.label, this.color, this.route);
}
