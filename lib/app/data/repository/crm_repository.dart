import '../providers/api_provider.dart';

/// CRM 仓库
/// 老 App 反编译真实接口：/oa/crm/initList/:tableKey (POST formData)
/// 之前 flutter app 用 /crm/initList/client 等路径都 404。后端 CRM 没单独接。
/// 返"未配置"友好提示。
class CrmRepository {
  final _api = ApiProvider();

  /// 客户列表（后端未接）
  Future<Map<String, dynamic>> getClientList({
    int page = 1,
    int pageSize = 10,
    String? keyword,
    String? type,
  }) async {
    return {
      'success': true,
      'data': [],
      'count': 0,
      'message': 'CRM 客户管理功能后端未配置',
    };
  }

  /// 客户详情（后端未接）
  Future<Map<String, dynamic>> getClientDetail(int clientId) async {
    return {'success': false, 'message': 'CRM 功能后端未配置'};
  }

  /// 商机列表（后端未接）
  Future<Map<String, dynamic>> getClientBusiness(int clientId) async {
    return {
      'success': true,
      'data': [],
      'count': 0,
      'message': 'CRM 商机功能后端未配置',
    };
  }

  /// 销售订单（后端未接）
  Future<Map<String, dynamic>> getClientSalesOrder(int clientId) async {
    return {
      'success': true,
      'data': [],
      'count': 0,
      'message': 'CRM 销售订单功能后端未配置',
    };
  }
}
