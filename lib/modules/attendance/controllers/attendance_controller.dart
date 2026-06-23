import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/data/repository/attendance_repository.dart';
import '../../../app/data/services/location_service.dart';
import '../../../app/themes/app_theme.dart';

class AttendanceController extends GetxController {
  final _repository = AttendanceRepository();
  final _location = LocationService();

  final isLoading = false.obs;
  final isLocating = false.obs;
  final todayStatus = <String, dynamic>{}.obs;
  final monthStats = <String, dynamic>{}.obs;
  final attendanceList = <dynamic>[].obs;
  final selectedMonth = DateTime.now().month.obs;
  final currentAddress = ''.obs;
  final currentLat = 0.0.obs;
  final currentLng = 0.0.obs;
  final hasCheckedIn = false.obs;
  final hasCheckedOut = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  @override
  void onReady() {
    super.onReady();
    _refreshLocation();
  }

  Future<void> _refreshLocation() async {
    isLocating.value = true;
    try {
      final loc = await _location.getCurrentLocation();
      currentAddress.value = loc['address']?.toString() ?? '';
      currentLat.value = (loc['latitude'] as num?)?.toDouble() ?? 0.0;
      currentLng.value = (loc['longitude'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      debugPrint('定位失败: $e');
      currentAddress.value = '定位失败,请检查权限';
    }
    isLocating.value = false;
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    errorMessage.value = null;
    final results = await Future.wait([
      _repository.getTodayStatus(),
      _repository.getMonthStats(selectedMonth.value),
      _repository.getAttendanceList(month: selectedMonth.value),
    ]);

    if (results[0]['success'] == true) {
      todayStatus.value = (results[0]['data'] is Map)
          ? Map<String, dynamic>.from(results[0]['data'] as Map)
          : <String, dynamic>{};
      hasCheckedIn.value = todayStatus.value['checkIn'] != null ||
          todayStatus.value['type'] != null;
      hasCheckedOut.value = todayStatus.value['checkOut'] != null;
    }
    if (results[1]['success'] == true) {
      monthStats.value = (results[1]['data'] is Map)
          ? Map<String, dynamic>.from(results[1]['data'] as Map)
          : <String, dynamic>{};
    }
    if (results[2]['success'] == true) {
      attendanceList.value = (results[2]['data'] as List?) ?? [];
    }
    if (results.every((r) => r['success'] != true)) {
      errorMessage.value = '考勤接口未实现或不可用';
    }
    isLoading.value = false;
  }

  Future<void> checkIn() async {
    await _refreshLocation();
    isLoading.value = true;
    final result = await _repository.checkIn(
      location: currentAddress.value,
      address: currentAddress.value,
      lat: currentLat.value,
      lng: currentLng.value,
    );
    isLoading.value = false;
    if (result['success'] == true) {
      hasCheckedIn.value = true;
      Get.snackbar('签到成功', '今日已签到', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.success, colorText: Colors.white);
      await _loadData();
    } else {
      Get.snackbar('签到失败', result['message']?.toString() ?? '请稍后再试', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> checkOut() async {
    await _refreshLocation();
    isLoading.value = true;
    final result = await _repository.checkOut(
      location: currentAddress.value,
      address: currentAddress.value,
      lat: currentLat.value,
      lng: currentLng.value,
    );
    isLoading.value = false;
    if (result['success'] == true) {
      hasCheckedOut.value = true;
      Get.snackbar('签退成功', '今日已签退', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.success, colorText: Colors.white);
      await _loadData();
    } else {
      Get.snackbar('签退失败', result['message']?.toString() ?? '请稍后再试', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void changeMonth(int month) {
    selectedMonth.value = month;
    _loadData();
  }

  String getWeekday(int weekday) {
    const list = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return list[weekday - 1];
  }

  Color getStatusColor(String status) {
    switch (status) {
      case '正常': return AppTheme.success;
      case '迟到': return AppTheme.warning;
      case '早退': return AppTheme.warning;
      case '请假': return AppTheme.info;
      case '旷工': return AppTheme.danger;
      default: return AppTheme.gray500;
    }
  }
}
