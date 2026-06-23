import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/project_repository.dart';

class ProjectController extends GetxController {
  final _repository = ProjectRepository();

  final searchController = TextEditingController();
  final isLoading = false.obs;
  final projectList = <dynamic>[].obs;
  final totalCount = 0.obs;
  final currentPage = 1.obs;
  final selectedTab = 0.obs; // 0: all, 1: fzr, 2: cyr

  final tabs = ['全部', '我负责', '我参与'];

  String get _kind {
    switch (selectedTab.value) {
      case 1: return 'fzr';
      case 2: return 'cyr';
      default: return 'all';
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadProjects();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadProjects({bool refresh = true}) async {
    if (refresh) {
      currentPage.value = 1;
      projectList.clear();
    }
    isLoading.value = true;
    try {
      final result = await _repository.getProjectList(
        page: currentPage.value,
        pageSize: 50,
      );

      if (result['success'] == true) {
        if (currentPage.value == 1) {
          projectList.value = result['data'] ?? [];
        } else {
          projectList.addAll(result['data'] ?? []);
        }
        totalCount.value = result['count'] ?? 0;
      } else {
        projectList.value = [];
        totalCount.value = 0;
      }
    } catch (e) {
      projectList.value = [];
      totalCount.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  void changeTab(int index) {
    selectedTab.value = index;
    loadProjects();
  }

  void search() {
    loadProjects();
  }
}
