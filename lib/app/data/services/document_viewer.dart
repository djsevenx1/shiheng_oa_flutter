import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../themes/app_theme.dart';

/// 文档预览服务
/// - PDF：先下载到本地缓存，再用 flutter_pdfview 渲染
/// - Office/图片/其他：下载后用 open_filex 调系统应用
class DocumentViewer {
  DocumentViewer._internal();
  static final DocumentViewer _instance = DocumentViewer._internal();
  factory DocumentViewer() => _instance;

  /// 打开远程文档
  /// [url] 远程地址；[title] 标题；[fileName] 可选下载文件名
  Future<void> openRemote(String url, {String title = '文档', String? fileName}) async {
    final name = fileName ?? _extractFileName(url);
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );
    try {
      final saved = await _downloadToTemp(url, name);
      Get.back();
      if (saved == null) {
        Get.snackbar('失败', '下载失败', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      if (ext == 'pdf') {
        Get.to(
          () => _PdfPreviewPage(path: saved.path, title: title),
          transition: Transition.cupertino,
        );
      } else {
        final result = await OpenFilex.open(saved.path);
        if (result.type != ResultType.done) {
          Get.snackbar('失败', '没有应用能打开此文件', snackPosition: SnackPosition.BOTTOM);
        }
      }
    } catch (e) {
      try { Get.back(); } catch (_) {}
      Get.snackbar('失败', '打开文件出错: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// 打开本地文件
  Future<void> openLocal(File file) async {
    final result = await OpenFilex.open(file.path);
    if (result.type != ResultType.done) {
      Get.snackbar('失败', '没有应用能打开此文件', snackPosition: SnackPosition.BOTTOM);
    }
  }

  String _extractFileName(String url) {
    try {
      final uri = Uri.parse(url);
      final segs = uri.pathSegments;
      if (segs.isNotEmpty) return segs.last;
    } catch (_) {}
    return 'document_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<File?> _downloadToTemp(String url, String fileName) async {
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/$fileName';
      final response = await dio.Dio().download(url, path);
      if (response.statusCode == 200) {
        return File(path);
      }
    } catch (_) {}
    return null;
  }
}

class _PdfPreviewPage extends StatelessWidget {
  const _PdfPreviewPage({required this.path, required this.title});
  final String path;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: PDFView(
        filePath: path,
        enableSwipe: true,
        autoSpacing: true,
        pageFling: true,
        onError: (error) {
          debugPrint('pdf error: $error');
        },
      ),
    );
  }
}
