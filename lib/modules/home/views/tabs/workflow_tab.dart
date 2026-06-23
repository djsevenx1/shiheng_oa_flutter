import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../app/data/repository/task_repository.dart';
import '../../../../app/data/repository/workflow_repository.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/themes/app_theme.dart';

class WorkflowTab extends StatefulWidget {
  const WorkflowTab({super.key});

  @override
  State<WorkflowTab> createState() => _WorkflowTabState();
}

class _WorkflowTabState extends State<WorkflowTab> {
  final _taskRepository = TaskRepository();
  final _workflowRepository = WorkflowRepository();

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
          onPressed: _openWorkflowPicker,
          icon: const Icon(Icons.add),
          label: const Text('发起流程'),
          backgroundColor: AppTheme.primaryColor,
        ),
      ),
    );
  }

  /// 弹出底部 sheet，列出可发起的流程模板
  Future<void> _openWorkflowPicker() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _WorkflowPickerSheet(repository: _workflowRepository),
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

/// 发起流程 picker
/// 后端 /oa/common/workflows 返回的列表，点了之后带 modId 跳到 workflow_form
class _WorkflowPickerSheet extends StatefulWidget {
  const _WorkflowPickerSheet({required this.repository});
  final WorkflowRepository repository;

  @override
  State<_WorkflowPickerSheet> createState() => _WorkflowPickerSheetState();
}

class _WorkflowPickerSheetState extends State<_WorkflowPickerSheet> {
  bool _loading = true;
  List<dynamic> _templates = [];
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMsg = null;
    });
    final result = await widget.repository.getWorkflowTemplates();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result['success'] == true) {
        _templates = (result['data'] as List?) ?? [];
        if (_templates.isEmpty) {
          _errorMsg = '后端尚未配置任何流程模板\n请联系管理员在 OA 后台添加';
        }
      } else {
        _errorMsg = result['message']?.toString() ?? '加载失败';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(maxHeight: 600.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: AppTheme.gray300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Text('选择流程类型', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
                const Spacer(),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
          ),
          Divider(height: 1.h, color: AppTheme.gray200),
          Flexible(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _errorMsg != null
                    ? Padding(
                        padding: EdgeInsets.all(40.w),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.info_outline, size: 64.w, color: AppTheme.gray300),
                            SizedBox(height: 16.h),
                            Text(_errorMsg!, textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary)),
                            SizedBox(height: 16.h),
                            TextButton.icon(
                              onPressed: _load,
                              icon: const Icon(Icons.refresh),
                              label: const Text('重试'),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        itemCount: _templates.length,
                        separatorBuilder: (_, __) => Divider(height: 1.h, indent: 20.w, color: AppTheme.gray100),
                        itemBuilder: (context, index) {
                          final tpl = _templates[index] as Map<String, dynamic>;
                          final id = tpl['id']?.toString() ?? '';
                          final name = tpl['name']?.toString() ?? tpl['title']?.toString() ?? '未命名流程';
                          final desc = tpl['description']?.toString() ?? tpl['remark']?.toString() ?? '';
                          return ListTile(
                            leading: Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(Icons.assignment_outlined, color: AppTheme.primaryColor, size: 22.w),
                            ),
                            title: Text(name, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w500)),
                            subtitle: desc.isNotEmpty ? Text(desc, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                            trailing: Icon(Icons.chevron_right, color: AppTheme.gray400, size: 20.w),
                            onTap: () {
                              Navigator.pop(context);
                              Get.toNamed(
                                Routes.WORKFLOW_FORM,
                                arguments: {'modId': int.tryParse(id) ?? 0, 'moduleName': name},
                              );
                            },
                          );
                        },
                      ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
        ],
      ),
    );
  }
}
