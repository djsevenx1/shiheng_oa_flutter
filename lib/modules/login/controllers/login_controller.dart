import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/core/app_config.dart';
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

  /// 顶部红色 banner 的短文案。null 表示不展示。
  final RxnString errorBanner = RxnString();
  /// 顶部红色 banner 副标题（调试细节），仅当 [AppConfig.verboseErrors] 为 true 时显示。
  final RxnString errorBannerDetail = RxnString();

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

  void clearError() {
    errorBanner.value = null;
    errorBannerDetail.value = null;
  }

  /// 顶部 banner 风格的提示（短文案 + 可选调试细节 + 关闭按钮）。
  ///
  /// 同时保留一个轻量 SnackBar 给用户即时反馈（2 秒就消失，不会盖住表单）。
  void _showMessage({
    required String title,
    required String message,
    required Color bg,
    bool isError = false,
    String? detail,
  }) {
    if (isError) {
      errorBanner.value = message;
      errorBannerDetail.value = detail;
    } else {
      clearError();
    }
    final ctx = Get.context;
    if (ctx == null) return;
    ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text('$title：${AppConfig.summarize(message)}'),
        backgroundColor: bg,
        duration: Duration(seconds: isError ? 3 : 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> login() async {
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (username.isEmpty) {
      _showMessage(title: '提示', message: '请输入用户名', bg: Colors.orange, isError: true);
      return;
    }

    if (password.isEmpty) {
      _showMessage(title: '提示', message: '请输入密码', bg: Colors.orange, isError: true);
      return;
    }

    isLoading.value = true;
    clearError();

    try {
      // 切换服务器地址
      _api.setBaseUrl(serverController.text);

      final result = await _authRepository.login(username, password);

      if (result['success'] == true) {
        _showMessage(
          title: '登录成功',
          message: '欢迎回来，${result['data']?['name'] ?? username}',
          bg: Colors.green,
        );
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(Routes.HOME);
      } else {
        _showMessage(
          title: '登录失败',
          message: result['message'] ?? '用户名或密码错误',
          bg: Colors.red,
          isError: true,
        );
      }
    } on Object catch (e) {
      // 防御性兜底：AuthRepository.login 不会再 throw DioException，但万一有其它异常。
      _showMessage(
        title: '登录异常',
        message: '请稍后再试',
        bg: Colors.red,
        isError: true,
        detail: ApiProvider.debugDetail(e),
      );
    } finally {
      isLoading.value = false;
    }
  }
}
