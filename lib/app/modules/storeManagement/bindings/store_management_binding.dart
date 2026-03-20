import 'package:get/get.dart';

import '../controllers/store_management_controller.dart';

class StoreManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StoreManagementController>(
      () => StoreManagementController(),
    );
  }
}
