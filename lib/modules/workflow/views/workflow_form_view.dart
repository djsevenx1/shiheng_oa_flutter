import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/contacts_repository.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/workflow_form_controller.dart';

class WorkflowFormView extends GetView<WorkflowFormController> {
  const WorkflowFormView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.moduleName.value.isEmpty ? '流程表单' : controller.moduleName.value)),
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
        if (controller.errorMessage.value != null && controller.formFields.isEmpty) {
          return _ErrorView(
            message: controller.errorMessage.value!,
            onRetry: controller.loadFormSchema,
          );
        }
        return RefreshIndicator(
          onRefresh: controller.loadFormSchema,
          child: Form(
            key: controller.formKey,
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                _buildFormHeader(),
                SizedBox(height: 16.h),
                _buildFormFields(),
                if (controller.formFields.isEmpty)
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 24.h),
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade800, size: 32.w),
                        SizedBox(height: 8.h),
                        Text(
                          '该流程未配置表单字段\n请到后端 OA 系统的"流程管理 → 模块配置"添加字段',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13.sp, color: Colors.amber.shade800),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 16.h),
                _buildSubmitInfo(),
                SizedBox(height: 100.h),
              ],
            ),
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
                  controller.moduleName.value.isEmpty ? '流程表单' : controller.moduleName.value,
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
    if (controller.formFields.isEmpty) return const SizedBox.shrink();
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
      case 'datetime':
        return _buildDateField(field);
      case 'textarea':
        return _buildTextareaField(field);
      case 'select':
        return _buildSelectField(field);
      case 'radio':
        return _buildRadioField(field);
      case 'file':
        return _buildFileField(field);
      case 'user':
        return _buildUserField(field);
      case 'detail':
        return _buildDetailField(field);
      default:
        return _buildTextField(field);
    }
  }

  /// 用户选择器（审批人/申请人/抄送人等）
  Widget _buildUserField(FormFieldSchema field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(field),
        SizedBox(height: 6.h),
        Obx(() => InkWell(
          onTap: () async {
            // 底部弹 sheet 选人
            final picked = await showModalBottomSheet<Map<String, dynamic>>(
              context: Get.context!,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => _UserPickerSheet(fieldLabel: field.label),
            );
            if (picked != null) {
                              // 后端要 user id 存 formData，name 显示用
                              final userId = picked['id']?.toString() ?? '';
                              final userName = picked['name']?.toString() ?? userId;
                              controller.updateField(field.name, userId);
                              // 缓存名字到显示用 key
                              controller.updateField('${field.name}__name', userName);
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
                Icon(Icons.person, color: AppTheme.gray400, size: 18),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    // 优先显示名字，id 只在 formData 里
                    controller.formData['${field.name}__name']?.toString()
                        ?? controller.formData[field.name]?.toString()
                        ?? '请选择${field.label}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: controller.formData[field.name] == null ? AppTheme.textTertiary : AppTheme.textPrimary,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: AppTheme.gray400, size: 18),
              ],
            ),
          ),
        )),
        if (field.helpText != null) _buildFieldHelp(field.helpText!),
      ],
    );
  }

  /// 明细子表（模仿老App：紫色标题栏+编辑按钮+新增明细按钮）
  Widget _buildDetailField(FormFieldSchema field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        Obx(() {
          final rows = controller.detailRows[field.name] ?? [];
          return Column(
            children: [
              // 渲染每条明细
              ...rows.asMap().entries.map((entry) {
                final idx = entry.key;
                final row = entry.value;
                return Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: Column(
                    children: [
                      // 紫色标题栏：明细N + 编辑按钮 + 删除按钮
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
                        ),
                        child: Row(
                          children: [
                            Text('明细${idx + 1}', style: TextStyle(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w500)),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => _showDetailEditDialog(field, idx, row),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                child: Text('编辑', style: TextStyle(fontSize: 13.sp, color: Colors.white)),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            GestureDetector(
                              onTap: () => controller.removeDetailRow(field.name, idx),
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                                child: Icon(Icons.close, color: Colors.white.withAlpha(200), size: 16.w),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // 明细内容预览
                      Padding(
                        padding: EdgeInsets.all(12.w),
                        child: Column(
                          children: ((field.fields ?? <Map<String, dynamic>>[]).cast<Map<String, dynamic>>()).map((sub) {
                            final subName = sub['name']?.toString() ?? '';
                            final subLabel = sub['label']?.toString() ?? subName;
                            final value = row[subName]?.toString() ?? '';
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 4.h),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 100.w,
                                    child: Text(subLabel, style: TextStyle(fontSize: 13.sp, color: AppTheme.textTertiary)),
                                  ),
                                  Expanded(
                                    child: Text(
                                      value.isEmpty ? '（未填）' : value,
                                      style: TextStyle(
                                        fontSize: 13.sp,
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
              }).toList(),
              // 新增明细按钮
              SizedBox(
                width: double.infinity,
                height: 44.h,
                child: ElevatedButton.icon(
                  onPressed: () {
                    controller.addDetailRow(field.name);
                    // 新增后自动弹出编辑框
                    final rows = controller.detailRows[field.name] ?? [];
                    if (rows.isNotEmpty) {
                      _showDetailEditDialog(field, rows.length - 1, rows.last);
                    }
                  },
                  icon: Icon(Icons.add, size: 18.w),
                  label: Text('新增明细', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }

  /// 明细编辑弹窗（模仿老App的编辑模式）
  void _showDetailEditDialog(FormFieldSchema field, int rowIdx, Map<String, dynamic> row) {
    final subFields = (field.fields ?? <Map<String, dynamic>>[]).cast<Map<String, dynamic>>();
    // 临时控制器
    final controllers = <String, TextEditingController>{};
    for (final sub in subFields) {
      final name = sub['name']?.toString() ?? '';
      controllers[name] = TextEditingController(text: row[name]?.toString() ?? '');
    }

    Get.dialog(
      AlertDialog(
        title: Row(
          children: [
            Text('编辑明细${rowIdx + 1}', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
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
              children: subFields.map((sub) {
                final name = sub['name']?.toString() ?? '';
                final label = sub['label']?.toString() ?? name;
                final type = sub['type']?.toString() ?? 'text';
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary, fontWeight: FontWeight.w500)),
                      SizedBox(height: 6.h),
                      if (type == 'date' || type == 'datetime')
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: Get.context!,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              final val = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                              controllers[name]!.text = val;
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppTheme.gray300),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16.w, color: AppTheme.gray400),
                                SizedBox(width: 8.w),
                                Expanded(child: Text(controllers[name]!.text.isEmpty ? '请选择' : controllers[name]!.text, style: TextStyle(fontSize: 14.sp, color: controllers[name]!.text.isEmpty ? AppTheme.textTertiary : AppTheme.textPrimary))),
                              ],
                            ),
                          ),
                        )
                      else
                        TextFormField(
                          controller: controllers[name],
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.r)),
                          ),
                          keyboardType: type == 'number' ? TextInputType.number : TextInputType.text,
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
              // 保存编辑结果到 controller
              for (final sub in subFields) {
                final name = sub['name']?.toString() ?? '';
                controller.updateDetailCell(field.name, rowIdx, name, controllers[name]!.text);
              }
              Get.back();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white),
            child: const Text('保存'),
          ),
        ],
      ),
    ).then((_) {
      // 清理控制器
      for (final c in controllers.values) {
        c.dispose();
      }
    });
  }

  Widget _buildTextField(FormFieldSchema field) {
    // 自动填写的字段也允许编辑，只是预填默认值
    return _buildEditableTextField(field);
  }

  Widget _buildEditableTextField(FormFieldSchema field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(field),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller.getTextController(field.name),
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

  /// 只读字段（自动填：sequence/current/info/logs/...）
  Widget _buildReadonlyField(FormFieldSchema field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel(field),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppTheme.gray100,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: AppTheme.gray200),
          ),
          child: Row(
            children: [
              Icon(Icons.lock_outline, color: AppTheme.gray400, size: 16),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  controller.formData[field.name]?.toString() ?? '系统自动',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: controller.formData[field.name] == null ? AppTheme.textTertiary : AppTheme.textSecondary,
                  ),
                ),
              ),
              Text('自动', style: TextStyle(fontSize: 11.sp, color: AppTheme.gray400)),
            ],
          ),
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
    // 自动填写的日期字段也允许编辑
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
          onTap: () {
            Get.snackbar('提示', '附件上传功能需要后端配置', snackPosition: SnackPosition.BOTTOM);
          },
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

  /// 提交说明（删了之前的"通知方式"硬编码三按钮）
  Widget _buildSubmitInfo() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.amber.shade800, size: 18.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              '提交后由后端 OA 系统按流程配置自动流转。',
              style: TextStyle(fontSize: 12.sp, color: Colors.amber.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 64.w, color: Colors.red.shade300),
            SizedBox(height: 16.h),
            Text(message, textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}

/// 选人底部 sheet（从 /oa/u/initList 拉）
class _UserPickerSheet extends StatefulWidget {
  final String fieldLabel;
  const _UserPickerSheet({required this.fieldLabel});

  @override
  State<_UserPickerSheet> createState() => _UserPickerSheetState();
}

class _UserPickerSheetState extends State<_UserPickerSheet> {
  final _repo = ContactsRepository();
  final _keyword = TextEditingController();
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _isLoading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final res = await _repo.getAllMembers(limit: 200);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res['success'] == true) {
          _allUsers = (res['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          _filtered = _allUsers;
        }
      });
    }
  }

  void _onSearch(String k) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (k.trim().isEmpty) {
        setState(() => _filtered = _allUsers);
      } else {
        setState(() {
          _filtered = _allUsers.where((u) {
            final n = u['name']?.toString() ?? '';
            return n.toLowerCase().contains(k.toLowerCase());
          }).toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _keyword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.h),
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2.r)),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Text('选择${widget.fieldLabel}', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TextField(
                  controller: _keyword,
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: '搜索姓名',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: AppTheme.gray50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filtered.isEmpty
                        ? const Center(child: Text('暂无成员'))
                        : ListView.separated(
                            controller: controller,
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                            itemBuilder: (_, i) {
                              final u = _filtered[i];
                              final name = u['name']?.toString() ?? '(无姓名)';
                              final dept = u['deptName']?.toString() ?? u['groupName']?.toString() ?? '';
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                  child: Text(name.isNotEmpty ? name[0] : '?',
                                      style: TextStyle(color: AppTheme.primaryColor)),
                                ),
                                title: Text(name),
                                subtitle: dept.isNotEmpty ? Text(dept, style: TextStyle(fontSize: 12.sp)) : null,
                                onTap: () => Get.back(result: u),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}
