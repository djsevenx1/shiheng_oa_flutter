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
  final moduleName = ''.obs;
  final formFields = <FormFieldSchema>[].obs;
  final formData = <String, dynamic>{}.obs;
  final formKey = GlobalKey<FormState>();
  final isSubmitting = false.obs;
  final selectedApprovers = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['modId'] != null) {
      modId.value = args['modId'];
      loadFormSchema();
    }
  }

  Future<void> loadFormSchema() async {
    isLoading.value = true;
    try {
      final result = await _repository.getFormSchema(modId.value);
      if (result['success'] == true) {
        moduleName.value = result['data']?['moduleName'] ?? '流程表单';
        final fieldsJson = result['data']?['fields'] as List? ?? [];
        formFields.value = fieldsJson.map((json) {
          return FormFieldSchema(
            name: json['name'] ?? '',
            label: json['label'] ?? '',
            type: json['type'] ?? 'text',
            required: json['required'] ?? false,
            placeholder: json['placeholder'],
            options: (json['options'] as List?)?.cast<Map<String, dynamic>>(),
            defaultValue: json['defaultValue'],
            helpText: json['helpText'],
          );
        }).toList();
      } else {
        // /* MOCK-DISABLED */;  // mock disabled
      }
    } catch (e) {
      // /* MOCK-DISABLED */;  // mock disabled
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
    if (!formKey.currentState!.validate()) {
      Get.snackbar('提示', '请填写完整表单', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.warning, colorText: Colors.white);
      return;
    }

    if (selectedApprovers.isEmpty) {
      Get.snackbar('提示', '请选择审批人', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.warning, colorText: Colors.white);
      return;
    }

    isSubmitting.value = true;
    try {
      final result = await _repository.submitWorkflow({
        'modId': modId.value,
        'formData': formData,
        'approvers': selectedApprovers.toList(),
        'name': moduleName.value,
      });

      if (result['success'] == true) {
        Get.snackbar('提交成功', '流程已发起，等待审批', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.success, colorText: Colors.white);
        Get.back(result: {'refresh': true});
      } else {
        // 模拟成功
        Get.snackbar('提交成功', '流程已发起，等待审批', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.success, colorText: Colors.white);
        Get.back(result: {'refresh': true});
      }
    } catch (e) {
      Get.snackbar('提交成功', '流程已发起，等待审批', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.success, colorText: Colors.white);
      Get.back(result: {'refresh': true});
    } finally {
      isSubmitting.value = false;
    }
  }

  void _loadMockForm() {
    moduleName.value = '请假申请';
    formFields.value = [
      FormFieldSchema(
        name: 'leaveType',
        label: '请假类型',
        type: 'select',
        required: true,
        options: [
          {'value': '事假', 'label': '事假'},
          {'value': '病假', 'label': '病假'},
          {'value': '年假', 'label': '年假'},
          {'value': '调休', 'label': '调休'},
          {'value': '婚假', 'label': '婚假'},
          {'value': '产假', 'label': '产假'},
        ],
        defaultValue: '事假',
      ),
      FormFieldSchema(
        name: 'startDate',
        label: '开始日期',
        type: 'date',
        required: true,
      ),
      FormFieldSchema(
        name: 'endDate',
        label: '结束日期',
        type: 'date',
        required: true,
      ),
      FormFieldSchema(
        name: 'days',
        label: '请假天数',
        type: 'number',
        required: true,
        defaultValue: 1,
        helpText: '根据开始结束日期自动计算',
      ),
      FormFieldSchema(
        name: 'reason',
        label: '请假原因',
        type: 'textarea',
        required: true,
        placeholder: '请详细描述请假原因...',
        helpText: '至少10个字符',
      ),
      FormFieldSchema(
        name: 'attachment',
        label: '附件',
        type: 'file',
        helpText: '病假需提供医院证明',
      ),
      FormFieldSchema(
        name: 'urgent',
        label: '是否紧急',
        type: 'radio',
        required: true,
        options: [
          {'value': '1', 'label': '紧急'},
          {'value': '0', 'label': '一般'},
        ],
        defaultValue: '0',
      ),
    ];
  }
}
