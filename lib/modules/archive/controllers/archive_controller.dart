import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/archive_repository.dart';

class ArchiveController extends GetxController {
  final _repository = ArchiveRepository();

  final searchController = TextEditingController();
  final isLoading = false.obs;
  final archiveList = <dynamic>[].obs;
  final totalCount = 0.obs;
  final selectedCategory = '全部'.obs;

  final categories = ['全部', '合同档案', '人事档案', '财务档案', '项目档案', '客户档案'];

  @override
  void onInit() {
    super.onInit();
    loadArchives();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadArchives() async {
    isLoading.value = true;
    try {
      final category = selectedCategory.value == '全部' ? '' : selectedCategory.value;
      final result = await _repository.getArchiveList(category: category);
      if (result['success'] == true) {
        archiveList.value = result['data'] ?? [];
        totalCount.value = result['count'] ?? 0;
      } else {
        // /* MOCK-DISABLED */;  // mock disabled
      }
    } catch (e) {
      // /* MOCK-DISABLED */;  // mock disabled
    } finally {
      isLoading.value = false;
    }
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
    loadArchives();
  }

  void _loadMock() {
    final mock = [
      {'id': 1, 'name': '华联科技采购合同', 'no': 'HT202401001', 'category': '合同档案', 'date': '2024-01-15', 'creator': '张经理', 'size': '256 KB', 'type': 'pdf'},
      {'id': 2, 'name': '李四 入职档案', 'no': 'RS202401005', 'category': '人事档案', 'date': '2024-01-10', 'creator': '王主管', 'size': '1.2 MB', 'type': 'doc'},
      {'id': 3, 'name': '2024年财务预算表', 'no': 'CW202401001', 'category': '财务档案', 'date': '2024-01-05', 'creator': '陈会计', 'size': '892 KB', 'type': 'xls'},
      {'id': 4, 'name': '智能控制器项目档案', 'no': 'XM202401001', 'category': '项目档案', 'date': '2024-01-12', 'creator': '张经理', 'size': '4.5 MB', 'type': 'folder'},
      {'id': 5, 'name': '盛达科技合作协议', 'no': 'HT202401002', 'category': '合同档案', 'date': '2024-01-08', 'creator': '李总监', 'size': '128 KB', 'type': 'pdf'},
      {'id': 6, 'name': '客户资料汇总', 'no': 'KH202401001', 'category': '客户档案', 'date': '2024-01-03', 'creator': '王主管', 'size': '3.2 MB', 'type': 'folder'},
    ];
    final filtered = selectedCategory.value == '全部' ? mock : mock.where((a) => a['category'] == selectedCategory.value).toList();
    archiveList.value = filtered;
    totalCount.value = filtered.length;
  }
}
