import 'package:get/get.dart';
import '../controllers/package_subscription_controller.dart';

class PackageSubscriptionBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PackageSubscriptionController>(
      () => PackageSubscriptionController(),
    );
  }
}
