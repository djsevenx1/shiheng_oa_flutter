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
    // 老 App 反编译没有 knowledge 单独模块；后端没接，返空。
    return _cache;
  }

  Future<List<KnowledgeEntry>> search(String keyword) async {
    final all = await loadAll();
    if (keyword.isEmpty) return all;
    return all.where((e) => e.matches(keyword)).toList();
  }
}
