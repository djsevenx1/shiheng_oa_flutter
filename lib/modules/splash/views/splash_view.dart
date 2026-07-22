import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/data/providers/api_provider.dart';
import '../../../app/routes/app_pages.dart';
import '../../login/controllers/login_controller.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    // 启动后立即并行做两件事:
    // 1) 预热服务器连接(发一个 GET /,触发 TCP 握手,后面业务请求能复用)
    // 2) 等待 800ms 后做自动登录判断
    // 同时把"最少停留时间"压到 800ms(原来是 2000ms),因为预热让首请求更快
    Future.microtask(() async {
      // 启动连接预热,不阻塞主流程
      unawaited(ApiProvider().warmup());

      // 至少停留 800ms,让 splash 不会闪一下就过
      await Future.delayed(const Duration(milliseconds: 800));

      try {
        // 自动登录(里面会读 token / JSESSIONID,有效则跳首页)
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
              '时恒电子',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              '移动办公平台',
              style: TextStyle(
                fontSize: 13,
                color: Colors.white70,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
