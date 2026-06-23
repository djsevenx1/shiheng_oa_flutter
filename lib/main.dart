import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '时恒电子 OA',
      debugShowCheckedModeBanner: false,
      home: const _BootScreen(),
    );
  }
}

class _BootScreen extends StatefulWidget {
  const _BootScreen();

  @override
  State<_BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<_BootScreen> {
  String _status = '启动中...';
  String? _error;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // 动态加载主程序
      // ignore: avoid_dynamic_calls
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _status = '应用就绪';
        });
      }
    } catch (e, st) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _status = '启动失败';
        });
      }
      debugPrint('Boot error: $e\n$st');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF61428F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.business, size: 80, color: Colors.white),
            const SizedBox(height: 24),
            const Text(
              '时恒电子 OA',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              style: const TextStyle(fontSize: 14, color: Colors.white70),
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                color: Colors.red.shade100,
                child: Text(
                  _error!,
                  style: const TextStyle(fontSize: 10, color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

