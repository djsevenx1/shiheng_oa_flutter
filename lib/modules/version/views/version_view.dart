import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/themes/app_theme.dart';

class VersionView extends StatelessWidget {
  const VersionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('关于版本')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            SizedBox(height: 24.h),
            Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(Icons.apps, color: Colors.white, size: 60.w),
            ),
            SizedBox(height: 16.h),
            Text(
              '时恒电子 OA',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
            ),
            SizedBox(height: 4.h),
            Text(
              '版本 v3.0.0',
              style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary),
            ),
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '已是最新版本',
                style: TextStyle(fontSize: 12.sp, color: AppTheme.success),
              ),
            ),
            SizedBox(height: 24.h),
            _buildInfoCard(),
            SizedBox(height: 16.h),
            _buildUpdateLog(),
            SizedBox(height: 24.h),
            Text(
              '© 2024 时恒电子 版权所有',
              style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
            ),
            SizedBox(height: 8.h),
            Text(
              '南京时恒电子科技有限公司',
              style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
        children: [
          _buildInfoRow('技术框架', 'Flutter 3.44'),
          _buildInfoRow('版本', 'v3.0.0 (Build 300)'),
          _buildInfoRow('发布时间', '2024-01-15'),
          _buildInfoRow('MD5', 'a1b2c3d4e5f6g7h8'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: [
          SizedBox(
            width: 80.w,
            child: Text(label, style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13.sp, color: AppTheme.textPrimary, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateLog() {
    return Container(
      padding: EdgeInsets.all(16.w),
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
          Text(
            '更新日志',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          SizedBox(height: 12.h),
          _buildLogItem('v3.0.0', '2024-01-15', [
            '全新 Flutter 重构，UI 全面升级',
            '新增 CRM 商机管理',
            '新增时恒专属报表',
            '修复若干已知问题',
          ]),
          SizedBox(height: 12.h),
          _buildLogItem('v2.0.0', '2023-08-10', [
            '新增任务管理',
            '优化流程审批',
          ]),
        ],
      ),
    );
  }

  Widget _buildLogItem(String version, String date, List<String> changes) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.gray50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(version, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
              SizedBox(width: 8.w),
              Text(date, style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary)),
            ],
          ),
          SizedBox(height: 8.h),
          ...changes.map((c) => Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• ', style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary)),
                Expanded(child: Text(c, style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary))),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
