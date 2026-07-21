import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildSection('外观'),
          _buildSettingCard([
            ListTile(
              leading: const Icon(Icons.dark_mode_outlined, color: AppTheme.primaryColor),
              title: Text('深色模式', style: TextStyle(fontSize: 15.sp)),
              trailing: Obx(() => Switch(
                value: controller.isDarkMode.value,
                onChanged: controller.toggleDarkMode,
                activeColor: AppTheme.primaryColor,
              )),
            ),
          ]),
          SizedBox(height: 16.h),
          _buildSection('通知'),
          _buildSettingCard([
            ListTile(
              leading: const Icon(Icons.notifications_outlined, color: AppTheme.primaryColor),
              title: Text('消息通知', style: TextStyle(fontSize: 15.sp)),
              trailing: Obx(() => Switch(
                value: controller.notificationsEnabled.value,
                onChanged: controller.toggleNotifications,
                activeColor: AppTheme.primaryColor,
              )),
            ),
          ]),
          SizedBox(height: 16.h),
          _buildSection('存储'),
          _buildSettingCard([
            ListTile(
              leading: const Icon(Icons.storage_outlined, color: AppTheme.primaryColor),
              title: Text('清除缓存', style: TextStyle(fontSize: 15.sp)),
              trailing: Obx(() => Text(
                controller.cacheSize.value,
                style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary),
              )),
              onTap: controller.clearCache,
            ),
          ]),
          SizedBox(height: 16.h),
          _buildSection('关于'),
          _buildSettingCard([
            ListTile(
              leading: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
              title: Text('版本信息', style: TextStyle(fontSize: 15.sp)),
              trailing: Text(
                'v2.4.0',
                style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary),
              ),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 8.w, bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
          color: AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingCard(List<Widget> children) {
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
      child: Column(children: children),
    );
  }
}
