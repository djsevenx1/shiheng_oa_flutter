import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/auth_repository.dart';
import '../../../app/data/repository/dashboard_repository.dart';
import '../../../app/data/repository/workflow_repository.dart';
import '../../../app/routes/app_pages.dart';

class HomeController extends GetxController {
  final _authRepository = AuthRepository();
  final _dashboardRepository = DashboardRepository();
  final _workflowRepository = WorkflowRepository();

  final currentIndex = 0.obs;
  final isLoading = false.obs;

  // 数据
  final bulletins = <dynamic>[].obs;
  final newsList = <dynamic>[].obs;
  final memos = <dynamic>[].obs;
  final userList = <dynamic>[].obs;
  final events = <dynamic>[].obs;
  final todoList = <dynamic>[].obs;  // 待处理流程（首页用）
  final userInfo = <String, dynamic>{}.obs;

  // 页面控制器
  final pageController = PageController();

  @override
  void onInit() {
    super.onInit();
    loadUserInfo();
    loadDashboardData();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void loadUserInfo() {
    final info = _authRepository.getUserInfo();
    if (info != null && info.isNotEmpty) {
      userInfo.value = info;
    } else {
      // 兜底：从 login 时缓存的真实 user/current 读
      final name = _authRepository.getStorage().read('cachedUserName');
      final group = _authRepository.getStorage().read('cachedUserGroup');
      final id = _authRepository.getStorage().read('cachedUserId');
      final icon = _authRepository.getStorage().read('cachedUserIcon');
      userInfo.value = {
        if (name != null) 'name': name,
        if (group != null) 'groupName': group,
        if (id != null) 'id': id,
        if (icon != null) 'icon': icon,
      };
    }
    // 触发 /oa/user/current 异步刷新
    refreshUserInfo();
  }

  /// 异步从 /oa/user/current 拉取最新用户信息
  Future<void> refreshUserInfo() async {
    try {
      final response = await _authRepository.getApi().dioInstance.get('/oa/user/current');
      final data = response.data;
      if (data is Map) {
        final m = data.cast<String, dynamic>();
        userInfo.value = {
          'name': m['name']?.toString() ?? userInfo.value['name'] ?? '用户',
          'groupName': m['groupName']?.toString() ?? userInfo.value['groupName'] ?? '',
          'id': m['id']?.toString() ?? userInfo.value['id'] ?? '',
          'icon': m['icon']?.toString() ?? userInfo.value['icon'] ?? '',
        };
        // 顺便缓存到 storage
        final s = _authRepository.getStorage();
        if (m['name'] != null) s.write('cachedUserName', m['name'].toString());
        if (m['groupName'] != null) s.write('cachedUserGroup', m['groupName'].toString());
        if (m['icon'] != null) s.write('cachedUserIcon', m['icon'].toString());
        if (m['id'] != null) s.write('cachedUserId', m['id'].toString());
      }
    } catch (e) {
      // 静默失败——已有缓存就用缓存
    }
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      // 并行加载数据
      final results = await Future.wait([
        _dashboardRepository.getBulletins(),
        _dashboardRepository.getNews(),
        _dashboardRepository.getUserList(),
        _dashboardRepository.getEvents(),
      ]);

      if (results[0]['success'] == true) {
        bulletins.value = results[0]['data'] ?? [];
      }
      if (results[1]['success'] == true) {
        newsList.value = results[1]['data'] ?? [];
      }
      if (results[2]['success'] == true) {
        userList.value = results[2]['data'] ?? [];
      }
      if (results[3]['success'] == true) {
        events.value = results[3]['data'] ?? [];
      }
      // 加载待处理流程（首页"待处理"板块）
      final todoRes = await _workflowRepository.getWorkflowList(status: 'todo', limit: 5);
      if (todoRes['success'] == true) {
        todoList.value = todoRes['data'] ?? [];
      }
    } catch (e) {
      print('加载仪表盘数据失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// 仅刷新首页待处理流程列表（从流程详情返回后调用）
  Future<void> refreshTodo() async {
    final todoRes = await _workflowRepository.getWorkflowList(status: 'todo', limit: 5);
    if (todoRes['success'] == true) {
      todoList.value = todoRes['data'] ?? [];
    }
  }

  void changePage(int index) {
    currentIndex.value = index;
    pageController.jumpToPage(index);
  }

  void logout() async {
    Get.defaultDialog(
      title: '确认退出',
      middleText: '确定要退出登录吗？',
      textConfirm: '退出',
      textCancel: '取消',
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await _authRepository.logout();
        Get.offAllNamed(Routes.LOGIN);
      },
    );
  }

  String getEventTypeName(int type) {
    switch (type) {
      case 0:
        return '内部邮件';
      case 1:
        return '待办流程';
      case 2:
        return '历史流程';
      default:
        return '其他';
    }
  }

  Color getEventTypeColor(int type) {
    switch (type) {
      case 0:
        return Colors.blue;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String getStateName(int state) {
    switch (state) {
      case 0:
        return '未提交';
      case 1:
        return '审批中';
      case 2:
        return '已结束';
      case -1:
        return '被拒绝';
      case -2:
        return '被撤回';
      default:
        return '未知';
    }
  }

  Color getStateColor(int state) {
    switch (state) {
      case 0:
        return Colors.orange;
      case 1:
        return Colors.blue;
      case 2:
        return Colors.green;
      case -1:
      case -2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
