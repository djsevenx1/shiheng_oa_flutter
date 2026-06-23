import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/crm_repository.dart';

class CrmClientController extends GetxController {
  final _repository = CrmRepository();

  final searchController = TextEditingController();
  final isLoading = false.obs;
  final clientList = <dynamic>[].obs;
  final totalCount = 0.obs;
  final currentPage = 1.obs;
  final selectedFilter = '全部'.obs;
  final isLoadingMore = false.obs;

  final filters = ['全部', '重点客户', '潜在客户', '已成交', '已流失'];

  int get totalPages => (totalCount.value / 10).ceil();
  bool get hasNextPage => currentPage.value < totalPages;
  bool get hasPreviousPage => currentPage.value > 1;

  @override
  void onInit() {
    super.onInit();
    loadClients();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadClients({bool refresh = true}) async {
    if (refresh) {
      currentPage.value = 1;
      clientList.clear();
    }
    isLoading.value = true;
    try {
      final result = await _repository.getClientList(
        page: currentPage.value,
        pageSize: 10,
        keyword: searchController.text,
        type: selectedFilter.value,
      );

      if (result['success'] == true) {
        if (currentPage.value == 1) {
          clientList.value = result['data'] ?? [];
        } else {
          clientList.addAll(result['data'] ?? []);
        }
        totalCount.value = result['count'] ?? 0;
      } else {
        clientList.value = [];
        totalCount.value = 0;
      }
    } catch (e) {
      clientList.value = [];
      totalCount.value = 0;
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void nextPage() {
    if (hasNextPage) {
      currentPage.value++;
      loadClients(refresh: false);
    }
  }

  void changeFilter(String filter) {
    selectedFilter.value = filter;
    loadClients();
  }

  void search() {
    loadClients();
  }

  void _loadMockData() {
    final mockData = [
      {
        'id': 1,
        'name': '华联科技股份有限公司',
        'type': '重点客户',
        'contact': '王经理',
        'phone': '13800138001',
        'address': '江苏省南京市',
        'industry': '电子制造',
        'level': 'A',
        'lastContact': '2024-01-15',
        'amount': 125800.0,
        'avatar': '',
      },
      {
        'id': 2,
        'name': '明华电子有限公司',
        'type': '潜在客户',
        'contact': '李总',
        'phone': '13900139002',
        'address': '江苏省南京市',
        'industry': '电子元件',
        'level': 'B',
        'lastContact': '2024-01-12',
        'amount': 58000.0,
        'avatar': '',
      },
      {
        'id': 3,
        'name': '盛达科技有限公司',
        'type': '已成交',
        'contact': '张总',
        'phone': '13700137003',
        'address': '江苏省南京市',
        'industry': '通信设备',
        'level': 'A',
        'lastContact': '2024-01-10',
        'amount': 358000.0,
        'avatar': '',
      },
      {
        'id': 4,
        'name': '金辉半导体有限公司',
        'type': '重点客户',
        'contact': '陈经理',
        'phone': '13600136004',
        'address': '上海市浦东新区',
        'industry': '半导体',
        'level': 'A',
        'lastContact': '2024-01-08',
        'amount': 256000.0,
        'avatar': '',
      },
      {
        'id': 5,
        'name': '新源电子元件厂',
        'type': '潜在客户',
        'contact': '刘老板',
        'phone': '13500135005',
        'address': '浙江省杭州市西湖区',
        'industry': '电子元件',
        'level': 'B',
        'lastContact': '2024-01-05',
        'amount': 32000.0,
        'avatar': '',
      },
      {
        'id': 6,
        'name': '智能科技股份有限公司',
        'type': '已流失',
        'contact': '黄总',
        'phone': '13400134006',
        'address': '江苏省苏州市工业园区',
        'industry': '智能制造',
        'level': 'C',
        'lastContact': '2023-12-20',
        'amount': 0.0,
        'avatar': '',
      },
    ];

    final filtered = selectedFilter.value == '全部'
        ? mockData
        : mockData.where((c) => c['type'] == selectedFilter.value).toList();

    clientList.value = filtered;
    totalCount.value = filtered.length;
  }
}
