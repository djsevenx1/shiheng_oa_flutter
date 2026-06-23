import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../controllers/knowledge_controller.dart';

class KnowledgeView extends GetView<KnowledgeController> {
  const KnowledgeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('知识库'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: TextField(
              autofocus: false,
              decoration: InputDecoration(
                hintText: '支持中英文 / 拼音首字母搜索',
                hintStyle: TextStyle(fontSize: 13.sp, color: AppTheme.gray400),
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                suffixIcon: Obx(() => controller.keyword.value.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(icon: const Icon(Icons.close, size: 18), onPressed: controller.clear)),
              ),
              onChanged: controller.search,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filtered.isEmpty) {
                return Center(
                  child: Text('无匹配结果', style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary)),
                );
              }
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: controller.filtered.length,
                separatorBuilder: (_, __) => SizedBox(height: 12.h),
                itemBuilder: (context, index) {
                  final e = controller.filtered[index];
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (e.category.isNotEmpty)
                              Container(
                                margin: EdgeInsets.only(right: 8.w),
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4.r),
                                ),
                                child: Text(e.category,
                                    style: TextStyle(fontSize: 11.sp, color: AppTheme.primaryColor)),
                              ),
                            if (controller.keyword.value.isNotEmpty)
                              Text('拼音: ${e.pinyinAbbr}',
                                  style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary)),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(e.title,
                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                        if (e.summary.isNotEmpty) ...[
                          SizedBox(height: 6.h),
                          Text(e.summary,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary)),
                        ],
                        if (e.tags.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          Wrap(
                            spacing: 6.w,
                            runSpacing: 4.h,
                            children: e.tags
                                .map((t) => Container(
                                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                      decoration: BoxDecoration(
                                        color: AppTheme.backgroundColor,
                                        borderRadius: BorderRadius.circular(4.r),
                                      ),
                                      child: Text('#$t',
                                          style: TextStyle(fontSize: 11.sp, color: AppTheme.textSecondary)),
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
