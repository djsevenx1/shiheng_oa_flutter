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
      // 老 App 真实接口：/oa/task/getDetail/id/:id (curl 200，/oa/task/get/:id 404)
      final response = await _api.dioInstance.get('/oa/task/getDetail/id/$taskId');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取任务详情失败: $e'};
    }
  }

  Future<Map<String, dynamic>> createTask(dynamic formData) async {
    try {
      // 老 App 真实接口：/oa/task/addTask (curl 实测 200，/oa/task/add 404)
      final response = await _api.dioInstance.post('/oa/task/addTask', data: formData);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '创建任务失败: $e'};
    }
  }

  Future<Map<String, dynamic>> updateTaskStatus(int taskId, String status) async {
    try {
      // 老 App 用 /oa/task/addFeedback（加反馈完成），curl /oa/task/updateStatus 404
      // 这里传 status 字段让后端识别是"完成"还是其他
      final response = await _api.dioInstance.post('/oa/task/addFeedback', data: {
        'id': taskId,
        'status': status,
        'description': '状态变更为: $status',
      });
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '更新状态失败: $e'};
    }
  }

  /// 获取待办事项（老 App 真实接口：/oa/eve/getList/8）
  /// 之前错用 /oa/todo/initList（结构乱）
  Future<Map<String, dynamic>> getTodo() async {
    try {
      final response = await _api.dioInstance.get('/oa/eve/getList/8', queryParameters: {'limit': 20});
      return {
        'success': true,
        'data': response.data,
      };
    } catch (e) {
      return {'success': false, 'message': '获取待办失败: $e'};
    }
  }
}
