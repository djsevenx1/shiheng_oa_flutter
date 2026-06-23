import 'package:dio/dio.dart' as dio;
import 'package:get_storage/get_storage.dart';

import '../providers/api_provider.dart';

/// 通讯录仓库
class ContactsRepository {
  ContactsRepository({ApiProvider? api, GetStorage? storage})
      : _api = api ?? ApiProvider(),
        _storage = storage ?? GetStorage();

  final ApiProvider _api;
  final GetStorage _storage;

  /// 部门树
  Future<Map<String, dynamic>> getDepartmentTree() async {
    try {
      final response = await _api.dioInstance.get('/oa/contacts/departments');
      if (response.data != null) {
        return {'success': true, 'data': response.data};
      }
      return {'success': true, 'data': []};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': []};
    } catch (e) {
      return {'success': false, 'message': '获取部门失败', 'data': []};
    }
  }

  /// 部门成员
  Future<Map<String, dynamic>> getDepartmentMembers(String departmentId, {String keyword = ''}) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/contacts/members',
        queryParameters: {'deptId': departmentId, 'keyword': keyword},
      );
      if (response.data != null) {
        return {'success': true, 'data': response.data};
      }
      return {'success': true, 'data': []};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': []};
    } catch (e) {
      return {'success': false, 'message': '获取成员失败', 'data': []};
    }
  }

  /// 搜索（按姓名 / 工号 / 手机号）
  Future<Map<String, dynamic>> searchMembers(String keyword) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/contacts/search',
        queryParameters: {'keyword': keyword},
      );
      if (response.data != null) {
        return {'success': true, 'data': response.data};
      }
      return {'success': true, 'data': []};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': []};
    } catch (e) {
      return {'success': false, 'message': '搜索失败', 'data': []};
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
}
