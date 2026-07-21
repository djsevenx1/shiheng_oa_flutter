import '../providers/api_provider.dart';

/// 任务仓库
/// 老 App 反编译真实接口（task.js）：
/// - /oa/task/initList/{key}?limit=N   任务列表（key=tab+status 组合）
/// - /oa/task/getDetail/id/:id         任务详情
/// - /oa/task/addTask                  创建任务（POST）
/// - /oa/task/addFeedback              更新状态/反馈（POST）
///
/// tab keys: JoinedOrCreated / Joined / Joined/AsLeader / Joined/AsMember / Created / Created/Approving / Created/Rejected
/// status keys: (空) / /Initialized / /InProgress / /Finished
class TaskRepository {
  final _api = ApiProvider();

  /// 获取任务列表
  /// tabKey: JoinedOrCreated / Joined / Created 等
  /// statusKey: '' / '/Initialized' / '/InProgress' / '/Finished'
  Future<Map<String, dynamic>> getTaskList({
    int limit = 20,
    String tabKey = 'JoinedOrCreated',
    String statusKey = '',
    String? keyword,
  }) async {
    try {
      final fullKey = tabKey + statusKey;
      final response = await _api.dioInstance.get('/oa/task/initList/$fullKey', queryParameters: {
        'limit': limit,
      });
      final data = response.data;
      if (data is Map) {
        return {
          'success': true,
          'data': data['list'] ?? [],
          'count': data['count'] ?? 0,
        };
      }
      if (data is List) {
        return {'success': true, 'data': data, 'count': data.length};
      }
      return {'success': true, 'data': [], 'count': 0};
    } catch (e) {
      return {'success': false, 'message': '获取任务列表失败: $e'};
    }
  }

  /// 获取任务统计（分别请求各状态数量）
  Future<Map<String, int>> getTaskStats() async {
    final stats = <String, int>{'total': 0, 'todo': 0, 'doing': 0, 'done': 0};
    try {
      final results = await Future.wait([
        _api.dioInstance.get('/oa/task/initList/JoinedOrCreated', queryParameters: {'limit': 1}),
        _api.dioInstance.get('/oa/task/initList/JoinedOrCreated/Initialized', queryParameters: {'limit': 1}),
        _api.dioInstance.get('/oa/task/initList/JoinedOrCreated/InProgress', queryParameters: {'limit': 1}),
        _api.dioInstance.get('/oa/task/initList/JoinedOrCreated/Finished', queryParameters: {'limit': 1}),
      ]);
      for (int i = 0; i < results.length; i++) {
        final data = results[i].data;
        int count = 0;
        if (data is Map) {
          count = (data['count'] as num?)?.toInt() ?? 0;
        } else if (data is List) {
          count = data.length;
        }
        switch (i) {
          case 0: stats['total'] = count; break;
          case 1: stats['todo'] = count; break;
          case 2: stats['doing'] = count; break;
          case 3: stats['done'] = count; break;
        }
      }
    } catch (_) {}
    return stats;
  }

  Future<Map<String, dynamic>> getTaskDetail(int taskId) async {
    try {
      final response = await _api.dioInstance.get('/oa/task/getDetail/id/$taskId');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取任务详情失败: $e'};
    }
  }

  Future<Map<String, dynamic>> createTask(dynamic formData) async {
    try {
      final response = await _api.dioInstance.post('/oa/task/addTask', data: formData);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '创建任务失败: $e'};
    }
  }

  Future<Map<String, dynamic>> updateTaskStatus(int taskId, String status) async {
    try {
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
}
