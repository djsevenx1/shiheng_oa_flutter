import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/themes/app_theme.dart';

class WorkflowTab extends StatelessWidget {
  const WorkflowTab({super.key});

  final mockWorkflows = const [
    {'id': 1, 'name': '请假申请', 'type': '事假', 'days': '2天', 'creator': '张三', 'date': '2024-01-15', 'state': 1},
    {'id': 2, 'name': '报销申请', 'type': '差旅费', 'amount': '¥3,500', 'creator': '李四', 'date': '2024-01-14', 'state': 1},
    {'id': 3, 'name': '采购申请', 'type': '办公用品', 'amount': '¥1,200', 'creator': '王五', 'date': '2024-01-13', 'state': 1},
    {'id': 4, 'name': '请假申请', 'type': '年假', 'days': '3天', 'creator': '赵六', 'date': '2024-01-12', 'state': 1},
    {'id': 5, 'name': '出差申请', 'type': '上海', 'days': '5天', 'creator': '钱七', 'date': '2024-01-11', 'state': 1},
  ];

  final mockHandledWorkflows = const [
    {'id': 101, 'name': '请假申请', 'type': '病假', 'days': '1天', 'creator': '孙八', 'date': '2024-01-10', 'state': 2},
    {'id': 102, 'name': '报销申请', 'type': '招待费', 'amount': '¥800', 'creator': '周九', 'date': '2024-01-09', 'state': 2},
    {'id': 103, 'name': '采购申请', 'type': '电子元件', 'amount': '¥15,000', 'creator': '吴十', 'date': '2024-01-08', 'state': -1},
  ];

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
            _buildWorkflowList(mockWorkflows, isHandle: true),
            _buildWorkflowList(mockHandledWorkflows, isHandle: false),
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

  Widget _buildWorkflowList(List<Map<String, dynamic>> items, {required bool isHandle}) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final state = item['state'] as int;
        final stateName = state == 1 ? '待审批' : state == 2 ? '已通过' : '已拒绝';
        final stateColor = state == 1 ? AppTheme.warning : state == 2 ? AppTheme.success : AppTheme.danger;

        return GestureDetector(
          onTap: () => Get.toNamed(Routes.WORKFLOW_DETAIL, arguments: {'proId': item['id']}),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: stateColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        stateName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: stateColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      item['date'] ?? '',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  '${item['name']} - ${item['creator']}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '类型: ${item['type']} | ${item['days'] != null ? '天数: ${item['days']}' : '金额: ${item['amount']}'}',
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
                      '发起人: ${item['creator']}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppTheme.textTertiary,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.chevron_right, size: 20.w, color: AppTheme.gray400),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
