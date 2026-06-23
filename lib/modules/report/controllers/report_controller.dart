import 'package:get/get.dart';

class ReportController extends GetxController {
  final isLoading = false.obs;
  final reports = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  Future<void> loadReports() async {
    isLoading.value = true;
    // TODO: 加载报表数据
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
  }
}
