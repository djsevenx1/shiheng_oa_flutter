import 'package:get/get.dart';
import '../../../app/data/repository/report_repository.dart';

class ReportController extends GetxController {
  final isLoading = false.obs;
  final categories = <Map<String, dynamic>>[].obs;
  final mods = <Map<String, dynamic>>[].obs;

  final _repo = ReportRepository();

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  Future<void> loadReports() async {
    isLoading.value = true;
    try {
      final res = await _repo.getReportCategories();
      if (res['success'] == true) {
        final data = res['data'];
        if (data is Map) {
          final cats = (data['cats'] is List) ? List<Map<String, dynamic>>.from(data['cats']) : <Map<String, dynamic>>[];
          final mds = (data['mods'] is List) ? List<Map<String, dynamic>>.from(data['mods']) : <Map<String, dynamic>>[];
          final catsMap = (data['catsMap'] is Map) ? Map<String, dynamic>.from(data['catsMap']) : <String, dynamic>{};
          // 兜底：从 catsMap 抽 mod
          if (mds.isEmpty && catsMap.isNotEmpty) {
            catsMap.forEach((k, v) {
              if (v is List) {
                for (final m in v) {
                  if (m is Map) mds.add(Map<String, dynamic>.from(m));
                }
              }
            });
          }
          categories.assignAll(cats);
          mods.assignAll(mds);
        }
      }
    } finally {
      isLoading.value = false;
    }
  }
}
