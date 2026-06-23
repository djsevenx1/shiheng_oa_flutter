import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanController extends GetxController {
  final MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
  );

  final isProcessing = false.obs;
  final lastResult = RxnString();
  final torchOn = false.obs;

  void onDetect(BarcodeCapture capture) {
    if (isProcessing.value) return;
    for (final b in capture.barcodes) {
      final raw = b.rawValue;
      if (raw == null) continue;
      isProcessing.value = true;
      lastResult.value = raw;
      _handleResult(raw);
      break;
    }
  }

  Future<void> _handleResult(String raw) async {
    // 暂停扫描
    try {
      await scannerController.stop();
    } catch (_) {}

    // 简单识别：URL/JSON/纯文本
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      final go = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('扫描结果'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('检测到链接，是否在浏览器打开？'),
              SizedBox(height: 12),
              SelectableText(raw, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Get.back(result: false), child: const Text('取消')),
            TextButton(onPressed: () => Get.back(result: true), child: const Text('打开')),
          ],
        ),
      );
      if (go == true) {
        Get.snackbar('提示', '已发送：$raw（需要 url_launcher 集成）', snackPosition: SnackPosition.BOTTOM);
      }
    } else if (raw.startsWith('{') && raw.endsWith('}')) {
      Get.snackbar('扫描结果', '检测到 JSON 业务码：$raw', snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 5));
    } else {
      Get.snackbar('扫描结果', raw, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 3));
    }

    isProcessing.value = false;
  }

  Future<void> toggleTorch() async {
    try {
      await scannerController.toggleTorch();
      torchOn.value = !torchOn.value;
    } catch (_) {}
  }

  Future<void> switchCamera() async {
    try {
      await scannerController.switchCamera();
    } catch (_) {}
  }

  Future<void> resume() async {
    try {
      await scannerController.start();
    } catch (_) {}
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }
}
