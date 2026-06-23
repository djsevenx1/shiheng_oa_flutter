import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/workflow_form_controller.dart';

class WorkflowFormView extends GetView<WorkflowFormController> {
  const WorkflowFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.moduleName.value)),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 14.sp)),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
        }
        return Form(
          key: controller.formKey,
          child: ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              _buildFormHeader(),
              SizedBox(height: 16.h),
              _buildFormFields(),
              SizedBox(height: 16.h),
              _buildApproversSection(),
              SizedBox(height: 16.h),
              _buildAttachmentSection(),
              SizedBox(height: 100.h),
            ],
          ),
        );
      }),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Obx(() => SizedBox(
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
                : const Icon(Icons.send),
            label: Text(
              controller.isSubmitting.value ? '提交中...' : '提交审批',
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
      ),
    );
  }

  Widget _buildFormHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(Icons.assignment, color: AppTheme.primaryColor, size: 22.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(() => Text(
                  controller.moduleName.value,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                )),
                SizedBox(height: 2.h),
                Text(
                  '请如实填写以下信息',
                  style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Container(
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
          Obx(() => Column(
            children: controller.formFields.map((field) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: _buildField(field),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildField(FormFieldSchema field) {
    switch (field.type) {
      case 'text':
        return _buildTextField(field);
      case 'number':
        return _buildNumberField(field);
      case 'date':
        return _buildDateField(field);
      case 'textarea':
        return _buildTextareaField(field);
      case 'select':
        return _buildSelectField(field);
      case 'radio':
        return _buildRadioField(field);
      case 'file':
        return _buildFileField(field);
      default:
        return _buildTextField(field);
    }
  }

  Widget _buildTextField(FormFieldSchema field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(field),
        SizedBox(height: 6.h),
        TextFormField(
          initialValue: field.defaultValue?.toString() ?? '',
          decoration: _inputDecoration(field.placeholder),
          validator: field.required
              ? (v) => v == null || v.isEmpty ? '请输入${field.label}' : null
              : null,
          onChanged: (v) => controller.updateField(field.name, v),
        ),
        if (field.helpText != null) _buildFieldHelp(field.helpText!),
      ],
    );
  }

  Widget _buildNumberField(FormFieldSchema field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(field),
        SizedBox(height: 6.h),
        TextFormField(
          initialValue: field.defaultValue?.toString() ?? '',
          keyboardType: TextInputType.number,
          decoration: _inputDecoration(field.placeholder),
          validator: field.required
              ? (v) => v == null || v.isEmpty ? '请输入${field.label}' : null
              : null,
          onChanged: (v) => controller.updateField(field.name, num.tryParse(v) ?? 0),
        ),
        if (field.helpText != null) _buildFieldHelp(field.helpText!),
      ],
    );
  }

  Widget _buildDateField(FormFieldSchema field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(field),
        SizedBox(height: 6.h),
        Obx(() => InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: Get.context!,
              initialDate: DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2030),
            );
            if (date != null) {
              controller.updateField(field.name, '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}');
            }
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppTheme.gray50,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: AppTheme.gray400, size: 18),
                SizedBox(width: 8.w),
                Text(
                  controller.formData[field.name]?.toString() ?? '请选择',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: controller.formData[field.name] == null ? AppTheme.textTertiary : AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        )),
        if (field.helpText != null) _buildFieldHelp(field.helpText!),
      ],
    );
  }

  Widget _buildTextareaField(FormFieldSchema field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(field),
        SizedBox(height: 6.h),
        TextFormField(
          initialValue: field.defaultValue?.toString() ?? '',
          maxLines: 4,
          decoration: _inputDecoration(field.placeholder),
          validator: field.required
              ? (v) => v == null || v.length < 10 ? '${field.label}至少需要10个字符' : null
              : null,
          onChanged: (v) => controller.updateField(field.name, v),
        ),
        if (field.helpText != null) _buildFieldHelp(field.helpText!),
      ],
    );
  }

  Widget _buildSelectField(FormFieldSchema field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(field),
        SizedBox(height: 6.h),
        Obx(() => Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: (field.options ?? []).map((option) {
            final isSelected = controller.formData[field.name]?.toString() == option['value'].toString();
            return GestureDetector(
              onTap: () => controller.updateField(field.name, option['value']),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.white,
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : AppTheme.gray300,
                  ),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  option['label']?.toString() ?? '',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isSelected ? Colors.white : AppTheme.textPrimary,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        )),
        if (field.helpText != null) _buildFieldHelp(field.helpText!),
      ],
    );
  }

  Widget _buildRadioField(FormFieldSchema field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(field),
        SizedBox(height: 6.h),
        Obx(() => Row(
          children: (field.options ?? []).map((option) {
            final isSelected = controller.formData[field.name]?.toString() == option['value'].toString();
            return Expanded(
              child: GestureDetector(
                onTap: () => controller.updateField(field.name, option['value']),
                child: Container(
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.gray300,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(
                    child: Text(
                      option['label']?.toString() ?? '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        )),
        if (field.helpText != null) _buildFieldHelp(field.helpText!),
      ],
    );
  }

  Widget _buildFileField(FormFieldSchema field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(field),
        SizedBox(height: 6.h),
        InkWell(
          onTap: () {},
          child: Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppTheme.gray50,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: AppTheme.gray300,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_upload_outlined, size: 32.w, color: AppTheme.gray400),
                SizedBox(height: 8.h),
                Text(
                  '点击上传文件',
                  style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
        ),
        if (field.helpText != null) _buildFieldHelp(field.helpText!),
      ],
    );
  }

  Widget _buildFieldLabel(FormFieldSchema field) {
    return Row(
      children: [
        if (field.required)
          Text('* ', style: TextStyle(color: AppTheme.danger, fontSize: 14.sp)),
        Text(
          field.label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildFieldHelp(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 4.h),
      child: Text(
        text,
        style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary),
      ),
    );
  }

  InputDecoration _inputDecoration(String? placeholder) {
    return InputDecoration(
      hintText: placeholder,
      filled: true,
      fillColor: AppTheme.gray50,
      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
      ),
    );
  }

  Widget _buildApproversSection() {
    return Container(
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
              Text(
                '选择审批人',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              Text(' *', style: TextStyle(color: AppTheme.danger, fontSize: 14.sp)),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(() => Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _mockApprovers.map((approver) {
              final isSelected = controller.selectedApprovers.contains(approver['name']!);
              return GestureDetector(
                onTap: () => controller.toggleApprover(approver['name']!),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.gray50,
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryColor : AppTheme.gray300,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 12.w,
                        backgroundColor: AppTheme.primaryColor,
                        child: Text(
                          approver['name']![0],
                          style: TextStyle(fontSize: 11.sp, color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        approver['name']!,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: isSelected ? AppTheme.primaryColor : AppTheme.textPrimary,
                        ),
                      ),
                      if (isSelected) ...[
                        SizedBox(width: 4.w),
                        Icon(Icons.check_circle, size: 14.w, color: AppTheme.primaryColor),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          )),
        ],
      ),
    );
  }

  Widget _buildAttachmentSection() {
    return Container(
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
            '通知方式',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildNotificationOption('站内消息', Icons.message, true),
              SizedBox(width: 12.w),
              _buildNotificationOption('邮件', Icons.email_outlined, true),
              SizedBox(width: 12.w),
              _buildNotificationOption('短信', Icons.sms_outlined, false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationOption(String label, IconData icon, bool selected) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryColor.withOpacity(0.1) : AppTheme.gray50,
          border: Border.all(
            color: selected ? AppTheme.primaryColor : AppTheme.gray300,
          ),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppTheme.primaryColor : AppTheme.gray400, size: 20.w),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: selected ? AppTheme.primaryColor : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  final _mockApprovers = const [
    {'name': '张经理', 'dept': '技术部'},
    {'name': '李总监', 'dept': '运营部'},
    {'name': '王主管', 'dept': '财务部'},
    {'name': '陈总', 'dept': '总经理'},
    {'name': '刘总', 'dept': '副总'},
  ];
}
