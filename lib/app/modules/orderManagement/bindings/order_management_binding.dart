import 'package:get/get.dart';

import '../controllers/order_management_controller.dart';

class OrderManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderManagementController>(
      () => OrderManagementController(),
    );
  }
}
