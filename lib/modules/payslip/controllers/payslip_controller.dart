import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../app/data/repository/payslip_repository.dart';

class PayslipController extends GetxController {
  final PayslipRepository _repo = PayslipRepository();

  final payslips = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final selectedYear = DateTime.now().year.obs;

  @override
  void onInit() {
    super.onInit();
    loadList();
  }

  Future<void> loadList() async {
    isLoading.value = true;
    final result = await _repo.getList(year: selectedYear.value);
    isLoading.value = false;
    if (result['success'] == true) {
      final data = result['data'];
      if (data is Map && data['data'] is List) {
        payslips.value = (data['data'] as List).cast<Map<String, dynamic>>();
      } else if (data is List) {
        payslips.value = data.cast<Map<String, dynamic>>();
      }
    }
  }

  void setYear(int year) {
    selectedYear.value = year;
    loadList();
  }

  String formatMoney(dynamic v) {
    if (v == null) return '0.00';
    final n = (v is num) ? v : num.tryParse(v.toString()) ?? 0;
    return NumberFormat('#,##0.00').format(n);
  }
}
