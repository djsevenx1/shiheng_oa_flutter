import 'package:get/get.dart';
import '../controllers/task_create_controller.dart';

class TaskCreateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskCreateController>(() => TaskCreateController());
  }
}
