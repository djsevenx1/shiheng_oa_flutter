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

  /// 获取项目合同 - 占位
  Future<Map<String, dynamic>> getProjectContracts(int projectId) async {
    try {
      final response = await _api.dioInstance.get('/oa/project/contracts', queryParameters: {'projectId': projectId});
      return {'success': true, 'data': response.data ?? []};
    } catch (e) {
      return {'success': true, 'data': []};
    }
  }

  /// 获取项目文件 - 占位
  Future<Map<String, dynamic>> getProjectFiles(int projectId) async {
    try {
      final response = await _api.dioInstance.get('/oa/project/files', queryParameters: {'projectId': projectId});
      return {'success': true, 'data': response.data ?? []};
    } catch (e) {
      return {'success': true, 'data': []};
    }
  }
}
