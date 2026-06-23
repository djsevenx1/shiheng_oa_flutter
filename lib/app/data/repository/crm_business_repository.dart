import '../providers/api_provider.dart';

class CrmBusinessRepository {
  final _api = ApiProvider();

  Future<Map<String, dynamic>> getBusinessList({
    int page = 1,
    int pageSize = 10,
    String? keyword,
    String? stage,
  }) async {
    try {
      final response = await _api.dioInstance.get('/crm/initList/xzsjxxb', queryParameters: {
        'limit': pageSize,
        'offset': (page - 1) * pageSize,
        'keyword': keyword ?? '',
        'stage': stage ?? '',
      });
      return {
        'success': true,
        'data': response.data?['list'] ?? [],
        'count': response.data?['count'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '获取商机列表失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getSalesOrderList({
    int page = 1,
    int pageSize = 10,
    String? keyword,
  }) async {
    try {
      final response = await _api.dioInstance.get('/crm/initList/xxsdd', queryParameters: {
        'limit': pageSize,
        'offset': (page - 1) * pageSize,
        'keyword': keyword ?? '',
      });
      return {
        'success': true,
        'data': response.data?['list'] ?? [],
        'count': response.data?['count'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '获取销售订单失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getChannelList({int page = 1, int pageSize = 10}) async {
    try {
      final response = await _api.dioInstance.get('/crm/initList/channel', queryParameters: {
        'limit': pageSize,
        'offset': (page - 1) * pageSize,
      });
      return {
        'success': true,
        'data': response.data?['list'] ?? [],
        'count': response.data?['count'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '获取渠道失败: $e'};
    }
  }
}
