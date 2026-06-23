import 'package:get/get.dart';

class AttendanceController extends GetxController {
  final isLoading = false.obs;
  final attendanceList = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    isLoading.value = true;
    // TODO: 加载考勤数据
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
  }
}
