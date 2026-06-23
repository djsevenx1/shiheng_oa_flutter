import 'package:get/get.dart';

import '../../modules/home/bindings/home_binding.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/login/bindings/login_binding.dart';
import '../../modules/login/views/login_view.dart';
import '../../modules/splash/views/splash_view.dart';
import '../../modules/workflow/bindings/workflow_binding.dart';
import '../../modules/workflow/views/workflow_view.dart';
import '../../modules/report/bindings/report_binding.dart';
import '../../modules/report/views/report_view.dart';
import '../../modules/attendance/bindings/attendance_binding.dart';
import '../../modules/attendance/views/attendance_view.dart';
import '../../modules/crm/bindings/crm_binding.dart';
import '../../modules/crm/views/crm_view.dart';
import '../../modules/settings/bindings/settings_binding.dart';
import '../../modules/settings/views/settings_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.WORKFLOW,
      page: () => const WorkflowView(),
      binding: WorkflowBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.REPORT,
      page: () => const ReportView(),
      binding: ReportBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.ATTENDANCE,
      page: () => const AttendanceView(),
      binding: AttendanceBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.CRM,
      page: () => const CrmView(),
      binding: CrmBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.cupertino,
    ),
  ];
}
