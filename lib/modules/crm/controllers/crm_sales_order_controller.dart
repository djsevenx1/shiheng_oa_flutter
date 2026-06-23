import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/crm_business_repository.dart';

class CrmSalesOrderController extends GetxController {
  final _repository = CrmBusinessRepository();

  final searchController = TextEditingController();
  final isLoading = false.obs;
  final orderList = <dynamic>[].obs;
  final totalCount = 0.obs;
  final selectedStatus = '全部'.obs;

  final statuses = ['全部', '待审核', '已确认', '生产中', '已发货', '已完成', '已取消'];

  @override
  void onInit() {
    super.onInit();
    loadOrders();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadOrders() async {
    isLoading.value = true;
    try {
      final result = await _repository.getSalesOrderList(
        keyword: searchController.text,
      );

      if (result['success'] == true) {
        orderList.value = result['data'] ?? [];
        totalCount.value = result['count'] ?? 0;
      } else {
        _loadMock();
      }
    } catch (e) {
      _loadMock();
    } finally {
      isLoading.value = false;
    }
  }

  void changeStatus(String status) {
    selectedStatus.value = status;
    loadOrders();
  }

  void _loadMock() {
    final mock = [
      {
        'id': 1,
        'no': 'SO20240115001',
        'client': '华联科技股份有限公司',
        'product': '电子元件一批',
        'amount': 35800.0,
        'quantity': 500,
        'status': '已发货',
        'date': '2024-01-15',
        'delivery': '2024-01-25',
        'manager': '张经理',
      },
      {
        'id': 2,
        'no': 'SO20240114002',
        'client': '明华电子有限公司',
        'product': '控制器模块',
        'amount': 25600.0,
        'quantity': 100,
        'status': '生产中',
        'date': '2024-01-14',
        'delivery': '2024-01-30',
        'manager': '李总监',
      },
      {
        'id': 3,
        'no': 'SO20240113003',
        'client': '盛达科技有限公司',
        'product': '电源组件',
        'amount': 64400.0,
        'quantity': 800,
        'status': '已完成',
        'date': '2024-01-13',
        'delivery': '2024-01-20',
        'manager': '王主管',
      },
      {
        'id': 4,
        'no': 'SO20240112004',
        'client': '金辉半导体有限公司',
        'product': 'IC 芯片 1000pcs',
        'amount': 128000.0,
        'quantity': 1000,
        'status': '已确认',
        'date': '2024-01-12',
        'delivery': '2024-02-05',
        'manager': '陈经理',
      },
      {
        'id': 5,
        'no': 'SO20240111005',
        'client': '新源电子元件厂',
        'product': 'PCB 板',
        'amount': 18500.0,
        'quantity': 300,
        'status': '待审核',
        'date': '2024-01-11',
        'delivery': '2024-01-28',
        'manager': '张经理',
      },
    ];

    orderList.value = mock;
    totalCount.value = mock.length;
  }
}
