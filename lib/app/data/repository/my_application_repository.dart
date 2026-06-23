import 'package:dio/dio.dart' as dio;

import '../providers/api_provider.dart';

/// 我的申请仓库（流程发起后的列表）
class MyApplicationRepository {
  MyApplicationRepository({ApiProvider? api}) : _api = api ?? ApiProvider();

  final ApiProvider _api;

  /// 我发起的流程
  /// [status] 可选：'running' 进行中、'finished' 已完成、'rejected' 已驳回
  Future<Map<String, dynamic>> getMyApplications({
    int page = 1,
    int pageSize = 20,
    String status = 'running',
  }) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/workflow/myApplications',
        queryParameters: {'page': page, 'pageSize': pageSize, 'status': status},
      );
      if (response.data is Map) {
        final data = response.data as Map;
        return {
          'success': true,
          'data': data['data'] ?? data,
          'total': data['total'] ?? 0,
        };
      }
      return {'success': true, 'data': [], 'total': 0};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message, 'data': [], 'total': 0};
    } catch (e) {
      return {'success': false, 'message': '获取我的申请失败', 'data': [], 'total': 0};
    }
  }

  /// 流程详情
  Future<Map<String, dynamic>> getApplicationDetail(String id) async {
    try {
      final response = await _api.dioInstance.get('/oa/workflow/myApplicationDetail', queryParameters: {'id': id});
      if (response.data != null) {
        return {'success': true, 'data': response.data};
      }
      return {'success': false, 'message': '申请不存在'};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取申请详情失败'};
    }
  }

  /// 撤销申请
  Future<Map<String, dynamic>> cancelApplication(String id, {String reason = ''}) async {
    try {
      final response = await _api.dioInstance.post(
        '/oa/workflow/cancel',
        data: {'id': id, 'reason': reason},
      );
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '撤销失败'};
    }
  }

  /// 催办
  Future<Map<String, dynamic>> urge(String id) async {
    try {
      final response = await _api.dioInstance.post('/oa/workflow/urge', data: {'id': id});
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '催办失败'};
    }
  }
}
