import 'package:dio/dio.dart' as dio;

import '../providers/api_provider.dart';

class WorkReportRepository {
  WorkReportRepository({ApiProvider? api}) : _api = api ?? ApiProvider();

  final ApiProvider _api;

  /// 我的汇报列表
  Future<Map<String, dynamic>> getMyReports({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/workReport/my',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取汇报失败'};
    }
  }

  /// 我收到的汇报
  Future<Map<String, dynamic>> getReceivedReports({int page = 1, int pageSize = 20}) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/workReport/received',
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取收到的汇报失败'};
    }
  }

  /// 提交汇报（content 是富文本的 JSON delta）
  Future<Map<String, dynamic>> submit({
    required String title,
    required String content,
    String type = 'daily', // daily / weekly / monthly
    List<String> recipients = const [],
    String period = '',
  }) async {
    try {
      final response = await _api.dioInstance.post('/oa/workReport/submit', data: {
        'title': title,
        'content': content,
        'type': type,
        'recipients': recipients,
        'period': period,
      });
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '提交失败'};
    }
  }
}
