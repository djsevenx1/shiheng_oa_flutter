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
      );

      if (response.data != null && response.data['success'] != false) {
        final userData = response.data is Map ? response.data : {'id': 1, 'name': username, 'loginName': username};
        await _storage.write('token', username);
        await _storage.write('userInfo', userData);
        return {'success': true, 'data': userData};
      }
      return {'success': false, 'message': response.data?['message'] ?? '登录失败'};
    } catch (e) {
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
