import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import '../providers/api_provider.dart';

class AuthRepository {
  final _api = ApiProvider();
  final _storage = GetStorage();

  /// 暴露给外部使用（例如 home_controller 拉取 /oa/user/current）
  ApiProvider getApi() => _api;
  GetStorage getStorage() => _storage;

  /// 用户登录 - Spring Security form login 风格
  /// 服务器: http://njsh2012.5i178.com:9090
  /// 端点: POST /login (form-encoded)
  /// 字段: username + password
  /// 成功: 302 重定向到 / 或首页
  /// 失败: 302 重定向到 /login.jsp?error=true
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      debugPrint('=== Login attempt: user=$username, baseUrl=${_api.baseUrl} ===');

      // 1. POST /login (form-encoded) - Spring Security form login
      final response = await _api.dioInstance.post(
        '/login',
        data: {
          'username': username,
          'password': password,
        },
        options: dio.Options(
          responseType: dio.ResponseType.plain,
          contentType: 'application/x-www-form-urlencoded',
          followRedirects: false, // 关键：不要跟随重定向，我们要看 302 状态码
          validateStatus: (status) {
            // 接受 2xx, 3xx, 4xx 但不接受 5xx
            return status != null && status < 500;
          },
          headers: {
            'Accept': 'text/html, application/json, */*',
          },
        ),
      );

      debugPrint('Login status: ${response.statusCode}');
      DiagLog.write('LOGIN', 'status=${response.statusCode}');
      debugPrint('Login location header: ${response.headers.value('location')}');
      debugPrint('Login set-cookie: ${response.headers.value('set-cookie')}');
      DiagLog.write('LOGIN', 'set-cookie header value = ${response.headers.value('set-cookie')}');

      final status = response.statusCode ?? 0;
      final location = response.headers.value('location') ?? '';
      final cookieFromResponse = response.headers.value('set-cookie') ?? '';

      // 提取 JSESSIONID
      String? jsessionId;
      String raw = '';
      try {
        // dio 5.x 的 response.headers 是 Headers(Map<String, List<String>>),
        // 优先用 ['set-cookie'] 拿 List<String>(每个元素一条 cookie)
        final list = response.headers['set-cookie'];
        if (list is List && list.isNotEmpty) {
          raw = list.map((e) => e.toString()).join('\n');
        }
        // 兜底用 value()
        if (raw.isEmpty) {
          raw = response.headers.value('set-cookie') ?? '';
        }
      } catch (e) {
        debugPrint('set-cookie parse error: $e');
        DiagLog.write('LOGIN', 'set-cookie parse error: $e');
      }
      debugPrint('Login set-cookie raw: $raw');
      DiagLog.write('LOGIN', 'set-cookie raw=[$raw]');
      debugPrint('Login all headers: ${response.headers}');
      DiagLog.write('LOGIN', 'all headers=${response.headers}');

      final cookieMatch = RegExp(r'JSESSIONID=([^;]+)').firstMatch(raw);
      if (cookieMatch != null) {
        jsessionId = 'JSESSIONID=${cookieMatch.group(1)}';
        await _storage.write('JSESSIONID', jsessionId);
        debugPrint('Stored JSESSIONID: $jsessionId');
        DiagLog.write('LOGIN', 'Stored JSESSIONID: $jsessionId');
      } else {
        jsessionId = _storage.read('JSESSIONID') as String?;
        debugPrint('JSESSIONID not found in set-cookie! Will rely on storage: $jsessionId');
        DiagLog.write('LOGIN', 'JSESSIONID not in set-cookie! storage=$jsessionId');
      }

      // 判断登录结果
      if (status == 302) {
        // Spring Security form login 风格: 用 Location 头判断
        if (location.contains('error') || location.contains('login')) {
          // 失败 - 重定向到登录错误页
          return {'success': false, 'message': '用户名或密码错误'};
        } else {
          // 成功 - 重定向到非 login 路径
          final userData = {
            'id': 0,
            'name': username,
            'loginName': username,
            'username': username,
          };
          await _storage.write('userInfo', userData);
          await _storage.write('token', jsessionId ?? username);
          return {'success': true, 'data': userData};
        }
      } else if (status == 200) {
        // 直接返回 200，看 body
        final body = response.data?.toString() ?? '';
        debugPrint('Login body (200): ${body.substring(0, body.length > 500 ? 500 : body.length)}');

        if (body.contains('error') || body.contains('登录失败') || body.contains('密码')) {
          return {'success': false, 'message': '用户名或密码错误'};
        }
        // 200 + 没有错误提示 -> 假设成功
        final userData = {'id': 0, 'name': username, 'loginName': username, 'username': username};
        await _storage.write('userInfo', userData);
        await _storage.write('token', jsessionId ?? username);
        return {'success': true, 'data': userData};
      } else if (status == 401 || status == 403) {
        return {'success': false, 'message': '认证失败 (HTTP $status)'};
      } else {
        return {'success': false, 'message': 'HTTP $status: ${response.data.toString().substring(0, response.data.toString().length > 200 ? 200 : response.data.toString().length)}'};
      }
    } catch (e, st) {
      debugPrint('Login error: $e\n$st');
      // 关键改动：不再把原始异常 toString 透传给 UI；改用 ApiProvider 归一化的友好提示。
      final apiErr = ApiProvider.normalize(e);
      return {'success': false, 'message': apiErr.message};
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _api.dioInstance.get('/user/current');
      if (response.data != null) {
        await _storage.write('userInfo', response.data);
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'message': '获取用户信息失败'};
    } catch (e) {
      final apiErr = ApiProvider.normalize(e);
      return {'success': false, 'message': apiErr.message};
    }
  }

  bool isLoggedIn() {
    return _storage.hasData('token') && _storage.hasData('userInfo');
  }

  Map<String, dynamic>? getUserInfo() {
    return _storage.read('userInfo');
  }

  Future<void> logout() async {
    await _storage.erase();
  }
}
