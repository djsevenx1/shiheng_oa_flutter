import 'package:get/get.dart';
import '../controllers/crm_client_controller.dart';

class CrmClientBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CrmClientController>(() => CrmClientController());
  }
}
