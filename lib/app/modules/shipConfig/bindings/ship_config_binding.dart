import 'package:get/get.dart';

import '../controllers/ship_config_controller.dart';

class ShipConfigBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShipConfigController>(
      () => ShipConfigController(),
    );
  }
}
