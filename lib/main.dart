import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'app/data/repository/name_dict_repository.dart';
import 'app/routes/app_pages.dart';
import 'app/themes/app_theme.dart';
import 'modules/settings/controllers/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 强制竖屏,禁止横屏
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
  ]);

  // 全局错误处理
  FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('FlutterError: ${details.exceptionAsString()}');
  };

  try {
    await GetStorage.init();
  } catch (e) {
    debugPrint('GetStorage init failed: $e');
  }

  // 启动时先从本地缓存恢复名称字典,无网络也能展示历史数据
  try {
    final dict = NameDictRepository();
    dict.loadFromCache();
    if (dict.isLoaded) {
      Get.put<NameDictRepository>(dict, permanent: true);
    }
  } catch (e) {
    debugPrint('NameDict loadFromCache failed: $e');
  }

  // 提前注册 SettingsController,让 main 可以响应式读取深色模式
  Get.put<SettingsController>(SettingsController(), permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          title: '时恒OA',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: Get.isRegistered<SettingsController>()
              ? Get.find<SettingsController>().themeMode.value
              : ThemeMode.light,
          initialRoute: AppPages.INITIAL,
          getPages: AppPages.routes,
          defaultTransition: Transition.cupertino,
        );
      },
    );
  }
}
