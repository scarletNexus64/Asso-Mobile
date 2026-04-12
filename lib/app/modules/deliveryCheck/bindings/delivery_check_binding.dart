import 'package:get/get.dart';
import '../controllers/delivery_check_controller.dart';

class DeliveryCheckBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliveryCheckController>(
      () => DeliveryCheckController(),
    );
  }
}
