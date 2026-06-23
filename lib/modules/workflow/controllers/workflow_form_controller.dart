import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/workflow_repository.dart';
import '../../../app/themes/app_theme.dart';

class FormFieldSchema {
  final String name;
  final String label;
  final String type; // text, number, date, datetime, textarea, select, radio, checkbox, file
  final bool required;
  final String? placeholder;
  final List<Map<String, dynamic>>? options;
  final dynamic defaultValue;
  final String? helpText;
  final String? validation;

  FormFieldSchema({
    required this.name,
    required this.label,
    required this.type,
    this.required = false,
    this.placeholder,
    this.options,
    this.defaultValue,
    this.helpText,
    this.validation,
  });
}

class WorkflowFormController extends GetxController {
  final _repository = WorkflowRepository();

  final isLoading = false.obs;
  final modId = 0.obs;
  final appKey = ''.obs;
  final moduleName = ''.obs;
  final formFields = <FormFieldSchema>[].obs;
  final formData = <String, dynamic>{}.obs;
  final formKey = GlobalKey<FormState>();
  final isSubmitting = false.obs;
  final selectedApprovers = <String>{}.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['modId'] != null) {
      modId.value = args['modId'] is int ? args['modId'] as int : int.tryParse(args['modId'].toString()) ?? 0;
      if (args['moduleName'] != null) {
        moduleName.value = args['moduleName'].toString();
      }
      loadFormSchema();
    } else {
      errorMessage.value = '缺少 modId 参数';
    }
  }

  Future<void> loadFormSchema() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _repository.getFormSchema(modId.value);
      if (result['success'] == true) {
        final data = (result['data'] as Map?)?.cast<String, dynamic>() ?? {};
        if (moduleName.value.isEmpty) {
          moduleName.value = data['moduleName']?.toString() ?? '流程表单';
        }
        appKey.value = data['appKey']?.toString() ?? '';
        final fieldsJson = (data['fields'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        formFields.value = fieldsJson.map((json) {
          return FormFieldSchema(
            name: json['name'] ?? '',
            label: json['label'] ?? '',
            type: json['type'] ?? 'text',
            required: json['required'] ?? false,
            placeholder: json['placeholder']?.toString(),
            options: (json['options'] as List?)?.cast<Map<String, dynamic>>(),
            defaultValue: json['defaultValue'],
            helpText: json['helpText']?.toString(),
          );
        }).toList();
        if (formFields.isEmpty) {
          errorMessage.value = '该流程未配置表单字段（后端 schema 为空）';
        }
      } else {
        errorMessage.value = result['message']?.toString() ?? '加载表单失败';
      }
    } catch (e) {
      errorMessage.value = '加载表单异常: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void updateField(String name, dynamic value) {
    formData[name] = value;
  }

  void toggleApprover(String name) {
    if (selectedApprovers.contains(name)) {
      selectedApprovers.remove(name);
    } else {
      selectedApprovers.add(name);
    }
  }

  Future<void> submit() async {
    if (formKey.currentState != null && !formKey.currentState!.validate()) {
      Get.snackbar('提示', '请填写完整表单', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.warning, colorText: Colors.white);
      return;
    }
    if (formFields.isEmpty) {
      Get.snackbar('提示', '表单字段未加载', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSubmitting.value = true;
    try {
      final result = await _repository.submitWorkflow(
        modId: modId.value,
        formData: Map<String, dynamic>.from(formData),
        appKey: appKey.value,
      );
      if (result['success'] == true) {
        Get.snackbar('提交成功', '流程已发起，等待审批', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.success, colorText: Colors.white);
        Get.back(result: {'refresh': true, 'submitted': true});
      } else {
        Get.snackbar('提交失败', result['message']?.toString() ?? '请稍后再试', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.danger, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('提交失败', '异常: $e', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.danger, colorText: Colors.white);
    } finally {
      isSubmitting.value = false;
    }
  }
}
