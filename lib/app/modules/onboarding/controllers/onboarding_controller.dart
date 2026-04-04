import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/storage_service.dart';
import '../../../routes/app_pages.dart';
import '../../../core/base/safe_controller_mixin.dart';

class OnboardingController extends GetxController with SafeControllerMixin {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final int totalPages = 3;

  @override
  void onInit() {
    super.onInit();
    pageController.addListener(() {
      safeExecute(() {
        currentPage.value = pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void onClose() {
    markAsDisposed();
    pageController.dispose();
    super.onClose();
  }

  void nextPage() {
    if (currentPage.value < totalPages - 1) {
      safeAnimateToPage(
        pageController,
        currentPage.value + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Mark onboarding as done and go to welcomer
      StorageService.setOnboardingDone();
      Get.offAllNamed(Routes.WELCOMER);
    }
  }

  void skipOnboarding() {
    // Mark onboarding as done when skipped
    StorageService.setOnboardingDone();
    Get.offAllNamed(Routes.WELCOMER);
  }

  void goToPage(int page) {
    safeAnimateToPage(
      pageController,
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}
