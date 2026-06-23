import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/favorite_controller.dart';

class FavoriteView extends GetView<FavoriteController> {
  const FavoriteView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏'),
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
        ],
      ),
      body: Obx(() {
        // 按 category 分组
        final groups = <String, List<dynamic>>{};
        for (final fav in controller.favoriteList) {
          final cat = fav['category'] ?? '其他';
          groups.putIfAbsent(cat, () => []).add(fav);
        }
        return ListView(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          children: groups.entries.map((entry) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
                  child: Text(
                    entry.key,
                    style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Column(
                    children: entry.value.map((fav) {
                      return ListTile(
                        leading: Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: (fav['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(fav['icon'], color: fav['color'], size: 20.w),
                        ),
                        title: Text(fav['name'], style: TextStyle(fontSize: 14.sp, color: AppTheme.textPrimary)),
                        trailing: Icon(Icons.star, color: AppTheme.warning, size: 20.w),
                        onTap: () => Get.toNamed(fav['route']),
                      );
                    }).toList(),
                  ),
                ),
              ],
            );
          }).toList(),
        );
      }),
    );
  }
}
