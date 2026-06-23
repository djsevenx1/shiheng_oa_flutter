import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/data/repository/contacts_repository.dart';

class ContactsController extends GetxController {
  final ContactsRepository _repo = ContactsRepository();

  final departments = <Map<String, dynamic>>[].obs;
  final members = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final selectedDeptId = RxnString();
  final selectedDeptName = ''.obs;
  final searchKeyword = ''.obs;
  final searchResults = <Map<String, dynamic>>[].obs;
  final isSearching = false.obs;
  final expandedDeptIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadDepartments();
  }

  Future<void> loadDepartments() async {
    isLoading.value = true;
    // 优先用缓存
    final cached = _repo.getCachedDepartments();
    if (cached != null && cached.isNotEmpty) {
      departments.value = cached.cast<Map<String, dynamic>>();
    }
    final result = await _repo.getDepartmentTree();
    isLoading.value = false;
    if (result['success'] == true) {
      final data = (result['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      departments.value = data;
      _repo.cacheDepartments(data);
    }
  }

  Future<void> selectDepartment(String id, String name) async {
    selectedDeptId.value = id;
    selectedDeptName.value = name;
    isLoading.value = true;
    final result = await _repo.getDepartmentMembers(id, keyword: searchKeyword.value);
    isLoading.value = false;
    if (result['success'] == true) {
      members.value = (result['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    }
  }

  void toggleDeptExpansion(String id) {
    if (expandedDeptIds.contains(id)) {
      expandedDeptIds.remove(id);
    } else {
      expandedDeptIds.add(id);
    }
  }

  Future<void> search(String keyword) async {
    searchKeyword.value = keyword;
    if (keyword.trim().isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }
    isSearching.value = true;
    final result = await _repo.searchMembers(keyword.trim());
    isSearching.value = false;
    if (result['success'] == true) {
      searchResults.value = (result['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    }
  }

  void clearSearch() {
    searchKeyword.value = '';
    searchResults.clear();
    isSearching.value = false;
  }

  void callMember(Map<String, dynamic> m) {
    final phone = m['phone']?.toString() ?? m['mobile']?.toString() ?? '';
    if (phone.isEmpty) {
      Get.snackbar('提示', '该成员没有电话', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    Get.snackbar('拨号', phone, snackPosition: SnackPosition.BOTTOM);
  }
}
