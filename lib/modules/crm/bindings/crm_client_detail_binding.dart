import 'package:get/get.dart';
import '../controllers/crm_client_detail_controller.dart';

class CrmClientDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CrmClientDetailController>(() => CrmClientDetailController());
  }
}
