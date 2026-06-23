import 'package:get/get.dart';
import '../controllers/sh_report_controller.dart';

class ShReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShReportController>(() => ShReportController());
  }
}
