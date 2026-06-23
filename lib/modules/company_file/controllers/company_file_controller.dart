import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/archive_repository.dart';

class CompanyFileController extends GetxController {
  final _repository = ArchiveRepository();

  final searchController = TextEditingController();
  final isLoading = false.obs;
  final fileList = <dynamic>[].obs;
  final totalCount = 0.obs;
  final selectedCategory = '全部'.obs;

  final categories = ['全部', '公司制度', '产品资料', '培训文档', '常用表格', '共享资源'];

  @override
  void onInit() {
    super.onInit();
    loadFiles();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadFiles() async {
    isLoading.value = true;
    try {
      final category = selectedCategory.value == '全部' ? '' : selectedCategory.value;
      final result = await _repository.getCompanyFiles(category: category);
      if (result['success'] == true) {
        fileList.value = result['data'] ?? [];
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
    loadFiles();
  }

  void _loadMock() {
    final mock = [
      {'id': 1, 'name': '员工手册2024版.pdf', 'category': '公司制度', 'size': '2.5 MB', 'date': '2024-01-15', 'downloads': 156, 'type': 'pdf'},
      {'id': 2, 'name': '产品白皮书.docx', 'category': '产品资料', 'size': '1.8 MB', 'date': '2024-01-10', 'downloads': 89, 'type': 'doc'},
      {'id': 3, 'name': '新员工培训资料.pptx', 'category': '培训文档', 'size': '8.5 MB', 'date': '2024-01-08', 'downloads': 234, 'type': 'ppt'},
      {'id': 4, 'name': '请假申请单.xlsx', 'category': '常用表格', 'size': '128 KB', 'date': '2024-01-05', 'downloads': 567, 'type': 'xls'},
      {'id': 5, 'name': '公司组织架构图.png', 'category': '公司制度', 'size': '512 KB', 'date': '2024-01-03', 'downloads': 312, 'type': 'img'},
      {'id': 6, 'name': '销售工具包.zip', 'category': '共享资源', 'size': '15.2 MB', 'date': '2024-01-01', 'downloads': 78, 'type': 'zip'},
    ];
    final filtered = selectedCategory.value == '全部' ? mock : mock.where((f) => f['category'] == selectedCategory.value).toList();
    fileList.value = filtered;
    totalCount.value = filtered.length;
  }
}
