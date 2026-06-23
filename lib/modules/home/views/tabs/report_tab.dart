import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/themes/app_theme.dart';

class ReportTab extends StatelessWidget {
  const ReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('报表中心'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildReportCategory(
            '库存报表',
            Icons.inventory_2_outlined,
            Colors.blue,
            [
              {'name': '非批号查询', 'route': Routes.STOCK_REPORT},
              {'name': '批号查询', 'route': Routes.STOCK_REPORT},
            ],
          ),
          SizedBox(height: 16.h),
          _buildReportCategory(
            '销售报表',
            Icons.trending_up,
            Colors.green,
            [
              {'name': '销售订单统计', 'route': '/report/sales'},
              {'name': '客户分析', 'route': '/report/customer'},
            ],
          ),
          SizedBox(height: 16.h),
          _buildReportCategory(
            '财务报表',
            Icons.account_balance_wallet_outlined,
            Colors.orange,
            [
              {'name': '应收应付', 'route': '/report/finance'},
              {'name': '成本分析', 'route': '/report/cost'},
            ],
          ),
          SizedBox(height: 16.h),
          _buildReportCategory(
            '生产报表',
            Icons.precision_manufacturing_outlined,
            Colors.purple,
            [
              {'name': '生产进度', 'route': '/report/production'},
              {'name': '质量统计', 'route': '/report/quality'},
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportCategory(String title, IconData icon, Color color, List<Map<String, String>> items) {
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
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(icon, color: color, size: 22.w),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1.h, color: AppTheme.gray200),
          ...items.map((item) => ListTile(
            title: Text(
              item['name']!,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textPrimary,
              ),
            ),
            trailing: Icon(Icons.chevron_right, color: AppTheme.gray400, size: 20.w),
            onTap: () {
              Get.toNamed(item['route']!);
            },
          )),
        ],
      ),
    );
  }
}
