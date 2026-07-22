import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/sh_report_controller.dart';

class ShReportView extends GetView<ShReportController> {
  const ShReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('专属报表'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => controller.loadData()),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.summary.isEmpty) {
          return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPeriodSelector(),
              SizedBox(height: 16.h),
              _buildSummaryCards(),
              SizedBox(height: 16.h),
              _buildSalesChart(),
              SizedBox(height: 16.h),
              _buildTopProducts(),
              SizedBox(height: 16.h),
              _buildProductionTable(),
              SizedBox(height: 24.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPeriodSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() => Row(
        children: controller.periods.map((period) {
          final isSelected = controller.selectedPeriod.value == period;
          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: GestureDetector(
              onTap: () => controller.selectedPeriod.value = period,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                  border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.gray300),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  period,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isSelected ? Colors.white : AppTheme.textSecondary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }

  Widget _buildSummaryCards() {
    return Obx(() {
      final s = controller.summary;
      return Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildKPI('营收', s['revenue'] ?? 0, '万', '¥', s['revenueChange'] ?? 0, AppTheme.success)),
              SizedBox(width: 12.w),
              Expanded(child: _buildKPI('订单数', s['orderCount'] ?? 0, '单', '', s['orderChange'] ?? 0, AppTheme.primaryColor)),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: _buildKPI('客户数', s['customerCount'] ?? 0, '位', '', s['customerChange'] ?? 0, AppTheme.warning)),
              SizedBox(width: 12.w),
              Expanded(child: _buildKPI('生产数', s['productionCount'] ?? 0, '件', '', s['productionChange'] ?? 0, Colors.purple)),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildKPI(String label, num value, String unit, String prefix, num change, Color color) {
    final isPositive = change >= 0;
    return Container(
      padding: EdgeInsets.all(14.w),
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
            label,
            style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
          ),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (prefix.isNotEmpty)
                Text(
                  prefix,
                  style: TextStyle(fontSize: 14.sp, color: color, fontWeight: FontWeight.w600),
                ),
              Text(
                value.toString(),
                style: TextStyle(fontSize: 22.sp, color: color, fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 2.w),
              Text(
                unit,
                style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary),
              ),
            ],
          ),
          SizedBox(height: 6.h),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 12.w,
                color: isPositive ? AppTheme.success : AppTheme.danger,
              ),
              SizedBox(width: 2.w),
              Text(
                '${change.abs()}%',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isPositive ? AppTheme.success : AppTheme.danger,
                ),
              ),
              SizedBox(width: 4.w),
              Text(
                '同比',
                style: TextStyle(fontSize: 10.sp, color: AppTheme.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSalesChart() {
    return Container(
      padding: EdgeInsets.all(14.w),
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
            '销售趋势',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 160.h,
            child: Obx(() => _buildBarChart(controller.salesByMonth)),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(List<dynamic> data) {
    if (data.isEmpty) return SizedBox.shrink();
    final maxValue = data.map((d) => (d['amount'] as num).toDouble()).reduce((a, b) => a > b ? a : b);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((item) {
        final amount = (item['amount'] as num).toDouble();
        final height = (amount / maxValue * 120).h;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '$amount',
              style: TextStyle(fontSize: 10.sp, color: AppTheme.textSecondary),
            ),
            SizedBox(height: 4.h),
            Container(
              width: 24.w,
              height: height,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              item['month'] ?? '',
              style: TextStyle(fontSize: 10.sp, color: AppTheme.textTertiary),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildTopProducts() {
    return Container(
      padding: EdgeInsets.all(14.w),
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
            '产品销售排行',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          SizedBox(height: 12.h),
          Obx(() => Column(
            children: controller.topProducts.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 6.h),
                child: Row(
                  children: [
                    Container(
                      width: 22.w,
                      height: 22.w,
                      decoration: BoxDecoration(
                        color: _getRankColor(index),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['name'] ?? '',
                            style: TextStyle(fontSize: 13.sp, color: AppTheme.textPrimary),
                          ),
                          SizedBox(height: 4.h),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(2.r),
                            child: LinearProgressIndicator(
                              value: (item['percent'] as num) / 100,
                              backgroundColor: AppTheme.gray200,
                              valueColor: AlwaysStoppedAnimation<Color>(_getRankColor(index)),
                              minHeight: 4.h,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '${item['amount']}万',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppTheme.success),
                    ),
                  ],
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildProductionTable() {
    return Container(
      padding: EdgeInsets.all(14.w),
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
            '生产完成率',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          SizedBox(height: 12.h),
          Obx(() => Column(
            children: controller.productionList.map((item) {
              final rate = (item['rate'] as num).toDouble();
              final color = rate >= 100 ? AppTheme.success : rate >= 95 ? AppTheme.primaryColor : AppTheme.warning;
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['product'] ?? '',
                            style: TextStyle(fontSize: 13.sp, color: AppTheme.textPrimary),
                          ),
                        ),
                        Text(
                          '${item['actual']}/${item['plan']}',
                          style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '${rate.toInt()}%',
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: color),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2.r),
                      child: LinearProgressIndicator(
                        value: (rate / 100).clamp(0, 1.0),
                        backgroundColor: AppTheme.gray200,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                        minHeight: 4.h,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0: return AppTheme.danger;
      case 1: return AppTheme.warning;
      case 2: return AppTheme.primaryColor;
      default: return AppTheme.gray500;
    }
  }
}
