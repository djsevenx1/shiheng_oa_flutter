import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/map_controller.dart';

class MapView extends GetView<MapController> {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地图'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: controller.locateMe,
          ),
        ],
      ),
      body: Column(
        children: [
          // 搜索栏
          _buildSearchBar(),
          // 地图区域（模拟）
          Expanded(
            child: Stack(
              children: [
                _buildMapPlaceholder(),
                // 标记点
                ...controller.markers.map((marker) => _buildMarker(marker)),
                // 当前位置指示器
                _buildCurrentLocationIndicator(),
              ],
            ),
          ),
          // 底部位置列表
          _buildLocationList(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(12.w),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchController,
              decoration: InputDecoration(
                hintText: '搜索地点...',
                prefixIcon: const Icon(Icons.search, color: AppTheme.gray400, size: 20),
                filled: true,
                fillColor: AppTheme.gray50,
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
                isDense: true,
              ),
              onSubmitted: controller.searchLocation,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.gray100,
        image: const DecorationImage(
          image: NetworkImage('https://restapi.amap.com/v3/staticmap?location=118.0894,24.4798&zoom=13&size=750*600&markers=mid,,24.4798,118.0894&key=placeholder'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.map_outlined, size: 48.w, color: AppTheme.primaryColor),
              SizedBox(height: 8.h),
              Text(
                '高德地图',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '集成 amap_flutter_map 后显示真实地图',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMarker(dynamic marker) {
    final color = controller.getMarkerTypeColor(marker['type']);
    return Positioned(
      // 模拟标记位置（基于经纬度偏移计算）
      left: (marker['lng'] - 118.08) * 5000.w,
      top: (24.50 - marker['lat']) * 5000.h,
      child: GestureDetector(
        onTap: () => controller.selectMarker(marker),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                marker['title'],
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(Icons.location_on, color: color, size: 20.w),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentLocationIndicator() {
    return Obx(() => Positioned(
      left: MediaQuery.of(Get.context!).size.width / 2 - 12.w,
      top: MediaQuery.of(Get.context!).size.height * 0.35,
      child: Container(
        width: 24.w,
        height: 24.w,
        decoration: BoxDecoration(
          color: AppTheme.info.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.my_location,
          size: 16.w,
          color: AppTheme.info,
        ),
      ),
    ));
  }

  Widget _buildLocationList() {
    return Container(
      height: 200.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: AppTheme.gray300, borderRadius: BorderRadius.circular(2.r))),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Text(
                  '附近地点',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const Spacer(),
                Obx(() => Text(
                  controller.currentAddress.value,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppTheme.textTertiary,
                  ),
                )),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          Expanded(
            child: Obx(() => ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: controller.markers.length,
              separatorBuilder: (context, index) => Divider(height: 1.h, color: AppTheme.gray200),
              itemBuilder: (context, index) {
                final marker = controller.markers[index];
                final color = controller.getMarkerTypeColor(marker['type']);
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      marker['type'] == 'company' ? Icons.business : marker['type'] == 'warehouse' ? Icons.warehouse : Icons.person,
                      color: color,
                      size: 18.w,
                    ),
                  ),
                  title: Text(
                    marker['title'],
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    marker['address'],
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      controller.getMarkerTypeLabel(marker['type']),
                      style: TextStyle(fontSize: 11.sp, color: color),
                    ),
                  ),
                  onTap: () => controller.selectMarker(marker),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}
