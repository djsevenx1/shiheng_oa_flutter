import 'package:get/get.dart';

class SettingsController extends GetxController {
  final isDarkMode = false.obs;
  final notificationsEnabled = true.obs;
  final cacheSize = '0 MB'.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() {
    // TODO: 加载设置
  }

  void toggleDarkMode(bool value) {
    isDarkMode.value = value;
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
  }

  Future<void> clearCache() async {
    // TODO: 清除缓存
  }
}
