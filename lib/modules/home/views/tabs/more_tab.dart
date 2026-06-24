import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/themes/app_theme.dart';
import '../../controllers/home_controller.dart';

/// 老 App "更多"页（app.js + app.tpl.html 拼接的 9 宫格）
/// 老 App 实际有：考勤/任务/项目/CRM/通讯录/档案/公司文件/报表/主题/...
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
            _MenuItem(Icons.contacts_outlined, '通讯录', Colors.blue, Routes.CONTACTS),
            _MenuItem(Icons.assignment_outlined, '我的申请', Colors.purple, Routes.MY_APPLICATION),
            _MenuItem(Icons.folder_copy_outlined, '项目管理', Colors.purple, Routes.PROJECT),
            _MenuItem(Icons.task_alt, '任务管理', Colors.teal, Routes.TASK),
            _MenuItem(Icons.forum_outlined, '话题讨论', Colors.cyan, Routes.TOPIC),
            _MenuItem(Icons.archive_outlined, '档案管理', Colors.brown, Routes.ARCHIVE),
            _MenuItem(Icons.folder_shared_outlined, '公司文件', Colors.indigo, Routes.COMPANY_FILE),
            _MenuItem(Icons.notifications_outlined, '消息通知', Colors.deepOrange, Routes.NOTICE),
            _MenuItem(Icons.analytics, '时恒报表', Colors.pink, Routes.SH_REPORT),
            _MenuItem(Icons.insert_chart, '报表中心', Colors.indigo, '/report'),
          ]),
          SizedBox(height: 16.h),
          _buildMenuSection('其他', [
            _MenuItem(Icons.star_outline, '我的收藏', Colors.amber, Routes.FAVORITE),
            _MenuItem(Icons.help_outline, '帮助中心', Colors.blue, Routes.HELP),
            _MenuItem(Icons.business_outlined, '公司信息', Colors.indigo, Routes.COMPANY),
            _MenuItem(Icons.info_outline, '关于版本', Colors.grey, Routes.VERSION),
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
