import 'package:get/get.dart';
import '../controllers/my_application_controller.dart';

class MyApplicationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => MyApplicationController());
  }
}
