import 'dart:async';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class SplashController extends GetxController {
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    print('SplashController onInit called');
    _startNavigation();
  }

  void _startNavigation() {
    _timer = Timer(const Duration(seconds: 3), () {
      print('Navigating to onboarding...');
      try {
        Get.offAllNamed(Routes.ONBOARDING);
      } catch (e) {
        print('Navigation error: $e');
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
