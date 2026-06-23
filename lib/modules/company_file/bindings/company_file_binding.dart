import 'package:get/get.dart';
import '../controllers/company_file_controller.dart';

class CompanyFileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CompanyFileController>(() => CompanyFileController());
  }
}
