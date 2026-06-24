import 'package:get/get.dart';

import '../../modules/home/bindings/home_binding.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/login/bindings/login_binding.dart';
import '../../modules/login/views/login_view.dart';
import '../../modules/splash/views/splash_view.dart';
import '../../modules/notice/bindings/notice_binding.dart';
import '../../modules/notice/views/notice_view.dart';
import '../../modules/contacts/bindings/contacts_binding.dart';
import '../../modules/contacts/views/contacts_view.dart';
import '../../modules/my_application/bindings/my_application_binding.dart';
import '../../modules/my_application/views/my_application_view.dart';
import '../../modules/qr_scan/bindings/qr_scan_binding.dart';
import '../../modules/qr_scan/views/qr_scan_view.dart';
import '../../modules/chat/views/chat_list_view.dart';
import '../../modules/workflow/bindings/workflow_binding.dart';
import '../../modules/workflow/views/workflow_view.dart';
import '../../modules/workflow/bindings/workflow_detail_binding.dart';
import '../../modules/workflow/views/workflow_detail_view.dart';
import '../../modules/workflow/bindings/workflow_form_binding.dart';
import '../../modules/workflow/views/workflow_form_view.dart';
import '../../modules/report/bindings/report_binding.dart';
import '../../modules/report/views/report_view.dart';
import '../../modules/report/views/stock_report_view.dart';
import '../../modules/report/bindings/stock_report_binding.dart';
import '../../modules/attendance/bindings/attendance_binding.dart';
import '../../modules/attendance/views/attendance_view.dart';
import '../../modules/project/bindings/project_binding.dart';
import '../../modules/project/bindings/project_detail_binding.dart';
import '../../modules/project/views/project_view.dart';
import '../../modules/project/views/project_detail_view.dart';
import '../../modules/task/bindings/task_binding.dart';
import '../../modules/task/bindings/task_detail_binding.dart';
import '../../modules/task/bindings/task_create_binding.dart';
import '../../modules/task/views/task_view.dart';
import '../../modules/task/views/task_detail_view.dart';
import '../../modules/task/views/task_create_view.dart';
import '../../modules/topic/bindings/topic_binding.dart';
import '../../modules/topic/views/topic_view.dart';
import '../../modules/sh_report/bindings/sh_report_binding.dart';
import '../../modules/sh_report/views/sh_report_view.dart';
import '../../modules/help/views/help_view.dart';
import '../../modules/company/views/company_view.dart';
import '../../modules/version/views/version_view.dart';
import '../../modules/settings/bindings/settings_binding.dart';
import '../../modules/settings/views/settings_view.dart';
import '../../modules/map/bindings/map_binding.dart';
import '../../modules/map/views/map_view.dart';

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
      name: _Paths.WORKFLOW_DETAIL,
      page: () => const WorkflowDetailView(),
      binding: WorkflowDetailBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.WORKFLOW_FORM,
      page: () => const WorkflowFormView(),
      binding: WorkflowFormBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.REPORT,
      page: () => const ReportView(),
      binding: ReportBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.STOCK_REPORT,
      page: () => const StockReportView(),
      binding: StockReportBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.ATTENDANCE,
      page: () => const AttendanceView(),
      binding: AttendanceBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.PROJECT,
      page: () => const ProjectView(),
      binding: ProjectBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.PROJECT_DETAIL,
      page: () => const ProjectDetailView(),
      binding: ProjectDetailBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.TASK,
      page: () => const TaskView(),
      binding: TaskBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.TASK_DETAIL,
      page: () => const TaskDetailView(),
      binding: TaskDetailBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.TASK_CREATE,
      page: () => const TaskCreateView(),
      binding: TaskCreateBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.TOPIC,
      page: () => const TopicView(),
      binding: TopicBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.SH_REPORT,
      page: () => const ShReportView(),
      binding: ShReportBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.HELP,
      page: () => const HelpView(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.COMPANY,
      page: () => const CompanyView(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.VERSION,
      page: () => const VersionView(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.MAP,
      page: () => const MapView(),
      binding: MapBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.NOTICE,
      page: () => const NoticeView(),
      binding: NoticeBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.NOTICE_DETAIL,
      page: () => const NoticeDetailView(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.CONTACTS,
      page: () => const ContactsView(),
      binding: ContactsBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.MY_APPLICATION,
      page: () => const MyApplicationView(),
      binding: MyApplicationBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.QR_SCAN,
      page: () => const QrScanView(),
      binding: QrScanBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.PAYSLIP,
      binding: PayslipBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.KNOWLEDGE,
      binding: KnowledgeBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.WORK_REPORT,
      binding: WorkReportBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.WORK_REPORT_SUBMIT,
      binding: WorkReportSubmitBinding(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.CHAT_LIST,
      page: () => const ChatListView(),
      transition: Transition.cupertino,
    ),
  ];
}
