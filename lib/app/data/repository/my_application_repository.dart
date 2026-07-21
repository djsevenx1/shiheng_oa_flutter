import 'package:dio/dio.dart' as dio;

import '../providers/api_provider.dart';

/// 工作流/我的申请仓库
/// 老 App 反编译真实接口（workflow.js + config/api.js $api 封装）：
/// sate 模式 name='handle'，initList 实际请求：
///   POST /oa/handle/initList?limit=&offset=  body=filter对象
/// filter 由 workflow.js 设置：
///   待处理(全部): {preHandle: null}
///   待审批:       {preHandle: null, handle: null}
///   待编辑:       {preHandle: null, edit: null}
///   历史(全部):   {related: null}
///   已发起的:     {related: null, submitted: null}
///   已审批的:     {related: null, handled: null}
/// 返回 {list: [...], count: N, filtersStr: "..."}
/// - /oa/handle/getPage?limit=&offset=  POST body={filtersStr}  分页加载
/// - /oa/pro/init/:proId                          流程实例初始化
/// - /oa/pro/handle                               提交流程/审批
/// - /oa/pro/withdraw                             撤回
/// - /oa/mod/init/:modId                          加载流程定义
class MyApplicationRepository {
  MyApplicationRepository({ApiProvider? api}) : _api = api ?? ApiProvider();

  final ApiProvider _api;

  /// 待办流程（待我审批）：POST /oa/handle/initList body={preHandle: null}
  Future<Map<String, dynamic>> getTodo({int limit = 20, int offset = 0}) async {
    return _postInitList({'preHandle': null}, limit: limit, offset: offset);
  }

  /// 历史流程（当前用户相关）：POST /oa/pro/initList body={related: null}
  Future<Map<String, dynamic>> getHistory({int limit = 20, int offset = 0}) async {
    try {
      final response = await _api.dioInstance.post(
        '/oa/pro/initList',
        queryParameters: {'limit': limit, 'offset': offset},
        data: {'related': null},
      );
      return _parseListResponse(response.data);
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': [], 'count': 0};
    } catch (e) {
      return {'success': false, 'message': '获取历史流程失败: $e', 'data': [], 'count': 0};
    }
  }

  /// 已发起的流程（我发起的）：POST /oa/handle/initList body={related: null, submitted: null}
  Future<Map<String, dynamic>> getMyRunning({int limit = 20, int offset = 0}) async {
    return _postInitList({'related': null, 'submitted': null}, limit: limit, offset: offset);
  }

  /// 已审批的流程（我审批过的）：POST /oa/handle/initList body={related: null, handled: null}
  Future<Map<String, dynamic>> getDone({int limit = 20, int offset = 0}) async {
    return _postInitList({'related': null, 'handled': null}, limit: limit, offset: offset);
  }

  /// 通用 POST /oa/handle/initList
  Future<Map<String, dynamic>> _postInitList(Map<String, dynamic> filter, {int limit = 20, int offset = 0}) async {
    try {
      final response = await _api.dioInstance.post(
        '/oa/handle/initList',
        queryParameters: {'limit': limit, 'offset': offset},
        data: filter,
      );
      return _parseListResponse(response.data);
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': [], 'count': 0};
    } catch (e) {
      return {'success': false, 'message': '获取流程列表失败: $e', 'data': [], 'count': 0};
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
  Future<Map<String, dynamic>> withdraw(dynamic proId) async {
    try {
      final id = proId is int ? proId : int.tryParse(proId.toString()) ?? 0;
      final response = await _api.dioInstance.post('/oa/pro/withdraw', data: {'id': id});
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '撤回失败: $e'};
    }
  }

  /// 审批
  Future<Map<String, dynamic>> approveWorkflow({
    required dynamic proId,
    required String result, // 'pass' / 'reject'
    String comment = '',
  }) async {
    try {
      final id = proId is int ? proId : int.tryParse(proId.toString()) ?? 0;
      final response = await _api.dioInstance.post('/oa/pro/handle', data: {
        'id': id,
        'result': result,
        'comment': comment,
        'isApprove': true,
      });
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '审批失败: $e'};
    }
  }

  /// 获取模块列表（POST /oa/handle/initMods）
  /// 老 App ProToDoCtrl: 调用 initMods 获取模块列表，构建 modsMap(modId→name) 用于列表标题
  /// 返回 {success, data: {modId: moduleName, ...}}
  Future<Map<String, dynamic>> getModules() async {
    try {
      final response = await _api.dioInstance.post(
        '/oa/handle/initMods',
        queryParameters: {'filtersStr': ''},
      );
      final list = response.data;
      final modsMap = <int, String>{};
      if (list is List) {
        for (final m in list) {
          if (m is Map) {
            final id = m['id'];
            final name = m['name']?.toString() ?? '';
            final modId = id is int ? id : int.tryParse(id?.toString() ?? '') ?? 0;
            if (modId > 0 && name.isNotEmpty) {
              modsMap[modId] = name;
            }
          }
        }
      }
      return {'success': true, 'data': modsMap};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': <int, String>{}};
    } catch (e) {
      return {'success': false, 'message': '获取模块列表失败: $e', 'data': <int, String>{}};
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
