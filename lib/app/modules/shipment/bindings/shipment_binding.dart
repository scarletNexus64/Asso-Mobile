import 'package:get/get.dart';
import '../controllers/shipment_controller.dart';
import '../../myOrder/controllers/my_order_controller.dart';

class ShipmentBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<MyOrderController>()) {
      Get.put(MyOrderController());
    }
    Get.lazyPut<ShipmentController>(() => ShipmentController());
  }
}
