import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../controllers/payslip_controller.dart';

class PayslipView extends GetView<PayslipController> {
  const PayslipView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('工资条'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.amber.shade50,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16.w, color: Colors.amber.shade800),
                SizedBox(width: 6.w),
                Expanded(
                  child: Text(
                    '演示模块：老 OA 未提供工资条接口，显示示例数据。',
                    style: TextStyle(fontSize: 12.sp, color: Colors.amber.shade800),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            child: SizedBox(
              height: 40.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                itemBuilder: (context, index) {
                  final year = currentYear - index;
                  return Obx(() {
                    final selected = controller.selectedYear.value == year;
                    return GestureDetector(
                      onTap: () => controller.setYear(year),
                      child: Container(
                        margin: EdgeInsets.only(right: 8.w),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primaryColor : AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Center(
                          child: Text(
                            '$year 年',
                            style: TextStyle(
                              color: selected ? Colors.white : AppTheme.textSecondary,
                              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.payslips.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.account_balance_wallet, size: 64.w, color: AppTheme.gray300),
                      SizedBox(height: 16.h),
                      Text('暂无工资条', style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary)),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.all(16.w),
                itemCount: controller.payslips.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final p = controller.payslips[index];
                  return _buildCard(p);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, dynamic> p) {
    final month = p['month']?.toString() ?? '';
    final base = p['baseSalary'] ?? 0;
    final bonus = p['bonus'] ?? 0;
    final tax = p['tax'] ?? 0;
    final net = p['netSalary'] ?? 0;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('${controller.selectedYear.value}年$month月',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('实发: ¥${controller.formatMoney(net)}',
                  style: TextStyle(fontSize: 15.sp, color: AppTheme.primaryColor, fontWeight: FontWeight.w600)),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: AppTheme.dividerColor, height: 1.h),
          SizedBox(height: 12.h),
          _row('基本工资', controller.formatMoney(base)),
          _row('绩效奖金', controller.formatMoney(bonus)),
          _row('个税', '-${controller.formatMoney(tax)}', isNegative: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool isNegative = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Text(label, style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                fontSize: 13.sp,
                color: isNegative ? Colors.red : AppTheme.textPrimary,
              )),
        ],
      ),
    );
  }
}
