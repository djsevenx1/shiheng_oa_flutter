import '../providers/api_provider.dart';

/// 主题/通知仓库
/// 真实接口（老 App 反编译 topic/topic.js）：
/// - /oa/message/initList          主题/消息列表
/// - /oa/top/getDetail/:id         主题详情
/// - /oa/message/getDetail/id/:id  消息详情
/// - /oa/access/add/_top           发布主题（POST formData）
/// - /oa/message/reply             回复
class TopicRepository {
  final _api = ApiProvider();

  Future<Map<String, dynamic>> getTopicList({int page = 1, int pageSize = 10, String? type}) async {
    try {
      // 老 App 真实接口：/oa/message/initList (curl 200)，/topic/init 404
      final response = await _api.dioInstance.get('/oa/message/initList', queryParameters: {
        'limit': pageSize,
        'offset': (page - 1) * pageSize,
      });
      return {
        'success': true,
        'data': response.data?['list'] ?? (response.data is List ? response.data : []),
        'count': response.data?['count'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '获取话题失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getTopicDetail(int topicId) async {
    try {
      // 老 App 真实接口：/oa/top/getDetail/:id 或 /oa/message/getDetail/id/:id
      final response = await _api.dioInstance.get('/oa/message/getDetail/id/$topicId');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取详情失败: $e'};
    }
  }

  Future<Map<String, dynamic>> createTopic(dynamic data) async {
    try {
      // 老 App 真实接口：POST /oa/access/add/_top (curl)
      final response = await _api.dioInstance.post('/oa/access/add/_top', data: data);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '创建失败: $e'};
    }
  }
}
