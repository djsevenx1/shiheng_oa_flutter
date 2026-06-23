import '../providers/api_provider.dart';

class TopicRepository {
  final _api = ApiProvider();

  Future<Map<String, dynamic>> getTopicList({int page = 1, int pageSize = 10, String? type}) async {
    try {
      final response = await _api.dioInstance.get('/topic/init', queryParameters: {
        'limit': pageSize,
        'offset': (page - 1) * pageSize,
        'type': type ?? 'all',
      });
      return {
        'success': true,
        'data': response.data?['list'] ?? [],
        'count': response.data?['count'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '获取话题失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getTopicDetail(int topicId) async {
    try {
      final response = await _api.dioInstance.get('/topic/get/$topicId');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取详情失败: $e'};
    }
  }

  Future<Map<String, dynamic>> createTopic(dynamic data) async {
    try {
      final response = await _api.dioInstance.post('/topic/add', data: data);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '创建失败: $e'};
    }
  }
}
