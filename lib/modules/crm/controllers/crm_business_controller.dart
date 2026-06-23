import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/crm_business_repository.dart';

class CrmBusinessController extends GetxController {
  final _repository = CrmBusinessRepository();

  final searchController = TextEditingController();
  final isLoading = false.obs;
  final businessList = <dynamic>[].obs;
  final totalCount = 0.obs;
  final selectedStage = '全部'.obs;

  final stages = ['全部', '需求确认', '方案报价', '商务谈判', '签约中', '已签约', '已丢单'];

  @override
  void onInit() {
    super.onInit();
    loadBusinesses();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadBusinesses() async {
    isLoading.value = true;
    try {
      final stage = selectedStage.value == '全部' ? '' : selectedStage.value;
      final result = await _repository.getBusinessList(
        keyword: searchController.text,
        stage: stage,
      );

      if (result['success'] == true) {
        businessList.value = result['data'] ?? [];
        totalCount.value = result['count'] ?? 0;
      } else {
        businessList.value = [];
        totalCount.value = 0;
      }
    } catch (e) {
      businessList.value = [];
      totalCount.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  void changeStage(String stage) {
    selectedStage.value = stage;
    loadBusinesses();
  }

  void search() {
    loadBusinesses();
  }

  void _loadMock() {
    final mockData = [
      {
        'id': 1,
        'name': '华联科技控制器采购',
        'client': '华联科技股份有限公司',
        'amount': 580000.0,
        'stage': '商务谈判',
        'probability': 75,
        'expectedDate': '2024-02-15',
        'manager': '张经理',
        'remark': '重点跟进中，客户对产品满意',
      },
      {
        'id': 2,
        'name': '明华电子电源模块项目',
        'client': '明华电子有限公司',
        'amount': 320000.0,
        'stage': '需求确认',
        'probability': 50,
        'expectedDate': '2024-03-01',
        'manager': '李总监',
        'remark': '需要提供详细技术方案',
      },
      {
        'id': 3,
        'name': '盛达科技元件供应',
        'client': '盛达科技有限公司',
        'amount': 880000.0,
        'stage': '签约中',
        'probability': 90,
        'expectedDate': '2024-01-30',
        'manager': '王主管',
        'remark': '合同已起草，等待客户确认',
      },
      {
        'id': 4,
        'name': '金辉半导体合作项目',
        'client': '金辉半导体有限公司',
        'amount': 1200000.0,
        'stage': '方案报价',
        'probability': 65,
        'expectedDate': '2024-02-28',
        'manager': '陈经理',
        'remark': '已提交初步报价',
      },
      {
        'id': 5,
        'name': '新源电子控制器项目',
        'client': '新源电子元件厂',
        'amount': 250000.0,
        'stage': '已签约',
        'probability': 100,
        'expectedDate': '2024-01-20',
        'manager': '张经理',
        'remark': '合同已签订，准备生产',
      },
      {
        'id': 6,
        'name': '智能科技合作项目',
        'client': '智能科技股份有限公司',
        'amount': 180000.0,
        'stage': '已丢单',
        'probability': 0,
        'expectedDate': '2024-01-10',
        'manager': '李总监',
        'remark': '客户选择了竞品',
      },
    ];

    final filtered = selectedStage.value == '全部'
        ? mockData
        : mockData.where((b) => b['stage'] == selectedStage.value).toList();
    businessList.value = filtered;
    totalCount.value = filtered.length;
  }
}
