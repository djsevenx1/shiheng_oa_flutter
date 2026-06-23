import '../providers/api_provider.dart';

class DashboardRepository {
  final _api = ApiProvider();

  Future<Map<String, dynamic>> getBulletins() async {
    try {
      final response = await _api.dioInstance.get('/access/getAllByAclSp/_bul');
      return {'success': true, 'data': response.data ?? []};
    } catch (e) {
      return {'success': false, 'message': '获取公告失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getNews({int limit = 10}) async {
    try {
      final response = await _api.dioInstance.get('/news/initAclList', queryParameters: {'limit': limit});
      return {'success': true, 'data': response.data?['list'] ?? []};
    } catch (e) {
      return {'success': false, 'message': '获取新闻失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getMemos() async {
    try {
      final response = await _api.dioInstance.get('/news/getMemoList');
      return {'success': true, 'data': response.data ?? []};
    } catch (e) {
      return {'success': false, 'message': '获取备忘失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getUserList({int offset = 0, int limit = 6}) async {
    try {
      final response = await _api.dioInstance.get('/user/initList', queryParameters: {'offset': offset, 'limit': limit});
      return {'success': true, 'data': response.data?['list'] ?? [], 'count': response.data?['count'] ?? 0};
    } catch (e) {
      return {'success': false, 'message': '获取用户列表失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getEvents() async {
    try {
      final response = await _api.dioInstance.get('/eve/getList/8');
      return {'success': true, 'data': response.data ?? []};
    } catch (e) {
      return {'success': false, 'message': '获取动态失败: $e'};
    }
  }
}
