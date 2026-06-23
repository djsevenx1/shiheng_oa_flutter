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
        keyword: searchController.text,
        kind: _kind,
      );

      if (result['success'] == true) {
        if (currentPage.value == 1) {
          projectList.value = result['data'] ?? [];
        } else {
          projectList.addAll(result['data'] ?? []);
        }
        totalCount.value = result['count'] ?? 0;
      } else {
        _loadMockData();
      }
    } catch (e) {
      _loadMockData();
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

  void _loadMockData() {
    final mockData = [
      {
        'id': 1,
        'name': '智能控制器研发项目',
        'no': 'XM202401001',
        'status': '进行中',
        'progress': 65,
        'manager': '张经理',
        'members': '张经理,李工,王工,赵工,钱工',
        'startDate': '2024-01-01',
        'endDate': '2024-06-30',
        'budget': 850000.0,
        'customer': '华联科技',
        'kind': 'fzr',
      },
      {
        'id': 2,
        'name': '电子元件采购系统升级',
        'no': 'XM202401002',
        'status': '进行中',
        'progress': 40,
        'manager': '王主管',
        'members': '王主管,刘工,陈工',
        'startDate': '2024-02-01',
        'endDate': '2024-05-31',
        'budget': 320000.0,
        'customer': '内部',
        'kind': 'cyr',
      },
      {
        'id': 3,
        'name': '华南区销售网络拓展',
        'no': 'XM202401003',
        'status': '已完成',
        'progress': 100,
        'manager': '李总监',
        'members': '李总监,孙经理,周经理',
        'startDate': '2023-09-01',
        'endDate': '2023-12-31',
        'budget': 1200000.0,
        'customer': '外部',
        'kind': 'fzr',
      },
      {
        'id': 4,
        'name': '生产自动化改造',
        'no': 'XM202401004',
        'status': '进行中',
        'progress': 25,
        'manager': '陈总工',
        'members': '陈总工,吴工,郑工,冯工',
        'startDate': '2024-03-01',
        'endDate': '2024-12-31',
        'budget': 2500000.0,
        'customer': '内部',
        'kind': 'cyr',
      },
      {
        'id': 5,
        'name': '新品发布会策划',
        'no': 'XM202401005',
        'status': '未开始',
        'progress': 0,
        'manager': '赵经理',
        'members': '赵经理,钱经理,孙设计',
        'startDate': '2024-04-15',
        'endDate': '2024-05-20',
        'budget': 180000.0,
        'customer': '内部',
        'kind': 'cyr',
      },
    ];

    final filtered = _kind == 'all'
        ? mockData
        : mockData.where((p) => p['kind'] == _kind).toList();

    projectList.value = filtered;
    totalCount.value = filtered.length;
  }
}
