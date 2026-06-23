import '../providers/api_provider.dart';

class TaskRepository {
  final _api = ApiProvider();

  Future<Map<String, dynamic>> getTaskList({
    int page = 1,
    int pageSize = 20,
    String? keyword,
    String? status, // all, todo, doing, done
  }) async {
    try {
      final response = await _api.dioInstance.get('/task/init', queryParameters: {
        'limit': pageSize,
        'offset': (page - 1) * pageSize,
        'keyword': keyword ?? '',
        'status': status ?? 'all',
      });
      return {
        'success': true,
        'data': response.data?['list'] ?? [],
        'count': response.data?['count'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '获取任务列表失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getTaskDetail(int taskId) async {
    try {
      final response = await _api.dioInstance.get('/task/get/$taskId');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取任务详情失败: $e'};
    }
  }

  Future<Map<String, dynamic>> createTask(dynamic formData) async {
    try {
      final response = await _api.dioInstance.post('/task/add', data: formData);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '创建任务失败: $e'};
    }
  }

  Future<Map<String, dynamic>> updateTaskStatus(int taskId, String status) async {
    try {
      final response = await _api.dioInstance.post('/task/updateStatus', data: {
        'id': taskId,
        'status': status,
      });
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '更新状态失败: $e'};
    }
  }
}
