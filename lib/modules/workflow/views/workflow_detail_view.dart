import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/workflow_detail_controller.dart';

class WorkflowDetailView extends GetView<WorkflowDetailController> {
  const WorkflowDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.workflowDetail['name'] ?? '流程详情')),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        if (controller.errorMessage.value != null) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.w, color: AppTheme.danger),
                  SizedBox(height: 16.h),
                  Text(controller.errorMessage.value!,
                      style: TextStyle(fontSize: 14.sp, color: AppTheme.danger),
                      textAlign: TextAlign.center),
                  SizedBox(height: 16.h),
                  OutlinedButton(onPressed: controller.loadDetail, child: const Text('重试')),
                ],
              ),
            ),
          );
        }
        if (controller.workflowDetail.isEmpty) {
          return Center(child: Text('暂无详情数据', style: TextStyle(fontSize: 14.sp, color: AppTheme.textTertiary)));
        }
        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatusCard(),
                    SizedBox(height: 12.h),
                    _buildFormFields(),
                    if (controller.mxItems.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      _buildDetailSection(),
                    ],
                    SizedBox(height: 12.h),
                    _buildTimeline(),
                    SizedBox(height: 80.h),
                  ],
                ),
              ),
            ),
            _buildBottomBar(),
          ],
        );
      }),
    );
  }

  /// 状态卡片
  Widget _buildStatusCard() {
    final state = controller.workflowDetail['state'] ?? 0;
    final stateName = controller.getStateName(state is int ? state : 0);
    final stateColor = controller.getStateColor(state is int ? state : 0);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [stateColor.withOpacity(0.1), stateColor.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: stateColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.workflowDetail['name'] ?? '',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                SizedBox(height: 4.h),
                Text(
                  '创建时间: ${controller.workflowDetail['createdDate'] ?? ''}',
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: stateColor,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(stateName, style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  /// 表单字段（用 tableSchema 渲染）
  Widget _buildFormFields() {
    if (controller.mainFields.isEmpty) {
      // tableSchema 为空时，回退到直接显示 formData
      return _buildFormDataFallback();
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(width: 3.w, height: 14.h, decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(2.r))),
                SizedBox(width: 8.w),
                Text('表单信息', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.dividerColor),
          ...controller.mainFields.asMap().entries.map((entry) {
            final field = entry.value;
            final value = controller.getFieldValue(field);
            final isLast = entry.key == controller.mainFields.length - 1;
            return _buildFieldRow(field['name']?.toString() ?? '', value, isLast);
          }),
        ],
      ),
    );
  }

  Widget _buildFieldRow(String label, String value, bool isLast) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: AppTheme.dividerColor, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80.w,
            child: Text(label, style: TextStyle(fontSize: 13.sp, color: AppTheme.textTertiary)),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: TextStyle(fontSize: 13.sp, color: AppTheme.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  /// 明细区域
  Widget _buildDetailSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(width: 3.w, height: 14.h, decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(2.r))),
                SizedBox(width: 8.w),
                Text('明细', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const Spacer(),
                Text('${controller.mxItems.length} 项', style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary)),
              ],
            ),
          ),
          // 表头
          if (controller.detailFields.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(color: AppTheme.gray50),
              child: Row(
                children: controller.detailFields.map((f) {
                  return Expanded(
                    child: Text(
                      f['name']?.toString() ?? '',
                      style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                  );
                }).toList(),
              ),
            ),
          // 数据行
          ...controller.mxItems.asMap().entries.map((entry) {
            final item = entry.value;
            final isLast = entry.key == controller.mxItems.length - 1;
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                border: isLast ? null : Border(bottom: BorderSide(color: AppTheme.dividerColor, width: 0.5)),
              ),
              child: Row(
                children: controller.detailFields.map((f) {
                  return Expanded(
                    child: Text(
                      controller.getDetailValue(item, f),
                      style: TextStyle(fontSize: 12.sp, color: AppTheme.textPrimary),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 审批记录时间线
  Widget _buildTimeline() {
    if (controller.logs.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 3.w, height: 14.h, decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(2.r))),
                SizedBox(width: 8.w),
                Text('审批记录', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              ],
            ),
            SizedBox(height: 16.h),
            ...controller.logs.asMap().entries.map((entry) {
              final index = entry.key;
              final log = entry.value;
              final isLast = index == controller.logs.length - 1;
              final actionId = log['actionId'];
              final isPositive = controller.isActionPositive(actionId);
              return _buildTimelineItem(log: log, isLast: isLast, isPositive: isPositive, actionName: controller.getActionName(actionId));
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required Map<String, dynamic> log,
    required bool isLast,
    required bool isPositive,
    required String actionName,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 4.w),
          Column(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: isPositive ? AppTheme.success : AppTheme.danger,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              if (!isLast) Container(width: 2.w, height: 36.h, color: AppTheme.gray200),
            ],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(log['name'] ?? '未知',
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: (isPositive ? AppTheme.success : AppTheme.danger).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(3.r),
                        ),
                        child: Text(actionName,
                            style: TextStyle(fontSize: 10.sp, color: isPositive ? AppTheme.success : AppTheme.danger)),
                      ),
                    ],
                  ),
                  if (log['message'] != null && log['message'].toString().isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(log['message']?.toString() ?? '',
                        style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary)),
                  ],
                  SizedBox(height: 2.h),
                  Text(log['createdDate']?.toString() ?? '',
                      style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 底部操作栏
  Widget _buildBottomBar() {
    return Obx(() {
      // 历史模式（只读）不显示底部按钮
      if (!controller.isHandleMode.value) return const SizedBox.shrink();
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, -2))],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // 放弃按钮
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(color: AppTheme.danger),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: Text('放弃', style: TextStyle(fontSize: 15.sp, color: AppTheme.danger, fontWeight: FontWeight.w500)),
                ),
              ),
              SizedBox(width: 12.w),
              // 提交按钮
              Expanded(
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : controller.approve,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: Text('提交', style: TextStyle(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  /// formData 回退显示（tableSchema 为空时）
  Widget _buildFormDataFallback() {
    final entries = controller.formData.entries.where((e) => e.key != 'mx' && e.key != 'logs').toList();
    if (entries.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(width: 3.w, height: 14.h, decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(2.r))),
                SizedBox(width: 8.w),
                Text('表单信息', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.dividerColor),
          ...entries.asMap().entries.map((entry) {
            return _buildFieldRow(entry.value.key, entry.value.value?.toString() ?? '', entry.key == entries.length - 1);
          }),
        ],
      ),
    );
  }
}
