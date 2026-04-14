import 'package:get/get.dart';
import '../controllers/certification_packages_controller.dart';

class CertificationPackagesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CertificationPackagesController>(
      () => CertificationPackagesController(),
    );
  }
}
