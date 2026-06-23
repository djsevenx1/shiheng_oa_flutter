import '../providers/api_provider.dart';

class DashboardRepository {
  final _api = ApiProvider();

  /// 获取公告通知
  Future<Map<String, dynamic>> getBulletins() async {
    try {
      final response = await _api.dioInstance.get('/oa/bulletin/initList', queryParameters: {'limit': 20});
      return {
        'success': true,
        'data': response.data?['list'] ?? [],
        'count': response.data?['count'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '获取公告失败: $e'};
    }
  }

  /// 获取新闻列表
  Future<Map<String, dynamic>> getNews({int limit = 10}) async {
    try {
      final response = await _api.dioInstance.get('/oa/news/initList', queryParameters: {'limit': limit});
      return {
        'success': true,
        'data': response.data?['list'] ?? [],
      };
    } catch (e) {
      return {'success': false, 'message': '获取新闻失败: $e'};
    }
  }

  /// 获取未读消息计数
  Future<Map<String, dynamic>> getMemos() async {
    try {
      final response = await _api.dioInstance.get('/oa/message/count');
      return {
        'success': true,
        'data': response.data ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '获取消息失败: $e'};
    }
  }

  /// 获取部门列表（替代"用户列表"）
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
      return {'success': false, 'message': '获取部门列表失败: $e'};
    }
  }

  /// 获取最新动态（任务相关）
  Future<Map<String, dynamic>> getEvents() async {
    try {
      final response = await _api.dioInstance.get('/oa/task/initList/Recent', queryParameters: {'limit': 10});
      return {
        'success': true,
        'data': response.data?['list'] ?? [],
      };
    } catch (e) {
      return {'success': false, 'message': '获取动态失败: $e'};
    }
  }

  /// 获取当前登录用户信息
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _api.dioInstance.get('/oa/common/name/');
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {'success': false, 'message': '获取用户信息失败: $e'};
    }
  }
}
