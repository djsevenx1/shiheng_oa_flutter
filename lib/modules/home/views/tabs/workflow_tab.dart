import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../app/data/repository/task_repository.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/themes/app_theme.dart';

class WorkflowTab extends StatefulWidget {
  const WorkflowTab({super.key});

  @override
  State<WorkflowTab> createState() => _WorkflowTabState();
}

class _WorkflowTabState extends State<WorkflowTab> {
  final _taskRepository = TaskRepository();

  List<dynamic> todoList = [];
  List<dynamic> doneList = [];
  bool isLoadingTodo = true;
  bool isLoadingDone = true;

  @override
  void initState() {
    super.initState();
    _loadTodo();
    _loadDone();
  }

  Future<void> _loadTodo() async {
    setState(() => isLoadingTodo = true);
    final result = await _taskRepository.getTaskList(status: 'Todo', pageSize: 50);
    if (mounted) {
      setState(() {
        isLoadingTodo = false;
        if (result['success'] == true) {
          todoList = List<dynamic>.from(result['data'] ?? []);
        } else {
          todoList = [];
        }
      });
    }
  }

  Future<void> _loadDone() async {
    setState(() => isLoadingDone = true);
    final result = await _taskRepository.getTaskList(status: 'Done', pageSize: 50);
    if (mounted) {
      setState(() {
        isLoadingDone = false;
        if (result['success'] == true) {
          doneList = List<dynamic>.from(result['data'] ?? []);
        } else {
          doneList = [];
        }
      });
    }
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '';
    if (timestamp is int) {
      final dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    }
    return timestamp.toString();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('流程审批'),
          bottom: TabBar(
            tabs: [
              Tab(text: '待处理 (${todoList.length})'),
              Tab(text: '已处理 (${doneList.length})'),
            ],
            labelStyle: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 15.sp),
          ),
        ),
        body: TabBarView(
          children: [
            _buildTaskList(todoList, isLoadingTodo, '暂无待办任务', _loadTodo),
            _buildTaskList(doneList, isLoadingDone, '暂无已办任务', _loadDone),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Get.snackbar('提示', '请在浏览器发起流程', snackPosition: SnackPosition.BOTTOM);
          },
          icon: const Icon(Icons.add),
          label: const Text('发起流程'),
          backgroundColor: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildTaskList(List<dynamic> items, bool isLoading, String emptyText, Future<void> Function() onRefresh) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (items.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: [
            SizedBox(height: 100.h),
            Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 64.w, color: AppTheme.gray300),
                  SizedBox(height: 16.h),
                  Text(emptyText, style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary)),
                  SizedBox(height: 8.h),
                  TextButton(onPressed: onRefresh, child: const Text('刷新')),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index] as Map<String, dynamic>;
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
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        '任务',
                        style: TextStyle(fontSize: 12.sp, color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(item['startDate']),
                      style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  item['name']?.toString() ?? '无标题',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                SizedBox(height: 8.h),
                if (item['leader'] != null)
                  Text(
                    '负责人: ${item['leader']}',
                    style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary),
                  ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    if (item['deadline'] != null) ...[
                      Icon(Icons.schedule, size: 14.w, color: AppTheme.textTertiary),
                      SizedBox(width: 4.w),
                      Text(
                        '截止: ${_formatDate(item['deadline'])}',
                        style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
