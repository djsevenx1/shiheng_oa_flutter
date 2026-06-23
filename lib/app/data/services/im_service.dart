import 'package:flutter/foundation.dart';

/// 即时通讯占位服务。
/// 真实部署时对接环信 im_flutter_sdk（4.10+）需要精确匹配 API；
/// 当前 Flutter 3.22 与 im_flutter_sdk 4.10 的 Windows bridge 仍有冲突，
/// 故先以占位 + 后端拉取的方式呈现会话列表，后端可通过 WebSocket / SSE 推送。
class ImService {
  ImService._internal();
  static final ImService _instance = ImService._internal();
  factory ImService() => _instance;

  bool _initialized = false;
  bool _loggedIn = false;
  String? _appKey;
  String? _userId;

  /// 初始化 SDK（占位）
  Future<void> init({required String appKey}) async {
    if (_initialized) return;
    _initialized = true;
    _appKey = appKey;
    debugPrint('ImService.init appKey=$appKey (placeholder)');
  }

  /// 登录（占位）
  Future<bool> login({required String userId, required String password}) async {
    _userId = userId;
    _loggedIn = true;
    debugPrint('ImService.login userId=$userId (placeholder)');
    return true;
  }

  /// 登出
  Future<void> logout() async {
    _loggedIn = false;
    _userId = null;
  }

  bool get isLoggedIn => _loggedIn;
  String? get currentUserId => _userId;
  String? get appKey => _appKey;
}
