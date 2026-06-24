import 'package:get/get.dart';
import '../../../app/data/repository/my_application_repository.dart';

class WorkflowController extends GetxController {
  final isLoading = false.obs;
  final todoList = <Map<String, dynamic>>[].obs;        // 待办
  final runningList = <Map<String, dynamic>>[].obs;     // 进行中
  final doneList = <Map<String, dynamic>>[].obs;        // 已完成
  final selectedTab = 0.obs;                            // 0=待办 1=进行中 2=已完成

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
        if (runningList.isEmpty) loadRunning();
        break;
      case 2:
        if (doneList.isEmpty) loadDone();
        break;
    }
  }

  Future<void> loadAll() async {
    await Future.wait([loadTodo(), loadRunning(), loadDone()]);
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

  Future<void> loadRunning() async {
    isLoading.value = true;
    try {
      final res = await _repo.getMyRunning(limit: 20);
      if (res['success'] == true && res['data'] is List) {
        runningList.assignAll((res['data'] as List).cast<Map<String, dynamic>>());
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDone() async {
    isLoading.value = true;
    try {
      final res = await _repo.getDone(limit: 20);
      if (res['success'] == true && res['data'] is List) {
        doneList.assignAll((res['data'] as List).cast<Map<String, dynamic>>());
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
        await loadRunning();
        break;
      case 2:
        await loadDone();
        break;
    }
  }
}
