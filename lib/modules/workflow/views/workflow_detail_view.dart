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
        return SingleChildScrollView(
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
              SizedBox(height: 12.h),
              // 审批意见输入框（仅待处理模式显示）
              if (controller.isHandleMode.value) _buildCommentField(),
              SizedBox(height: 80.h),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        if (!controller.isHandleMode.value) return const SizedBox.shrink();
        if (controller.isLoading.value) return const SizedBox.shrink();
        return _buildBottomBar();
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
    return Obx(() => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // 标题栏
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
          // 每条明细：紫色标题栏 + 编辑按钮 + 内容预览
          ...controller.mxItems.asMap().entries.map((entry) {
            final idx = entry.key;
            final item = entry.value;
            return Container(
              margin: EdgeInsets.fromLTRB(8.w, 0, 8.w, 8.h),
              decoration: BoxDecoration(
                color: AppTheme.gray50,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppTheme.gray200),
              ),
              child: Column(
                children: [
                  // 紫色标题栏
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
                    ),
                    child: Row(
                      children: [
                        Text('明细${idx + 1}', style: TextStyle(fontSize: 13.sp, color: Colors.white, fontWeight: FontWeight.w500)),
                        const Spacer(),
                        if (controller.isHandleMode.value)
                          GestureDetector(
                            onTap: () => _showMxEditDialog(idx, item),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                              child: Text('编辑', style: TextStyle(fontSize: 12.sp, color: Colors.white)),
                            ),
                          ),
                        if (controller.isHandleMode.value) SizedBox(width: 12.w),
                        if (controller.isHandleMode.value)
                          GestureDetector(
                            onTap: () => controller.removeMxItem(idx),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                              child: Icon(Icons.close, color: Colors.white.withAlpha(200), size: 16.w),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // 内容预览
                  Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Column(
                      children: controller.detailFields.map((f) {
                        final label = f['name']?.toString() ?? '';
                        final value = controller.getDetailValue(item, f);
                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: 3.h),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 90.w,
                                child: Text(label, style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary)),
                              ),
                              Expanded(
                                child: Text(
                                  value.isEmpty ? '（未填）' : value,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: value.isEmpty ? AppTheme.textTertiary : AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          }),
          // 新增明细按钮（仅待处理模式）
          if (controller.isHandleMode.value)
            Padding(
              padding: EdgeInsets.fromLTRB(8.w, 0, 8.w, 12.h),
              child: SizedBox(
                width: double.infinity,
                height: 40.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.addMxItem();
                    final idx = controller.mxItems.length - 1;
                    _showMxEditDialog(idx, controller.mxItems.last);
                  },
                  icon: Icon(Icons.add, size: 18.w),
                  label: Text('新增明细', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    elevation: 0,
                  ),
                ),
              ),
            ),
        ],
      ),
    ));
  }

  /// 明细编辑弹窗
  void _showMxEditDialog(int idx, Map<String, dynamic> item) {
    final fields = controller.detailFields.toList();
    final controllers = <String, TextEditingController>{};
    for (final f in fields) {
      final id = f['id']?.toString() ?? f['name']?.toString() ?? '';
      controllers[id] = TextEditingController(text: item[id]?.toString() ?? '');
    }

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Text('编辑明细${idx + 1}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Get.back(),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        contentPadding: EdgeInsets.all(16.w),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: fields.map((f) {
                final id = f['id']?.toString() ?? f['name']?.toString() ?? '';
                final label = f['name']?.toString() ?? id;
                final ctrl = f['ctrl']?.toString() ?? 'text';
                final isDate = ctrl == 'date' || ctrl == 'datetime';
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                      SizedBox(height: 6.h),
                      if (isDate)
                        TextFormField(
                          controller: controllers[id],
                          readOnly: true,
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r)),
                            suffixIcon: Icon(Icons.calendar_today, size: 16.w, color: AppTheme.gray400),
                          ),
                          onTap: () async {
                            final date = await showDatePicker(
                              context: Get.context!,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              controllers[id]!.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                            }
                          },
                        )
                      else
                        TextFormField(
                          controller: controllers[id],
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r)),
                          ),
                          keyboardType: ctrl == 'number' || ctrl == 'num' || ctrl == 'money' ? TextInputType.number : TextInputType.text,
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final values = <String, dynamic>{};
              for (final f in fields) {
                final id = f['id']?.toString() ?? f['name']?.toString() ?? '';
                values[id] = controllers[id]!.text;
              }
              controller.updateMxItem(idx, values);
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
            child: const Text('保存'),
          ),
        ],
      ),
    ).then((_) {
      for (final c in controllers.values) {
        c.dispose();
      }
    });
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

  /// 审批意见输入框
  Widget _buildCommentField() {
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
                Text('审批意见', style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                SizedBox(width: 4.w),
                Text('*', style: TextStyle(fontSize: 15.sp, color: AppTheme.danger)),
              ],
            ),
            SizedBox(height: 12.h),
            TextField(
              controller: controller.commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: '请输入审批意见',
                hintStyle: TextStyle(fontSize: 14.sp, color: AppTheme.textTertiary),
                filled: true,
                fillColor: AppTheme.gray50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: AppTheme.gray200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: AppTheme.gray200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide(color: AppTheme.primaryColor),
                ),
                contentPadding: EdgeInsets.all(12.w),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 底部操作栏
  Widget _buildBottomBar() {
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
                child: controller.isLoading.value
                    ? SizedBox(width: 18.w, height: 18.w, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text('提交', style: TextStyle(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
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
