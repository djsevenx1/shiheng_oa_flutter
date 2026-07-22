import 'package:get_storage/get_storage.dart';

import '../providers/api_provider.dart';

/// ID → 名称 全局字典（部门 + 人员）
/// 登录成功后异步预加载并缓存到 GetStorage，
/// 流程详情、首页等任何需要把 groupId/userId 展示成名字的地方都来这里查。
class NameDictRepository {
  NameDictRepository({ApiProvider? api, GetStorage? storage})
      : _api = api ?? ApiProvider(),
        _storage = storage ?? GetStorage();

  final ApiProvider _api;
  final GetStorage _storage;

  static const _kDeptCache = 'name_dict_dept_v1';
  static const _kUserCache = 'name_dict_user_v1';
  static const _kCacheTime = 'name_dict_cache_time_v1';

  // 内存索引（id 字符串 → 名称）
  final Map<String, String> _deptMap = {};
  final Map<String, String> _userMap = {};

  bool _loaded = false;
  bool get isLoaded => _loaded;

  /// 从缓存恢复（启动时调用,失败也不影响主流程）
  void loadFromCache() {
    try {
      final d = _storage.read(_kDeptCache);
      if (d is Map) {
        _deptMap
          ..clear()
          ..addAll(d.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')));
      }
      final u = _storage.read(_kUserCache);
      if (u is Map) {
        _userMap
          ..clear()
          ..addAll(u.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')));
      }
      _loaded = _deptMap.isNotEmpty || _userMap.isNotEmpty;
    } catch (_) {
      _loaded = false;
    }
  }

  /// 异步预加载（登录后调用,失败静默）
  Future<void> preload() async {
    try {
      // 1) 部门树 /oa/common/groups
      final deptRes = await _api.dioInstance.get('/oa/common/groups');
      _deptMap.clear();
      _collectDepts(deptRes.data, _deptMap);
      await _storage.write(_kDeptCache, _deptMap);

      // 2) 全员 /oa/u/initList（分页拉完为止）
      await _loadAllUsers();

      _loaded = true;
      await _storage.write(_kCacheTime, DateTime.now().millisecondsSinceEpoch);
    } catch (_) {
      // 静默失败,内存里有缓存就用缓存
    }
  }

  Future<void> _loadAllUsers() async {
    const pageSize = 200;
    int offset = 0;
    while (true) {
      final res = await _api.dioInstance.get(
        '/oa/u/initList',
        queryParameters: {'limit': pageSize, 'offset': offset},
      );
      final data = res.data;
      final list = _extractList(data);
      if (list.isEmpty) break;
      for (final u in list) {
        if (u is! Map) continue;
        final id = (u['id'] ?? u['userId'])?.toString();
        if (id == null || id.isEmpty) continue;
        // 优先用 name,其次 login_name
        final name = (u['name'] ?? u['login_name'])?.toString() ?? '';
        if (name.isNotEmpty) {
          _userMap[id] = name;
        }
      }
      if (list.length < pageSize) break;
      offset += pageSize;
      // 防御:最多 2000 人,防呆
      if (offset >= 2000) break;
    }
    await _storage.write(_kUserCache, _userMap);
  }

  List _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['list'] is List) return data['list'] as List;
    return const [];
  }

  void _collectDepts(dynamic data, Map<String, String> out) {
    if (data is List) {
      for (final g in data) {
        _collectDepts(g, out);
      }
      return;
    }
    if (data is Map) {
      final m = data.cast<String, dynamic>();
      final id = (m['id'] ?? m['groupId'])?.toString();
      final name = (m['name'] ?? m['groupName'])?.toString() ?? '';
      if (id != null && id.isNotEmpty && name.isNotEmpty) {
        out[id] = name;
      }
      final children = m['children'] ?? m['subGroups'];
      if (children is List && children.isNotEmpty) {
        _collectDepts(children, out);
      }
    }
  }

  /// 查部门名(查不到返回原值)
  String deptName(dynamic id) {
    if (id == null) return '';
    final s = id.toString();
    return _deptMap[s] ?? s;
  }

  /// 查用户名(查不到返回原值)
  String userName(dynamic id) {
    if (id == null) return '';
    final s = id.toString();
    return _userMap[s] ?? s;
  }

  /// 查名字(优先人,其次部门)
  String nameOf(dynamic id) {
    final s = id?.toString() ?? '';
    if (s.isEmpty) return '';
    return _userMap[s] ?? _deptMap[s] ?? s;
  }
}
