import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/attendance_controller.dart';

class AttendanceView extends GetView<AttendanceController> {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value && controller.todayStatus.isEmpty) {
          return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        return CustomScrollView(
          slivers: [
            _buildHeader(),
            SliverToBoxAdapter(child: SizedBox(height: 16.h)),
            _buildStatsCard(),
            SliverToBoxAdapter(child: SizedBox(height: 16.h)),
            _buildMonthSelector(),
            SliverToBoxAdapter(child: SizedBox(height: 8.h)),
            _buildListHeader(),
            _buildAttendanceList(),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          ],
        );
      }),
    );
  }

  Widget _buildHeader() {
    return SliverToBoxAdapter(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryColor, AppTheme.primaryDark],
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '考勤签到',
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.history, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
                _buildTimeDisplay(),
                SizedBox(height: 24.h),
                Row(
                  children: [
                    Expanded(child: _buildCheckButton(
                      label: '签到',
                      icon: Icons.login,
                      color: AppTheme.success,
                      enabled: !controller.hasCheckedIn.value,
                      onPressed: controller.checkIn,
                    )),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildCheckButton(
                      label: '签退',
                      icon: Icons.logout,
                      color: AppTheme.warning,
                      enabled: !controller.hasCheckedOut.value,
                      onPressed: controller.checkOut,
                    )),
                  ],
                ),
                SizedBox(height: 16.h),
                _buildLocationInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTimeDisplay() {
    return Obx(() {
      final now = DateTime.now();
      return Center(
        child: Column(
          children: [
            Text(
              '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 48.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '${now.year}年${now.month}月${now.day}日',
              style: TextStyle(fontSize: 14.sp, color: Colors.white70),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCheckButton({
    required String label,
    required IconData icon,
    required Color color,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Obx(() {
      final isDisabled = !enabled;
      return ElevatedButton.icon(
        onPressed: isDisabled ? null : onPressed,
        icon: Icon(icon, size: 20.w),
        label: Text(
          isDisabled ? '已$label' : label,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: isDisabled ? Colors.white.withOpacity(0.3) : Colors.white,
          foregroundColor: isDisabled ? Colors.white : color,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          elevation: 0,
        ),
      );
    });
  }

  Widget _buildLocationInfo() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.white, size: 18.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '福建省厦门市思明区软件园二期',
              style: TextStyle(fontSize: 13.sp, color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
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
        child: Obx(() {
          final stats = controller.monthStats;
          return Row(
            children: [
              _buildStatItem('应到', '${stats['workDays'] ?? 0}', '天', AppTheme.primaryColor),
              _buildDivider(),
              _buildStatItem('实到', '${stats['actualDays'] ?? 0}', '天', AppTheme.success),
              _buildDivider(),
              _buildStatItem('迟到', '${stats['lateCount'] ?? 0}', '次', AppTheme.warning),
              _buildDivider(),
              _buildStatItem('请假', '${stats['leaveCount'] ?? 0}', '次', AppTheme.info),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: color),
                ),
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 30.h, color: AppTheme.gray200);
  }

  Widget _buildMonthSelector() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left),
              onPressed: () {
                if (controller.selectedMonth.value > 1) {
                  controller.changeMonth(controller.selectedMonth.value - 1);
                }
              },
            ),
            Expanded(
              child: Center(
                child: Obx(() => Text(
                  '${DateTime.now().year}年${controller.selectedMonth.value}月',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                )),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                if (controller.selectedMonth.value < 12) {
                  controller.changeMonth(controller.selectedMonth.value + 1);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
        child: Text(
          '打卡记录',
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    return Obx(() => SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final item = controller.attendanceList[index];
          return _buildAttendanceItem(item);
        },
        childCount: controller.attendanceList.length,
      ),
    ));
  }

  Widget _buildAttendanceItem(dynamic item) {
    final status = item['status'] ?? '正常';
    final statusColor = controller.getStatusColor(status);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item['date']?.split('-').last ?? '',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                item['weekday'] ?? '',
                style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary),
              ),
            ],
          ),
          SizedBox(width: 16.w),
          Container(width: 1, height: 36.h, color: AppTheme.gray200),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.login, size: 14.w, color: AppTheme.success),
                    SizedBox(width: 4.w),
                    Text(
                      item['checkIn'] ?? '-',
                      style: TextStyle(fontSize: 13.sp, color: AppTheme.textPrimary),
                    ),
                    SizedBox(width: 12.w),
                    Icon(Icons.logout, size: 14.w, color: AppTheme.warning),
                    SizedBox(width: 4.w),
                    Text(
                      item['checkOut'] ?? '-',
                      style: TextStyle(fontSize: 13.sp, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '工时: ${item['hours'] ?? 0} 小时',
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              status,
              style: TextStyle(fontSize: 12.sp, color: statusColor, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
