import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/themes/app_theme.dart';
import '../controllers/workflow_controller.dart';

class WorkflowView extends GetView<WorkflowController> {
  const WorkflowView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('流程审批'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => controller.loadAll(),
            tooltip: '刷新',
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab 切换
          Obx(() => Row(
                children: [
                  _tabBtn('待办 (${controller.todoList.length})', 0),
                  _tabBtn('进行中 (${controller.runningList.length})', 1),
                  _tabBtn('已完成 (${controller.doneList.length})', 2),
                ],
              )),
          Divider(height: 1.h, color: AppTheme.divider),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = controller.selectedTab.value == 0
                  ? controller.todoList
                  : controller.selectedTab.value == 1
                      ? controller.runningList
                      : controller.doneList;
              if (list.isEmpty) {
                return _emptyView();
              }
              return RefreshIndicator(
                onRefresh: controller.refresh,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => Divider(height: 1.h, color: AppTheme.divider),
                  itemBuilder: (_, i) => _flowItem(list[i]),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(String label, int idx) {
    final selected = controller.selectedTab.value == idx;
    return Expanded(
      child: InkWell(
        onTap: () => controller.changeTab(idx),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppTheme.primary : Colors.transparent,
                width: 2.h,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: selected ? AppTheme.primary : AppTheme.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64.w, color: AppTheme.gray300),
          SizedBox(height: 16.h),
          Text('暂无流程', style: TextStyle(fontSize: 14.sp, color: AppTheme.textTertiary)),
        ],
      ),
    );
  }

  Widget _flowItem(Map<String, dynamic> item) {
    final id = item['id']?.toString() ?? '';
    final name = item['name']?.toString() ?? '(无标题)';
    final creator = item['creator']?.toString() ?? '';
    final date = item['createdDate']?.toString() ?? '';
    final state = item['state']?.toString() ?? '';
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
        child: Icon(Icons.assignment, color: AppTheme.primaryColor, size: 20.w),
      ),
      title: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
      subtitle: Text('$creator · $date',
        style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary)),
      trailing: state.isNotEmpty
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: _stateColor(state).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(_stateText(state),
                style: TextStyle(fontSize: 11.sp, color: _stateColor(state))),
            )
          : null,
      onTap: () {
        if (id.isNotEmpty) {
          Get.toNamed(Routes.WORKFLOW_DETAIL, arguments: {'id': id});
        }
      },
    );
  }

  Color _stateColor(String state) {
    if (state == '0' || state == '待办') return Colors.orange;
    if (state == '1' || state == '进行中') return Colors.blue;
    if (state == '2' || state == '已完成') return Colors.green;
    return AppTheme.textTertiary;
  }

  String _stateText(String state) {
    if (state == '0') return '待办';
    if (state == '1') return '进行中';
    if (state == '2') return '已完成';
    return state;
  }
}
