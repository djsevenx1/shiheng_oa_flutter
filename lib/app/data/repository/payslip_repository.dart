import 'package:dio/dio.dart' as dio;

import '../providers/api_provider.dart';

class PayslipRepository {
  PayslipRepository({ApiProvider? api}) : _api = api ?? ApiProvider();

  final ApiProvider _api;

  /// 工资条列表
  Future<Map<String, dynamic>> getList({int year = 0, int page = 1, int pageSize = 20}) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/payslip/list',
        queryParameters: {'year': year, 'page': page, 'pageSize': pageSize},
      );
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取工资条失败'};
    }
  }

  /// 工资条详情
  Future<Map<String, dynamic>> getDetail(String id) async {
    try {
      final response = await _api.dioInstance.get('/oa/payslip/detail', queryParameters: {'id': id});
      return {'success': true, 'data': response.data};
    } on dio.DioException catch (e) {
      return {'success': false, 'message': ApiProvider.normalize(e).message};
    } catch (e) {
      return {'success': false, 'message': '获取工资条详情失败'};
    }
  }
}
