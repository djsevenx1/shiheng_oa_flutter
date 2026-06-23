import 'package:flutter/foundation.dart';
import 'package:im_flutter_sdk/im_flutter_sdk.dart';

/// 环信 IM 服务封装。
/// 后端需要：用户登录后从后端拿一个 imToken（环信用户密码可能是固定或动态），
/// 然后调用 [login] 完成 IM 登录。
class ImService {
  ImService._internal();
  static final ImService _instance = ImService._internal();
  factory ImService() => _instance;

  bool _initialized = false;
  bool _loggedIn = false;

  /// 初始化 SDK（在 main() 启动后调用一次）
  /// [appKey] 形如 "1121230123012301#shiheng"
  Future<void> init({required String appKey}) async {
    if (_initialized) return;
    _initialized = true;
    try {
      final options = EMOptions(
        appKey: appKey,
        autoLogin: false,
        debugMode: kDebugMode,
      );
      await EMClient.getInstance.init(options);
    } catch (e) {
      debugPrint('im init failed: $e');
    }
  }

  /// 登录
  /// [userId] 用户 ID；[password] 环信密码（通常后端签发）
  Future<bool> login({required String userId, required String password}) async {
    try {
      await EMClient.getInstance.login(userId, password);
      _loggedIn = true;
      return true;
    } catch (e) {
      debugPrint('im login failed: $e');
      return false;
    }
  }

  /// 登出
  Future<void> logout() async {
    if (!_loggedIn) return;
    try {
      await EMClient.getInstance.logout(false);
    } catch (_) {}
    _loggedIn = false;
  }

  bool get isLoggedIn => _loggedIn;
}
