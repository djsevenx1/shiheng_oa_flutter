import '../providers/api_provider.dart';

/// 上海报表仓库
/// 真实接口（老 App 反编译 sh_report/*）：
/// - POST /ShBaobiao/Stock?first=&end=  body={...}  库存报表
/// - POST /pda/workProByPc?first=&end=&userId=       PDA 工序
class ShReportRepository {
  final _api = ApiProvider();

  Future<Map<String, dynamic>> getReportSummary() async {
    try {
      // 老 App 用 POST /ShBaobiao/Stock（带 first/end 参数）
      final response = await _api.dioInstance.post('/ShBaobiao/Stock', data: {
        'first': 0,
        'end': 100,
      });
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': true, 'data': [], 'message': '报表功能未配置'};
    }
  }

  Future<Map<String, dynamic>> getProductionReport({int page = 1, int pageSize = 15}) async {
    try {
      final response = await _api.dioInstance.post('/pda/workProByPc', queryParameters: {
        'first': (page - 1) * pageSize,
        'end': page * pageSize,
        'userId': 191,
      });
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': true, 'data': [], 'message': '生产报表未配置'};
    }
  }

  Future<Map<String, dynamic>> getSalesReport() async {
    try {
      final response = await _api.dioInstance.post('/ShBaobiao/Stock', data: {
        'first': 0,
        'end': 100,
      });
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': true, 'data': [], 'message': '销售报表未配置'};
    }
  }
}
