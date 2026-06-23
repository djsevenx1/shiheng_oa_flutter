import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/crm_channel_controller.dart';

class CrmChannelView extends GetView<CrmChannelController> {
  const CrmChannelView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('销售渠道'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.channelList.isEmpty) {
          return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.channelList.length,
          itemBuilder: (context, index) => _buildChannelCard(controller.channelList[index]),
        );
      }),
    );
  }

  Widget _buildChannelCard(dynamic channel) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.location_city, color: AppTheme.primaryColor, size: 22.w),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      channel['name'] ?? '-',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '负责人: ${channel['manager'] ?? '-'}',
                      style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                '¥${((channel['amount'] ?? 0) as num).toStringAsFixed(0)}',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppTheme.success),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildMetric('线索数', '${channel['leads'] ?? 0}', Icons.lightbulb, AppTheme.warning),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildMetric('成交数', '${channel['deals'] ?? 0}', Icons.handshake, AppTheme.success),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildMetric('成交率', channel['rate'] ?? '0%', Icons.trending_up, AppTheme.primaryColor),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(String label, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16.w, color: color),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: color),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }
}
