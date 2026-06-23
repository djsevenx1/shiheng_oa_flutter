import '../providers/api_provider.dart';

class ArchiveRepository {
  final _api = ApiProvider();

  Future<Map<String, dynamic>> getArchiveList({int page = 1, int pageSize = 15, String? keyword, String? category}) async {
    try {
      final response = await _api.dioInstance.get('/archive/init', queryParameters: {
        'limit': pageSize,
        'offset': (page - 1) * pageSize,
        'keyword': keyword ?? '',
        'category': category ?? '',
      });
      return {
        'success': true,
        'data': response.data?['list'] ?? [],
        'count': response.data?['count'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '获取档案失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getArchiveDetail(int id) async {
    try {
      final response = await _api.dioInstance.get('/archive/get/$id');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取档案详情失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getCompanyFiles({int page = 1, int pageSize = 15, String? category}) async {
    try {
      final response = await _api.dioInstance.get('/file/init', queryParameters: {
        'limit': pageSize,
        'offset': (page - 1) * pageSize,
        'category': category ?? '',
      });
      return {
        'success': true,
        'data': response.data?['list'] ?? [],
        'count': response.data?['count'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '获取文件失败: $e'};
    }
  }
}
