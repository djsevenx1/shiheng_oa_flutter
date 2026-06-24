import 'package:dio/dio.dart' as dio;

import '../providers/api_provider.dart';

/// 工作汇报仓库
/// 老 App 反编译没有 workReport 单独模块 —— 老 OA 用"主题通知"承载（/oa/access/add/_top + type=report）。
/// 后端没单独接 workReport 接口，所有调用返"未配置"友好提示。
class WorkReportRepository {
  WorkReportRepository({ApiProvider? api}) : _api = api ?? ApiProvider();

  final ApiProvider _api;

  /// 我的汇报列表（后端未接，返空）
  Future<Map<String, dynamic>> getMyReports({int page = 1, int pageSize = 20}) async {
    return {
      'success': true,
      'data': [],
      'count': 0,
      'message': '工作汇报功能后端未配置',
    };
  }

  /// 我收到的汇报（后端未接，返空）
  Future<Map<String, dynamic>> getReceivedReports({int page = 1, int pageSize = 20}) async {
    return {
      'success': true,
      'data': [],
      'count': 0,
      'message': '工作汇报功能后端未配置',
    };
  }

  /// 提交汇报（后端未接）
  Future<Map<String, dynamic>> submit({
    required String title,
    required String content,
    String type = 'daily',
    List<String> recipients = const [],
    String period = '',
  }) async {
    return {
      'success': false,
      'message': '工作汇报功能后端未配置，请用"主题通知"代替',
    };
  }
}
