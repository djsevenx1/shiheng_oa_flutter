import 'package:get/get.dart';
import '../../../app/data/repository/my_application_repository.dart';

class WorkflowController extends GetxController {
  final isLoading = false.obs;
  final todoList = <Map<String, dynamic>>[].obs;        // 待处理（preHandle）
  final historyList = <Map<String, dynamic>>[].obs;     // 历史流程（全部）
  final selectedTab = 0.obs;                            // 0=待处理 1=历史流程

  final _repo = MyApplicationRepository();

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  void changeTab(int idx) {
    selectedTab.value = idx;
    switch (idx) {
      case 0:
        if (todoList.isEmpty) loadTodo();
        break;
      case 1:
        if (historyList.isEmpty) loadHistory();
        break;
    }
  }

  Future<void> loadAll() async {
    await Future.wait([loadTodo(), loadHistory()]);
  }

  Future<void> loadTodo() async {
    isLoading.value = true;
    try {
      final res = await _repo.getTodo(limit: 20);
      if (res['success'] == true && res['data'] is List) {
        todoList.assignAll((res['data'] as List).cast<Map<String, dynamic>>());
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadHistory() async {
    isLoading.value = true;
    try {
      final res = await _repo.getHistory(limit: 20);
      if (res['success'] == true && res['data'] is List) {
        historyList.assignAll((res['data'] as List).cast<Map<String, dynamic>>());
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    switch (selectedTab.value) {
      case 0:
        await loadTodo();
        break;
      case 1:
        await loadHistory();
        break;
    }
  }
}
