import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../app/themes/app_theme.dart';

class HelpView extends StatelessWidget {
  const HelpView({super.key});
  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': '如何发起一个流程？',
        'a': '在「流程审批」页面点击右下角"发起流程"按钮，选择相应的流程类型，填写表单后选择审批人即可提交。',
      },
      {
        'q': '如何查看历史考勤？',
        'a': '在「考勤签到」页面，可以通过左右箭头切换月份，查看该月的所有打卡记录。',
      },
      {
        'q': '忘记密码怎么办？',
        'a': '请联系系统管理员重置密码，或在登录页面点击"忘记密码"通过手机验证码找回。',
      },
      {
        'q': '如何导出报表数据？',
        'a': '在报表页面点击右上角的导出按钮（下载图标），选择导出格式即可。',
      },
      {
        'q': '客户信息如何修改？',
        'a': '在「CRM → 客户」列表中点击客户进入详情页，点击右上角编辑按钮即可修改。',
      },
      {
        'q': '消息推送如何设置？',
        'a': '在「设置 → 通知设置」中可以选择接收哪些类型的消息推送。',
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('帮助中心')),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildContactCard(),
          SizedBox(height: 16.h),
          Text(
            '常见问题',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          SizedBox(height: 8.h),
          ...faqs.map((faq) => _buildFAQItem(faq['q']!, faq['a']!)),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Icon(Icons.support_agent, color: Colors.white, size: 40.w),
          SizedBox(height: 8.h),
          Text(
            '需要帮助？',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          SizedBox(height: 4.h),
          Text(
            '工作时间: 周一至周五 9:00-18:00',
            style: TextStyle(fontSize: 12.sp, color: Colors.white70),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('电话咨询'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.chat, size: 16),
                  label: const Text('在线客服'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(String q, String a) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 6,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            q,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
          ),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Text(
                a,
                style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
