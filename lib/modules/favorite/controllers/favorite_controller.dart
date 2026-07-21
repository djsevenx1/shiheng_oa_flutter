import 'package:get/get.dart';

import '../../../app/data/providers/api_provider.dart';

/// 收藏夹控制器
/// 对应老 App modules/app/favorite.tpl.html
/// 老 App 接口：/oa/news/getMemoList（收藏的动态/邮件列表）
class FavoriteController extends GetxController {
  final _api = ApiProvider();

  final favorites = <dynamic>[].obs;
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final response = await _api.get('/oa/news/getMemoList');
      final data = response.data;
      if (data is List) {
        favorites.value = data;
      } else if (data is Map && data['list'] is List) {
        favorites.value = data['list'] as List;
      } else {
        favorites.value = [];
      }
    } catch (e) {
      errorMessage.value = '加载收藏失败，请稍后重试';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeFavorite(dynamic item, int index) async {
    final type = item is Map ? item['eveType']?.toString() : '';
    final id = item is Map ? item['topId']?.toString() ?? item['id']?.toString() : '';
    if (type == null || id == null) return;
    try {
      await _api.get('/oa/news/deMemo/type/$type/id/$id');
      favorites.removeAt(index);
    } catch (e) {
      Get.snackbar('提示', '取消收藏失败', snackPosition: SnackPosition.BOTTOM);
    }
  }
}
