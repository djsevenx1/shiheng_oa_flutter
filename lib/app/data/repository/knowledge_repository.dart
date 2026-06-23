import 'package:dio/dio.dart' as dio;
import 'package:lpinyin/lpinyin.dart';

import '../providers/api_provider.dart';

class KnowledgeEntry {
  KnowledgeEntry({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    required this.tags,
  });

  final String id;
  final String title;
  final String summary;
  final String category;
  final List<String> tags;

  String get pinyinAbbr => PinyinHelper.getPinyinE(title);

  /// 是否匹配关键字（按 title / 拼音首字母 / tags）
  bool matches(String keyword) {
    if (keyword.isEmpty) return true;
    final k = keyword.toLowerCase().trim();
    if (title.toLowerCase().contains(k)) return true;
    if (pinyinAbbr.toLowerCase().contains(k.replaceAll(' ', ''))) return true;
    for (final t in tags) {
      if (t.toLowerCase().contains(k)) return true;
    }
    return false;
  }
}

class KnowledgeRepository {
  KnowledgeRepository({ApiProvider? api}) : _api = api ?? ApiProvider();

  final ApiProvider _api;
  final List<KnowledgeEntry> _cache = [];

  Future<List<KnowledgeEntry>> loadAll() async {
    if (_cache.isNotEmpty) return _cache;
    try {
      final response = await _api.dioInstance.get('/oa/knowledge/list');
      final list = (response.data is Map ? response.data['data'] : response.data) as List? ?? [];
      _cache.clear();
      for (final raw in list) {
        if (raw is Map) {
          _cache.add(KnowledgeEntry(
            id: raw['id']?.toString() ?? '',
            title: raw['title']?.toString() ?? '',
            summary: raw['summary']?.toString() ?? '',
            category: raw['category']?.toString() ?? '',
            tags: ((raw['tags'] as List?) ?? const []).map((e) => e.toString()).toList(),
          ));
        }
      }
      return _cache;
    } catch (_) {
      return _cache;
    }
  }

  Future<List<KnowledgeEntry>> search(String keyword) async {
    final all = await loadAll();
    if (keyword.isEmpty) return all;
    return all.where((e) => e.matches(keyword)).toList();
  }
}
