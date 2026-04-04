import 'package:get/get.dart';
import '../controllers/product_management_controller.dart';

class ProductManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProductManagementController>(
      () => ProductManagementController(),
    );
  }
}
