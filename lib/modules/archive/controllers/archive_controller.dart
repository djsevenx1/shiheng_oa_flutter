import 'package:get/get.dart';

import '../../../app/data/repository/archive_repository.dart';

/// 档案/知识文档控制器
/// 对应老 App modules/archive + modules/app/app.tpl.html 的"知识文档"入口
/// 老 App 接口：/oa/ao/getAll/_dir（admin）或 /oa/access/getAllByAcl/_dir（user）
class ArchiveController extends GetxController {
  final _repo = ArchiveRepository();

  final categories = <Map<String, dynamic>>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final infoMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    errorMessage.value = null;
    infoMessage.value = null;
    final result = await _repo.getArchiveList();
    isLoading.value = false;
    if (result['success'] == true) {
      categories.value = (result['data'] as List?)
              ?.map((e) => e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map))
              .toList() ??
          [];
      if (categories.isEmpty) {
        infoMessage.value = result['message']?.toString() ?? '暂无档案分类';
      }
    } else {
      errorMessage.value = result['message']?.toString() ?? '加载失败';
    }
  }
}
