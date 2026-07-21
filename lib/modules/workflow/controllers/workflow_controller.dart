import 'package:get/get.dart';
import '../../../app/data/repository/my_application_repository.dart';

class WorkflowController extends GetxController {
  final isLoading = false.obs;
  final todoList = <Map<String, dynamic>>[].obs;        // 待处理（preHandle）
  final historyList = <Map<String, dynamic>>[].obs;     // 历史流程（全部）
  final selectedTab = 0.obs;                            // 0=待处理 1=历史流程
  final modsMap = <int, String>{}.obs;                  // modId → moduleName（列表标题用）

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
    await Future.wait([loadTodo(), loadHistory(), _loadModules()]);
  }

  /// 获取模块列表（用于列表标题显示，老 App 调 /oa/handle/initMods）
  Future<void> _loadModules() async {
    final res = await _repo.getModules();
    if (res['success'] == true && res['data'] is Map) {
      modsMap.assignAll((res['data'] as Map).cast<int, String>());
    }
  }

  /// 根据 modId 获取模块名（列表标题）
  String getModuleName(dynamic modId) {
    final id = modId is int ? modId : int.tryParse(modId?.toString() ?? '') ?? 0;
    return modsMap[id] ?? '';
  }

  Future<void> loadTodo() async {
    isLoading.value = true;
    try {
      if (modsMap.isEmpty) await _loadModules();
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
      if (modsMap.isEmpty) await _loadModules();
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
