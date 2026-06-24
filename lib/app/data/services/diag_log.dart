// lib/app/data/services/diag_log.dart
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

/// 调试日志写入文件
/// 真机无 USB 调试时，用户可通过"导出日志"按钮把日志拿给我
class DiagLog {
  static File? _file;
  static final List<String> _buffer = [];
  static const int _maxBuffer = 500;

  static Future<String> filePath() async {
    if (_file != null) return _file!.path;
    try {
      final dir = await getApplicationDocumentsDirectory();
      _file = File('${dir.path}/diag.log');
      if (!await _file!.exists()) {
        await _file!.create(recursive: true);
      }
      return _file!.path;
    } catch (e) {
      return '';
    }
  }

  static Future<void> write(String tag, String msg) async {
    final ts = DateTime.now().toIso8601String();
    final line = '[$ts][$tag] $msg';
    _buffer.add(line);
    if (_buffer.length > _maxBuffer) {
      _buffer.removeRange(0, _buffer.length - _maxBuffer);
    }
    if (kDebugMode) debugPrint(line);
    try {
      final p = await filePath();
      if (p.isEmpty) return;
      await File(p).writeAsString('${line}\n', mode: FileMode.append, flush: false);
    } catch (_) {}
  }

  static Future<String> read() async {
    try {
      final p = await filePath();
      if (p.isEmpty) return '日志文件不可用';
      final f = File(p);
      if (!await f.exists()) return '日志文件不存在';
      return await f.readAsString();
    } catch (e) {
      return '读取失败: $e';
    }
  }

  static Future<void> clear() async {
    _buffer.clear();
    try {
      final p = await filePath();
      if (p.isEmpty) return;
      await File(p).writeAsString('');
    } catch (_) {}
  }
}
