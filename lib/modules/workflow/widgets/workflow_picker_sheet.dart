import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/workflow_repository.dart';
import '../../../app/routes/app_pages.dart';
import '../../../app/themes/app_theme.dart';

/// 流程类型选择器（公共组件）
/// 从 /oa/handle/initMods 获取可发起的流程模板列表
class WorkflowPickerSheet extends StatefulWidget {
  final WorkflowRepository? repository;
  const WorkflowPickerSheet({super.key, this.repository});

  /// 弹出选择器（静态方法，方便调用）
  static void show({WorkflowRepository? repository}) {
    showModalBottomSheet(
      context: Get.context!,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => WorkflowPickerSheet(repository: repository),
    );
  }

  @override
  State<WorkflowPickerSheet> createState() => _WorkflowPickerSheetState();
}

class _WorkflowPickerSheetState extends State<WorkflowPickerSheet> {
  late final WorkflowRepository _repo;
  bool isLoading = true;
  List<dynamic> mods = [];
  String? error;

  @override
  void initState() {
    super.initState();
    _repo = widget.repository ?? WorkflowRepository();
    _load();
  }

  Future<void> _load() async {
    final result = await _repo.getWorkflowTemplates();
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
                                        'moduleName': name,
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
