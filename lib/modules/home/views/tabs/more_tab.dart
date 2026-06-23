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
            _MenuItem(Icons.notifications_outlined, '消息通知', Colors.deepOrange, Routes.NOTICE),
            _MenuItem(Icons.contacts_outlined, '通讯录', Colors.blue, Routes.CONTACTS),
            _MenuItem(Icons.assignment_outlined, '我的申请', Colors.purple, Routes.MY_APPLICATION),
            _MenuItem(Icons.qr_code_scanner, '二维码扫描', Colors.teal, Routes.QR_SCAN, demo: true),
            _MenuItem(Icons.map_outlined, '地图', Colors.green, Routes.MAP),
            _MenuItem(Icons.folder_copy_outlined, '项目管理', Colors.purple, Routes.PROJECT),
            _MenuItem(Icons.task_alt, '任务管理', Colors.teal, Routes.TASK),
            _MenuItem(Icons.forum_outlined, '话题讨论', Colors.cyan, Routes.TOPIC),
            _MenuItem(Icons.archive_outlined, '档案管理', Colors.brown, Routes.ARCHIVE),
            _MenuItem(Icons.folder_shared_outlined, '公司文件', Colors.indigo, Routes.COMPANY_FILE),
            _MenuItem(Icons.analytics, '时恒报表', Colors.pink, Routes.SH_REPORT),
            _MenuItem(Icons.account_balance_wallet, '工资条', Colors.green, Routes.PAYSLIP, demo: true),
            _MenuItem(Icons.menu_book, '知识库', Colors.brown, Routes.KNOWLEDGE, demo: true),
            _MenuItem(Icons.assignment_turned_in, '工作汇报', Colors.deepPurple, Routes.WORK_REPORT, demo: true),
            _MenuItem(Icons.chat_bubble_outline, '即时通讯', Colors.cyan, Routes.CHAT_LIST, demo: true),
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
            title: Row(
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 15.sp,
                    color: AppTheme.textPrimary,
                  ),
                ),
                if (item.demo) ...[
                  SizedBox(width: 6.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade100,
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                    child: Text(
                      '演示',
                      style: TextStyle(fontSize: 10.sp, color: Colors.amber.shade800),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: item.demo
                ? Text(
                    '后端未提供接口',
                    style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary),
                  )
                : null,
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
  final bool demo;

  _MenuItem(this.icon, this.label, this.color, this.route, {this.demo = false});
}
