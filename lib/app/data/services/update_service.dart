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
/// 使用 Cloudflare Pages 代理加速 GitHub 访问（path-based 路由）
class UpdateService {
  static const _repoOwner = 'djsevenx1';
  static const _repoName = 'shiheng_oa_flutter';
  static const _apkName = 'shiheng-oa-universal.apk';
  static const _currentVersion = '2.7.5';

  /// CF Pages 代理域名（path-based 路由，跟 LunaTV-Mobile 一致）
  static const _cfProxy = 'https://tmdb-8d1.pages.dev';

  /// CF 代理 API: /github/repos/:owner/:repo/releases/latest
  static String get _apiUrlProxy =>
      '$_cfProxy/github/repos/$_repoOwner/$_repoName/releases/latest';

  /// GitHub API 直连
  static const _apiUrlDirect =
      'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest';

  /// 构建 CF 代理下载 URL: /github/asset/:owner/:repo/:tag/:asset
  static String _buildProxyDownloadUrl(String owner, String repo, String tag, String asset) {
    return '$_cfProxy/github/asset/$owner/$repo/$tag/$asset';
  }

  /// 检查是否有新版本
  static Future<Map<String, dynamic>> checkUpdate() async {
    // 先尝试 CF 代理，失败回退直连
    final result = await _checkUpdateWithUrl(_apiUrlProxy, useProxy: true);
    if (result != null) return result;

    final directResult = await _checkUpdateWithUrl(_apiUrlDirect, useProxy: false);
    if (directResult != null) return directResult;

    return {'hasUpdate': false, 'error': '检查更新失败，请稍后重试'};
  }

  static Future<Map<String, dynamic>?> _checkUpdateWithUrl(String apiUrl, {required bool useProxy}) async {
    try {
      final response = await dio.Dio().get(
        apiUrl,
        options: dio.Options(
          headers: {'Accept': 'application/vnd.github+json'},
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
        ),
      );
      final data = response.data;
      if (data is! Map) return null;
      if (data['tag_name'] == null) return null;

      final tagName = data['tag_name']?.toString() ?? '';
      final latestVersion = tagName.startsWith('v') ? tagName.substring(1) : tagName;
      final hasUpdate = _compareVersion(latestVersion, _currentVersion) > 0;

      // 找 APK 下载 URL
      String? directDownloadUrl;
      String? apkAssetName;
      final assets = data['assets'];
      if (assets is List) {
        for (final asset in assets) {
          if (asset is Map && asset['name']?.toString() == _apkName) {
            directDownloadUrl = asset['browser_download_url']?.toString();
            apkAssetName = asset['name']?.toString();
            break;
          }
        }
      }
      directDownloadUrl ??=
          'https://github.com/$_repoOwner/$_repoName/releases/download/$tagName/$_apkName';
      apkAssetName ??= _apkName;

      // 构建代理下载 URL
      final proxyDownloadUrl = useProxy
          ? _buildProxyDownloadUrl(_repoOwner, _repoName, tagName, apkAssetName)
          : _buildProxyDownloadUrl(_repoOwner, _repoName, tagName, apkAssetName);

      final releaseNotes = data['body']?.toString() ?? '';

      return {
        'hasUpdate': hasUpdate,
        'latestVersion': latestVersion,
        'currentVersion': _currentVersion,
        'directDownloadUrl': directDownloadUrl,
        'proxyDownloadUrl': proxyDownloadUrl,
        'releaseNotes': releaseNotes,
        'htmlUrl': data['html_url']?.toString() ?? '',
      };
    } catch (e) {
      return null;
    }
  }

  /// 比较版本号
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

  /// 下载 APK 并安装（先 CF 代理，失败回退直连）
  static Future<void> downloadAndInstall({
    required String directDownloadUrl,
    required String proxyDownloadUrl,
    required Function(int received, int total, int percentage) onProgress,
  }) async {
    final dir = await getExternalStorageDirectory();
    final filePath = '${dir?.path}/$_apkName';
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }

    // 先尝试 CF 代理下载
    bool success = await _downloadFile(proxyDownloadUrl, filePath, onProgress);

    // 代理失败，回退直连
    if (!success) {
      success = await _downloadFile(directDownloadUrl, filePath, onProgress);
    }

    if (!success) {
      Get.snackbar('下载失败', '网络错误，请检查网络后重试',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.danger,
          colorText: Colors.white);
      return;
    }

    // 调起系统安装
    try {
      final result = await OpenFilex.open(filePath);
      if (result.type != ResultType.done) {
        Get.snackbar('提示', '无法自动安装，请到下载目录手动安装',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('安装失败', '$e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.danger,
          colorText: Colors.white);
    }
  }

  static Future<bool> _downloadFile(
    String url,
    String filePath,
    Function(int received, int total, int percentage) onProgress,
  ) async {
    try {
      await dio.Dio().download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            final percentage = (received / total * 100).round();
            onProgress(received, total, percentage);
          }
        },
        options: dio.Options(
          responseType: dio.ResponseType.bytes,
          receiveTimeout: const Duration(minutes: 10),
          sendTimeout: const Duration(seconds: 30),
          followRedirects: true,
          maxRedirects: 5,
        ),
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 显示更新对话框
  static void showUpdateDialog(Map<String, dynamic> updateInfo) {
    final latestVersion = updateInfo['latestVersion']?.toString() ?? '';
    final directDownloadUrl = updateInfo['directDownloadUrl']?.toString() ?? '';
    final proxyDownloadUrl = updateInfo['proxyDownloadUrl']?.toString() ?? '';
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
              Text('更新内容：',
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
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
            child: Text('稍后再说',
                style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showDownloadDialog(directDownloadUrl, proxyDownloadUrl);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor),
            child: Text('立即更新',
                style: TextStyle(fontSize: 14.sp, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  /// 显示下载进度对话框
  static void _showDownloadDialog(String directDownloadUrl, String proxyDownloadUrl) {
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
                      child: Text('取消',
                          style: TextStyle(fontSize: 14.sp, color: AppTheme.textSecondary)),
                    ),
                  ]
                : null,
          )),
      barrierDismissible: false,
    );

    downloadAndInstall(
      directDownloadUrl: directDownloadUrl,
      proxyDownloadUrl: proxyDownloadUrl,
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
      await Future.delayed(const Duration(seconds: 2));
      showUpdateDialog(result);
    }
  }
}
