import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/task_create_controller.dart';

class TaskCreateView extends GetView<TaskCreateController> {
  const TaskCreateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('新建任务'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消', style: TextStyle(color: Colors.white.withAlpha(200))),
          ),
        ],
      ),
      body: Form(
        key: controller.formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            _buildTextField(
              controller: controller.titleController,
              label: '任务标题',
              required: true,
              hint: '请输入任务标题',
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              controller: controller.descController,
              label: '任务描述',
              hint: '请输入任务详情',
              maxLines: 4,
            ),
            SizedBox(height: 16.h),
            _buildPrioritySection(),
            SizedBox(height: 16.h),
            _buildDateSection(),
            SizedBox(height: 16.h),
            _buildAssigneeSection(),
            SizedBox(height: 32.h),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 50.h,
              child: ElevatedButton.icon(
                onPressed: controller.isSubmitting.value ? null : controller.submit,
                icon: controller.isSubmitting.value
                    ? SizedBox(
                        width: 18.w,
                        height: 18.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(
                  controller.isSubmitting.value ? '创建中...' : '创建任务',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  elevation: 0,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (required) Text('* ', style: TextStyle(color: AppTheme.danger, fontSize: 14.sp)),
            Text(label, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppTheme.gray300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppTheme.gray300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
            ),
          ),
          validator: required
              ? (v) => v == null || v.isEmpty ? '请输入$label' : null
              : null,
        ),
      ],
    );
  }

  Widget _buildPrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('优先级', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        SizedBox(height: 8.h),
        Obx(() => Row(
          children: [
            _buildPriorityChip('高', 'high', AppTheme.danger),
            SizedBox(width: 8.w),
            _buildPriorityChip('中', 'medium', AppTheme.warning),
            SizedBox(width: 8.w),
            _buildPriorityChip('低', 'low', AppTheme.info),
          ],
        )),
      ],
    );
  }

  Widget _buildPriorityChip(String label, String value, Color color) {
    final isSelected = controller.priority.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.setPriority(value),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            border: Border.all(
              color: isSelected ? color : AppTheme.gray300,
              width: isSelected ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: isSelected ? color : AppTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('* ', style: TextStyle(color: AppTheme.danger, fontSize: 14.sp)),
            Text('截止日期', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
          ],
        ),
        SizedBox(height: 8.h),
        Obx(() => InkWell(
          onTap: controller.pickDate,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppTheme.gray300),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppTheme.gray400, size: 18),
                SizedBox(width: 8.w),
                Text(
                  controller.dueDate.value.isEmpty ? '请选择截止日期' : controller.dueDate.value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: controller.dueDate.value.isEmpty ? AppTheme.textTertiary : AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down, color: AppTheme.gray400),
              ],
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildAssigneeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('指派给', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppTheme.textPrimary)),
        SizedBox(height: 8.h),
        Obx(() => Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppTheme.gray300),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14.w,
                backgroundColor: AppTheme.primaryColor,
                child: const Icon(Icons.person, color: Colors.white, size: 18),
              ),
              SizedBox(width: 8.w),
              Text(controller.assignee.value, style: TextStyle(fontSize: 14.sp, color: AppTheme.textPrimary)),
              const Spacer(),
              const Icon(Icons.arrow_drop_down, color: AppTheme.gray400),
            ],
          ),
        )),
      ],
    );
  }
}
