import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/report_repository.dart';

class StockReportController extends GetxController {
  final _repository = ReportRepository();

  final searchController = TextEditingController();
  final isLoading = false.obs;
  final stockList = <dynamic>[].obs;
  final currentPage = 1.obs;
  final totalCount = 0.obs;
  final selectedFilters = <String>[].obs;

  int get totalPages => (totalCount.value / 15).ceil();
  bool get hasPreviousPage => currentPage.value > 1;
  bool get hasNextPage => currentPage.value < totalPages;

  @override
  void onInit() {
    super.onInit();
    loadStockData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadStockData() async {
    isLoading.value = true;
    try {
      final result = await _repository.getStockReport(
        type: 1,
        page: currentPage.value,
        searchData: _buildSearchData(),
      );

      if (result['success'] == true) {
        stockList.value = result['data'] ?? [];
        totalCount.value = result['count'] ?? 0;
      }
    } catch (e) {
      print('加载库存数据失败: $e');
      // 加载模拟数据用于演示
      // /* MOCK-DISABLED */;  // mock disabled
    } finally {
      isLoading.value = false;
    }
  }

  Map<String, dynamic> _buildSearchData() {
    return {
      'AA': searchController.text,
      'AC': '',
      'AD': '',
      'AE': '',
      'AF': '',
    };
  }

  void search() {
    currentPage.value = 1;
    loadStockData();
  }

  void previousPage() {
    if (hasPreviousPage) {
      currentPage.value--;
      loadStockData();
    }
  }

  void nextPage() {
    if (hasNextPage) {
      currentPage.value++;
      loadStockData();
    }
  }

  void toggleFilter(String filter) {
    if (selectedFilters.contains(filter)) {
      selectedFilters.remove(filter);
    } else {
      selectedFilters.add(filter);
    }
  }

  void applyFilter() {
    currentPage.value = 1;
    loadStockData();
  }

  void _loadMockData() {
    stockList.value = [
      {'code': 'MAT001', 'name': '电阻 10KΩ 1%', 'spec': '0603', 'qty': 5000, 'amount': 250},
      {'code': 'MAT002', 'name': '电容 100nF', 'spec': '0805', 'qty': 3200, 'amount': 320},
      {'code': 'MAT003', 'name': 'IC STM32F103', 'spec': 'LQFP48', 'qty': 500, 'amount': 12500},
      {'code': 'MAT004', 'name': '二极管 1N4148', 'spec': 'DO-35', 'qty': 8000, 'amount': 400},
      {'code': 'MAT005', 'name': 'LED 红色', 'spec': '3mm', 'qty': 2000, 'amount': 200},
      {'code': 'MAT006', 'name': '连接器 2.54mm', 'spec': '10P', 'qty': 1500, 'amount': 750},
      {'code': 'MAT007', 'name': '晶振 8MHz', 'spec': 'HC-49S', 'qty': 300, 'amount': 600},
      {'code': 'MAT008', 'name': '电感 10uH', 'spec': 'SMD', 'qty': 1200, 'amount': 360},
    ];
    totalCount.value = 1256;
  }
}
