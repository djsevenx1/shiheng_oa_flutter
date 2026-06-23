import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:getuiflut/getuiflut.dart';
import 'package:get/get.dart';

import '../../modules/notice/controllers/notice_controller.dart';

/// 个推推送服务封装。
/// - Android: 集成 getui SDK（需要 appid/appkey/secret）
/// - iOS: 仅占位
class PushService {
  PushService._internal();
  static final PushService _instance = PushService._internal();
  factory PushService() => _instance;

  final GetStorage _storage = GetStorage();
  bool _initialized = false;

  /// 启动推送服务（在 main() 启动后调用一次）
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      await GetuiFlutterPlugin().init();
      GetuiFlutterPlugin().addEventHandler(
        onReceiveMessage: onMessage,
        onReceiveMessageData: onMessageData,
        onReceiveNotificationResponse: onNotificationResponse,
        onAppLinkPayload: onAppLink,
      );
    } catch (e) {
      debugPrint('push init failed: $e');
    }
  }

  /// 客户端注册成功后，回传给后端（用于按 userId 推送）
  Future<void> bindUser(String userId) async {
    try {
      final cid = await GetuiFlutterPlugin().getClientId();
      if (cid == null || cid.isEmpty) return;
      await _storage.write('push_cid', cid);
      // 通知后端：把 cid 绑定到 userId
      // 后端需要暴露 /oa/push/bind 接口
      // 这里只把信息存到本地，业务侧在登录成功后再调用
      debugPrint('push cid: $cid');
    } catch (e) {
      debugPrint('push bindUser failed: $e');
    }
  }

  String? getCachedCid() {
    return _storage.read('push_cid');
  }

  // 推送回调
  void onMessage(String message) {
    debugPrint('push onMessage: $message');
    _showInApp(message);
  }

  void onMessageData(String data) {
    debugPrint('push onMessageData: $data');
    try {
      final json = jsonDecode(data) as Map<String, dynamic>;
      _handlePayload(json);
    } catch (_) {
      _showInApp(data);
    }
  }

  void onNotificationResponse(String response) {
    debugPrint('push onNotificationResponse: $response');
    try {
      final json = jsonDecode(response) as Map<String, dynamic>;
      _handlePayload(json);
    } catch (_) {}
  }

  void onAppLink(String payload) {
    debugPrint('push onAppLink: $payload');
  }

  void _handlePayload(Map<String, dynamic> payload) {
    final type = payload['type']?.toString() ?? 'notice';
    switch (type) {
      case 'notice':
        // 通知公告推送：刷新通知列表
        try {
          if (Get.isRegistered<NoticeController>()) {
            Get.find<NoticeController>().refreshUnread();
            Get.find<NoticeController>().refreshList();
          }
        } catch (_) {}
        break;
      case 'workflow':
        final id = payload['id']?.toString() ?? '';
        if (id.isNotEmpty) {
          Get.toNamed(Routes.WORKFLOW_DETAIL, arguments: {'id': id});
        }
        break;
      case 'url':
        final url = payload['url']?.toString() ?? '';
        if (url.isNotEmpty) {
          // TODO: 接通 WebView 页面后改为 Get.toNamed(Routes.WEB_VIEW, ...)
          debugPrint('push url payload: $url');
        }
        break;
    }
  }

  void _showInApp(String message) {
    if (!Get.isRegistered<GetMaterialController>()) return;
    try {
      Get.snackbar(
        '新消息',
        message,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
        backgroundColor: const Color(0xFF1E88E5),
        colorText: Colors.white,
        icon: const Icon(Icons.notifications, color: Colors.white),
        onTap: (_) {},
      );
    } catch (_) {}
  }

  /// 关闭推送通道（注销 / 退出登录时调用）
  Future<void> logout() async {
    try {
      await GetuiFlutterPlugin().unBindAlias('', '');
    } catch (_) {}
  }
}
