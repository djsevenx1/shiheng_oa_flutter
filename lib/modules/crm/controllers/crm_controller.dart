import 'package:get/get.dart';

class CrmController extends GetxController {
  final isLoading = false.obs;
  final customers = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    isLoading.value = true;
    // TODO: 加载客户数据
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
  }
}
