import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../controllers/favorite_controller.dart';

/// 收藏夹页面
/// 对应老 App modules/app/favorite.tpl.html
class FavoriteView extends GetView<FavoriteController> {
  const FavoriteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('收藏夹')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value != null) {
          return _buildEmpty(controller.errorMessage.value!, true);
        }
        if (controller.favorites.isEmpty) {
          return _buildEmpty('暂无收藏内容', false);
        }
        return RefreshIndicator(
          onRefresh: controller.loadFavorites,
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.favorites.length,
            itemBuilder: (context, index) {
              final item = controller.favorites[index];
              final name = item is Map ? (item['name'] ?? item['title'] ?? '(无标题)') : '(无标题)';
              final creator = item is Map ? (item['creatorName'] ?? item['creator'] ?? '') : '';
              final date = item is Map ? (item['createdDate'] ?? '') : '';
              final type = item is Map ? (item['eveType'] ?? 0) : 0;
              return Dismissible(
                key: Key('fav_$index'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 20.w),
                  color: Colors.red,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => controller.removeFavorite(item, index),
                child: Container(
                  margin: EdgeInsets.only(bottom: 12.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: _getTypeColor(type as int).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(_getTypeIcon(type), color: _getTypeColor(type), size: 22.w),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.toString(),
                              style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (creator.toString().isNotEmpty || date.toString().isNotEmpty) ...[
                              SizedBox(height: 4.h),
                              Text(
                                '$creator  $date',
                                style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  Widget _buildEmpty(String message, bool isError) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(isError ? Icons.error_outline : Icons.star_border, size: 56.w, color: AppTheme.gray300),
          SizedBox(height: 16.h),
          Text(message, style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary)),
          SizedBox(height: 16.h),
          if (!isError)
            TextButton(onPressed: controller.loadFavorites, child: const Text('刷新')),
        ],
      ),
    );
  }

  IconData _getTypeIcon(int type) {
    switch (type) {
      case 0: return Icons.email_outlined;
      case 1: return Icons.assignment_outlined;
      case 2: return Icons.description_outlined;
      default: return Icons.star_outline;
    }
  }

  Color _getTypeColor(int type) {
    switch (type) {
      case 0: return Colors.blue;
      case 1: return Colors.orange;
      case 2: return Colors.green;
      default: return Colors.grey;
    }
  }
}
