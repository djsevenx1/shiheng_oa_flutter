import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/auth_repository.dart';
import '../../../app/data/repository/contacts_repository.dart';
import '../../../app/data/repository/workflow_repository.dart';
import '../../../app/themes/app_theme.dart';

class WorkflowDetailController extends GetxController {
  final _repository = WorkflowRepository();
  final _authRepo = AuthRepository();

  final isLoading = false.obs;
  final proId = 0.obs;
  final workflowDetail = <String, dynamic>{}.obs;
  final logs = <Map<String, dynamic>>[].obs;
  final formData = <String, dynamic>{}.obs;
  final commentController = TextEditingController();
  final errorMessage = RxnString();

  // tableSchema 解析结果
  final mainFields = <Map<String, dynamic>>[].obs;  // 主表字段（非明细）
  final detailFields = <Map<String, dynamic>>[].obs; // 明细子字段定义
  final mxItems = <Map<String, dynamic>>[].obs;      // 明细数据行
  final isHandleMode = false.obs; // true=待处理(可审批) false=历史(只读)

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args['proId'] != null) {
      final raw = args['proId'];
      proId.value = raw is int ? raw : int.tryParse(raw.toString()) ?? 0;
      isHandleMode.value = args['handle'] == true;
      loadDetail();
    }
  }

  @override
  void onClose() {
    commentController.dispose();
    super.onClose();
  }

  Future<void> loadDetail() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await _repository.getWorkflowDetail(proId.value);
      if (result['success'] == true) {
        final data = (result['data'] as Map?)?.cast<String, dynamic>() ?? {};
        _formatTimestampField(data, 'createdDate');
        _formatTimestampField(data, 'lastDate');
        workflowDetail.value = data;

        // 解析 tableSchema
        var ts = data['tableSchema'];
        if (ts is String) {
          ts = jsonDecode(ts);
        }
        if (ts is List) {
          mainFields.clear();
          detailFields.clear();
          for (final f in ts) {
            final field = Map<String, dynamic>.from(f as Map);
            if (field['flagDetail'] == true) {
              final subs = field['fields'];
              if (subs is List) {
                for (final s in subs) {
                  detailFields.add(Map<String, dynamic>.from(s as Map));
                }
              }
            } else {
              mainFields.add(field);
            }
          }
        }

        // 解析 formData
        final rawFormData = (data['formData'] as Map?)?.cast<String, dynamic>() ?? {};
        formData.value = Map<String, dynamic>.from(rawFormData);
        for (final key in ['created_date', 'rq', 'last_date']) {
          if (formData.containsKey(key)) {
            _formatTimestampField(formData, key);
          }
        }

        // 解析 mx（明细数据行）
        final mx = formData['mx'];
        if (mx is List) {
          mxItems.value = mx.map((m) {
            final item = Map<String, dynamic>.from(m as Map);
            for (final key in ['created_date', 'xqrq', 'rq']) {
              if (item.containsKey(key)) {
                _formatTimestampField(item, key);
              }
            }
            return item;
          }).toList();
        } else {
          mxItems.clear();
        }

        // 解析 logs
        final rawLogs = (data['logs'] as List?) ?? [];
        logs.value = rawLogs.map((log) {
          final m = Map<String, dynamic>.from(log as Map);
          _formatTimestampField(m, 'createdDate');
          return m;
        }).toList();
      } else {
        errorMessage.value = result['message']?.toString() ?? '加载详情失败';
      }
    } catch (e) {
      errorMessage.value = '加载详情异常: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void _formatTimestampField(Map<String, dynamic> map, String key) {
    final v = map[key];
    if (v is int && v > 100000000000) {
      final dt = DateTime.fromMillisecondsSinceEpoch(v);
      map[key] = '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } else if (v is String && v.length > 10) {
      map[key] = v.substring(0, v.length > 16 ? 16 : v.length);
    }
  }

  String getActionName(dynamic actionId) {
    final id = actionId is int ? actionId : int.tryParse(actionId?.toString() ?? '') ?? 0;
    switch (id) {
      case 1: return '发起';
      case 2: return '同意';
      case 3: return '拒绝';
      case 4: return '转交';
      case 5: return '指定审批';
      case 6: return '退回';
      case 11: return '加签';
      case -1: return '撤回';
      default: return '审批';
    }
  }

  bool isActionPositive(dynamic actionId) {
    final id = actionId is int ? actionId : int.tryParse(actionId?.toString() ?? '') ?? 0;
    return id == 1 || id == 2 || id == 4 || id == 5 || id == 11;
  }

  /// 是否为审批人模式（显示拒绝/通过 + 转交/前加签/通知）
  /// 老 App pro.js goHandle(): state > 0 || state == -2 → handle 视图
  ///                        state <= 0 && state != -2 → form 视图
  bool get isApproverMode {
    if (!isHandleMode.value) return false;
    final state = workflowDetail['state'];
    if (state is int) {
      return state > 0 || state == -2;
    }
    return false;
  }

  /// 获取字段显示值
  String getFieldValue(Map<String, dynamic> field) {
    final id = field['id']?.toString() ?? '';
    final ctrl = field['ctrl']?.toString() ?? '';
    final value = formData[id];

    if (ctrl == 'logs') {
      final names = <String>[];
      for (final log in logs) {
        final name = log['name']?.toString();
        if (name != null && name.isNotEmpty) names.add(name);
      }
      return names.join(', ');
    }

    if (value == null) return '';
    return value.toString();
  }

  String getDetailValue(Map<String, dynamic> mxItem, Map<String, dynamic> field) {
    final id = field['id']?.toString() ?? '';
    final value = mxItem[id];
    if (value == null) return '';
    return value.toString();
  }

  Future<void> approve() async {
    if (commentController.text.trim().isEmpty) {
      Get.snackbar('提示', '请输入审批意见', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading.value = true;
    try {
      final oldLogCount = logs.length;
      final result = await _repository.approveWorkflow(
        proId: proId.value,
        result: 'pass',
        comment: commentController.text.trim(),
      );
      if (result['success'] == true) {
        Get.snackbar('成功', '审批已通过', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.success, colorText: Colors.white);
        Get.back(result: {'refresh': true});
      } else {
        // 后端可能返回错误但操作已生效，重新加载详情验证
        await loadDetail();
        if (logs.length > oldLogCount) {
          Get.snackbar('成功', '审批已通过', snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppTheme.success, colorText: Colors.white);
          Get.back(result: {'refresh': true});
        } else {
          Get.snackbar('失败', result['message']?.toString() ?? '操作失败',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppTheme.danger, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar('失败', '网络错误: $e', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.danger, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reject() async {
    if (commentController.text.trim().isEmpty) {
      Get.snackbar('提示', '请输入拒绝原因', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    isLoading.value = true;
    try {
      final oldLogCount = logs.length;
      final result = await _repository.approveWorkflow(
        proId: proId.value,
        result: 'reject',
        comment: commentController.text.trim(),
      );
      if (result['success'] == true) {
        Get.snackbar('成功', '已拒绝', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.warning, colorText: Colors.white);
        Get.back(result: {'refresh': true});
      } else {
        // 后端可能返回错误但操作已生效，重新加载详情验证
        await loadDetail();
        if (logs.length > oldLogCount) {
          Get.snackbar('成功', '已拒绝', snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppTheme.warning, colorText: Colors.white);
          Get.back(result: {'refresh': true});
        } else {
          Get.snackbar('失败', result['message']?.toString() ?? '操作失败',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppTheme.danger, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar('失败', '网络错误: $e', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.danger, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// 放弃此申购单（GET /oa/pro/drop/:proId 彻底删除流程实例及表单数据）
  /// 与老 App proView.js 的 $scope.remove 一致：删除成功后返回流程列表
  Future<void> abandon() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('确认放弃'),
        content: const Text('放弃后将删除此申购单，且无法恢复。是否确认放弃？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text('确认放弃', style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    isLoading.value = true;
    try {
      final result = await _repository.dropProcess(proId.value);
      if (result['success'] == true) {
        Get.snackbar('成功', '已放弃此申购单', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.success, colorText: Colors.white);
        Get.back(result: {'refresh': true});
      } else {
        Get.snackbar('失败', result['message']?.toString() ?? '网络错误，请重试',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.danger, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('失败', '网络错误，请重试', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.danger, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// 转交：选择人员后，通过审批接口带 extraUserIds 转交
  Future<void> forward() async {
    final users = await _pickUsers(title: '选择转交人', multiSelect: true);
    if (users == null || users.isEmpty) return;
    final userIds = users.map((u) {
      final id = u['id'];
      return id is int ? id : int.tryParse(id?.toString() ?? '') ?? 0;
    }).where((id) => id > 0).toList();
    if (userIds.isEmpty) {
      Get.snackbar('提示', '请选择有效的转交人', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final oldLogCount = logs.length;
      final moduleName = workflowDetail['module']?['name']?.toString() ?? '';
      final userInfo = _authRepo.getUserInfo();
      final groupId = userInfo?['groupId'] is int
          ? userInfo!['groupId'] as int
          : int.tryParse(userInfo?['groupId']?.toString() ?? '') ?? 0;

      final result = await _repository.forwardWorkflow(
        proId: proId.value,
        extraUserIds: userIds,
        comment: commentController.text.trim(),
        name: moduleName,
        groupId: groupId > 0 ? groupId : null,
      );
      if (result['success'] == true) {
        Get.snackbar('成功', '已转交给${users.length}人审批', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.success, colorText: Colors.white);
        Get.back(result: {'refresh': true});
      } else {
        // 后端可能返回错误但操作已生效，重新加载详情验证
        await loadDetail();
        if (logs.length > oldLogCount) {
          // logs 增加 → 操作实际已生效
          Get.snackbar('成功', '已转交给${users.length}人审批', snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppTheme.success, colorText: Colors.white);
          Get.back(result: {'refresh': true});
        } else {
          Get.snackbar('失败', result['message']?.toString() ?? '操作失败',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppTheme.danger, colorText: Colors.white);
        }
      }
    } catch (e) {
      Get.snackbar('失败', '网络错误: $e', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.danger, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// 前加签：选择人员后，调用 /oa/pro/assist 加签
  Future<void> assist() async {
    final users = await _pickUsers(title: '选择前加签人员', multiSelect: false);
    if (users == null || users.isEmpty) return;
    final user = users.first;
    final assistId = user['id'] is int ? user['id'] : int.tryParse(user['id']?.toString() ?? '') ?? 0;
    if (assistId <= 0) {
      Get.snackbar('提示', '请选择有效的加签人', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final result = await _repository.assistWorkflow(
        proId: proId.value,
        assistId: assistId,
        comment: commentController.text.trim(),
      );
      if (result['success'] == true) {
        Get.snackbar('成功', '已加签${user['name']}，等待其审批后由您继续处理',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.success, colorText: Colors.white);
        await loadDetail();
      } else {
        Get.snackbar('失败', result['message']?.toString() ?? '操作失败',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.danger, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('失败', '网络错误: $e', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.danger, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// 通知：选择人员后，推送企业微信通知到其手机
  /// 老 App APIWechat.pushText(): POST /oa/wechat/pushText
  Future<void> broadcast() async {
    final users = await _pickUsers(title: '选择通知人', multiSelect: true);
    if (users == null || users.isEmpty) return;
    final loginNames = users.map((u) {
      return u['login_name']?.toString() ?? u['loginName']?.toString() ?? '';
    }).where((n) => n.isNotEmpty).toList();
    if (loginNames.isEmpty) {
      Get.snackbar('提示', '选中人员没有登录账号，无法推送通知', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    try {
      final moduleName = workflowDetail['module']?['name']?.toString() ?? '流程';
      final userInfo = _authRepo.getUserInfo();
      final senderName = userInfo?['name']?.toString() ?? '';
      final result = await _repository.broadcastWorkflow(
        title: '来自$senderName的$moduleName通知',
        content: '请查看流程：$moduleName（编号：${proId.value}）',
        loginNames: loginNames,
      );
      if (result['success'] == true) {
        Get.snackbar('成功', '已推送通知给${users.length}人', snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.success, colorText: Colors.white);
      } else {
        Get.snackbar('失败', result['message']?.toString() ?? '操作失败',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.danger, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('失败', '网络错误: $e', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.danger, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  /// 选人弹窗（复用通讯录接口 /oa/u/initList）
  /// multiSelect=true 返回 List<Map>，false 返回 List<Map>（1个元素）
  Future<List<Map<String, dynamic>>?> _pickUsers({
    required String title,
    required bool multiSelect,
  }) async {
    return Get.bottomSheet<List<Map<String, dynamic>>>(
      _UserPickerBottomSheet(title: title, multiSelect: multiSelect),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
    );
  }

  String getStateName(int state) {
    switch (state) {
      case 0: return '未提交';
      case 1: return '审批中';
      case 2: return '已结束';
      case -1: return '被拒绝';
      case -2: return '被撤回';
      default: return '未知';
    }
  }

  Color getStateColor(int state) {
    switch (state) {
      case 0: return AppTheme.warning;
      case 1: return AppTheme.info;
      case 2: return AppTheme.success;
      case -1: case -2: return AppTheme.danger;
      default: return AppTheme.gray500;
    }
  }

  /// 编辑明细行
  void updateMxItem(int index, Map<String, dynamic> values) {
    if (index < mxItems.length) {
      final item = Map<String, dynamic>.from(mxItems[index]);
      item.addAll(values);
      mxItems[index] = item;
      mxItems.refresh();
      formData['mx'] = mxItems.toList();
    }
  }

  /// 新增明细行
  void addMxItem() {
    final newItem = <String, dynamic>{};
    for (final f in detailFields) {
      final id = f['id']?.toString() ?? f['name']?.toString() ?? '';
      if (id.isNotEmpty) newItem[id] = '';
    }
    mxItems.add(newItem);
    formData['mx'] = mxItems.toList();
  }

  /// 删除明细行
  void removeMxItem(int index) {
    if (index < mxItems.length) {
      mxItems.removeAt(index);
      formData['mx'] = mxItems.toList();
    }
  }
}

/// 选人底部弹窗（支持单选/多选，复用 /oa/u/initList）
class _UserPickerBottomSheet extends StatefulWidget {
  final String title;
  final bool multiSelect;
  const _UserPickerBottomSheet({required this.title, required this.multiSelect});

  @override
  State<_UserPickerBottomSheet> createState() => _UserPickerBottomSheetState();
}

class _UserPickerBottomSheetState extends State<_UserPickerBottomSheet> {
  final _repo = ContactsRepository();
  final _keyword = TextEditingController();
  List<Map<String, dynamic>> _allUsers = [];
  List<Map<String, dynamic>> _filtered = [];
  final Set<int> _selectedIds = {};
  bool _isLoading = true;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final res = await _repo.getAllMembers(limit: 200);
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res['success'] == true) {
          _allUsers = (res['data'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          _filtered = _allUsers;
        }
      });
    }
  }

  void _onSearch(String k) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 200), () {
      if (k.trim().isEmpty) {
        setState(() => _filtered = _allUsers);
      } else {
        setState(() {
          _filtered = _allUsers.where((u) {
            final n = u['name']?.toString() ?? '';
            return n.toLowerCase().contains(k.toLowerCase());
          }).toList();
        });
      }
    });
  }

  int _getId(Map u) {
    final id = u['id'];
    return id is int ? id : int.tryParse(id?.toString() ?? '') ?? 0;
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _keyword.dispose();
    super.dispose();
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
                width: 36.w, height: 4.h,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2.r)),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Text(widget.title, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Get.back()),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: TextField(
                  controller: _keyword,
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: '搜索姓名',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true, fillColor: AppTheme.gray50,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _filtered.isEmpty
                        ? const Center(child: Text('暂无成员'))
                        : ListView.separated(
                            controller: controller,
                            itemCount: _filtered.length,
                            separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey[200]),
                            itemBuilder: (_, i) {
                              final u = _filtered[i];
                              final name = u['name']?.toString() ?? '(无姓名)';
                              final dept = u['deptName']?.toString() ?? u['groupName']?.toString() ?? '';
                              final id = _getId(u);
                              final isSelected = _selectedIds.contains(id);
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                                  child: Text(name.isNotEmpty ? name[0] : '?',
                                      style: TextStyle(color: AppTheme.primaryColor)),
                                ),
                                title: Text(name),
                                subtitle: dept.isNotEmpty ? Text(dept, style: TextStyle(fontSize: 12.sp)) : null,
                                trailing: widget.multiSelect
                                    ? Icon(isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                                        color: isSelected ? AppTheme.primaryColor : Colors.grey[400])
                                    : null,
                                onTap: () {
                                  if (widget.multiSelect) {
                                    setState(() {
                                      if (isSelected) {
                                        _selectedIds.remove(id);
                                      } else {
                                        _selectedIds.add(id);
                                      }
                                    });
                                  } else {
                                    Get.back(result: <Map<String, dynamic>>[u]);
                                  }
                                },
                              );
                            },
                          ),
              ),
              if (widget.multiSelect && _selectedIds.isNotEmpty)
                SafeArea(
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final selected = _allUsers.where((u) => _selectedIds.contains(_getId(u))).toList();
                          Get.back(result: selected);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          backgroundColor: AppTheme.primaryColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                        child: Text('确认选择（${_selectedIds.length}人）',
                            style: TextStyle(fontSize: 15.sp, color: Colors.white, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
