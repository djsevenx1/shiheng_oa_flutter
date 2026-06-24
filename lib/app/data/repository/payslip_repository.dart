import 'package:dio/dio.dart' as dio;

import '../providers/api_provider.dart';

/// 工资条仓库
/// 老 App 反编译没有 payslip 模块，后端没接。所有调用返"未配置"友好提示。
class PayslipRepository {
  PayslipRepository({ApiProvider? api}) : _api = api ?? ApiProvider();

  final ApiProvider _api;

  /// 工资条列表（后端未接，返空）
  Future<Map<String, dynamic>> getList({int year = 0, int page = 1, int pageSize = 20}) async {
    return {
      'success': true,
      'data': [],
      'count': 0,
      'message': '工资条功能后端未配置',
    };
  }

  /// 工资条详情（后端未接）
  Future<Map<String, dynamic>> getDetail(String id) async {
    return {
      'success': false,
      'message': '工资条功能后端未配置',
    };
  }
}
