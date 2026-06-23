import 'package:dio/dio.dart' as dio;

import '../providers/api_provider.dart';

/// 工作流仓库
/// 真实接口（老 OA inspinia）：
/// - /oa/common/workflows        流程模板列表
/// - /oa/flow/config/{id}        流程表单 schema（含 fields 列表）
/// - /oa/flow/initList/{key}     流程实例列表（todo/running/done）
/// - /oa/flow/submit/{id}        提交流程
/// - /oa/flow/approve/           审批
/// - /oa/flow/withdraw/          撤回
class WorkflowRepository {
  WorkflowRepository({ApiProvider? api}) : _api = api ?? ApiProvider();

  final ApiProvider _api;

  /// 流程模板列表（GET /oa/common/workflows）
  /// 返回 [{id, name, description, ...}]（后端没配置时是 []）
  Future<Map<String, dynamic>> getWorkflowTemplates() async {
    try {
      final response = await _api.dioInstance.get('/oa/common/workflows');
      final data = response.data;
      if (data is List) {
        return {'success': true, 'data': data, 'count': data.length};
      }
      if (data is Map && data['list'] is List) {
        final list = data['list'] as List;
        return {'success': true, 'data': list, 'count': list.length};
      }
      return {'success': true, 'data': [], 'count': 0};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': [], 'count': 0};
    } catch (e) {
      return {'success': false, 'message': '获取流程模板失败: $e', 'data': [], 'count': 0};
    }
  }

  /// 流程表单 schema（GET /oa/flow/config/{id}）
  /// 返回 {name, config: {...}, fields, steps, currentStep, schema}
  /// 真实响应很复杂；我们挑出 view 需要的：moduleName + schema 字段
  Future<Map<String, dynamic>> getFormSchema(int modId) async {
    try {
      final response = await _api.dioInstance.get('/oa/flow/config/$modId');
      final data = response.data;
      if (data is Map) {
        // 解析老 OA 格式
        final result = <String, dynamic>{
          'moduleName': data['name']?.toString() ?? '流程表单',
          'appKey': data['app_key']?.toString() ?? '',
          'tableName': data['name']?.toString() ?? '',
          'fields': _parseSchema(data),
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

  /// 流程实例列表（GET /oa/flow/initList/{todo|running|done}）
  Future<Map<String, dynamic>> getWorkflowList({
    required String status, // 'todo' / 'running' / 'done'
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/flow/initList/$status',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return _parseListResponse(response.data);
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': [], 'count': 0};
    } catch (e) {
      return {'success': false, 'message': '获取流程列表失败: $e', 'data': [], 'count': 0};
    }
  }

  /// 流程详情（GET /oa/flow/getDetail/{formId}/{objectId}）
  Future<Map<String, dynamic>> getWorkflowDetail(String formId, String objectId) async {
    try {
      final response = await _api.dioInstance.get('/oa/flow/getDetail/$formId/$objectId');
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取流程详情失败: $e'};
    }
  }

  /// 提交流程（POST /oa/flow/submit/{id}）
  /// [formData] 实际参数是 {formData: {...}, nextStep, appKey, isDraft, groupId, ...}
  Future<Map<String, dynamic>> submitWorkflow({
    required int modId,
    required Map<String, dynamic> formData,
    String appKey = '',
  }) async {
    try {
      final response = await _api.dioInstance.post('/oa/flow/submit/$modId', data: {
        'formData': formData,
        'appKey': appKey,
        'isDraft': false,
      });
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '提交失败: $e'};
    }
  }

  /// 审批（POST /oa/flow/approve/）
  Future<Map<String, dynamic>> approveWorkflow({
    required String processId,
    required String result, // 'pass' / 'reject'
    String comment = '',
  }) async {
    try {
      final response = await _api.dioInstance.post('/oa/flow/approve/', data: {
        'id': processId,
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
  Future<Map<String, dynamic>> withdrawWorkflow(String processId) async {
    try {
      final response = await _api.dioInstance.post('/oa/flow/withdraw/', data: {'id': processId});
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '撤回失败: $e'};
    }
  }

  /// 解析老 OA schema 为 Flutter 端 FormFieldSchema 列表
  /// 老 OA 的 schema 字段：{type, label, required, options, defaultValue, placeholder, ...}
  List<Map<String, dynamic>> _parseSchema(dynamic data) {
    final out = <Map<String, dynamic>>[];
    try {
      // 老 OA 数据结构：data.config.init.schema.{fieldName: {type, label, ...}}
      final config = (data is Map) ? data['config'] : null;
      if (config is! Map) return out;
      final init = config['init'];
      if (init is! Map) return out;
      final schema = init['schema'];
      if (schema is! Map) return out;

      schema.forEach((key, value) {
        if (value is! Map) return;
        // 跳过非字段类型
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
