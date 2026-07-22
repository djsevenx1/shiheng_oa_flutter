import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

class SettingsController extends GetxController {
  static const _kDarkMode = 'dark_mode';

  final GetStorage _storage = GetStorage();

  /// 当前主题模式（响应式：UI 通过 Obx 监听）
  final themeMode = ThemeMode.light.obs;

  /// 兼容旧字段（已废弃，使用 themeMode）
  RxBool get isDarkMode => RxBool(themeMode.value == ThemeMode.dark);

  final notificationsEnabled = true.obs;
  final cacheSize = '0 B'.obs;
  final isClearingCache = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
    _calcCacheSize();
  }

  void loadSettings() {
    // 从本地恢复深色模式选择
    final saved = _storage.read(_kDarkMode);
    if (saved is bool) {
      themeMode.value = saved ? ThemeMode.dark : ThemeMode.light;
    } else {
      themeMode.value = ThemeMode.light;
    }
  }

  /// 切换深色模式
  void toggleDarkMode(bool value) {
    themeMode.value = value ? ThemeMode.dark : ThemeMode.light;
    _storage.write(_kDarkMode, value);
    Get.changeThemeMode(themeMode.value);
  }

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
  }

  /// 重新计算缓存大小
  Future<void> refreshCacheSize() async {
    await _calcCacheSize();
  }

  Future<void> _calcCacheSize() async {
    try {
      int total = 0;
      // 1) GetStorage 占用
      try {
        final dir = await getApplicationDocumentsDirectory();
        final f = File('${dir.path}/$GetStorageName');
        if (await f.exists()) {
          total += await f.length();
        }
      } catch (_) {}
      // 2) 应用缓存目录占用
      try {
        final cacheDir = await getTemporaryDirectory();
        if (await cacheDir.exists()) {
          total += await _dirSize(cacheDir);
        }
      } catch (_) {}
      // 3) 外部存储(若有 APK 下载等)
      try {
        final ext = await getExternalStorageDirectory();
        if (ext != null && await ext.exists()) {
          total += await _dirSize(ext);
        }
      } catch (_) {}
      cacheSize.value = _formatBytes(total);
    } catch (e) {
      cacheSize.value = '—';
    }
  }

  Future<int> _dirSize(Directory dir) async {
    int total = 0;
    try {
      await for (final entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File) {
          try {
            total += await entity.length();
          } catch (_) {}
        }
      }
    } catch (_) {}
    return total;
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / 1024 / 1024).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024 / 1024 / 1024).toStringAsFixed(2)} GB';
  }

  /// 清除缓存:清空 GetStorage 中的非关键数据 + 临时目录
  Future<void> clearCache() async {
    if (isClearingCache.value) return;
    isClearingCache.value = true;
    try {
      // 1) 清除 GetStorage 中非登录态、非深色模式的数据
      final keys = _storage.getKeys().toList();
      for (final k in keys) {
        if (k == _kDarkMode) continue; // 保留深色模式选择
        if (k.startsWith('login_') || k == 'server_url' || k == 'auto_login') {
          continue; // 保留登录相关
        }
        await _storage.remove(k);
      }
      // 2) 清空临时目录
      try {
        final cacheDir = await getTemporaryDirectory();
        if (await cacheDir.exists()) {
          await for (final entity in cacheDir.list(followLinks: false)) {
            try {
              if (entity is File) {
                await entity.delete();
              }
            } catch (_) {}
          }
        }
      } catch (_) {}
      // 3) 删除外部存储中的 APK 下载文件
      try {
        final ext = await getExternalStorageDirectory();
        if (ext != null) {
          for (final f in await ext.list().toList()) {
            try {
              if (f is File && f.path.endsWith('.apk')) {
                await f.delete();
              }
            } catch (_) {}
          }
        }
      } catch (_) {}
      // 4) 重新计算
      await _calcCacheSize();
      Get.snackbar('完成', '缓存已清除', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('失败', '清除缓存失败: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isClearingCache.value = false;
    }
  }
}

/// 与 GetStorage 内部文件名保持一致
const String GetStorageName = 'GetStorage';
