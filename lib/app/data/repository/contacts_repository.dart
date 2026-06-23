import 'package:dio/dio.dart' as dio;
import 'package:get_storage/get_storage.dart';

import '../providers/api_provider.dart';

/// 通讯录仓库
/// 真实接口：/oa/common/groups（部门树）+ /oa/u/initList（人员列表）
class ContactsRepository {
  ContactsRepository({ApiProvider? api, GetStorage? storage})
      : _api = api ?? ApiProvider(),
        _storage = storage ?? GetStorage();

  final ApiProvider _api;
  final GetStorage _storage;

  /// 部门树（GET /oa/common/groups）
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

  /// 全员（GET /oa/u/initList?limit&offset）
  /// 真实字段：{id, login_name, name, userGroup, groupId, userRole, userId, mobile, email, icon}
  /// 关键修复：之前用 /oa/human/initList 后端返回 0，真实接口是 /oa/u/initList 有 155 人
  Future<Map<String, dynamic>> getAllMembers({int limit = 200, int offset = 0}) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/u/initList',
        queryParameters: {'limit': limit, 'offset': offset},
      );
      return _parseListResponse(response.data);
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': [], 'count': 0};
    } catch (e) {
      return {'success': false, 'message': '获取成员失败: $e', 'data': [], 'count': 0};
    }
  }

  /// 按部门筛选成员（前端用 groupId 过滤）
  /// 老 OA 字段可能是 groupId（数字）或 userGroup（字符串）
  List<Map<String, dynamic>> filterByDept(List<dynamic> all, String groupId) {
    return all
        .where((m) {
          if (m is! Map) return false;
          final gid = m['groupId'];
          return gid?.toString() == groupId;
        })
        .cast<Map<String, dynamic>>()
        .toList();
  }

  /// 搜索成员（GET /oa/u/initList?humanSearch.name=%X%&limit&offset）
  Future<Map<String, dynamic>> searchMembers(String keyword, {int limit = 50, int offset = 0}) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/u/initList',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'humanSearch.name': '%${keyword.trim()}%',
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

  /// 缓存部门树
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

  /// 把嵌套部门树拍平成 [{id, name, depth, parentId}]
  /// 老 OA 返回的是平铺 [{id, name, parentId, ...}]（无 children），
  /// 我们按 parentId 二次构图
  List<Map<String, dynamic>> _flattenGroups(List<dynamic> groups, {int depth = 0, String? parentId}) {
    final out = <Map<String, dynamic>>[];
    for (final g in groups) {
      if (g is! Map) continue;
      final m = g.cast<String, dynamic>();
      final id = (m['id'] ?? m['groupId'] ?? '').toString();
      final name = (m['name'] ?? m['groupName'] ?? '').toString();
      if (id.isNotEmpty) {
        out.add({
          'id': id,
          'name': name,
          'depth': depth,
          'parentId': parentId ?? m['parentId']?.toString(),
        });
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
