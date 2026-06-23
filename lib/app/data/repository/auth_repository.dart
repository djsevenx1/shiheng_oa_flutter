import 'package:dio/dio.dart' as dio;
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import '../providers/api_provider.dart';

class AuthRepository {
  final _api = ApiProvider();
  final _storage = GetStorage();

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      // 用户登录
      final response = await _api.dioInstance.post(
        '/oa/login',
        data: {
          'loginName': username,
          'password': password,
        },
        options: dio.Options(
          responseType: dio.ResponseType.json,
          contentType: 'application/json',
        ),
      );

      // 打印原始响应，方便调试
      debugPrint('Login response: ${response.data}');

      final data = response.data;
      if (data != null && data is Map) {
        // 兼容不同返回结构
        // 格式1: {success: true, data: {user}, token: 'xxx'}
        // 格式2: {code: 0, msg: 'ok', data: {user}, token: 'xxx'}
        // 格式3: {user: {...}, token: 'xxx'} (直接返回用户)
        Map<String, dynamic> userData;
        String? token;
        bool success = true;

        if (data['success'] == false || data['code'] == 500 || data['code'] == 401) {
          success = false;
        } else if (data['data'] is Map) {
          userData = Map<String, dynamic>.from(data['data'] as Map);
          token = data['token']?.toString();
        } else if (data['data'] == null && (data.containsKey('loginName') || data.containsKey('name'))) {
          // 格式3: 直接返回用户对象
          userData = Map<String, dynamic>.from(data);
          token = data['token']?.toString();
        } else {
          // 默认成功
          userData = {'id': 0, 'name': username, 'loginName': username};
        }

        if (success) {
          // 把所有 String 类型的 id 字段尝试转为 int
          if (userData['id'] is String) {
            userData['id'] = int.tryParse(userData['id'].toString()) ?? 0;
          }
          await _storage.write('userInfo', userData);
          if (token != null && token.isNotEmpty) {
            await _storage.write('token', token);
          } else {
            await _storage.write('token', username);
          }
          return {'success': true, 'data': userData};
        } else {
          return {'success': false, 'message': (data['message'] ?? data['msg'] ?? '登录失败').toString()};
        }
      }

      return {'success': false, 'message': '返回数据格式错误'};
    } catch (e, st) {
      debugPrint('Login error: $e\n$st');
      return {'success': false, 'message': '网络错误: $e'};
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
      return {'success': false, 'message': '网络错误: $e'};
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
