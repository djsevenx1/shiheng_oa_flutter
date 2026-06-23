import '../providers/api_provider.dart';

class ProjectRepository {
  final _api = ApiProvider();

  Future<Map<String, dynamic>> getProjectList({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final response = await _api.dioInstance.get('/oa/project/initList', queryParameters: {
        'limit': pageSize,
      });
      return {
        'success': true,
        'data': response.data?['list'] ?? response.data ?? [],
        'count': response.data?['count'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '获取项目列表失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getProjectDetail(int projectId) async {
    try {
      final response = await _api.dioInstance.get('/oa/project/get/$projectId');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取项目详情失败: $e'};
    }
  }
}
