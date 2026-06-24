import 'package:dio/dio.dart' as dio;

import '../providers/api_provider.dart';

/// 工作流仓库
/// 老 App 反编译真实接口：
/// - /oa/access/getAccess/0                       流程模板列表（cats/catsMap/mods）
/// - /oa/mod/init/:modId                          加载模块定义（含 schema/fields）
/// - /oa/pro/init/:proId                          流程实例初始化
/// - /oa/pro/handle                               提交流程/审批（POST）
/// - /oa/pro/withdraw                             撤回
/// - /oa/handle/initList?state=                   流程列表（state=0/1/2）
/// - /oa/flow/form/:formId/view/:objectId/process/:processId  自由流程表单
/// - /oa/flow/approve/:processId                  自由流程审批
class WorkflowRepository {
  WorkflowRepository({ApiProvider? api}) : _api = api ?? ApiProvider();

  final ApiProvider _api;

  /// 流程模板列表（GET /oa/access/getAccess/0）
  Future<Map<String, dynamic>> getWorkflowTemplates() async {
    try {
      final response = await _api.dioInstance.get('/oa/access/getAccess/0');
      final data = response.data;
      if (data is Map) {
        final cats = (data['cats'] is List) ? List<Map<String, dynamic>>.from(data['cats']) : <Map<String, dynamic>>[];
        final catsMap = (data['catsMap'] is Map) ? Map<String, dynamic>.from(data['catsMap']) : <String, dynamic>{};
        final mods = (data['mods'] is List) ? List<Map<String, dynamic>>.from(data['mods']) : <Map<String, dynamic>>[];

        if (mods.isEmpty) {
          final flat = <Map<String, dynamic>>[];
          catsMap.forEach((k, v) {
            if (v is List) {
              for (final m in v) {
                if (m is Map) flat.add(Map<String, dynamic>.from(m));
              }
            }
          });
          if (flat.isNotEmpty) {
            return {'success': true, 'data': flat, 'count': flat.length,
                    'cats': cats, 'catsMap': catsMap};
          }
        }
        return {'success': true, 'data': mods, 'count': mods.length,
                'cats': cats, 'catsMap': catsMap};
      }
      if (data is List) {
        return {'success': true, 'data': data, 'count': data.length};
      }
      return {'success': true, 'data': [], 'count': 0};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': [], 'count': 0};
    } catch (e) {
      return {'success': false, 'message': '获取流程模板失败: $e', 'data': [], 'count': 0};
    }
  }

  /// 流程表单 schema（GET /oa/mod/init/:modId）
  /// 老 App 真实接口：domain + '/oa/mod/init/' + modId
  /// 之前错用 /oa/flow/config/:modId (返 2B 空)，应改 mod/init
  Future<Map<String, dynamic>> getFormSchema(int modId) async {
    try {
      // 老 App 真实：/oa/mod/init/:modId (curl 200)，/oa/flow/config/:modId 返空
      final response = await _api.dioInstance.get('/oa/mod/init/$modId');
      final data = response.data;
      if (data is Map) {
        // 老 OA 流程 schema 在 data.module 里
        final module = data['module'] is Map ? data['module'] : data;
        final result = <String, dynamic>{
          'moduleName': module['name']?.toString() ?? module['moduleName']?.toString() ?? '流程表单',
          'appKey': module['appKey']?.toString() ?? module['app_key']?.toString() ?? '',
          'tableName': module['tableName']?.toString() ?? module['name']?.toString() ?? '',
          'fields': _parseSchema(module),
        };
        return {'success': true, 'data': result};
      }
      return {'success': false, 'message': '表单 schema 返回数据格式不正确'};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取表单失败: $e'};
    }
  }

  /// 流程实例列表（GET /oa/handle/initList）
  Future<Map<String, dynamic>> getWorkflowList({
    required String status, // 'todo' / 'running' / 'done'
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      // state: 0=待办 1=进行中 2=已完成
      int state = 1;
      if (status == 'todo') state = 0;
      if (status == 'done') state = 2;
      final response = await _api.dioInstance.get(
        '/oa/handle/initList',
        queryParameters: {'limit': limit, 'offset': offset, 'state': state},
      );
      return _parseListResponse(response.data);
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': [], 'count': 0};
    } catch (e) {
      return {'success': false, 'message': '获取流程列表失败: $e', 'data': [], 'count': 0};
    }
  }

  /// 流程详情（GET /oa/pro/init/:proId）
  Future<Map<String, dynamic>> getWorkflowDetail(int proId) async {
    try {
      final response = await _api.dioInstance.get('/oa/pro/init/$proId');
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取流程详情失败: $e'};
    }
  }

  /// 提交流程（POST /oa/pro/handle）
  Future<Map<String, dynamic>> submitWorkflow({
    required int modId,
    required Map<String, dynamic> formData,
    String appKey = '',
  }) async {
    try {
      // 老 App 真实：POST /oa/pro/handle  body=formData
      // 之前错用 /oa/flow/submit/:modId (400)
      final response = await _api.dioInstance.post('/oa/pro/handle', data: {
        'formData': formData,
        'appKey': appKey,
        'isDraft': false,
        'modId': modId,
      });
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '提交失败: $e'};
    }
  }

  /// 审批（POST /oa/pro/handle）
  Future<Map<String, dynamic>> approveWorkflow({
    required int proId,
    required String result, // 'pass' / 'reject'
    String comment = '',
  }) async {
    try {
      final response = await _api.dioInstance.post('/oa/pro/handle', data: {
        'id': proId,
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

  /// 撤回（POST /oa/pro/withdraw）
  Future<Map<String, dynamic>> withdrawWorkflow(int proId) async {
    try {
      final response = await _api.dioInstance.post('/oa/pro/withdraw', data: {'id': proId});
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '撤回失败: $e'};
    }
  }

  /// 解析老 OA schema 为 Flutter 端 FormFieldSchema 列表
  List<Map<String, dynamic>> _parseSchema(dynamic data) {
    final out = <Map<String, dynamic>>[];
    try {
      final config = (data is Map) ? data['config'] : null;
      if (config is! Map) return out;
      final init = config['init'];
      if (init is! Map) return out;
      final schema = init['schema'];
      if (schema is! Map) return out;

      schema.forEach((key, value) {
        if (value is! Map) return;
        final type = (value['type'] ?? 'text').toString();
        if (['label', 'group', 'divider', 'html'].contains(type)) return;

        out.add({
          'name': key.toString(),
          'label': (value['label'] ?? value['name'] ?? key).toString(),
          'type': _mapType(type),
          'required': value['required'] == true,
          'placeholder': value['placeholder']?.toString(),
          'options': (value['options'] is List) ? List<Map<String, dynamic>>.from(value['options']) : null,
          'defaultValue': value['defaultValue'] ?? value['default'],
          'helpText': value['helpText']?.toString(),
        });
      });
    } catch (_) {}
    return out;
  }

  /// 老 OA 类型 → Flutter 类型
  String _mapType(String oldType) {
    switch (oldType) {
      case 'text':
      case 'string':
        return 'text';
      case 'number':
      case 'int':
      case 'float':
        return 'number';
      case 'date':
        return 'date';
      case 'datetime':
        return 'datetime';
      case 'textarea':
      case 'longtext':
        return 'textarea';
      case 'select':
      case 'dropdown':
        return 'select';
      case 'radio':
        return 'radio';
      case 'checkbox':
        return 'checkbox';
      case 'file':
      case 'attachment':
        return 'file';
      default:
        return 'text';
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
