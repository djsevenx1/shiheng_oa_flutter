import 'package:dio/dio.dart' as dio;

import '../providers/api_provider.dart';

/// 工作流/我的申请仓库
/// 老 OA 的工作流通过 `/oa/flow/*` + `/oa/wf/*` 暴露
class MyApplicationRepository {
  MyApplicationRepository({ApiProvider? api}) : _api = api ?? ApiProvider();

  final ApiProvider _api;

  /// 我发起的流程（GET /oa/flow/initList/running）
  Future<Map<String, dynamic>> getMyRunning({int limit = 20, int offset = 0}) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/flow/initList/running',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return _parseListResponse(response.data);
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': [], 'count': 0};
    } catch (e) {
      return {'success': false, 'message': '获取进行中流程失败: $e', 'data': [], 'count': 0};
    }
  }

  /// 待我审批（GET /oa/flow/initList/todo）
  Future<Map<String, dynamic>> getTodo({int limit = 20, int offset = 0}) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/flow/initList/todo',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return _parseListResponse(response.data);
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': [], 'count': 0};
    } catch (e) {
      return {'success': false, 'message': '获取待办失败: $e', 'data': [], 'count': 0};
    }
  }

  /// 我已审批/已完成（GET /oa/flow/initList/done）
  Future<Map<String, dynamic>> getDone({int limit = 20, int offset = 0}) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/flow/initList/done',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return _parseListResponse(response.data);
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': [], 'count': 0};
    } catch (e) {
      return {'success': false, 'message': '获取已完成失败: $e', 'data': [], 'count': 0};
    }
  }

  /// 流程详情（GET /oa/flow/getDetail/{formId}/{objectId}）
  Future<Map<String, dynamic>> getFlowDetail(String formId, String objectId) async {
    try {
      final response = await _api.dioInstance.get('/oa/flow/getDetail/$formId/$objectId');
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取流程详情失败: $e'};
    }
  }

  /// 审批（POST /oa/flow/approve/）
  /// [result]: 'pass' / 'reject'
  Future<Map<String, dynamic>> approve({
    required String id,
    required String result,
    String comment = '',
  }) async {
    try {
      final response = await _api.dioInstance.post('/oa/flow/approve/', data: {
        'id': id,
        'result': result,
        'comment': comment,
      });
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '审批失败: $e'};
    }
  }

  /// 撤回（POST /oa/flow/withdraw/）
  Future<Map<String, dynamic>> withdraw(String id) async {
    try {
      final response = await _api.dioInstance.post('/oa/flow/withdraw/', data: {'id': id});
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '撤回失败: $e'};
    }
  }

  /// 通用：根据 tab key 拉对应列表
  Future<Map<String, dynamic>> getListByTab(String tabKey, {int limit = 20, int offset = 0}) async {
    switch (tabKey) {
      case 'todo':
        return getTodo(limit: limit, offset: offset);
      case 'done':
        return getDone(limit: limit, offset: offset);
      case 'running':
      default:
        return getMyRunning(limit: limit, offset: offset);
    }
  }

  Map<String, dynamic> _parseListResponse(dynamic data) {
    if (data is Map) {
      final list = (data['list'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final count = (data['count'] as num?)?.toInt() ?? list.length;
      return {'success': true, 'data': list, 'count': count};
    }
    if (data is List) {
      final list = data.cast<Map<String, dynamic>>();
      return {'success': true, 'data': list, 'count': list.length};
    }
    return {'success': true, 'data': [], 'count': 0};
  }
}
