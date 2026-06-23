import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/crm_business_controller.dart';

class CrmBusinessView extends GetView<CrmBusinessController> {
  const CrmBusinessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('商机管理'),
        actions: [
          IconButton(icon: const Icon(Icons.add_chart), onPressed: () {}),
          IconButton(icon: const Icon(Icons.add), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildStats(),
          _buildSearchBar(),
          _buildStageFilter(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.businessList.isEmpty) {
                return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
              }
              if (controller.businessList.isEmpty) {
                return _buildEmpty();
              }
              return _buildList();
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
        ),
      ),
      child: Obx(() {
        final total = controller.totalCount.value;
        final totalAmount = controller.businessList.fold<double>(0.0, (s, b) => s + ((b['amount'] ?? 0) as num).toDouble());
        return Row(
          children: [
            _buildStat('商机数', total.toString(), Colors.white.withOpacity(0.2)),
            SizedBox(width: 12.w),
            _buildStat('总金额', '¥${(totalAmount / 10000).toStringAsFixed(1)}万', Colors.white.withOpacity(0.2)),
            SizedBox(width: 12.w),
            _buildStat('进行中', controller.businessList.where((b) => !['已签约', '已丢单'].contains(b['stage'])).length.toString(), Colors.white.withOpacity(0.2)),
            SizedBox(width: 12.w),
            _buildStat('已签约', controller.businessList.where((b) => b['stage'] == '已签约').length.toString(), Colors.white.withOpacity(0.2)),
          ],
        );
      }),
    );
  }

  Widget _buildStat(String label, String value, Color bg) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10.r)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 4.h),
            Text(label, style: TextStyle(fontSize: 11.sp, color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(12.w),
      color: Colors.white,
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: '搜索商机/客户...',
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
        onSubmitted: (_) => controller.search(),
      ),
    );
  }

  Widget _buildStageFilter() {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        child: Obx(() => Row(
          children: controller.stages.map((stage) {
            final isSelected = controller.selectedStage.value == stage;
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: GestureDetector(
                onTap: () => controller.changeStage(stage),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: isSelected ? _getStageColor(stage) : Colors.transparent,
                    border: Border.all(color: isSelected ? _getStageColor(stage) : AppTheme.gray300),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Text(
                    stage,
                    style: TextStyle(
                      fontSize: 12.sp,
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

  Widget _buildList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: controller.businessList.length,
      itemBuilder: (context, index) => _buildCard(controller.businessList[index]),
    );
  }

  Widget _buildCard(dynamic business) {
    final stage = business['stage'] ?? '';
    final stageColor = _getStageColor(stage);
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: stageColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  stage,
                  style: TextStyle(fontSize: 11.sp, color: stageColor, fontWeight: FontWeight.w500),
                ),
              ),
              const Spacer(),
              Text(
                '¥${((business['amount'] ?? 0) as num).toStringAsFixed(0)}',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.success),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            business['name'] ?? '商机名称',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            '客户: ${business['client'] ?? '-'}',
            style: TextStyle(fontSize: 12.sp, color: AppTheme.textSecondary),
          ),
          SizedBox(height: 10.h),
          _buildProbabilityBar(business['probability'] ?? 0, stageColor),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.person_outline, size: 13.w, color: AppTheme.textTertiary),
              SizedBox(width: 4.w),
              Text(
                business['manager'] ?? '-',
                style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
              ),
              SizedBox(width: 16.w),
              Icon(Icons.event, size: 13.w, color: AppTheme.textTertiary),
              SizedBox(width: 4.w),
              Text(
                business['expectedDate'] ?? '-',
                style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProbabilityBar(int probability, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('成交概率', style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary)),
            Text('$probability%', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: color)),
          ],
        ),
        SizedBox(height: 4.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(3.r),
          child: LinearProgressIndicator(
            value: probability / 100,
            backgroundColor: AppTheme.gray200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5.h,
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lightbulb_outline, size: 64.w, color: AppTheme.gray300),
          SizedBox(height: 16.h),
          Text('暂无商机', style: TextStyle(fontSize: 16.sp, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  Color _getStageColor(String stage) {
    switch (stage) {
      case '需求确认': return AppTheme.info;
      case '方案报价': return AppTheme.warning;
      case '商务谈判': return AppTheme.primaryColor;
      case '签约中': return Colors.purple;
      case '已签约': return AppTheme.success;
      case '已丢单': return AppTheme.gray500;
      default: return AppTheme.primaryColor;
    }
  }
}
