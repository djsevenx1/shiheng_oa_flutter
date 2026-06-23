import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/project_controller.dart';

class ProjectView extends GetView<ProjectController> {
  const ProjectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('项目管理'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.projectList.isEmpty) {
                return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
              }
              if (controller.projectList.isEmpty) {
                return _buildEmptyState();
              }
              return _buildProjectList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Obx(() => Row(
        children: controller.tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = controller.selectedTab.value == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.changeTab(index),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                      width: 2.h,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(12.w),
      color: Colors.white,
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: '搜索项目名称/编号...',
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
        onSubmitted: (_) => controller.search(),
      ),
    );
  }

  Widget _buildProjectList() {
    return RefreshIndicator(
      onRefresh: () => controller.loadProjects(),
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.projectList.length,
        itemBuilder: (context, index) {
          final project = controller.projectList[index];
          return _buildProjectCard(project);
        },
      ),
    );
  }

  Widget _buildProjectCard(dynamic project) {
    final status = project['status'] ?? '进行中';
    final statusColor = _getStatusColor(status);
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.PROJECT_DETAIL, arguments: {'projectId': project['id']}),
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
                SizedBox(width: 8.w),
                Text(
                  project['no'] ?? '',
                  style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary),
                ),
                const Spacer(),
                Text(
                  '¥${((project['budget'] ?? 0) as num).toStringAsFixed(0)}',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppTheme.success),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              project['name'] ?? '项目名称',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 12.h),
            _buildProgressBar(project['progress'] ?? 0, statusColor),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14.w, color: AppTheme.textTertiary),
                SizedBox(width: 4.w),
                Text(
                  '负责人: ${project['manager'] ?? '-'}',
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 12.w, color: AppTheme.textTertiary),
                SizedBox(width: 4.w),
                Text(
                  '${project['startDate'] ?? '-'} 至 ${project['endDate'] ?? '-'}',
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
                ),
                const Spacer(),
                Icon(Icons.group, size: 14.w, color: AppTheme.textTertiary),
                SizedBox(width: 4.w),
                Text(
                  '${(project['members'] ?? '').toString().split(',').length} 人',
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(int progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '进度',
              style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary),
            ),
            SizedBox(width: 4.w),
            Text(
              '$progress%',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: color),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: AppTheme.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6.h,
          ),
        ),
      ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_open, size: 64.w, color: AppTheme.gray300),
          SizedBox(height: 16.h),
          Text('暂无项目', style: TextStyle(fontSize: 16.sp, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}
