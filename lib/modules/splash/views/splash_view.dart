import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../login/controllers/login_controller.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () async {
      try {
        // 尝试自动登录
        final autoLoggedIn = await LoginController.tryAutoLogin();
        if (autoLoggedIn) {
          Get.offAllNamed(Routes.HOME);
        } else {
          Get.offAllNamed(Routes.LOGIN);
        }
      } catch (e) {
        debugPrint('Navigate error: $e');
        Get.offAllNamed(Routes.LOGIN);
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
