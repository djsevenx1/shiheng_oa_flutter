import '../providers/api_provider.dart';

/// 档案仓库
/// 老 App 反编译档案真实接口：/oa/ao/getAll/_dir（admin）或 /oa/access/getAllByAcl/_dir（user）
/// 父目录/子目录/文件：/oa/dir/getDirFiles/:dirId
/// 后端没接 archive 独立接口（用旧 archive 路径都 404），返"未配置"友好提示。
class ArchiveRepository {
  final _api = ApiProvider();

  /// 档案列表（后端未接，返空 + 提示）
  Future<Map<String, dynamic>> getArchiveList({int page = 1, int pageSize = 15, String? keyword, String? category}) async {
    return {
      'success': true,
      'data': [],
      'count': 0,
      'message': '档案管理功能后端未配置，请联系管理员',
    };
  }

  /// 档案详情（后端未接）
  Future<Map<String, dynamic>> getArchiveDetail(int id) async {
    return {'success': false, 'message': '档案功能后端未配置'};
  }

  /// 公司文件（后端未接）
  Future<Map<String, dynamic>> getCompanyFiles({int page = 1, int pageSize = 15, String? category}) async {
    return {
      'success': true,
      'data': [],
      'count': 0,
      'message': '公司文件功能后端未配置',
    };
  }
}
