import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../app/themes/app_theme.dart';

class WorkflowTab extends StatelessWidget {
  const WorkflowTab({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('流程审批'),
          bottom: TabBar(
            tabs: [
              Tab(text: '待处理'),
              Tab(text: '已处理'),
            ],
            labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 15.sp),
          ),
        ),
        body: TabBarView(
          children: [
            _buildWorkflowList(isHandle: true),
            _buildWorkflowList(isHandle: false),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('发起流程'),
          backgroundColor: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildWorkflowList({required bool isHandle}) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: isHandle ? AppTheme.warning.withOpacity(0.1) : AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      isHandle ? '待审批' : '已结束',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isHandle ? AppTheme.warning : AppTheme.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '2024-01-15',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                '请假申请 - 张三',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '申请类型: 事假 | 天数: 2天',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppTheme.textSecondary,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16.w, color: AppTheme.textTertiary),
                  SizedBox(width: 4.w),
                  Text(
                    '发起人: 张三',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppTheme.textTertiary,
                    ),
                  ),
                  const Spacer(),
                  if (isHandle)
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        minimumSize: Size(0, 32.h),
                        textStyle: TextStyle(fontSize: 12.sp),
                      ),
                      child: const Text('审批'),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
