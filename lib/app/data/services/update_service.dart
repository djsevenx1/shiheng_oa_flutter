import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../themes/app_theme.dart';

/// 应用内更新服务
/// 通过 GitHub Releases API 检查新版本，下载 APK 并调起安装
class UpdateService {
  static const _repoOwner = 'djsevenx1';
  static const _repoName = 'shiheng_oa_flutter';
  static const _apkName = 'shiheng-oa-universal.apk';
  static const _currentVersion = '2.5.8'; // 与 pubspec.yaml 保持一致

  /// GitHub API: 获取最新 release
  static const _apiUrl =
      'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest';

  /// 检查是否有新版本
  /// 返回 {hasUpdate, latestVersion, downloadUrl, releaseNotes, htmlUrl}
  static Future<Map<String, dynamic>> checkUpdate() async {
    try {
      final response = await dio.Dio().get(
        _apiUrl,
        options: dio.Options(
          headers: {'Accept': 'application/vnd.github+json'},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      final data = response.data;
      if (data is! Map) return {'hasUpdate': false};

      final tagName = data['tag_name']?.toString() ?? '';
      // tag_name 格式: v2.5.7 → 去掉 v 前缀
      final latestVersion = tagName.startsWith('v') ? tagName.substring(1) : tagName;

      // 版本比较：按 . 分隔的数字比较
      final hasUpdate = _compareVersion(latestVersion, _currentVersion) > 0;

      // 找 APK 下载 URL
      String? downloadUrl;
      final assets = data['assets'];
      if (assets is List) {
        for (final asset in assets) {
          if (asset is Map && asset['name']?.toString() == _apkName) {
            downloadUrl = asset['browser_download_url']?.toString();
            break;
          }
        }
      }
      // fallback: 拼接 URL
      downloadUrl ??=
          'https://github.com/$_repoOwner/$_repoName/releases/download/$tagName/$_apkName';

      final releaseNotes = data['body']?.toString() ?? '';

      return {
        'hasUpdate': hasUpdate,
        'latestVersion': latestVersion,
        'currentVersion': _currentVersion,
        'downloadUrl': downloadUrl,
        'releaseNotes': releaseNotes,
        'htmlUrl': data['html_url']?.toString() ?? '',
      };
    } on dio.DioException catch (e) {
      return {'hasUpdate': false, 'error': e.message ?? '网络错误'};
    } catch (e) {
      return {'hasUpdate': false, 'error': '$e'};
    }
  }

  /// 比较版本号，返回 >0 表示 a 更新，<0 表示 a 更旧，0 表示相同
  static int _compareVersion(String a, String b) {
    final pa = a.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final pb = b.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    for (var i = 0; i < pa.length || i < pb.length; i++) {
      final va = i < pa.length ? pa[i] : 0;
      final vb = i < pb.length ? pb[i] : 0;
      if (va != vb) return va - vb;
    }
    return 0;
  }

  /// 下载 APK 并安装
  /// onProgress: (received, total, percentage) 回调
  static Future<void> downloadAndInstall({
    required String downloadUrl,
    required Function(int received, int total, int percentage) onProgress,
  }) async {
    try {
      final dir = await getExternalStorageDirectory();
      final filePath = '${dir?.path}/$_apkName';
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      await dio.Dio().download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final percentage = (received / total * 100).round();
            onProgress(received, total, percentage);
          }
        },
        options: dio.Options(
          receiveTimeout: const Duration(minutes: 10),
          sendTimeout: const Duration(seconds: 30),
        ),
      );

      // 调起系统安装
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        Get.snackbar('提示', '无法自动安装，请到下载目录手动安装',
            snackPosition: SnackPosition.BOTTOM);
      }
    } on dio.DioException catch (e) {
      Get.snackbar('下载失败', e.message ?? '网络错误，请重试',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.danger,
          colorText: Colors.white);
    } catch (e) {
      Get.snackbar('安装失败', '$e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.danger,
          colorText: Colors.white);
    }
  }

  /// 显示更新对话框
  static void showUpdateDialog(Map<String, dynamic> updateInfo) {
    final latestVersion = updateInfo['latestVersion']?.toString() ?? '';
    final downloadUrl = updateInfo['downloadUrl']?.toString() ?? '';
    final releaseNotes = updateInfo['releaseNotes']?.toString() ?? '';
    final currentVersion = updateInfo['currentVersion']?.toString() ?? _currentVersion;

    Get.dialog(
      AlertDialog(
        title: Text('发现新版本 v$latestVersion',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('当前版本: v$currentVersion',
                  style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary)),
              SizedBox(height: 12.h),
              Text('更新内容：', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
              SizedBox(height: 4.h),
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    releaseNotes.isNotEmpty ? releaseNotes : 'Bug 修复和性能优化',
                    style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary, height: 1.5),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('稍后再说', style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showDownloadDialog(downloadUrl);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: Text('立即更新', style: TextStyle(fontSize: 14.sp, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// 显示下载进度对话框
  static void _showDownloadDialog(String downloadUrl) {
    final progress = 0.obs;
    final isDownloading = true.obs;
    final receivedStr = ''.obs;
    final totalStr = ''.obs;

    Get.dialog(
      Obx(() => AlertDialog(
        title: Text(isDownloading.value ? '正在下载更新' : '下载完成',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: progress.value / 100.0,
              backgroundColor: AppTheme.gray100,
              valueColor: AlwaysStoppedAnimation(AppTheme.primaryColor),
            ),
            SizedBox(height: 12.h),
            Text(
              isDownloading.value
                  ? '${progress.value}%  ${receivedStr.value} / ${totalStr.value}'
                  : '正在安装，请稍候...',
              style: TextStyle(fontSize: 13.sp, color: AppTheme.textSecondary),
            ),
          ],
        ),
        actions: isDownloading.value
            ? [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text('取消', style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary)),
                ),
              ]
            : null,
      )),
      barrierDismissible: false,
    );

    downloadAndInstall(
      downloadUrl: downloadUrl,
      onProgress: (received, total, percentage) {
        progress.value = percentage;
        receivedStr.value = _formatBytes(received);
        totalStr.value = _formatBytes(total);
        if (percentage >= 100) {
          isDownloading.value = false;
        }
      },
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
  }

  /// 启动时静默检查更新（有新版本才弹窗）
  static Future<void> checkUpdateOnStartup() async {
    final result = await checkUpdate();
    if (result['hasUpdate'] == true) {
      // 延迟 2 秒等首页加载完
      await Future.delayed(const Duration(seconds: 2));
      showUpdateDialog(result);
    }
  }
}
