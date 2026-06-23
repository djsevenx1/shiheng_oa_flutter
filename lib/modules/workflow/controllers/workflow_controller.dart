import 'package:get/get.dart';

class WorkflowController extends GetxController {
  final isLoading = false.obs;
  final workflows = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadWorkflows();
  }

  Future<void> loadWorkflows() async {
    isLoading.value = true;
    // TODO: 加载流程数据
    await Future.delayed(const Duration(seconds: 1));
    isLoading.value = false;
  }
}
