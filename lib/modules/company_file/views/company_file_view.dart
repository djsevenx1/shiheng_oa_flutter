import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/company_file_controller.dart';

class CompanyFileView extends GetView<CompanyFileController> {
  const CompanyFileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('公司文件'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryChips(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.fileList.isEmpty) {
                return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
              }
              return _buildGrid();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Obx(() => Row(
          children: controller.categories.map((category) {
            final isSelected = controller.selectedCategory.value == category;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () => controller.changeCategory(category),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                    border: Border.all(color: isSelected ? AppTheme.primaryColor : AppTheme.gray300),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        )),
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
        childAspectRatio: 0.85,
      ),
      itemCount: controller.fileList.length,
      itemBuilder: (context, index) => _buildFileCard(controller.fileList[index]),
    );
  }

  Widget _buildFileCard(dynamic file) {
    return Container(
      padding: EdgeInsets.all(14.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 70.h,
            decoration: BoxDecoration(
              color: _getTypeColor(file['type']).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Icon(_getTypeIcon(file['type']), size: 32.w, color: _getTypeColor(file['type'])),
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            file['name'] ?? '',
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6.h),
          Text(
            file['category'] ?? '',
            style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary),
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                file['size'] ?? '',
                style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary),
              ),
              const Spacer(),
              Icon(Icons.download_outlined, size: 12.w, color: AppTheme.textTertiary),
              SizedBox(width: 2.w),
              Text(
                '${file['downloads'] ?? 0}',
                style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String? type) {
    switch (type) {
      case 'pdf': return Icons.picture_as_pdf;
      case 'doc': return Icons.article;
      case 'xls': return Icons.table_chart;
      case 'ppt': return Icons.slideshow;
      case 'img': return Icons.image;
      case 'zip': return Icons.folder_zip;
      default: return Icons.insert_drive_file;
    }
  }

  Color _getTypeColor(String? type) {
    switch (type) {
      case 'pdf': return AppTheme.danger;
      case 'doc': return AppTheme.info;
      case 'xls': return AppTheme.success;
      case 'ppt': return AppTheme.warning;
      case 'img': return Colors.purple;
      case 'zip': return AppTheme.gray500;
      default: return AppTheme.primaryColor;
    }
  }
}
