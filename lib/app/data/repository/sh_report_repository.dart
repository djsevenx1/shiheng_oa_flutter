import '../providers/api_provider.dart';

class ShReportRepository {
  final _api = ApiProvider();

  Future<Map<String, dynamic>> getReportSummary() async {
    try {
      final response = await _api.dioInstance.get('/shReport/summary');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取报表汇总失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getProductionReport({int page = 1, int pageSize = 15}) async {
    try {
      final response = await _api.dioInstance.get('/shReport/production', queryParameters: {
        'page': page,
        'pageSize': pageSize,
      });
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取生产报表失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getSalesReport() async {
    try {
      final response = await _api.dioInstance.get('/shReport/sales');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取销售报表失败: $e'};
    }
  }
}
