import 'package:dio/dio.dart' as dio;

import '../providers/api_provider.dart';

/// 首页仪表盘仓库
/// 老 App 反编译真实接口（dashboard.js / EveCtrl）：
/// - /oa/access/getAllByAclSp/_bul   公告列表（返回 List）
/// - /oa/bulletin/getList/news       新闻/轮播图（返回 List）
/// - /oa/eve/getList/8               最新动态（返回 List，含 eveType 0=邮件 1=待办流程 2=历史流程）
/// - /oa/user/initList?limit=6       用户列表（返回 {list, count}）
class DashboardRepository {
  final _api = ApiProvider();

  /// 获取公告通知（GET /oa/access/getAllByAclSp/_bul）
  Future<Map<String, dynamic>> getBulletins() async {
    try {
      final response = await _api.dioInstance.get('/oa/access/getAllByAclSp/_bul');
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

  /// 获取新闻列表（GET /oa/bulletin/getList/news）
  Future<Map<String, dynamic>> getNews({int limit = 10}) async {
    try {
      final response = await _api.dioInstance.get('/oa/bulletin/getList/news');
      final data = response.data;
      if (data is List) return {'success': true, 'data': data};
      if (data is Map) return {'success': true, 'data': data['list'] ?? []};
      return {'success': true, 'data': []};
    } catch (e) {
      return {'success': false, 'message': '获取新闻失败', 'data': []};
    }
  }

  /// 获取最新动态（GET /oa/eve/getList/8）
  /// 返回 List，每项含 eveType(0=邮件 1=待办流程 2=历史流程)、name、creatorName、createdDate、state、proId、topId
  Future<Map<String, dynamic>> getEvents() async {
    try {
      final response = await _api.dioInstance.get('/oa/eve/getList/8', queryParameters: {'limit': 10});
      final data = response.data;
      if (data is List) return {'success': true, 'data': data};
      if (data is Map) return {'success': true, 'data': data['list'] ?? []};
      return {'success': true, 'data': []};
    } catch (e) {
      return {'success': false, 'message': '获取动态失败', 'data': []};
    }
  }

  /// 获取用户列表（GET /oa/user/initList?limit=6）
  Future<Map<String, dynamic>> getUserList({int offset = 0, int limit = 6}) async {
    try {
      final response = await _api.dioInstance.get('/oa/user/initList', queryParameters: {'limit': limit});
      final data = response.data;
      if (data is Map) {
        return {
          'success': true,
          'data': data['list'] ?? [],
          'count': data['count'] ?? 0,
        };
      }
      if (data is List) {
        return {'success': true, 'data': data, 'count': data.length};
      }
      return {'success': true, 'data': [], 'count': 0};
    } catch (e) {
      return {'success': false, 'message': '获取用户列表失败', 'data': [], 'count': 0};
    }
  }
}
