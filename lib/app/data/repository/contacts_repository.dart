import 'package:dio/dio.dart' as dio;
import 'package:get_storage/get_storage.dart';

import '../providers/api_provider.dart';

/// 通讯录仓库
/// 真实接口：/oa/common/groups（部门树）+ /oa/human/initList（成员）
class ContactsRepository {
  ContactsRepository({ApiProvider? api, GetStorage? storage})
      : _api = api ?? ApiProvider(),
        _storage = storage ?? GetStorage();

  final ApiProvider _api;
  final GetStorage _storage;

  /// 部门树（GET /oa/common/groups）
  /// 返回结构因 OA 版本而异：通常是 list<{id, name, parentId, children:[]}>
  Future<Map<String, dynamic>> getDepartmentTree() async {
    try {
      final response = await _api.dioInstance.get('/oa/common/groups');
      final data = response.data;
      if (data is List) {
        return {'success': true, 'data': data, 'flat': _flattenGroups(data)};
      }
      if (data is Map && data['list'] is List) {
        final list = (data['list'] as List);
        return {'success': true, 'data': list, 'flat': _flattenGroups(list)};
      }
      return {'success': true, 'data': [], 'flat': []};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': [], 'flat': []};
    } catch (e) {
      return {'success': false, 'message': '获取部门失败: $e', 'data': [], 'flat': []};
    }
  }

  /// 部门成员（GET /oa/human/initList?limit&offset）
  /// 备注：老 OA 这个接口是全员列表，部门筛选要靠前端用 groupId 过滤
  Future<Map<String, dynamic>> getAllMembers({int limit = 200, int offset = 0}) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/human/initList',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return _parseListResponse(response.data);
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': [], 'count': 0};
    } catch (e) {
      return {'success': false, 'message': '获取成员失败: $e', 'data': [], 'count': 0};
    }
  }

  /// 搜索成员（POST /oa/u/initList?limit&offset body={humanSearch:{name:"%X%"}}）
  Future<Map<String, dynamic>> searchMembers(String keyword, {int limit = 50, int offset = 0}) async {
    try {
      final response = await _api.dioInstance.post(
        '/oa/u/initList?limit=$limit&offset=$offset',
        data: {
          'humanSearch': {
            'name': '%${keyword.trim()}%',
          },
        },
      );
      return _parseListResponse(response.data);
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': [], 'count': 0};
    } catch (e) {
      return {'success': false, 'message': '搜索失败: $e', 'data': [], 'count': 0};
    }
  }

  /// 用户详情（GET /oa/user/getUserOne?id=...）
  Future<Map<String, dynamic>> getUserDetail(String id) async {
    try {
      final response = await _api.dioInstance.get('/oa/user/getUserOne', queryParameters: {'id': id});
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取详情失败: $e'};
    }
  }

  /// 当前用户（GET /oa/user/current）
  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _api.dioInstance.get('/oa/user/current');
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取当前用户失败: $e'};
    }
  }

  /// 缓存部门树，避免每次启动都拉
  Future<void> cacheDepartments(List<dynamic> data) async {
    try {
      await _storage.write('contacts_departments', data);
    } catch (_) {}
  }

  List<dynamic>? getCachedDepartments() {
    try {
      return _storage.read('contacts_departments');
    } catch (_) {
      return null;
    }
  }

  /// 把嵌套的部门树拍平成 list<{id, name, depth, parentId}>
  List<Map<String, dynamic>> _flattenGroups(List<dynamic> groups, {int depth = 0, String? parentId}) {
    final out = <Map<String, dynamic>>[];
    for (final g in groups) {
      if (g is! Map) continue;
      final m = g.cast<String, dynamic>();
      final id = (m['id'] ?? m['groupId'] ?? '').toString();
      final name = (m['name'] ?? m['groupName'] ?? '').toString();
      if (id.isNotEmpty) {
        out.add({'id': id, 'name': name, 'depth': depth, 'parentId': parentId ?? m['parentId']?.toString()});
      }
      final children = m['children'] ?? m['subGroups'];
      if (children is List && children.isNotEmpty) {
        out.addAll(_flattenGroups(children, depth: depth + 1, parentId: id));
      }
    }
    return out;
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
