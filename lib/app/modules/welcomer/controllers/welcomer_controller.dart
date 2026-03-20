import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class WelcomerController extends GetxController {
  final phoneController = TextEditingController();
  final RxString phoneNumber = ''.obs;
  final RxString countryCode = '+237'.obs;

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  void skipWelcome() {
    Get.offAllNamed(Routes.HOME);
  }

  void createAccountWithPhone() {
    if (phoneNumber.value.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez entrer votre numéro de téléphone',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      return;
    }

    // TODO: Envoyer le code OTP via API

    // Afficher un message de succès
    Get.snackbar(
      'Code envoyé',
      'Un code de vérification a été envoyé au ${phoneNumber.value}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 2),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );

    // Navigation vers la page OTP pour vérification
    Get.toNamed(
      Routes.OTP,
      arguments: {
        'phoneNumber': phoneNumber.value,
      },
    );
  }

  void continueWithGoogle() {
    Get.snackbar(
      'Google',
      'Connexion avec Google...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Implémenter l'authentification Google
    Get.offAllNamed(Routes.HOME);
  }

  void continueWithApple() {
    Get.snackbar(
      'Apple',
      'Connexion avec Apple...',
      snackPosition: SnackPosition.BOTTOM,
    );
    // TODO: Implémenter l'authentification Apple
    Get.offAllNamed(Routes.HOME);
  }

  void continueAsGuest() {
    Get.offAllNamed(Routes.HOME);
  }

  void goToLogin() {
    Get.toNamed(Routes.LOGIN);
  }
}
