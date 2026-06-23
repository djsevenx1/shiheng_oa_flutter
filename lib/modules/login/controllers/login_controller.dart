import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../app/core/app_config.dart';
import '../../../app/data/providers/api_provider.dart';
import '../../../app/data/repository/auth_repository.dart';
import '../../../app/routes/app_pages.dart';

class LoginController extends GetxController {
  LoginController({GetStorage? storage}) : _storage = storage ?? GetStorage();

  final AuthRepository _authRepository = AuthRepository();
  final ApiProvider _api = ApiProvider();
  final GetStorage _storage;

  // 凭据保存的存储 key（base64 后存，避免明文落盘）
  static const _kSavedUsername = 'remembered_username';
  static const _kSavedPassword = 'remembered_password';

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
    // 默认服务器地址
    serverController.text = _api.baseUrl;

    // 关键改动：恢复"记住密码"保存的凭据。
    // 注意：优先使用 user 真正保存过的账号，其次才回退到默认 'admin'。
    final savedUsername = _storage.read(_kSavedUsername);
    final savedPasswordRaw = _storage.read(_kSavedPassword);
    if (savedUsername != null && savedPasswordRaw != null) {
      try {
        usernameController.text = savedUsername.toString();
        passwordController.text = base64Decode(savedPasswordRaw.toString()).toString();
        rememberMe.value = true;
      } catch (_) {
        // 凭据损坏时忽略，回到默认
        usernameController.text = 'admin';
        rememberMe.value = false;
      }
    } else {
      // 没有保存的凭据，预填默认账号但不预填密码
      usernameController.text = 'admin';
      rememberMe.value = false;
    }
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
    if (!rememberMe.value) {
      // 用户主动取消记住，立即清除已保存的凭据
      clearSavedCredentials();
    }
  }

  void clearError() {
    errorBanner.value = null;
    errorBannerDetail.value = null;
  }

  /// 保存凭据到本地（base64 编码后写入 GetStorage）。
  /// 注意：本地存储对设备 root 场景并非真正安全；正式方案应改用
  /// `flutter_secure_storage`（Keychain / EncryptedSharedPreferences）。
  void _saveCredentials(String username, String password) {
    try {
      _storage.write(_kSavedUsername, username);
      _storage.write(_kSavedPassword, base64Encode(utf8.encode(password)));
    } catch (e) {
      debugPrint('save credentials failed: $e');
    }
  }

  /// 清除已保存的凭据。
  void clearSavedCredentials() {
    try {
      _storage.remove(_kSavedUsername);
      _storage.remove(_kSavedPassword);
    } catch (_) {}
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
        // 关键改动：根据 rememberMe 选择保存或清除凭据。
        if (rememberMe.value) {
          _saveCredentials(username, password);
        } else {
          clearSavedCredentials();
        }
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
