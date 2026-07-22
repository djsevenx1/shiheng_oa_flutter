import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/data/repository/auth_repository.dart';
import '../../../app/data/repository/contacts_repository.dart';
import '../../../app/data/repository/name_dict_repository.dart';
import '../../../app/data/repository/workflow_repository.dart';
import '../../../app/themes/app_theme.dart';

class WorkflowDetailController extends GetxController {
  final _repository = WorkflowRepository();
  final _authRepo = AuthRepository();
  final _contactsRepo = ContactsRepository();
  final NameDictRepository _nameDict =
      Get.isRegistered<NameDictRepository>() ? Get.find<NameDictRepository>() : NameDictRepository();

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
  // 转交：选人后暂存，等用户填审批意见点"通过"时一起提交
  final forwardUserIds = <int>[].obs;
  final forwardUserNames = <String>[].obs;

  // ID→名字 映射（用于把 groupId/userId 等数字显示为名字）
  final _deptMap = <String, String>{};   // groupId → groupName
  final _userMap = <String, String>{};   // userId → userName
  bool _nameMapLoaded = false;

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
      // 进入详情时确保字典可用(若还没加载或缓存为空,异步预加载一次,失败静默)
      if (!_nameDict.isLoaded) {
        unawaited(_nameDict.preload());
      }
      final result = await _repository.getWorkflowDetail(proId.value);
      if (result['success'] == true) {
        final data = (result['data'] as Map?)?.cast<String, dynamic>() ?? {};
        _formatTimestampField(data, 'createdDate');
        _formatTimestampField(data, 'lastDate');
        workflowDetail.value = data;

        // 解析 tableSchema
        var ts = data['tableSchema'];
        if (ts is String) {
          try { ts = jsonDecode(ts); } catch (_) { ts = null; }
        }
        if (ts is List) {
          mainFields.clear();
          detailFields.clear();
          for (final f in ts) {
            if (f is! Map) continue;
            final field = Map<String, dynamic>.from(f);
            if (field['flagDetail'] == true) {
              final subs = field['fields'];
              if (subs is List) {
                for (final s in subs) {
                  if (s is Map) detailFields.add(Map<String, dynamic>.from(s));
                }
              }
            } else {
              mainFields.add(field);
            }
          }
        }

        // 解析 formData
        final rawFormData = data['formData'] is Map
            ? (data['formData'] as Map).cast<String, dynamic>()
            : <String, dynamic>{};
        formData.value = Map<String, dynamic>.from(rawFormData);
        for (final key in ['created_date', 'rq', 'last_date']) {
          if (formData.containsKey(key)) {
            _formatTimestampField(formData, key);
          }
        }

        // 解析 mx（明细数据行）
        final mx = formData['mx'];
        if (mx is List) {
          mxItems.value = mx.whereType<Map>().map((m) {
            final item = Map<String, dynamic>.from(m);
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
        final rawLogs = data['logs'];
        if (rawLogs is List) {
          logs.value = rawLogs.whereType<Map>().map((log) {
            final m = Map<String, dynamic>.from(log);
            _formatTimestampField(m, 'createdDate');
            return m;
          }).toList();
        } else {
          logs.clear();
        }
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
      case 6: return '转交';
      case 11: return '加签';
      case -1: return '撤回';
      default: return '审批';
    }
  }

  bool isActionPositive(dynamic actionId) {
    final id = actionId is int ? actionId : int.tryParse(actionId?.toString() ?? '') ?? 0;
    return id == 1 || id == 2 || id == 4 || id == 5 || id == 6 || id == 11;
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
  /// 老 App tableSchema 字段结构:{id, name, ctrl, config, required, ...}
  /// 关键规则:
  ///   ctrl == "info" + config == "name"|"loginName"|"id"|"userId" → 查 userMap
  ///   ctrl == "info" + config == "department"|"groupId"|"groupName" → 查 deptMap
  ///   其他情况:对纯数字值,优先 userMap 兜底,再 deptMap
  String getFieldValue(Map<String, dynamic> field) {
    final id = field['id']?.toString() ?? '';
    final ctrl = field['ctrl']?.toString() ?? '';
    final config = field['config']?.toString() ?? '';
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

    // 列表型字段直接拼名字
    if (value is List) {
      return value
          .map((e) => e is Map ? (e['name']?.toString() ?? e.toString()) : e.toString())
          .where((s) => s.toString().isNotEmpty)
          .join('、');
    }
    if (value is Map) {
      final name = value['name'];
      if (name != null) return name.toString();
    }

    final s = value.toString();
    final isPureNumber = RegExp(r'^\d+$').hasMatch(s);

    // 1) 精确 ctrl + config 匹配
    if (isPureNumber) {
      if (ctrl == 'info') {
        // 用户类 config
        const userConfigs = {'name', 'loginname', 'id', 'userid', 'creator'};
        // 部门类 config
        const deptConfigs = {'department', 'groupid', 'groupname', 'dep', 'deptid'};
        final cfgLower = config.toLowerCase();
        if (userConfigs.contains(cfgLower)) {
          final mapped = _nameDict.userName(s);
          if (mapped != s) return mapped;
        } else if (deptConfigs.contains(cfgLower)) {
          final mapped = _nameDict.deptName(s);
          if (mapped != s) return mapped;
        }
      }
      // 2) 通用兜底:纯数字优先人,再部门
      final mapped = _nameDict.nameOf(s);
      if (mapped != s) return mapped;
    }
    return s;
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
    var shouldPop = true; // 标记是否要 pop（任何路径都默认要 pop）
    try {
      final oldLogCount = logs.length;
      final moduleName = workflowDetail['module']?['name']?.toString() ?? '';
      final userInfo = _authRepo.getUserInfo();
      final groupId = userInfo?['groupId'] is int
          ? userInfo!['groupId'] as int
          : int.tryParse(userInfo?['groupId']?.toString() ?? '') ?? 0;

      // 根据模式选择接口：审批人 → approveWorkflow（不带 formData）
      // 发起人（待处理列表里 state<=0 或 isHandleMode 但不是审批节点）→ submitWorkflow（带 formData,flagPositive=null）
      final Map<String, dynamic> result;
      final isApprover = isApproverMode;
      if (forwardUserIds.isNotEmpty) {
        result = await _repository.forwardWorkflow(
          proId: proId.value,
          extraUserIds: forwardUserIds.toList(),
          comment: commentController.text.trim(),
          name: moduleName,
          groupId: groupId > 0 ? groupId : null,
        );
      } else if (isApprover) {
        result = await _repository.approveWorkflow(
          proId: proId.value,
          result: 'pass',
          comment: commentController.text.trim(),
          name: moduleName,
          groupId: groupId > 0 ? groupId : null,
        );
      } else {
        // 发起人"提交"：带完整 formData，flagPositive=null
        result = await _repository.submitWorkflow(
          modId: (workflowDetail['module'] is Map ? (workflowDetail['module'] as Map)['id'] : null) is int
              ? (workflowDetail['module'] as Map)['id'] as int
              : int.tryParse(workflowDetail['module']?['id']?.toString() ?? '') ?? 0,
          formData: Map<String, dynamic>.from(formData),
          appKey: workflowDetail['module']?['tableKey']?.toString() ?? '',
          name: moduleName,
          module: workflowDetail['module'] is Map
              ? Map<String, dynamic>.from(workflowDetail['module'] as Map)
              : null,
          proId: proId.value,
          groupId: groupId > 0 ? groupId : null,
          message: commentController.text.trim(),
          flagPositive: null,
        );
      }
      // 老 App: 后端返回 errMsg 作为提示信息（如"已提交库房审批"）
      final serverMsg = result['message']?.toString() ?? '';
      final displayMsg = serverMsg.isNotEmpty
          ? serverMsg
          : (forwardUserIds.isNotEmpty
              ? '已转交给${forwardUserNames.length}人审批'
              : (isApprover ? '审批已通过' : '提交成功,等待审批'));
      final isSuccess = result['success'] == true;
      if (!isSuccess) {
        // 后端返回失败，重新加载详情验证操作是否实际已生效
        try {
          await loadDetail();
        } catch (_) {}
        // 失败时不立即 pop,留给用户看错误
        shouldPop = false;
      }
      final actuallySucceeded = isSuccess || logs.length > oldLogCount;
      Get.snackbar(
        actuallySucceeded ? '成功' : '失败',
        actuallySucceeded ? displayMsg : (result['message']?.toString() ?? '操作失败'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: actuallySucceeded ? AppTheme.success : AppTheme.danger,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar('失败', '网络错误: $e', snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.danger, colorText: Colors.white);
    } finally {
      isLoading.value = false;
      // 任何路径都保证 pop 一次（成功或异常），避免卡在详情页
      if (shouldPop && Get.isOverlaysOpen == false) {
        // 延迟一帧让 snackbar/loading 完全释放
        Future.microtask(() {
          if (Get.isOverlaysOpen) return;
          // Get.back 可能被调用多次导致多次 pop，加 guard
          if (Get.currentRoute.contains('detail')) {
            Get.back(result: {'refresh': true});
          }
        });
      }
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
      final moduleName = workflowDetail['module']?['name']?.toString() ?? '';
      final userInfo = _authRepo.getUserInfo();
      final groupId = userInfo?['groupId'] is int
          ? userInfo!['groupId'] as int
          : int.tryParse(userInfo?['groupId']?.toString() ?? '') ?? 0;
      final result = await _repository.approveWorkflow(
        proId: proId.value,
        result: 'reject',
        comment: commentController.text.trim(),
        name: moduleName,
        groupId: groupId > 0 ? groupId : null,
      );
      final serverMsg = result['message']?.toString() ?? '';
      final displayMsg = serverMsg.isNotEmpty ? serverMsg : '已拒绝';
      final isSuccess = result['success'] == true;
      if (!isSuccess) {
        await loadDetail();
      }
      final actuallySucceeded = isSuccess || logs.length > oldLogCount;
      Get.snackbar(
        actuallySucceeded ? '成功' : '失败',
        actuallySucceeded ? displayMsg : (result['message']?.toString() ?? '操作失败'),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: actuallySucceeded ? AppTheme.warning : AppTheme.danger,
        colorText: Colors.white,
      );
      // 无论成功失败都返回上一页，让列表刷新
      Get.back(result: {'refresh': true});
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

  /// 转交：仅选择人员并暂存，等用户填审批意见后点"通过"时一起提交
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
    // 暂存转交人，不提交；等用户填审批意见点"通过"时一起提交
    forwardUserIds.value = userIds;
    forwardUserNames.value = users.map((u) => u['name']?.toString() ?? '').toList();
    final names = forwardUserNames.join('、');
    Get.snackbar('已选转交人', '$names\n请填写审批意见后点击"通过"提交',
        snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
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
