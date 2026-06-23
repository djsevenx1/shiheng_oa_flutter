import 'package:get/get.dart';
import '../controllers/workflow_form_controller.dart';

class WorkflowFormBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<WorkflowFormController>(() => WorkflowFormController());
  }
}
