import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/topic_controller.dart';

class TopicView extends GetView<TopicController> {
  const TopicView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('话题讨论'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.topicList.isEmpty) {
                return Center(child: CircularProgressIndicator(color: AppTheme.primaryColor));
              }
              return _buildList();
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: Obx(() => Row(
        children: controller.tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = controller.selectedTab.value == index;
          return Expanded(
            child: GestureDetector(
              onTap: () => controller.changeTab(index),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                      width: 2.h,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      )),
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: () => controller.loadTopics(),
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.topicList.length,
        itemBuilder: (context, index) => _buildTopicCard(controller.topicList[index]),
      ),
    );
  }

  Widget _buildTopicCard(dynamic topic) {
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
              CircleAvatar(
                radius: 16.w,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  (topic['creator'] ?? '?')[0],
                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic['creator'] ?? '-',
                      style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppTheme.textPrimary),
                    ),
                    Text(
                      topic['createdDate'] ?? '',
                      style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary),
                    ),
                  ],
                ),
              ),
              if (topic['isPinned'] == true)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: AppTheme.danger.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.push_pin, size: 10.w, color: AppTheme.danger),
                      SizedBox(width: 2.w),
                      Text('置顶', style: TextStyle(fontSize: 10.sp, color: AppTheme.danger)),
                    ],
                  ),
                ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            topic['title'] ?? '',
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 6.h),
          Text(
            topic['content'] ?? '',
            style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10.h),
          Divider(height: 1.h, color: AppTheme.gray200),
          SizedBox(height: 8.h),
          Row(
            children: [
              Icon(Icons.people, size: 14.w, color: AppTheme.textTertiary),
              SizedBox(width: 4.w),
              Text(
                '${topic['participantCount'] ?? 0}人参与',
                style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
              ),
              SizedBox(width: 16.w),
              Icon(Icons.chat_bubble_outline, size: 14.w, color: AppTheme.textTertiary),
              SizedBox(width: 4.w),
              Text(
                '${topic['replyCount'] ?? 0}条回复',
                style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
              ),
              const Spacer(),
              Text(
                topic['lastReplyDate']?.toString().substring(5) ?? '',
                style: TextStyle(fontSize: 11.sp, color: AppTheme.textTertiary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context) {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '发起话题',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
              SizedBox(height: 16.h),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: '请输入话题标题（不超过20字）',
                  filled: true,
                  fillColor: AppTheme.gray50,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              TextField(
                controller: contentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: '请输入话题内容...',
                  filled: true,
                  fillColor: AppTheme.gray50,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: const Text('取消'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isEmpty || contentController.text.isEmpty) {
                          Get.snackbar('提示', '请填写完整', snackPosition: SnackPosition.BOTTOM);
                          return;
                        }
                        Get.back();
                        Get.snackbar('成功', '话题已发布', snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppTheme.success, colorText: Colors.white);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                      ),
                      child: const Text('发布'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
