import '../providers/api_provider.dart';

class CrmRepository {
  final _api = ApiProvider();

  Future<Map<String, dynamic>> getClientList({
    int page = 1,
    int pageSize = 10,
    String? keyword,
    String? type,
  }) async {
    try {
      final response = await _api.dioInstance.get(
        '/crm/initList/client',
        queryParameters: {
          'limit': pageSize,
          'offset': (page - 1) * pageSize,
          'keyword': keyword ?? '',
          'type': type ?? '',
        },
      );
      return {
        'success': true,
        'data': response.data?['list'] ?? [],
        'count': response.data?['count'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '获取客户列表失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getClientDetail(int clientId) async {
    try {
      final response = await _api.dioInstance.get('/crm/get/client/$clientId');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取客户详情失败: $e'};
    }
  }

  Future<Map<String, dynamic>> getClientBusiness(int clientId) async {
    try {
      final response = await _api.dioInstance.get('/crm/initList/xzsjxxb', queryParameters: {
        'clientId': clientId,
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

  Future<Map<String, dynamic>> getClientSalesOrder(int clientId) async {
    try {
      final response = await _api.dioInstance.get('/crm/initList/xxsdd', queryParameters: {
        'clientId': clientId,
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
}
