import '../providers/api_provider.dart';

class WorkflowRepository {
  final _api = ApiProvider();

  Future<Map<String, dynamic>> getWorkflowList({
    required bool isHandle,
    Map<String, dynamic>? filters,
    int offset = 0,
    int limit = 20,
  }) async {
    try {
      final name = 'pro';
      final response = await _api.dioInstance.post(
        '/$name/initList',
        queryParameters: {'offset': offset, 'limit': limit},
        data: filters,
      );
      return {'success': true, 'data': response.data?['list'] ?? [], 'count': response.data?['count'] ?? 0};
    } catch (e) {
      return {'success': false, 'message': '获取流程列表失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getMods() async {
    try {
      final response = await _api.dioInstance.post('/pro/initMods');
      return {'success': true, 'data': response.data ?? []};
    } catch (e) {
      return {'success': false, 'message': '获取模块列表失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getWorkflowDetail(int proId) async {
    try {
      final response = await _api.dioInstance.get('/pro/get/$proId');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取流程详情失败: $e'};
    }
  }

  Future<Map<String, dynamic>> submitWorkflow(dynamic formData) async {
    try {
      final response = await _api.dioInstance.post('/pro/add', data: formData);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '提交流程失败: $e'};
    }
  }

  Future<Map<String, dynamic>> approveWorkflow(int proId, dynamic data) async {
    try {
      final response = await _api.dioInstance.post('/pro/handle/$proId', data: data);
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '审批流程失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getFormSchema(int modId) async {
    try {
      final response = await _api.dioInstance.get('/pro/getFormSchema/$modId');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取表单失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getApprovers() async {
    try {
      final response = await _api.dioInstance.get('/user/approvers');
      return {
        'success': true,
        'data': response.data is List ? response.data : (response.data?['list'] ?? []),
      };
    } catch (e) {
      return {'success': false, 'message': '获取审批人失败: $e'};
    }
  }
}
