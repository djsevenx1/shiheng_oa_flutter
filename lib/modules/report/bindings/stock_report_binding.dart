import 'package:get/get.dart';
import '../controllers/stock_report_controller.dart';

class StockReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StockReportController>(() => StockReportController());
  }
}
