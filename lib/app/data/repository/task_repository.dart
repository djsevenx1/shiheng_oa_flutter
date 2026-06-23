import '../providers/api_provider.dart';

class TaskRepository {
  final _api = ApiProvider();

  /// 获取任务列表
  /// status: Done | Recent | Todo
  Future<Map<String, dynamic>> getTaskList({
    int page = 1,
    int pageSize = 20,
    String? keyword,
    String? status, // Done | Recent | Todo
  }) async {
    try {
      // 后端用 /oa/task/initList/{status}?limit=N
      final s = status ?? 'Todo';
      final response = await _api.dioInstance.get('/oa/task/initList/$s', queryParameters: {
        'limit': pageSize,
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
      final response = await _api.dioInstance.get('/oa/task/get/$taskId');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取任务详情失败: $e'};
    }
  }

  Future<Map<String, dynamic>> createTask(dynamic formData) async {
    try {
      final response = await _api.dioInstance.post('/oa/task/add', data: formData);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '创建任务失败: $e'};
    }
  }

  Future<Map<String, dynamic>> updateTaskStatus(int taskId, String status) async {
    try {
      final response = await _api.dioInstance.post('/oa/task/updateStatus', data: {
        'id': taskId,
        'status': status,
      });
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '更新状态失败: $e'};
    }
  }

  /// 获取待办事项
  Future<Map<String, dynamic>> getTodo() async {
    try {
      final response = await _api.dioInstance.get('/oa/todo/initList', queryParameters: {'limit': 20});
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {'success': false, 'message': '获取待办失败: $e'};
    }
  }
}
