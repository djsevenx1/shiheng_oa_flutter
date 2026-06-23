import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/providers/api_provider.dart';
import '../../../app/data/repository/auth_repository.dart';
import '../../../app/routes/app_pages.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final ApiProvider _api = ApiProvider();

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
    serverController.text = _api.baseUrl;
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

  void _showSnack(String title, String message, Color bg) {
    final ctx = Get.context;
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('$title：$message'),
        backgroundColor: bg,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty) {
      _showSnack('提示', '请输入用户名', Colors.orange);
      return;
    }

    if (password.isEmpty) {
      _showSnack('提示', '请输入密码', Colors.orange);
      return;
    }

    isLoading.value = true;

    try {
      // 切换服务器地址
      _api.setBaseUrl(serverController.text);

      final result = await _authRepository.login(username, password);

      if (result['success'] == true) {
        _showSnack('登录成功', '欢迎回来，${result['data']?['name'] ?? username}', Colors.green);
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(Routes.HOME);
      } else {
        _showSnack('登录失败', result['message'] ?? '用户名或密码错误', Colors.red);
      }
    } catch (e) {
      _showSnack('错误', '网络连接失败: $e', Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
}
