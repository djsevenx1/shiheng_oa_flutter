import '../providers/api_provider.dart';

/// 项目仓库
/// 真实接口（老 App 反编译 project/project_flow_list.js）：
/// - /oa/item/init/xmxx?kind=...&limit=...    项目列表
/// - /oa/item/init/xmxx?kind=cyr&...           我参与的
/// - /oa/item/init/xmxx?kind=fzr&...           我负责的
/// - /oa/item/itemInfoDetail/:id/:modId        项目详情
/// - /oa/item/relevanceMenuList/:modId         关联菜单
/// - /oa/item/getComment/item_xmxx_comment/:id 评论
/// - /oa/item/getRelevanceFile/item_mod_relevance/:id 文件
/// - /oa/item/getContracts/:pmd_modId          合同
class ProjectRepository {
  final _api = ApiProvider();

  Future<Map<String, dynamic>> getProjectList({
    int page = 1,
    int pageSize = 20,
    String kind = 'all', // all/cyr/fzr
  }) async {
    try {
      // 老 App 真实接口：/oa/item/init/xmxx?kind=...&limit=...
      // 之前错用 /oa/project/initList（400，参数不对）
      final response = await _api.dioInstance.get('/oa/item/init/xmxx', queryParameters: {
        'limit': pageSize,
        'kind': kind,
        'more': 1,
      });
      return {
        'success': true,
        'data': response.data?['list'] ?? response.data ?? [],
        'count': response.data?['count'] ?? 0,
      };
    } catch (e) {
      return {'success': false, 'message': '获取项目列表失败: $e', 'data': []};
    }
  }

  Future<Map<String, dynamic>> getProjectDetail(int projectId, int modId) async {
    try {
      // 老 App 真实接口：/oa/item/itemInfoDetail/:id/:modId
      final response = await _api.dioInstance.get('/oa/item/itemInfoDetail/$projectId/$modId');
      return {'success': true, 'data': response.data};
    } catch (e) {
      return {'success': false, 'message': '获取项目详情失败: $e'};
    }
  }

  /// 获取项目合同 - /oa/item/getContracts/:pmd_modId
  Future<Map<String, dynamic>> getProjectContracts(int modId) async {
    try {
      final response = await _api.dioInstance.post('/oa/item/getContracts/$modId', data: {});
      return {'success': true, 'data': response.data ?? []};
    } catch (e) {
      return {'success': true, 'data': []};
    }
  }

  /// 获取项目文件 - /oa/item/getRelevanceFile/item_mod_relevance/:id?limit=...&offset=...
  Future<Map<String, dynamic>> getProjectFiles(int relevanceId) async {
    try {
      final response = await _api.dioInstance.get(
        '/oa/item/getRelevanceFile/item_mod_relevance/$relevanceId',
        queryParameters: {'limit': 50, 'offset': 0},
      );
      return {'success': true, 'data': response.data ?? []};
    } catch (e) {
      return {'success': true, 'data': []};
    }
  }
}
