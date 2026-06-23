import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/auth_repository.dart';
import '../../../app/data/repository/dashboard_repository.dart';
import '../../../app/routes/app_pages.dart';

class HomeController extends GetxController {
  final _authRepository = AuthRepository();
  final _dashboardRepository = DashboardRepository();

  final currentIndex = 0.obs;
  final isLoading = false.obs;

  // 数据
  final bulletins = <dynamic>[].obs;
  final newsList = <dynamic>[].obs;
  final memos = <dynamic>[].obs;
  final userList = <dynamic>[].obs;
  final events = <dynamic>[].obs;
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
    if (info != null) {
      userInfo.value = info;
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
    } catch (e) {
      print('加载仪表盘数据失败: $e');
    } finally {
      isLoading.value = false;
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
