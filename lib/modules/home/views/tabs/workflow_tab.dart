import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../app/data/repository/workflow_repository.dart';
import '../../../../app/routes/app_pages.dart';
import '../../../../app/themes/app_theme.dart';

/// 老 App 主流程 tab：待处理(preHandle) + 已发起的(submitted) + 已审批的(handled)
/// 老 App sate 模式 POST /oa/handle/initList + filter body
class WorkflowTab extends StatefulWidget {
  const WorkflowTab({super.key});

  @override
  State<WorkflowTab> createState() => _WorkflowTabState();
}

class _WorkflowTabState extends State<WorkflowTab> {
  final _workflowRepository = WorkflowRepository();

  List<dynamic> todoList = [];       // 待处理（preHandle）
  List<dynamic> historyList = [];    // 历史流程（全部）
  bool isLoadingTodo = true;
  bool isLoadingHistory = true;
  String? todoError;
  String? historyError;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([_loadTodo(), _loadHistory()]);
  }

  Future<void> _loadTodo() async {
    setState(() { isLoadingTodo = true; todoError = null; });
    final result = await _workflowRepository.getWorkflowList(status: 'todo', limit: 50);
    if (mounted) {
      setState(() {
        isLoadingTodo = false;
        if (result['success'] == true) {
          todoList = List<dynamic>.from(result['data'] ?? []);
        } else {
          todoList = [];
          todoError = result['message']?.toString() ?? '加载失败';
        }
      });
    }
  }

  Future<void> _loadHistory() async {
    setState(() { isLoadingHistory = true; historyError = null; });
    final result = await _workflowRepository.getWorkflowList(status: 'history', limit: 50);
    if (mounted) {
      setState(() {
        isLoadingHistory = false;
        if (result['success'] == true) {
          historyList = List<dynamic>.from(result['data'] ?? []);
        } else {
          historyList = [];
          historyError = result['message']?.toString() ?? '加载失败';
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
          title: const Text('流程'),
          bottom: TabBar(
            tabs: [
              Tab(text: '待处理 (${todoList.length})'),
              Tab(text: '历史流程 (${historyList.length})'),
            ],
            labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
            unselectedLabelStyle: TextStyle(fontSize: 14.sp),
            isScrollable: true,
            tabAlignment: TabAlignment.start,
          ),
        ),
        body: TabBarView(
          children: [
            _buildFlowList(todoList, isLoadingTodo, '暂无待处理流程', _loadTodo, error: todoError, isHandle: true),
            _buildFlowList(historyList, isLoadingHistory, '暂无历史流程', _loadHistory, error: historyError, isHandle: false),
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

  Widget _buildFlowList(List<dynamic> items, bool isLoading, String emptyText, Future<void> Function() onRefresh, {String? error, bool isHandle = false}) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          children: [
            SizedBox(height: 100.h),
            Center(
              child: Column(
                children: [
                  Icon(Icons.error_outline, size: 64.w, color: AppTheme.danger),
                  SizedBox(height: 16.h),
                  Text(error, style: TextStyle(fontSize: 14.sp, color: AppTheme.danger), textAlign: TextAlign.center),
                  SizedBox(height: 8.h),
                  TextButton(onPressed: onRefresh, child: const Text('重试')),
                ],
              ),
            ),
          ],
        ),
      );
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
          return GestureDetector(
            onTap: () {
              final id = item['id'];
              if (id != null) {
                Get.toNamed(Routes.WORKFLOW_DETAIL, arguments: {'proId': id, 'handle': isHandle});
              }
            },
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
