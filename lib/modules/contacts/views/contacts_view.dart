import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../app/themes/app_theme.dart';
import '../controllers/contacts_controller.dart';

class ContactsView extends GetView<ContactsController> {
  const ContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('通讯录'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Row(
        children: [
          // 左侧部门树
          Container(
            width: 120.w,
            color: AppTheme.backgroundColor,
            child: Obx(() {
              if (controller.isLoading.value && controller.departments.isEmpty) {
                return const Center(child: CircularProgressIndicator(strokeWidth: 2));
              }
              return ListView.builder(
                itemCount: controller.departments.length,
                itemBuilder: (context, index) {
                  final d = controller.departments[index];
                  final id = d['id']?.toString() ?? '';
                  final name = d['name']?.toString() ?? '';
                  return Obx(() {
                    final selected = controller.selectedDeptId.value == id;
                    return InkWell(
                      onTap: () => controller.selectDepartment(id, name),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: selected ? Colors.white : Colors.transparent,
                          border: Border(
                            left: BorderSide(
                              color: selected ? AppTheme.primaryColor : Colors.transparent,
                              width: 3,
                            ),
                          ),
                        ),
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: selected ? AppTheme.primaryColor : AppTheme.textSecondary,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  });
                },
              );
            }),
          ),
          // 右侧成员 + 搜索
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(12.w),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: '搜索姓名/工号/手机号',
                        hintStyle: TextStyle(fontSize: 13.sp, color: AppTheme.gray400),
                        prefixIcon: const Icon(Icons.search, size: 20),
                        filled: true,
                        fillColor: AppTheme.backgroundColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                        suffixIcon: Obx(() => controller.searchKeyword.value.isEmpty
                            ? const SizedBox.shrink()
                            : IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                onPressed: controller.clearSearch,
                              )),
                      ),
                      onChanged: controller.search,
                    ),
                  ),
                  Expanded(
                    child: Obx(() {
                      if (controller.searchKeyword.value.isNotEmpty) {
                        return _buildSearchResults();
                      }
                      return _buildMembers();
                    }),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembers() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      }
      if (controller.members.isEmpty) {
        return Center(
          child: Text(
            controller.selectedDeptId.value == null ? '请选择部门' : '该部门暂无成员',
            style: TextStyle(fontSize: 13.sp, color: AppTheme.textTertiary),
          ),
        );
      }
      return ListView.separated(
        itemCount: controller.members.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: AppTheme.dividerColor, indent: 16.w),
        itemBuilder: (context, index) {
          final m = controller.members[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                (m['name']?.toString() ?? '?').substring(0, 1),
                style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(m['name']?.toString() ?? ''),
            subtitle: Text(
              '${m['position'] ?? ''}${m['phone'] != null ? '  ·  ${m['phone']}' : ''}',
              style: TextStyle(fontSize: 12.sp),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.phone, color: AppTheme.primaryColor, size: 20),
              onPressed: () => controller.callMember(m),
            ),
          );
        },
      );
    });
  }

  Widget _buildSearchResults() {
    return Obx(() {
      if (controller.isSearching.value) {
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      }
      if (controller.searchResults.isEmpty) {
        return Center(
          child: Text('无匹配结果', style: TextStyle(fontSize: 13.sp, color: AppTheme.textTertiary)),
        );
      }
      return ListView.separated(
        itemCount: controller.searchResults.length,
        separatorBuilder: (_, __) => Divider(height: 1, color: AppTheme.dividerColor, indent: 16.w),
        itemBuilder: (context, index) {
          final m = controller.searchResults[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
              child: Text(
                (m['name']?.toString() ?? '?').substring(0, 1),
                style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(m['name']?.toString() ?? ''),
            subtitle: Text(
              '${m['deptName'] ?? ''}  ·  ${m['position'] ?? ''}',
              style: TextStyle(fontSize: 12.sp),
            ),
            onTap: () => controller.callMember(m),
          );
        },
      );
    });
  }
}
