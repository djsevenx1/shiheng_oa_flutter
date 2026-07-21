import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../app/data/repository/dashboard_repository.dart';
import '../../../../app/data/repository/auth_repository.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/themes/app_theme.dart';
import '../../controllers/home_controller.dart';
import '../../../workflow/widgets/workflow_picker_sheet.dart';

class DashboardTab extends GetView<HomeController> {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // 顶部渐变区域
          SliverToBoxAdapter(
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
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 用户信息
                      Row(
                        children: [
                          Container(
                            width: 48.w,
                            height: 48.w,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 28.w,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Obx(() => Text(
                                  '欢迎回来，${controller.userInfo['name'] ?? '用户'}',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                )),
                                SizedBox(height: 4.h),
                                Obx(() => Text(
                                  controller.userInfo['groupName'] ?? '',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: Colors.white70,
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      // 快捷入口
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildQuickAction(Icons.people_outline, '通讯录', Colors.blue, () => Get.toNamed(Routes.CONTACTS)),
                          _buildQuickAction(Icons.add_circle_outline, '发起流程', Colors.indigo, () => WorkflowPickerSheet.show()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 16.h)),
          // 公告区域
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildSectionTitle('公告通知', Icons.campaign),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 12.h)),
          Obx(() {
            if (controller.isLoading.value && controller.bulletins.isEmpty) {
              return SliverToBoxAdapter(child: _buildBulletinShimmer());
            }
            if (controller.bulletins.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: _buildEmptyState('暂无公告'),
                ),
              );
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = controller.bulletins[index];
                  return _buildBulletinCard(item);
                },
                childCount: controller.bulletins.length > 3 ? 3 : controller.bulletins.length,
              ),
            );
          }),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          // 待处理流程
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: _buildSectionTitle('待处理', Icons.assignment_outlined),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 12.h)),
          Obx(() {
            if (controller.isLoading.value && controller.todoList.isEmpty) {
              return SliverToBoxAdapter(child: _buildEventShimmer());
            }
            if (controller.todoList.isEmpty) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: _buildEmptyState('暂无待处理流程'),
                ),
              );
            }
            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = controller.todoList[index];
                  return _buildTodoCard(item);
                },
                childCount: controller.todoList.length,
              ),
            );
          }),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap ?? () {},
      child: Column(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(icon, color: color, size: 26.w),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
        SizedBox(width: 8.w),
        Icon(icon, size: 18.w, color: AppTheme.primaryColor),
        SizedBox(width: 6.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBulletinCard(dynamic item) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
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
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  '公告',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${item['startDate'] ?? ''} 至 ${item['endDate'] ?? ''}',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            item['name'] ?? '无标题',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEventCard(dynamic item) {
    final type = item['eveType'] ?? 0;
    final state = item['state'] ?? 0;
    return GestureDetector(
      onTap: () {
        final proId = item['proId'];
        final topId = item['topId'];
        if (type == 0 && topId != null) {
          // 内部邮件 → 话题详情
          Get.toNamed(Routes.TOPIC, arguments: {'id': topId});
        } else if ((type == 1 || type == 2) && proId != null) {
          // 待办流程 / 历史流程 → 流程详情
          Get.toNamed(Routes.WORKFLOW_DETAIL, arguments: {'proId': proId});
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
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
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: controller.getEventTypeColor(type as int).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                type == 0 ? Icons.email_outlined : Icons.assignment_outlined,
                color: controller.getEventTypeColor(type),
                size: 22.w,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? '无标题',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        item['creatorName'] ?? '',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        item['createdDate'] ?? '',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: controller.getStateColor(state).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                controller.getStateName(state),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: controller.getStateColor(state),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodoCard(dynamic item) {
    final proId = item['id'];
    return GestureDetector(
      onTap: () async {
        if (proId != null) {
          final result = await Get.toNamed(Routes.WORKFLOW_DETAIL, arguments: {'proId': proId, 'handle': true});
          // 从详情返回后，若有操作（放弃/提交）则刷新待处理列表
          if (result is Map && result['refresh'] == true) {
            controller.refreshTodo();
          }
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
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
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppTheme.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(Icons.assignment_outlined, color: AppTheme.warning, size: 22.w),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? controller.getModuleName(item['modId']) ?? '无标题',
                    style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    item['creator'] ?? '',
                    style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppTheme.gray300, size: 20.w),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, size: 48.w, color: AppTheme.gray300),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletinShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 40.w, height: 18.h, color: Colors.white),
            SizedBox(height: 8.h),
            Container(width: double.infinity, height: 16.h, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildEventShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(width: 44.w, height: 44.w, color: Colors.white),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: double.infinity, height: 16.h, color: Colors.white),
                  SizedBox(height: 8.h),
                  Container(width: 120.w, height: 12.h, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
