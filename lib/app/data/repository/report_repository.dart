import '../providers/api_provider.dart';

class ReportRepository {
  final _api = ApiProvider();

  Future<Map<String, dynamic>> getReportCategories() async {
    try {
      // 老 App 真实接口：/oa/access/getAccess/1 (curl 200，/access/getAccess/1 404)
      final response = await _api.dioInstance.get('/oa/access/getAccess/1');
      return {'success': true, 'data': response.data ?? {}};
    } catch (e) {
      return {'success': false, 'message': '获取报表分类失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getReportData({
    required int modId,
    int offset = 0,
    int limit = 10,
    String? filtersStr,
  }) async {
    try {
      final response = await _api.dioInstance.post(
        '/rep/init',
        data: {
          'modId': modId,
          'limit': limit,
          'offset': offset,
          'open': '1',
        },
      );
      return {'success': true, 'data': response.data ?? {}};
    } catch (e) {
      return {'success': false, 'message': '获取报表数据失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getStockReport({
    required int type,
    int page = 1,
    Map<String, dynamic>? searchData,
  }) async {
    try {
      final response = await _api.dioInstance.post(
        '/ShBaobiao/Stock',
        queryParameters: {'first': page, 'end': page + 14},
        data: {
          'bj': type.toString(),
          'AA': searchData?['AA'] ?? '',
          'AC': searchData?['AC'] ?? '',
          'AD': searchData?['AD'] ?? '',
          'AE': searchData?['AE'] ?? '',
          'AF': searchData?['AF'] ?? '',
        },
      );
      return {'success': true, 'data': response.data?['list'] ?? [], 'count': response.data?['count'] ?? 0};
    } catch (e) {
      return {'success': false, 'message': '获取库存报表失败: $e'};
    }
  }
}
