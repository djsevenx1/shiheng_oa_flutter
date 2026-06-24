import 'package:dio/dio.dart' as dio;
import 'dart:convert' as _json;

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
  /// 老 App 真实：/oa/mod/init/:modId (curl 200)，返 {formView, tableSchema, module, flowConfig}
  /// tableSchema 才是真字段定义：[{id, name, ctrl, required, fields, flagDetail}]
  /// formView 是 HTML 模板（仅用于显示）
  Future<Map<String, dynamic>> getFormSchema(int modId) async {
    try {
      final response = await _api.dioInstance.get('/oa/mod/init/$modId');
      final data = response.data;
      if (data is! Map) {
        return {'success': false, 'message': '表单 schema 返回数据格式不正确'};
      }
      final module = (data['module'] is Map) ? data['module'] : data;
      final List<dynamic> rawSchema =
          (data['tableSchema'] is List) ? data['tableSchema'] :
          (data['tableSchema'] is String ? _parseJsonString(data['tableSchema']) : []);

      final fields = rawSchema.whereType<Map>().map((f) => _parseTableSchemaField(f)).toList();
      final detailFields = <String, List<Map<String, dynamic>>>{};
      for (final f in fields) {
        if (f['flagDetail'] == true && f['fields'] is List) {
          detailFields[f['name']?.toString() ?? ''] =
              (f['fields'] as List).cast<Map<String, dynamic>>();
        }
      }

      final result = <String, dynamic>{
        'moduleName': module['name']?.toString() ?? module['moduleName']?.toString() ?? '流程表单',
        'appKey': module['tableKey']?.toString() ?? module['appKey']?.toString() ?? '',
        'tableName': module['tableKey']?.toString() ?? module['tableName']?.toString() ?? '',
        'fields': fields,
        'detailFields': detailFields,
        'formView': data['formView']?.toString() ?? '',
        'module': module,
        'flowConfig': data['flowConfig'] is String ? _parseJsonString(data['flowConfig']) : data['flowConfig'],
      };
      return {'success': true, 'data': result};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取表单失败: $e'};
    }
  }

  /// 解析单个 tableSchema 字段为 Flutter 端字段定义
  Map<String, dynamic> _parseTableSchemaField(Map f) {
    final id = f['id']?.toString() ?? '';
    final name = f['name']?.toString() ?? id;
    final ctrl = f['ctrl']?.toString() ?? 'text';
    final required = f['required'] == true;
    final flagDetail = f['flagDetail'] == true;
    final flagNew = f['flagNew'] == true;
    final config = f['config']?.toString();
    final subFields = (f['fields'] is List)
        ? (f['fields'] as List).whereType<Map>().map((sf) => _parseTableSchemaField(Map<String, dynamic>.from(sf))).toList()
        : <Map<String, dynamic>>[];

    return {
      'name': id,
      'label': name,
      'type': _mapCtrl(ctrl),
      'ctrl': ctrl,
      'required': required,
      'flagDetail': flagDetail,
      'flagNew': flagNew,
      'config': config,
      'fields': subFields,
      'defaultValue': f['defaultValue'] ?? f['default'],
    };
  }

  /// 解析老 OA ctrl 字段类型 → Flutter 端类型
  String _mapCtrl(String ctrl) {
    switch (ctrl) {
      case 'text':
      case 'sequence':
      case 'info':
      case 'logs':
      case 'name':
      case 'department':
        return 'text';
      case 'number':
      case 'num':
      case 'money':
        return 'number';
      case 'date':
        return 'date';
      case 'datetime':
      case 'current':
        return 'datetime';
      case 'longtext':
      case 'textarea':
        return 'textarea';
      case 'select':
      case 'dict':
      case 'dictionary':
        return 'select';
      case 'radio':
        return 'radio';
      case 'checkbox':
        return 'checkbox';
      case 'user':
      case 'users':
        return 'user';
      case 'file':
      case 'attachment':
        return 'file';
      default:
        return 'text';
    }
  }

  /// 解析 JSON 字符串（老 OA 后端有时返 JSON 字符串）
  List<dynamic> _parseJsonString(dynamic s) {
    if (s is! String || s.isEmpty) return [];
    try {
      final v = _json.decode(s);
      if (v is List) return v;
    } catch (_) {}
    return [];
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
  /// 老 App 真实：POST /oa/pro/handle body=formData
  /// 之前错用 /oa/flow/submit/:modId (400)
  /// 老 OA 实际需要 formData + appKey (tableKey) + modId
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

  /// 解析老 OA formView HTML 字符串，提取字段
  /// HTML 格式：<tr><td class="form-label">受订单号</td><td class="form-ctrl" id="os_no">{{os_no}}</td></tr>
  /// 字段 = id="xxx" 的 td 元素（class="form-ctrl"）
  /// 标签 = 同行 form-label 的内容
  List<Map<String, dynamic>> _parseFormViewHtml(String html) {
    final out = <Map<String, dynamic>>[];
    if (html.isEmpty) return out;
    try {
      // 找所有 <tr>...</tr>
      final trRegex = RegExp(r'<tr[^>]*>(.*?)</tr>', dotAll: true);
      final tdRegex = RegExp(r'<td[^>]*?(?:\s+id="([^"]+)")?[^>]*?class="([^"]*)"[^>]*?>(.*?)</td>',
          dotAll: true);
      final placeholderRegex = RegExp(r'\{\{([a-zA-Z_][a-zA-Z0-9_]*)\}\}');
      final htmlTagStrip = RegExp(r'<[^>]+>');
      final trMatches = trRegex.allMatches(html);
      for (final tr in trMatches) {
        // 收集本行所有 td（label + ctrl 配对）
        final tds = tdRegex.allMatches(tr.group(1) ?? '').toList();
        // 找 label-ctrl 对
        for (int i = 0; i + 1 < tds.length; i += 2) {
          final labelTd = tds[i];
          final ctrlTd = tds[i + 1];
          if (!labelTd.group(2)!.contains('form-label')) continue;
          if (!ctrlTd.group(2)!.contains('form-ctrl')) continue;
          // 提取标签文字（去 HTML 标签）
          final labelHtml = labelTd.group(3) ?? '';
          final label = labelHtml.replaceAll(htmlTagStrip, '').trim();
          // 提取字段名
          String? name = ctrlTd.group(1);
          if (name == null || name.isEmpty) {
            // 从 {{xxx}} 占位符提取
            final ctrlHtml = ctrlTd.group(3) ?? '';
            final m = placeholderRegex.firstMatch(ctrlHtml);
            name = m?.group(1);
          }
          if (name == null || name.isEmpty) continue;
          out.add({
            'name': name,
            'label': label.isEmpty ? name : label,
            'type': _guessType(name, ctrlTd.group(3) ?? ''),
            'required': false,
          });
        }
      }
    } catch (_) {}
    return out;
  }

  /// 猜测字段类型（按字段名规则）
  String _guessType(String name, String ctrlHtml) {
    final n = name.toLowerCase();
    if (n.contains('date') || n.contains('dd') || n.endsWith('_dd')) return 'date';
    if (n.contains('time') || n.contains('datetime')) return 'datetime';
    if (n.contains('num') || n.contains('qty') || n.contains('count') ||
        n.contains('je') || n.contains('amount') || n.contains('hj') ||
        n.contains('sl') || n.contains('price')) return 'number';
    if (n.contains('memo') || n.contains('remark') || n.contains('note') ||
        n.contains('des') || n.contains('content')) return 'textarea';
    if (n.contains('no') || n.contains('id') || n.endsWith('_id')) return 'text';
    if (ctrlHtml.contains('select') || ctrlHtml.contains('option')) return 'select';
    return 'text';
  }

  /// 解析老 OA schema 为 Flutter 端 FormFieldSchema 列表（兼容旧版）
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
