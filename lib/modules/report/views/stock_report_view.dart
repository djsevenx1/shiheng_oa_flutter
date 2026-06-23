import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/stock_report_controller.dart';

class StockReportView extends GetView<StockReportController> {
  const StockReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('库存报表'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(),
          // 统计卡片
          _buildStatsCards(),
          // 数据表格
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.stockList.isEmpty) {
                return _buildLoadingState();
              }
              if (controller.stockList.isEmpty) {
                return _buildEmptyState();
              }
              return _buildDataTable();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: '搜索物料编码/名称/规格...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.gray400),
                filled: true,
                fillColor: AppTheme.gray50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
              ),
              onSubmitted: (value) => controller.search(),
            ),
          ),
          SizedBox(width: 12.w),
          ElevatedButton(
            onPressed: controller.search,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: const Text('查询'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard('总数量', '12,580', Icons.inventory_2, Colors.blue),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard('总金额', '¥2.8M', Icons.account_balance_wallet, Colors.green),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildStatCard('品种数', '1,256', Icons.category, Colors.orange),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.w, color: color),
              SizedBox(width: 4.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataTable() {
    return Container(
      margin: EdgeInsets.all(16.w),
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
          // 表头
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppTheme.gray50,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.r),
                topRight: Radius.circular(12.r),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    '物料编码',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    '物料名称',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '数量',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '金额',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 数据行
          Expanded(
            child: Obx(() => ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: controller.stockList.length,
              separatorBuilder: (context, index) => Divider(
                height: 1.h,
                color: AppTheme.gray200,
                indent: 16.w,
              ),
              itemBuilder: (context, index) {
                final item = controller.stockList[index];
                return _buildDataRow(item, index);
              },
            )),
          ),
          // 分页
          _buildPagination(),
        ],
      ),
    );
  }

  Widget _buildDataRow(dynamic item, int index) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      color: index % 2 == 0 ? Colors.white : AppTheme.gray50.withOpacity(0.5),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              item['code'] ?? 'N/A',
              style: TextStyle(
                fontSize: 13.sp,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? '未知物料',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (item['spec'] != null)
                  Text(
                    item['spec'],
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppTheme.textTertiary,
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '${item['qty'] ?? 0}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '¥${item['amount'] ?? 0}',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.sp,
                color: AppTheme.success,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppTheme.gray50,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(12.r),
          bottomRight: Radius.circular(12.r),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: controller.hasPreviousPage ? controller.previousPage : null,
            color: controller.hasPreviousPage ? AppTheme.primaryColor : AppTheme.gray300,
          ),
          Obx(() => Text(
            '第 ${controller.currentPage.value} 页',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppTheme.textSecondary,
            ),
          )),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: controller.hasNextPage ? controller.nextPage : null,
            color: controller.hasNextPage ? AppTheme.primaryColor : AppTheme.gray300,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppTheme.primaryColor),
          SizedBox(height: 16.h),
          Text(
            '加载中...',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64.w, color: AppTheme.gray300),
          SizedBox(height: 16.h),
          Text(
            '暂无数据',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppTheme.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '请调整搜索条件或筛选条件',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppTheme.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppTheme.gray200),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('取消'),
                  ),
                  Text(
                    '筛选条件',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      controller.applyFilter();
                      Get.back();
                    },
                    child: const Text('确定'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  _buildFilterSection('仓库', [
                    '全部仓库',
                    '原材料仓',
                    '成品仓',
                    '半成品仓',
                  ]),
                  SizedBox(height: 20.h),
                  _buildFilterSection('物料类型', [
                    '全部类型',
                    '电子元件',
                    '结构件',
                    '包装材料',
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: options.map((option) {
            final isSelected = controller.selectedFilters.contains(option);
            return FilterChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                controller.toggleFilter(option);
              },
              selectedColor: AppTheme.primaryColor.withOpacity(0.1),
              checkmarkColor: AppTheme.primaryColor,
              labelStyle: TextStyle(
                fontSize: 13.sp,
                color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
                side: BorderSide(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.gray300,
                ),
              ),
              backgroundColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }
}
