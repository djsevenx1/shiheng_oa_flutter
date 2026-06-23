import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/task_repository.dart';

class TaskController extends GetxController {
  final _repository = TaskRepository();

  final searchController = TextEditingController();
  final isLoading = false.obs;
  final taskList = <dynamic>[].obs;
  final totalCount = 0.obs;
  final selectedTab = 0.obs; // 0: all, 1: todo, 2: doing, 3: done

  final List<Map<String, String>> tabs = [
    {'key': 'all', 'label': '全部', 'icon': 'list_alt'},
    {'key': 'todo', 'label': '待办', 'icon': 'pending_actions'},
    {'key': 'doing', 'label': '进行中', 'icon': 'autorenew'},
    {'key': 'done', 'label': '已完成', 'icon': 'check_circle_outline'},
  ];

  String get _status {
    return tabs[selectedTab.value]['key']!;
  }

  @override
  void onInit() {
    super.onInit();
    loadTasks();
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
        keyword: searchController.text,
        status: _status,
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

  void changeTab(int index) {
    selectedTab.value = index;
    loadTasks();
  }

  void search() {
    loadTasks();
  }

  Future<void> toggleTaskStatus(dynamic task) async {
    final currentStatus = task['status'];
    final newStatus = currentStatus == 'done' ? 'todo' : 'done';
    try {
      await _repository.updateTaskStatus(task['id'], newStatus);
      task['status'] = newStatus;
      taskList.refresh();
    } catch (e) {
      task['status'] = newStatus;
      taskList.refresh();
    }
  }

  void _loadMockData() {
    final mockData = [
      {
        'id': 1,
        'title': '完成控制器硬件测试',
        'description': '对新一批控制器进行硬件测试并记录结果',
        'status': 'doing',
        'priority': 'high',
        'assignee': '张工',
        'creator': '张经理',
        'dueDate': '2024-01-20',
        'createdDate': '2024-01-15',
        'progress': 60,
      },
      {
        'id': 2,
        'title': '编写技术文档',
        'description': '整理项目技术方案并编写为正式文档',
        'status': 'todo',
        'priority': 'medium',
        'assignee': '我',
        'creator': '李总监',
        'dueDate': '2024-01-25',
        'createdDate': '2024-01-14',
        'progress': 0,
      },
      {
        'id': 3,
        'title': '采购申请审批',
        'description': '提交5万元电子元件采购申请',
        'status': 'todo',
        'priority': 'low',
        'assignee': '我',
        'creator': '我',
        'dueDate': '2024-01-18',
        'createdDate': '2024-01-16',
        'progress': 0,
      },
      {
        'id': 4,
        'title': '客户回访',
        'description': '回访华联科技对产品的反馈',
        'status': 'done',
        'priority': 'medium',
        'assignee': '王主管',
        'creator': '王主管',
        'dueDate': '2024-01-10',
        'createdDate': '2024-01-05',
        'progress': 100,
      },
      {
        'id': 5,
        'title': '生产数据周报',
        'description': '汇总本周生产数据并提交周报',
        'status': 'doing',
        'priority': 'high',
        'assignee': '我',
        'creator': '陈总',
        'dueDate': '2024-01-22',
        'createdDate': '2024-01-15',
        'progress': 40,
      },
    ];

    final filtered = _status == 'all'
        ? mockData
        : mockData.where((t) => t['status'] == _status).toList();

    taskList.value = filtered;
    totalCount.value = filtered.length;
  }
}
