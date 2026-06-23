import 'package:get/get.dart';
import '../controllers/workflow_detail_controller.dart';

class WorkflowDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkflowDetailController>(() => WorkflowDetailController());
  }
}
