import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      try {
        Get.offAllNamed(Routes.LOGIN);
      } catch (e) {
        debugPrint('Navigate error: $e');
      }
    });

    return const Scaffold(
      backgroundColor: Color(0xFF61428F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 80, color: Colors.white),
            SizedBox(height: 16),
            Text(
              '时恒电子 OA',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
