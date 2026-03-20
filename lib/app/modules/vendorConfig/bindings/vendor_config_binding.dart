import 'package:get/get.dart';

import '../controllers/vendor_config_controller.dart';

class VendorConfigBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VendorConfigController>(
      () => VendorConfigController(),
    );
  }
}
