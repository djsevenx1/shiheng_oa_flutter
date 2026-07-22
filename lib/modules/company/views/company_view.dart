import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/themes/app_theme.dart';

class CompanyView extends StatelessWidget {
  const CompanyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              padding: EdgeInsets.all(20.w),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(Icons.business, color: AppTheme.primaryColor, size: 50.w),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      '时恒电子',
                      style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '移动办公平台 v2.7.10',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('公司简介', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  SizedBox(height: 8.h),
                  Text(
                    '专注于电子产品研发、生产、销售为一体的综合性企业。公司主要产品包括电子元件、控制器模块、电源组件等，广泛应用于工业自动化、智能制造等领域。',
                    style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 12.h)),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('联系信息', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                  SizedBox(height: 12.h),
                  _buildInfoRow(Icons.location_on, '公司地址', '江苏省南京市'),
                  _buildInfoRow(Icons.phone, '联系电话', '025-12345678'),
                  _buildInfoRow(Icons.email, '邮箱', 'info@shiheng.com'),
                  _buildInfoRow(Icons.web, '官网', 'www.shiheng.com'),
                  _buildInfoRow(Icons.schedule, '工作时间', '周一至周五 9:00-18:00'),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16.w, color: AppTheme.primaryColor),
          SizedBox(width: 8.w),
          SizedBox(
            width: 70.w,
            child: Text(label, style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 13.sp, color: AppTheme.textPrimary)),
          ),
        ],
      ),
    );
  }
}
