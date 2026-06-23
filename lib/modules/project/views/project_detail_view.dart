import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/project_detail_controller.dart';

class ProjectDetailView extends GetView<ProjectDetailController> {
  const ProjectDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value && controller.project.isEmpty) {
          return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        return CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverToBoxAdapter(child: SizedBox(height: 16.h)),
            _buildInfoCard(),
            SliverToBoxAdapter(child: SizedBox(height: 16.h)),
            _buildDescription(),
            SliverToBoxAdapter(child: SizedBox(height: 16.h)),
            _buildMembers(),
            SliverToBoxAdapter(child: SizedBox(height: 16.h)),
            _buildTabBar(),
            SliverToBoxAdapter(child: SizedBox(height: 12.h)),
            _buildTabContent(),
            SliverToBoxAdapter(child: SizedBox(height: 32.h)),
          ],
        );
      }),
    );
  }

  Widget _buildHeader() {
    final project = controller.project;
    final status = project['status'] ?? '进行中';
    final statusColor = _getStatusColor(status);
    final progress = project['progress'] ?? 0;
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [statusColor, statusColor.withOpacity(0.7)],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_horiz, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  project['name'] ?? '项目名称',
                  style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 4.h),
                Text(
                  project['no'] ?? '',
                  style: TextStyle(fontSize: 12.sp, color: Colors.white70),
                ),
                SizedBox(height: 20.h),
                _buildProgress(progress, statusColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgress(int progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '项目进度',
              style: TextStyle(fontSize: 13.sp, color: Colors.white70),
            ),
            Text(
              '$progress%',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8.h,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    final project = controller.project;
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
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
            _buildInfoRow('负责人', project['manager'] ?? '-', Icons.person),
            _buildInfoRow('项目预算', '¥${((project['budget'] ?? 0) as num).toStringAsFixed(0)}', Icons.account_balance_wallet),
            _buildInfoRow('开始日期', project['startDate'] ?? '-', Icons.calendar_today),
            _buildInfoRow('结束日期', project['endDate'] ?? '-', Icons.event),
            _buildInfoRow('客户名称', project['customer'] ?? '-', Icons.business),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        children: [
          Icon(icon, size: 16.w, color: AppTheme.gray400),
          SizedBox(width: 8.w),
          SizedBox(
            width: 70.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13.sp, color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    final desc = controller.project['description'] ?? '';
    if (desc.isEmpty) return SliverToBoxAdapter(child: SizedBox.shrink());
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
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
              '项目描述',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            SizedBox(height: 8.h),
            Text(
              desc,
              style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembers() {
    final members = (controller.project['members'] ?? '').toString().split(',');
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
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
              '项目成员',
              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            SizedBox(height: 12.h),
            Wrap(
              spacing: 12.w,
              runSpacing: 12.h,
              children: members.map((name) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12.w,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          name.trim().isNotEmpty ? name.trim()[0] : '?',
                          style: TextStyle(fontSize: 11.sp, color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        name.trim(),
                        style: TextStyle(fontSize: 13.sp, color: AppTheme.textPrimary),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
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
        child: Obx(() => Row(
          children: ['合同', '文件'].asMap().entries.map((entry) {
            final index = entry.key;
            final label = entry.value;
            final isActive = controller.activeTab.value == index;
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.changeTab(index),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: isActive ? AppTheme.primaryColor : Colors.transparent,
                        width: 2.h,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                        color: isActive ? AppTheme.primaryColor : AppTheme.textSecondary,
                      ),
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

  Widget _buildTabContent() {
    return SliverToBoxAdapter(
      child: Obx(() {
        if (controller.activeTab.value == 0) {
          return _buildContractsList();
        } else {
          return _buildFilesList();
        }
      }),
    );
  }

  Widget _buildContractsList() {
    if (controller.contracts.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(child: Text('暂无合同', style: TextStyle(fontSize: 14.sp, color: AppTheme.textTertiary))),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: controller.contracts.map((item) {
          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(14.w),
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
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: AppTheme.info.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(Icons.description, color: AppTheme.info, size: 20.w),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? '',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        item['no'] ?? '',
                        style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '¥${((item['amount'] ?? 0) as num).toStringAsFixed(0)}',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppTheme.success),
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: Text(
                        item['status'] ?? '',
                        style: TextStyle(fontSize: 10.sp, color: AppTheme.success),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFilesList() {
    if (controller.files.isEmpty) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Center(child: Text('暂无文件', style: TextStyle(fontSize: 14.sp, color: AppTheme.textTertiary))),
      );
    }
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        children: controller.files.map((item) {
          return Container(
            margin: EdgeInsets.only(bottom: 8.h),
            padding: EdgeInsets.all(14.w),
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
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: _getFileColor(item['type']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    _getFileIcon(item['type']),
                    color: _getFileColor(item['type']),
                    size: 20.w,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'] ?? '',
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${item['size']} · ${item['date']}',
                        style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download_outlined),
                  onPressed: () {},
                  color: AppTheme.primaryColor,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '进行中': return AppTheme.primaryColor;
      case '已完成': return AppTheme.success;
      case '未开始': return AppTheme.gray500;
      case '已暂停': return AppTheme.warning;
      default: return AppTheme.gray400;
    }
  }

  IconData _getFileIcon(String? type) {
    switch (type) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc': return Icons.article;
      case 'xls': return Icons.table_chart;
      case 'fig': return Icons.brush;
      default: return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String? type) {
    switch (type) {
      case 'pdf': return AppTheme.danger;
      case 'doc': return AppTheme.info;
      case 'xls': return AppTheme.success;
      case 'fig': return AppTheme.warning;
      default: return AppTheme.gray500;
    }
  }
}
