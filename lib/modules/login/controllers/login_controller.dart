import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/auth_repository.dart';
import '../../../app/routes/app_pages.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();

  final serverController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final rememberMe = true.obs;

  @override
  void onInit() {
    super.onInit();
    // 预填充测试账号
    usernameController.text = 'admin';
    // 默认服务器地址
    serverController.text = 'http://xmyjsss.gnway.cc:22178';
  }

  @override
  void onClose() {
    serverController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleRememberMe(bool? value) {
    rememberMe.value = value ?? false;
  }

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty) {
      Get.snackbar(
        '提示',
        '请输入用户名',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (password.isEmpty) {
      Get.snackbar(
        '提示',
        '请输入密码',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    isLoading.value = true;

    try {
      final result = await _authRepository.login(username, password);

      if (result['success'] == true) {
        Get.snackbar(
          '登录成功',
          '欢迎回来，${result['data']?['name'] ?? username}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed(Routes.HOME);
      } else {
        Get.snackbar(
          '登录失败',
          result['message'] ?? '用户名或密码错误',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '网络连接失败，请检查网络设置',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
