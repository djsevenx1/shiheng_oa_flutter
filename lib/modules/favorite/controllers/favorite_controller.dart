import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoriteController extends GetxController {
  final favoriteList = <dynamic>[].obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    // /* MOCK-DISABLED */;  // mock disabled
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _loadMock() {
    favoriteList.value = [
      {'id': 1, 'name': '请假申请流程', 'icon': Icons.beach_access, 'color': Colors.blue, 'route': '/workflow/form', 'category': '常用流程'},
      {'id': 2, 'name': '报销申请流程', 'icon': Icons.receipt_long, 'color': Colors.green, 'route': '/workflow/form', 'category': '常用流程'},
      {'id': 3, 'name': '库存报表', 'icon': Icons.inventory_2, 'color': Colors.orange, 'route': '/report/stock', 'category': '常用报表'},
      {'id': 4, 'name': 'CRM 客户管理', 'icon': Icons.people, 'color': Colors.purple, 'route': '/crm', 'category': '业务模块'},
      {'id': 5, 'name': '考勤签到', 'icon': Icons.location_on, 'color': Colors.teal, 'route': '/attendance', 'category': '日常工具'},
      {'id': 6, 'name': '项目管理', 'icon': Icons.folder_copy, 'color': Colors.indigo, 'route': '/project', 'category': '业务模块'},
      {'id': 7, 'name': '时恒专属报表', 'icon': Icons.analytics, 'color': Colors.pink, 'route': '/sh_report', 'category': '常用报表'},
      {'id': 8, 'name': '任务管理', 'icon': Icons.task_alt, 'color': Colors.cyan, 'route': '/task', 'category': '业务模块'},
    ];
  }

  void removeFavorite(int id) {
    favoriteList.removeWhere((f) => f['id'] == id);
  }
}
