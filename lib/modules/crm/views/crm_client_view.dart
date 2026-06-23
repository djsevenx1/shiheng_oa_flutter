import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/crm_client_controller.dart';

class CrmClientView extends GetView<CrmClientController> {
  const CrmClientView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('客户管理'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined),
            onPressed: () => _showFilterSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterTabs(),
          _buildStatsBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.clientList.isEmpty) {
                return _buildLoadingState();
              }
              if (controller.clientList.isEmpty) {
                return _buildEmptyState();
              }
              return _buildClientList();
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
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: '搜索客户名称/联系人/电话...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.gray400),
          suffixIcon: controller.searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.gray400),
                  onPressed: () {
                    controller.searchController.clear();
                    controller.search();
                  },
                )
              : null,
          filled: true,
          fillColor: AppTheme.gray50,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (_) => controller.search(),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Obx(() => Row(
          children: controller.filters.map((filter) {
            final isSelected = controller.selectedFilter.value == filter;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () => controller.changeFilter(filter),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.gray300,
                    ),
                  ),
                  child: Text(
                    filter,
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
      ),
    );
  }

  Widget _buildStatsBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      color: Colors.white,
      child: Obx(() => Row(
        children: [
          _buildStatItem('总客户数', controller.totalCount.value.toString(), AppTheme.primaryColor),
          Container(width: 1, height: 30.h, color: AppTheme.gray200),
          _buildStatItem('总金额', '¥${(controller.clientList.fold<double>(0.0, (sum, c) => sum + ((c['amount'] ?? 0) as num).toDouble()) / 10000).toStringAsFixed(1)}万', AppTheme.success),
        ],
      )),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: controller.clientList.length,
      itemBuilder: (context, index) {
        final client = controller.clientList[index];
        return _buildClientCard(client);
      },
    );
  }

  Widget _buildClientCard(dynamic client) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.CRM_CLIENT_DETAIL, arguments: {'clientId': client['id']}),
      child: Container(
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
                    color: _getLevelColor(client['level']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(
                      client['level'] ?? 'B',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: _getLevelColor(client['level']),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client['name'] ?? '未知客户',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${client['industry'] ?? ''} · ${client['type'] ?? ''}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '¥${((client['amount'] ?? 0) as num).toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.success,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: _getTypeColor(client['type']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        client['type'] ?? '',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: _getTypeColor(client['type']),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(height: 1.h, color: AppTheme.gray200),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14.w, color: AppTheme.textTertiary),
                SizedBox(width: 4.w),
                Text(
                  client['contact'] ?? '-',
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
                ),
                SizedBox(width: 16.w),
                Icon(Icons.phone_outlined, size: 14.w, color: AppTheme.textTertiary),
                SizedBox(width: 4.w),
                Text(
                  client['phone'] ?? '-',
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.access_time, size: 14.w, color: AppTheme.textTertiary),
                SizedBox(width: 4.w),
                Text(
                  '最近联系: ${client['lastContact'] ?? '-'}',
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor(String? level) {
    switch (level) {
      case 'A': return AppTheme.danger;
      case 'B': return AppTheme.warning;
      case 'C': return AppTheme.info;
      default: return AppTheme.gray400;
    }
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case '重点客户': return AppTheme.danger;
      case '潜在客户': return AppTheme.warning;
      case '已成交': return AppTheme.success;
      case '已流失': return AppTheme.gray500;
      default: return AppTheme.primaryColor;
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(color: AppTheme.primaryColor),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64.w, color: AppTheme.gray300),
          SizedBox(height: 16.h),
          Text(
            '暂无客户',
            style: TextStyle(fontSize: 16.sp, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '高级筛选',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 16.h),
            // TODO: 添加更多筛选条件
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}
