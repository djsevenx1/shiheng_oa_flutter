// lib/modules/login/views/diag_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../app/data/providers/api_provider.dart';
import '../../../app/data/services/diag_log.dart';
import '../../../app/data/repository/auth_repository.dart';
import '../../../app/themes/app_theme.dart';

/// 诊断页：显示 baseUrl / JSESSIONID / 用户信息 / 日志路径 + 一键测 ping
/// 用户遇到问题时能截图这一页给我，我能看到真机真实状态
class DiagView extends StatelessWidget {
  const DiagView({super.key});

  @override
  Widget build(BuildContext context) {
    final api = ApiProvider();
    final auth = AuthRepository();
    final baseUrl = api.baseUrl;
    final jsession = (auth.getStorage().read('JSESSIONID') ?? '').toString();
    final userInfo = auth.getUserInfo();
    final cachedName = (auth.getStorage().read('cachedUserName') ?? '').toString();
    final cachedGroup = (auth.getStorage().read('cachedUserGroup') ?? '').toString();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('网络诊断', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _section('基本信息', [
            _kv('BaseURL', baseUrl),
            _kv('JSESSIONID', jsession.isEmpty ? '(空)' : jsession),
            _kv('当前版本', '2.0.4'),
          ]),
          SizedBox(height: 16.h),
          _section('登录信息', [
            _kv('userInfo', userInfo == null || userInfo.isEmpty ? '(空)' : userInfo.toString()),
            _kv('cachedUserName', cachedName.isEmpty ? '(空)' : cachedName),
            _kv('cachedUserGroup', cachedGroup.isEmpty ? '(空)' : cachedGroup),
          ]),
          SizedBox(height: 16.h),
          _section('操作', [
            ElevatedButton.icon(
              icon: const Icon(Icons.network_check),
              label: const Text('测试连接后端'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 44.h),
              ),
              onPressed: () => _testConnection(api),
            ),
            SizedBox(height: 8.h),
            ElevatedButton.icon(
              icon: const Icon(Icons.copy),
              label: const Text('复制日志路径'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor.withAlpha(50),
                foregroundColor: AppTheme.primaryColor,
                minimumSize: Size(double.infinity, 44.h),
              ),
              onPressed: () async {
                final p = await DiagLog.filePath();
                if (p.isNotEmpty) {
                  Clipboard.setData(ClipboardData(text: p));
                  Get.snackbar('已复制', p, snackPosition: SnackPosition.BOTTOM);
                }
              },
            ),
            SizedBox(height: 8.h),
            ElevatedButton.icon(
              icon: const Icon(Icons.delete_outline),
              label: const Text('清空日志'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                minimumSize: Size(double.infinity, 44.h),
              ),
              onPressed: () async {
                await DiagLog.clear();
                Get.snackbar('已清空', '日志已清空', snackPosition: SnackPosition.BOTTOM);
              },
            ),
          ]),
          SizedBox(height: 16.h),
          _section('最近日志', [
            FutureBuilder<String>(
              future: DiagLog.read(),
              builder: (context, snap) {
                final text = snap.data ?? '加载中...';
                return Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SelectableText(
                    text.isEmpty ? '(空)' : text,
                    style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Colors.black87),
                  ),
                );
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppTheme.primaryColor)),
          SizedBox(height: 8.h),
          ...children,
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(k, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
          ),
          Expanded(
            child: SelectableText(
              v.isEmpty ? '(空)' : v,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _testConnection(ApiProvider api) async {
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      final r = await api.dioInstance.get('/oa/common/groups');
      Get.back();
      Get.snackbar(
        '连接成功',
        'HTTP ${r.statusCode} / ${r.data is List ? (r.data as List).length : '?'} 个部门',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      DiagLog.write('TEST', 'ping /oa/common/groups → ${r.statusCode}');
    } catch (e) {
      Get.back();
      Get.snackbar(
        '连接失败',
        '$e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 6),
      );
      DiagLog.write('TEST', 'ping FAILED → $e');
    }
  }
}
