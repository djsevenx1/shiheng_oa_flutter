import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../app/data/repository/workflow_repository.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/themes/app_theme.dart';

/// 老 App 主流程 tab：待办(state=0) + 已完成(state=2)
/// 老 App 实际是 3 个 tab：待办 / 进行中 / 已完成
class WorkflowTab extends StatefulWidget {
  const WorkflowTab({super.key});

  @override
  State<WorkflowTab> createState() => _WorkflowTabState();
}

class _WorkflowTabState extends State<WorkflowTab> {
  final _workflowRepository = WorkflowRepository();

  List<dynamic> todoList = [];       // state=0 待我审批
  List<dynamic> runningList = [];    // state=1 进行中（我发起的）
  List<dynamic> doneList = [];       // state=2 已完成
  bool isLoadingTodo = true;
  bool isLoadingRunning = true;
  bool isLoadingDone = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadTodo(), _loadRunning(), _loadDone()]);
  }

  Future<void> _loadTodo() async {
    setState(() => isLoadingTodo = true);
    final result = await _workflowRepository.getWorkflowList(status: 'todo', limit: 50);
    if (mounted) {
      setState(() {
        isLoadingTodo = false;
        todoList = (result['success'] == true) ? List<dynamic>.from(result['data'] ?? []) : [];
      });
    }
  }

  Future<void> _loadRunning() async {
    setState(() => isLoadingRunning = true);
    final result = await _workflowRepository.getWorkflowList(status: 'running', limit: 50);
    if (mounted) {
      setState(() {
        isLoadingRunning = false;
        runningList = (result['success'] == true) ? List<dynamic>.from(result['data'] ?? []) : [];
      });
    }
  }

  Future<void> _loadDone() async {
    setState(() => isLoadingDone = true);
    final result = await _workflowRepository.getWorkflowList(status: 'done', limit: 50);
    if (mounted) {
      setState(() {
        isLoadingDone = false;
        doneList = (result['success'] == true) ? List<dynamic>.from(result['data'] ?? []) : [];
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
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('流程'),
          bottom: TabBar(
            tabs: [
              Tab(text: '待办 (${todoList.length})'),
              Tab(text: '进行中 (${runningList.length})'),
              Tab(text: '已完成 (${doneList.length})'),
            ],
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 14.sp),
            isScrollable: true,
            tabAlignment: TabAlignment.start,
          ),
        ),
        body: TabBarView(
          children: [
            _buildFlowList(todoList, isLoadingTodo, '暂无待办', _loadTodo),
            _buildFlowList(runningList, isLoadingRunning, '暂无进行中', _loadRunning),
            _buildFlowList(doneList, isLoadingDone, '暂无已完成', _loadDone),
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

  Widget _buildFlowList(List<dynamic> items, bool isLoading, String emptyText, Future<void> Function() onRefresh) {
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
                        '流程',
                        style: TextStyle(fontSize: 12.sp, color: AppTheme.primaryColor, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(item['createdDate'] ?? item['startDate'] ?? item['date']),
                      style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  item['name']?.toString() ?? item['title']?.toString() ?? '(无标题)',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                SizedBox(height: 8.h),
                if (item['creator'] != null)
                  Text(
                    '发起人：${item['creator']}',
                    style: TextStyle(fontSize: 12.sp, color: AppTheme.textTertiary),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WorkflowPickerSheet extends StatefulWidget {
  final WorkflowRepository repository;
  const _WorkflowPickerSheet({required this.repository});

  @override
  State<_WorkflowPickerSheet> createState() => _WorkflowPickerSheetState();
}

class _WorkflowPickerSheetState extends State<_WorkflowPickerSheet> {
  bool isLoading = true;
  List<dynamic> mods = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final result = await widget.repository.getWorkflowTemplates();
    if (mounted) {
      setState(() {
        isLoading = false;
        if (result['success'] == true) {
          mods = List<dynamic>.from(result['data'] ?? []);
        } else {
          error = result['message']?.toString();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
          ),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.h),
                width: 36.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Text('选择流程类型', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey[200]),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : error != null
                        ? Center(child: Text(error!))
                        : mods.isEmpty
                            ? const Center(child: Text('暂无可用流程模板'))
                            : ListView.separated(
                                controller: controller,
                                itemCount: mods.length,
                                separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                                itemBuilder: (_, i) {
                                  final m = mods[i] as Map<String, dynamic>;
                                  final id = m['id']?.toString() ?? '';
                                  final name = m['name']?.toString() ?? '(无标题)';
                                  return ListTile(
                                    leading: Icon(Icons.assignment_outlined, color: AppTheme.primaryColor),
                                    title: Text(name),
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () {
                                      Get.back();
                                      Get.toNamed(Routes.WORKFLOW_FORM, arguments: {
                                        'modId': id,
                                        'appKey': m['tableKey']?.toString() ?? m['appKey']?.toString() ?? '',
                                        'name': name,
                                      });
                                    },
                                  );
                                },
                              ),
              ),
            ],
          ),
        );
      },
    );
  }
}
