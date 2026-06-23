import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/attendance_repository.dart';
import '../../../app/themes/app_theme.dart';

class AttendanceController extends GetxController {
  final _repository = AttendanceRepository();

  final isLoading = false.obs;
  final todayStatus = <String, dynamic>{}.obs;
  final monthStats = <String, dynamic>{}.obs;
  final attendanceList = <dynamic>[].obs;
  final selectedMonth = DateTime.now().month.obs;
  final currentLocation = '定位中...'.obs;
  final currentAddress = ''.obs;
  final hasCheckedIn = false.obs;
  final hasCheckedOut = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repository.getTodayStatus(),
        _repository.getMonthStats(selectedMonth.value),
        _repository.getAttendanceList(month: selectedMonth.value),
      ]);

      if (results[0]['success'] == true) {
        todayStatus.value = results[0]['data'] ?? {};
        hasCheckedIn.value = results[0]['data']?['checkIn'] != null;
        hasCheckedOut.value = results[0]['data']?['checkOut'] != null;
      } else {
        _loadMockToday();
      }
      if (results[1]['success'] == true) {
        monthStats.value = results[1]['data'] ?? {};
      } else {
        _loadMockStats();
      }
      if (results[2]['success'] == true) {
        attendanceList.value = results[2]['data'] ?? [];
      } else {
        _loadMockList();
      }
    } catch (e) {
      _loadMockToday();
      _loadMockStats();
      _loadMockList();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkIn() async {
    isLoading.value = true;
    try {
      final result = await _repository.checkIn(
        location: currentLocation.value,
        address: currentAddress.value,
        lat: 24.4798,
        lng: 118.0894,
      );
      if (result['success'] == true) {
        hasCheckedIn.value = true;
        todayStatus.value = result['data'] ?? {};
        Get.snackbar('签到成功', '今日已签到', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.success, colorText: Colors.white);
        await _loadData();
      }
    } catch (e) {
      // 本地模拟
      hasCheckedIn.value = true;
      todayStatus.value = {
        'checkIn': DateTime.now().toString().substring(0, 19),
        'checkInAddress': '福建省厦门市思明区软件园二期',
      };
      Get.snackbar('签到成功', '今日已签到', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.success, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> checkOut() async {
    isLoading.value = true;
    try {
      final result = await _repository.checkOut(
        location: currentLocation.value,
        address: currentAddress.value,
        lat: 24.4798,
        lng: 118.0894,
      );
      if (result['success'] == true) {
        hasCheckedOut.value = true;
        todayStatus.value = result['data'] ?? {};
        Get.snackbar('签退成功', '今日已签退', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.success, colorText: Colors.white);
        await _loadData();
      }
    } catch (e) {
      hasCheckedOut.value = true;
      final newMap = Map<String, dynamic>.from(todayStatus);
      newMap['checkOut'] = DateTime.now().toString().substring(0, 19);
      todayStatus.value = newMap;
      Get.snackbar('签退成功', '今日已签退', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.success, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void changeMonth(int month) {
    selectedMonth.value = month;
    _loadData();
  }

  void _loadMockToday() {
    todayStatus.value = {
      'date': DateTime.now().toString().substring(0, 10),
      'checkIn': '08:55:32',
      'checkInAddress': '福建省厦门市思明区软件园二期',
      'checkOut': null,
      'status': '正常',
    };
    hasCheckedIn.value = true;
  }

  void _loadMockStats() {
    monthStats.value = {
      'workDays': 22,
      'actualDays': 21,
      'lateCount': 1,
      'earlyCount': 0,
      'absentCount': 0,
      'leaveCount': 0,
      'totalHours': '168',
    };
  }

  void _loadMockList() {
    final now = DateTime.now();
    attendanceList.value = List.generate(15, (i) {
      final date = now.subtract(Duration(days: i));
      final checkInHour = 8 + (i % 3);
      final checkInMin = (30 + (i * 5) % 30);
      final checkOutHour = 17 + (i % 2);
      final checkOutMin = (45 + (i * 3) % 15);
      return {
        'date': date.toString().substring(0, 10),
        'weekday': _getWeekday(date.weekday),
        'checkIn': '${checkInHour.toString().padLeft(2, '0')}:${checkInMin.toString().padLeft(2, '0')}',
        'checkOut': '${checkOutHour.toString().padLeft(2, '0')}:${checkOutMin.toString().padLeft(2, '0')}',
        'status': i == 3 ? '迟到' : (i == 7 ? '请假' : '正常'),
        'hours': 8.0 + (i % 3) * 0.5,
      };
    });
  }

  String _getWeekday(int weekday) {
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
