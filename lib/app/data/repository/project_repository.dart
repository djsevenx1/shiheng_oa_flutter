import '../providers/api_provider.dart';

class ProjectRepository {
  final _api = ApiProvider();

  Future<Map<String, dynamic>> getProjectList({
    int page = 1,
    int pageSize = 15,
    String? keyword,
    String kind = 'all', // all, fzr, cyr
  }) async {
    try {
      final response = await _api.dioInstance.get('/item/init/xmxx', queryParameters: {
        'limit': pageSize,
        'offset': (page - 1) * pageSize,
        'more': 'fzr,cyr',
        'kind': kind,
        'mobile': 'created_date',
      });
      return {
        'success': true,
        'data': response.data?['list'] ?? [],
        'count': response.data?['count'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '获取项目列表失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getProjectDetail(int projectId) async {
    try {
      final response = await _api.dioInstance.get('/item/get/xmxx/$projectId');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取项目详情失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getProjectContracts(int projectId) async {
    try {
      final response = await _api.dioInstance.get('/item/init/xmht', queryParameters: {
        'projectId': projectId,
      });
      return {
        'success': true,
        'data': response.data?['list'] ?? [],
      };
    } catch (e) {
      return {'success': false, 'message': '获取项目合同失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getProjectFiles(int projectId) async {
    try {
      final response = await _api.dioInstance.get('/item/init/xmwj', queryParameters: {
        'projectId': projectId,
      });
      return {
        'success': true,
        'data': response.data?['list'] ?? [],
      };
    } catch (e) {
      return {'success': false, 'message': '获取项目文件失败: $e'};
    }
  }
}
