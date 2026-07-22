import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/data/services/update_service.dart';
import '../../../app/routes/app_pages.dart';
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
            Obx(() => ListTile(
                  leading: Icon(
                    controller.themeMode.value == ThemeMode.dark
                        ? Icons.dark_mode
                        : Icons.dark_mode_outlined,
                    color: AppTheme.primaryColor,
                  ),
                  title: Text('深色模式', style: TextStyle(fontSize: 15.sp)),
                  subtitle: Text(
                    controller.themeMode.value == ThemeMode.dark ? '已开启' : '已关闭',
                    style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
                  ),
                  trailing: Switch(
                    value: controller.themeMode.value == ThemeMode.dark,
                    onChanged: controller.toggleDarkMode,
                    activeColor: AppTheme.primaryColor,
                  ),
                )),
          ]),
          SizedBox(height: 16.h),
          _buildSection('通知'),
          _buildSettingCard([
            ListTile(
              leading: const Icon(Icons.notifications_outlined, color: AppTheme.primaryColor),
              title: Text('消息通知', style: TextStyle(fontSize: 15.sp)),
              subtitle: Text(
                '通过企业微信推送流程审批结果',
                style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
              ),
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
            Obx(() => ListTile(
                  leading: const Icon(Icons.storage_outlined, color: AppTheme.primaryColor),
                  title: Text('清除缓存', style: TextStyle(fontSize: 15.sp)),
                  subtitle: Text(
                    '清空临时文件与图片缓存,登录信息会保留',
                    style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
                  ),
                  trailing: SizedBox(
                    width: 80.w,
                    child: Text(
                      controller.cacheSize.value,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary),
                    ),
                  ),
                  onTap: controller.isClearingCache.value
                      ? null
                      : () => _confirmClearCache(),
                )),
          ]),
          SizedBox(height: 16.h),
          _buildSection('关于'),
          _buildSettingCard([
            ListTile(
              leading: const Icon(Icons.info_outline, color: AppTheme.primaryColor),
              title: Text('版本信息', style: TextStyle(fontSize: 15.sp)),
              subtitle: Text(
                '点击进入查看更新日志',
                style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
              ),
              trailing: Text(
                'v${UpdateService.currentVersion}',
                style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary),
              ),
              onTap: () => Get.toNamed(Routes.VERSION),
            ),
          ]),
        ],
      ),
    );
  }

  void _confirmClearCache() {
    Get.dialog(
      AlertDialog(
        title: const Text('清除缓存'),
        content: const Text('确定要清除所有缓存吗?\n登录信息和深色模式设置会保留。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.clearCache();
            },
            child: const Text('确定'),
          ),
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
        color: AppTheme.surface,
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
