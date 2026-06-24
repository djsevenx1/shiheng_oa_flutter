import 'package:dio/dio.dart' as dio;

import '../providers/api_provider.dart';

/// 工作流/我的申请仓库
/// 老 App 反编译真实接口（workflow.js / engine/core.js）：
/// - /oa/handle/initList?limit=&offset=           待办/已办/进行中（state 过滤）
/// - /oa/pro/init/:proId                          流程实例初始化
/// - /oa/pro/flag/withdraw/:proId                 是否可撤回
/// - /oa/pro/save                                 暂存草稿
/// - /oa/pro/handle                               提交流程/审批
/// - /oa/pro/withdraw                             撤回
/// - /oa/pro/getUsers                             候选审批人
/// - /oa/pro/getLastAndCurrentHandlers            上一步/当前处理人
/// - /oa/pro/drop/:proId                          流程删除
/// - /oa/mod/init/:modId                          加载流程定义
/// - /oa/flow/form/:formId/view/:objectId/process/:processId  自由流程表单
/// - /oa/flow/approve/:processId/run              自由流程逐级审批
/// - /oa/flow/approve/:processId                  自由流程审批
/// - /oa/flow/withdraw/:processId                 自由流程撤回
class MyApplicationRepository {
  MyApplicationRepository({ApiProvider? api}) : _api = api ?? ApiProvider();

  final ApiProvider _api;

  /// 我发起的流程（进行中）：state=1 过滤 /oa/handle/initList
  Future<Map<String, dynamic>> getMyRunning({int limit = 20, int offset = 0}) async {
    try {
      // 老 App 真实接口：/oa/handle/initList?limit=10 (curl 200，381190 条数据)
      // 之前错用 /oa/flow/initList/running (404)
      final response = await _api.dioInstance.get(
        '/oa/handle/initList',
        queryParameters: {'limit': limit, 'offset': offset, 'state': 1},
      );
      return _parseListResponse(response.data);
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': [], 'count': 0};
    } catch (e) {
      return {'success': false, 'message': '获取进行中流程失败: $e', 'data': [], 'count': 0};
    }
  }

  /// 待我审批：state=0 过滤
  Future<Map<String, dynamic>> getTodo({int limit = 20, int offset = 0}) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/handle/initList',
        queryParameters: {'limit': limit, 'offset': offset, 'state': 0},
      );
      return _parseListResponse(response.data);
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': [], 'count': 0};
    } catch (e) {
      return {'success': false, 'message': '获取待办失败: $e', 'data': [], 'count': 0};
    }
  }

  /// 已完成：state=2
  Future<Map<String, dynamic>> getDone({int limit = 20, int offset = 0}) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/handle/initList',
        queryParameters: {'limit': limit, 'offset': offset, 'state': 2},
      );
      return _parseListResponse(response.data);
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': [], 'count': 0};
    } catch (e) {
      return {'success': false, 'message': '获取已完成失败: $e', 'data': [], 'count': 0};
    }
  }

  /// 流程详情（GET /oa/pro/init/:proId 或 /oa/flow/form/:formId/view/:objectId/process/:processId）
  Future<Map<String, dynamic>> getFlowDetail({int? proId, int? processId, int? formId, int? objectId}) async {
    try {
      // 老 App 默认走 /oa/pro/init/:proId；如果有 processId/formId 走 flow/form
      if (processId != null && formId != null) {
        final url = '/oa/flow/form/$formId/view/$objectId/process/$processId';
        final response = await _api.dioInstance.get(url);
        return {'success': true, 'data': response.data};
      }
      if (proId != null) {
        final response = await _api.dioInstance.get('/oa/pro/init/$proId');
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'message': '缺少必要参数'};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取流程详情失败: $e'};
    }
  }

  /// 提交流程/审批（POST /oa/pro/handle）
  Future<Map<String, dynamic>> submit(Map<String, dynamic> formData) async {
    try {
      final response = await _api.dioInstance.post('/oa/pro/handle', data: formData);
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '提交失败: $e'};
    }
  }

  /// 暂存草稿（POST /oa/pro/save）
  Future<Map<String, dynamic>> saveDraft(Map<String, dynamic> formData) async {
    try {
      final response = await _api.dioInstance.post('/oa/pro/save', data: formData);
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '暂存失败: $e'};
    }
  }

  /// 撤回（POST /oa/pro/withdraw）
  Future<Map<String, dynamic>> withdraw(int proId) async {
    try {
      final response = await _api.dioInstance.post('/oa/pro/withdraw', data: {'id': proId});
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
