import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

import '../../../app/data/repository/contacts_repository.dart';

class ContactsController extends GetxController {
  final ContactsRepository _repo = ContactsRepository();

  /// 部门拍平列表 [{id, name, depth, parentId}]
  final departments = <Map<String, dynamic>>[].obs;
  /// 部门树原始数据
  final departmentTree = <dynamic>[].obs;

  /// 全员缓存（用于"按部门筛选"）
  final allMembers = <Map<String, dynamic>>[].obs;
  /// 当前展示的成员
  final members = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  final selectedDeptId = RxnString();
  final selectedDeptName = ''.obs;
  final searchKeyword = ''.obs;
  final searchResults = <Map<String, dynamic>>[].obs;
  final isSearching = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDepartments();
    loadAllMembers();
  }

  Future<void> loadDepartments() async {
    isLoading.value = true;
    errorMessage.value = null;
    // 优先用缓存
    final cached = _repo.getCachedDepartments();
    if (cached != null && cached.isNotEmpty) {
      departments.value = cached.cast<Map<String, dynamic>>();
    }
    final result = await _repo.getDepartmentTree();
    if (result['success'] == true) {
      final flat = (result['flat'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final tree = (result['data'] as List?) ?? [];
      departments.value = flat;
      departmentTree.value = tree;
      _repo.cacheDepartments(flat);
      errorMessage.value = null;
    } else {
      errorMessage.value = result['message']?.toString();
    }
    isLoading.value = false;
  }

  /// 加载全员到 members（默认视图）
  Future<void> loadAllMembers() async {
    final result = await _repo.getAllMembers(limit: 200);
    if (result['success'] == true) {
      allMembers.value = (result['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      // 默认视图：显示全部
      members.value = allMembers.toList();
    }
  }

  void selectDepartment(String id, String name) {
    selectedDeptId.value = id;
    selectedDeptName.value = name;
    // 客户端按 groupId 过滤全员
    final filtered = allMembers.where((m) {
      final gid = m['groupId']?.toString() ?? m['deptId']?.toString() ?? m['group']?.toString();
      return gid == id;
    }).toList();
    members.value = filtered;
  }

  /// 选"全部" — 显示全员
  void selectAllDepartment() {
    selectedDeptId.value = null;
    selectedDeptName.value = '全部';
    members.value = allMembers.toList();
  }

  Timer? _searchDebounce;
  Future<void> search(String keyword) async {
    searchKeyword.value = keyword;
    _searchDebounce?.cancel();
    if (keyword.trim().isEmpty) {
      searchResults.clear();
      isSearching.value = false;
      return;
    }
    isSearching.value = true;
    // 后端不支持 humanSearch 参数（被忽略），改为本地过滤 allMembers
    _searchDebounce = Timer(const Duration(milliseconds: 200), () {
      final kw = keyword.trim().toLowerCase();
      final filtered = allMembers.where((m) {
        final name = (m['name']?.toString() ?? '').toLowerCase();
        final loginName = (m['login_name']?.toString() ?? '').toLowerCase();
        final mobile = (m['mobile']?.toString() ?? '').toLowerCase();
        final userGroup = (m['userGroup']?.toString() ?? '').toLowerCase();
        final userRole = (m['userRole']?.toString() ?? '').toLowerCase();
        return name.contains(kw) ||
            loginName.contains(kw) ||
            mobile.contains(kw) ||
            userGroup.contains(kw) ||
            userRole.contains(kw);
      }).toList();
      searchResults.value = filtered;
      isSearching.value = false;
    });
  }

  @override
  void onClose() {
    _searchDebounce?.cancel();
    super.onClose();
  }

  void clearSearch() {
    _searchDebounce?.cancel();
    searchKeyword.value = '';
    searchResults.clear();
    isSearching.value = false;
  }

  void callMember(Map<String, dynamic> m) async {
    final phone = m['mobile']?.toString() ?? m['phone']?.toString() ?? m['tel']?.toString() ?? '';
    if (phone.isEmpty) {
      Get.snackbar('提示', '该成员没有电话', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    // 过滤掉非数字字符,保留 + 和数字
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri(scheme: 'tel', path: cleaned);
    try {
      final canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        Get.snackbar('提示', '当前设备无法拨号', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      Get.snackbar('拨号失败', '$e', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
