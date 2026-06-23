import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/crm_sales_order_controller.dart';

class CrmSalesOrderView extends GetView<CrmSalesOrderController> {
  const CrmSalesOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('销售订单'),
        actions: [
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatusFilter(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.orderList.isEmpty) {
                return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
              }
              return _buildList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(12.w),
      color: Colors.white,
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: '搜索订单号/客户...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.gray400, size: 20),
          filled: true,
          fillColor: AppTheme.gray50,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide.none,
          ),
          isDense: true,
        ),
        onSubmitted: (_) => controller.loadOrders(),
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Obx(() => Row(
          children: controller.statuses.map((status) {
            final isSelected = controller.selectedStatus.value == status;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () => controller.changeStatus(status),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                    border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.gray300),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        )),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: controller.orderList.length,
      itemBuilder: (context, index) => _buildOrderCard(controller.orderList[index]),
    );
  }

  Widget _buildOrderCard(dynamic order) {
    final status = order['status'] ?? '';
    final statusColor = _getStatusColor(status);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
          Row(
            children: [
              Text(
                order['no'] ?? '',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(fontSize: 11.sp, color: statusColor, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            order['client'] ?? '-',
            style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary),
          ),
          SizedBox(height: 4.h),
          Text(
            order['product'] ?? '-',
            style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
          ),
          SizedBox(height: 10.h),
          Divider(height: 1.h, color: AppTheme.gray200),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('金额', style: TextStyle(fontSize: 10.sp, color: AppTheme.textTertiary)),
                    Text(
                      '¥${((order['amount'] ?? 0) as num).toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppTheme.success),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('数量', style: TextStyle(fontSize: 10.sp, color: AppTheme.textTertiary)),
                    Text(
                      '${order['quantity'] ?? 0} pcs',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('交期', style: TextStyle(fontSize: 10.sp, color: AppTheme.textTertiary)),
                    Text(
                      order['delivery'] ?? '-',
                      style: TextStyle(fontSize: 12.sp, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '待审核': return AppTheme.warning;
      case '已确认': return AppTheme.info;
      case '生产中': return AppTheme.primaryColor;
      case '已发货': return Colors.purple;
      case '已完成': return AppTheme.success;
      case '已取消': return AppTheme.gray500;
      default: return AppTheme.primaryColor;
    }
  }
}
