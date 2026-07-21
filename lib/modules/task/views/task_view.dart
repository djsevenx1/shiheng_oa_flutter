import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/task_controller.dart';

class TaskView extends GetView<TaskController> {
  const TaskView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('任务管理'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildStats(),
          _buildTabBar(),
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.taskList.isEmpty) {
                return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
              }
              if (controller.taskList.isEmpty) {
                return _buildEmptyState();
              }
              return _buildTaskList();
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.TASK_CREATE),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStats() {
    return Obx(() => Container(
      padding: EdgeInsets.all(16.w),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem('全部', '${controller.stats['total'] ?? 0}', Icons.list_alt, Colors.white.withOpacity(0.2))),
          SizedBox(width: 12.w),
          Expanded(child: _buildStatItem('未开始', '${controller.stats['todo'] ?? 0}', Icons.pending_actions, Colors.white.withOpacity(0.2))),
          SizedBox(width: 12.w),
          Expanded(child: _buildStatItem('进行中', '${controller.stats['doing'] ?? 0}', Icons.autorenew, Colors.white.withOpacity(0.2))),
          SizedBox(width: 12.w),
          Expanded(child: _buildStatItem('已完成', '${controller.stats['done'] ?? 0}', Icons.check_circle, Colors.white.withOpacity(0.2))),
        ],
      ),
    ));
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color bgColor) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 18.w),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(fontSize: 11.sp, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabIcons = [Icons.list_alt, Icons.pending_actions, Icons.autorenew, Icons.check_circle_outline];
    return Container(
      color: Colors.white,
      child: Obx(() => Row(
        children: controller.tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = controller.selectedTab.value == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.changeTab(index),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                      width: 2.h,
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      tabIcons[index],
                      size: 16.w,
                      color: isSelected ? AppTheme.primaryColor : AppTheme.gray400,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      tab['label']!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                      ),
                    ),
                  ],
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
          hintText: '搜索任务...',
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

  Widget _buildTaskList() {
    return RefreshIndicator(
      onRefresh: () => controller.loadTasks(),
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.taskList.length,
        itemBuilder: (context, index) {
          return _buildTaskCard(controller.taskList[index]);
        },
      ),
    );
  }

  Widget _buildTaskCard(dynamic task) {
    // 老 App 字段：approve(0=审核中 1=已通过 2=未通过) name deadline schedule
    final approve = task['approve'];
    final isApproved = approve == 1;
    final isRejected = approve == 2;
    final schedule = (task['schedule'] as num?)?.toInt() ?? 0;
    final deadline = task['deadline'];
    String deadlineStr = '';
    if (deadline != null) {
      final dt = deadline is int
          ? DateTime.fromMillisecondsSinceEpoch(deadline)
          : DateTime.tryParse(deadline.toString());
      if (dt != null) {
        deadlineStr = '${dt.year}年${dt.month.toString().padLeft(2, '0')}月${dt.day.toString().padLeft(2, '0')}日';
      }
    }
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.TASK_DETAIL, arguments: {'taskId': task['id']}),
      child: Container(
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
                if (isRejected)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text('未通过', style: TextStyle(fontSize: 10.sp, color: AppTheme.danger, fontWeight: FontWeight.w500)),
                  ),
                Expanded(
                  child: Text(
                    task['name'] ?? '(无标题)',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (approve == 0)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text('审核中', style: TextStyle(fontSize: 10.sp, color: AppTheme.warning, fontWeight: FontWeight.w500)),
                  )
                else if (isApproved && schedule > 0)
                  Container(
                    width: 44.w,
                    height: 44.w,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 44.w,
                          height: 44.w,
                          child: CircularProgressIndicator(
                            value: schedule / 100,
                            strokeWidth: 3,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                          ),
                        ),
                        Text('$schedule%', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
                      ],
                    ),
                  ),
              ],
            ),
            if (deadlineStr.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.schedule, size: 14.w, color: AppTheme.textTertiary),
                  SizedBox(width: 4.w),
                  Text(
                    '截至日期：$deadlineStr',
                    style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 64.w, color: AppTheme.gray300),
          SizedBox(height: 16.h),
          Text('暂无任务', style: TextStyle(fontSize: 16.sp, color: AppTheme.textSecondary)),
          SizedBox(height: 8.h),
          Text('点击右下角 + 创建新任务', style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary)),
        ],
      ),
    );
  }
}
