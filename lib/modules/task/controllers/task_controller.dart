import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/task_repository.dart';

class TaskController extends GetxController {
  final _repository = TaskRepository();

  final searchController = TextEditingController();
  final isLoading = false.obs;
  final taskList = <dynamic>[].obs;
  final totalCount = 0.obs;
  final selectedTab = 0.obs;

  // 统计数据（从接口获取，不再硬编码）
  final stats = <String, int>{'total': 0, 'todo': 0, 'doing': 0, 'done': 0}.obs;

  // 老 App 真实 tab 结构
  final List<Map<String, dynamic>> tabs = [
    {'key': 'JoinedOrCreated', 'label': '全部', 'statusKey': ''},
    {'key': 'JoinedOrCreated', 'label': '未开始', 'statusKey': '/Initialized'},
    {'key': 'JoinedOrCreated', 'label': '进行中', 'statusKey': '/InProgress'},
    {'key': 'JoinedOrCreated', 'label': '已完成', 'statusKey': '/Finished'},
  ];

  String get _tabKey => tabs[selectedTab.value]['key'] as String;
  String get _statusKey => tabs[selectedTab.value]['statusKey'] as String;

  @override
  void onInit() {
    super.onInit();
    loadTasks();
    loadStats();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> loadTasks({bool refresh = true}) async {
    isLoading.value = true;
    try {
      final result = await _repository.getTaskList(
        tabKey: _tabKey,
        statusKey: _statusKey,
        keyword: searchController.text.isEmpty ? null : searchController.text,
      );

      if (result['success'] == true) {
        taskList.value = result['data'] ?? [];
        totalCount.value = result['count'] ?? 0;
      } else {
        taskList.value = [];
        totalCount.value = 0;
      }
    } catch (e) {
      taskList.value = [];
      totalCount.value = 0;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadStats() async {
    final s = await _repository.getTaskStats();
    stats.value = s;
  }

  void changeTab(int index) {
    selectedTab.value = index;
    loadTasks();
  }

  void search() {
    loadTasks();
  }

  Future<void> toggleTaskStatus(dynamic task) async {
    final id = task['id'];
    if (id == null) return;
    // 老 App 用 approve 字段：0=审核中 1=已通过 2=未通过
    // 切换已完成/未完成
    final currentApprove = task['approve'];
    final newApprove = currentApprove == 1 ? 0 : 1;
    try {
      await _repository.updateTaskStatus(
        id is int ? id : int.tryParse(id.toString()) ?? 0,
        newApprove == 1 ? 'Finished' : 'InProgress',
      );
      task['approve'] = newApprove;
      taskList.refresh();
      loadStats();
    } catch (e) {
      task['approve'] = newApprove;
      taskList.refresh();
    }
  }
}
