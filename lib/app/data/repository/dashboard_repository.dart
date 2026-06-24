import 'package:dio/dio.dart' as dio;
import '../providers/api_provider.dart';

class DashboardRepository {
  final _api = ApiProvider();

  /// 获取公告通知（GET /oa/bulletin/initList）
  /// 老 OA Spring Security 要求带 X-Requested-With 头（api_provider 全局已加）
  Future<Map<String, dynamic>> getBulletins() async {
    try {
      final response = await _api.dioInstance.get('/oa/bulletin/initList', queryParameters: {'limit': 20});
      final data = response.data;
      if (data is List) {
        return {'success': true, 'data': data, 'count': data.length};
      }
      if (data is Map) {
        return {
          'success': true,
          'data': data['list'] ?? [],
          'count': data['count'] ?? 0,
        };
      }
      return {'success': true, 'data': [], 'count': 0};
    } catch (e) {
      return {'success': false, 'message': '获取公告失败', 'data': [], 'count': 0};
    }
  }

  /// 获取新闻列表
  Future<Map<String, dynamic>> getNews({int limit = 10}) async {
    try {
      final response = await _api.dioInstance.get('/oa/news/initList', queryParameters: {'limit': limit});
      final data = response.data;
      if (data is List) return {'success': true, 'data': data};
      if (data is Map) return {'success': true, 'data': data['list'] ?? []};
      return {'success': true, 'data': []};
    } catch (e) {
      return {'success': false, 'message': '获取新闻失败', 'data': []};
    }
  }

  /// 获取未读消息计数（GET /oa/message/count）
  Future<Map<String, dynamic>> getMemos() async {
    try {
      final response = await _api.dioInstance.get('/oa/message/count');
      return {
        'success': true,
        'data': response.data ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '获取消息失败', 'data': 0};
    }
  }

  /// 获取部门列表
  Future<Map<String, dynamic>> getUserList({int offset = 0, int limit = 6}) async {
    try {
      final response = await _api.dioInstance.get('/oa/common/groups');
      final list = (response.data is List) ? response.data : [];
      return {
        'success': true,
        'data': list,
        'count': list.length,
      };
    } catch (e) {
      return {'success': false, 'message': '获取部门列表失败', 'data': [], 'count': 0};
    }
  }

  /// 获取最新动态（任务相关）
  Future<Map<String, dynamic>> getEvents() async {
    try {
      final response = await _api.dioInstance.get('/oa/task/initList/Recent', queryParameters: {'limit': 10});
      final data = response.data;
      if (data is List) return {'success': true, 'data': data};
      if (data is Map) return {'success': true, 'data': data['list'] ?? []};
      return {'success': true, 'data': []};
    } catch (e) {
      return {'success': false, 'message': '获取动态失败', 'data': []};
    }
  }

  /// 获取当前登录用户信息（已废弃；改用 /oa/user/current）
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _api.dioInstance.get('/oa/user/current');
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {'success': false, 'message': '获取用户信息失败'};
    }
  }
}
