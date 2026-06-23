import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';

class MapController extends GetxController {
  final searchController = TextEditingController();
  final currentAddress = '定位中...'.obs;
  final latitude = 0.0.obs;
  final longitude = 0.0.obs;
  final markers = <Map<String, dynamic>>[].obs;
  final isMapReady = false.obs;

  // 模拟定位数据（时恒电子位置）
  final mockLat = 24.4798;
  final mockLng = 118.0894;

  @override
  void onInit() {
    super.onInit();
    _initMockData();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _initMockData() {
    latitude.value = mockLat;
    longitude.value = mockLng;
    currentAddress.value = '江苏省南京市';
    isMapReady.value = true;

    markers.value = [
      {
        'id': 'company',
        'title': '时恒电子',
        'address': '江苏省南京市',
        'lat': mockLat,
        'lng': mockLng,
        'type': 'company',
      },
      {
        'id': 'warehouse1',
        'title': '原材料仓库',
        'address': '江苏省南京市',
        'lat': 24.4850,
        'lng': 118.0950,
        'type': 'warehouse',
      },
      {
        'id': 'warehouse2',
        'title': '成品仓库',
        'address': '江苏省南京市',
        'lat': 24.5650,
        'lng': 118.1050,
        'type': 'warehouse',
      },
      {
        'id': 'client1',
        'title': '客户A - 华联科技',
        'address': '江苏省南京市',
        'lat': 24.4900,
        'lng': 118.1100,
        'type': 'client',
      },
    ];
  }

  void searchLocation(String query) {
    if (query.trim().isEmpty) return;
    // TODO: 调用高德地图搜索 API
    Get.snackbar('搜索', '正在搜索: $query', snackPosition: SnackPosition.BOTTOM);
  }

  void selectMarker(dynamic marker) {
    Get.defaultDialog(
      title: marker['title'],
      middleText: '${marker['address']}\n坐标: ${marker['lat']}, ${marker['lng']}',
      textConfirm: '导航',
      textCancel: '关闭',
      onConfirm: () {
        Get.back();
        Get.snackbar('导航', '正在启动导航...', snackPosition: SnackPosition.BOTTOM);
      },
    );
  }

  void locateMe() {
    // TODO: 调用高德定位
    Get.snackbar('定位', '正在获取当前位置...', snackPosition: SnackPosition.BOTTOM);
  }

  String getMarkerTypeLabel(String type) {
    switch (type) {
      case 'company': return '公司';
      case 'warehouse': return '仓库';
      case 'client': return '客户';
      default: return '其他';
    }
  }

  Color getMarkerTypeColor(String type) {
    switch (type) {
      case 'company': return AppTheme.primaryColor;
      case 'warehouse': return AppTheme.warning;
      case 'client': return AppTheme.info;
      default: return AppTheme.gray500;
    }
  }
}
