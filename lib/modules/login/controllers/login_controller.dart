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
        // 修：base64Decode 返 Uint8List，.toString() 是 "[1, 2, 3, ...]"
        // 应该 utf8.decode 转回原密码字符串
        passwordController.text = utf8.decode(base64Decode(savedPasswordRaw.toString()));
        rememberMe.value = true;
      } catch (_) {
        // 旧版本写的是错误编码的密码（[1,2,3,...]），解码失败就清掉让用户重输
        _storage.remove(_kSavedPassword);
        passwordController.text = '';
        usernameController.text = savedUsername.toString();
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

      // 关键修复：登录前清掉旧 session，避免 dio 自动加上旧 Cookie 头
      // 导致后端返回 302 时被 dio 误判为异常（"只能登录一次"的根因）
      _storage.remove('JSESSIONID');
      _storage.remove('token');
      _storage.remove('userInfo');
      _storage.remove('cachedUserName');
      _storage.remove('cachedUserGroup');
      _storage.remove('cachedUserIcon');
      _storage.remove('cachedUserId');

      final result = await _authRepository.login(username, password);

      if (result['success'] == true) {
        // 关键改动：根据 rememberMe 选择保存或清除凭据。
        if (rememberMe.value) {
          _saveCredentials(username, password);
        } else {
          clearSavedCredentials();
        }
        // 登录成功后主动拉取一次用户信息并缓存（供首页展示用）
        _storage.write('cachedUsername', username);
        _fetchAndCacheCurrentUser(username);
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

  /// 登录后从 /oa/user/current 拉取真实用户信息（name/groupName/icon）缓存到 storage。
  /// 失败不阻塞登录。
  Future<void> _fetchAndCacheCurrentUser(String username) async {
    try {
      final response = await _api.dioInstance.get('/oa/user/current');
      final data = response.data;
      if (data is Map) {
        final m = data.cast<String, dynamic>();
        // 老 OA user/current 字段是 {id, name, groupName, groupId, roleName, ...}
        if (m['name'] != null) _storage.write('cachedUserName', m['name'].toString());
        if (m['groupName'] != null) _storage.write('cachedUserGroup', m['groupName'].toString());
        if (m['icon'] != null) _storage.write('cachedUserIcon', m['icon'].toString());
        if (m['id'] != null) _storage.write('cachedUserId', m['id'].toString());
      }
    } catch (e) {
      debugPrint('fetch current user failed: $e');
    }
  }
}
