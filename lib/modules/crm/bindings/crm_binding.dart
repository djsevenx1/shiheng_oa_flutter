import 'package:get/get.dart';
import '../controllers/crm_client_controller.dart';
import '../controllers/crm_business_controller.dart';
import '../controllers/crm_sales_order_controller.dart';
import '../controllers/crm_channel_controller.dart';

class CrmBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CrmClientController>(() => CrmClientController());
    Get.lazyPut<CrmBusinessController>(() => CrmBusinessController());
    Get.lazyPut<CrmSalesOrderController>(() => CrmSalesOrderController());
    Get.lazyPut<CrmChannelController>(() => CrmChannelController());
  }
}
