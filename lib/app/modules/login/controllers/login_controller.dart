import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  // Controller pour le champ de téléphone
  late TextEditingController phoneController;

  // États observables
  final phoneNumber = ''.obs;
  final countryCode = '+237'.obs; // Cameroun par défaut
  final isLoading = false.obs;
  final isPhoneValid = false.obs;

  @override
  void onInit() {
    super.onInit();
    phoneController = TextEditingController();

    // Écouter les changements du numéro de téléphone
    ever(phoneNumber, (_) => _validatePhone());
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  /// Valide le numéro de téléphone
  void _validatePhone() {
    // Validation simple : vérifier que le numéro n'est pas vide
    isPhoneValid.value = phoneNumber.value.isNotEmpty;
  }

  /// Connexion avec le numéro de téléphone
  Future<void> login() async {
    if (!isPhoneValid.value) {
      Get.snackbar(
        'Numéro invalide',
        'Veuillez entrer un numéro de téléphone valide',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    isLoading.value = true;

    try {
      // TODO: Implémenter l'appel API pour envoyer le code OTP
      // Exemple:
      // final response = await AuthService.sendOtp(phoneNumber.value);

      // Simulation d'un délai réseau
      await Future.delayed(const Duration(seconds: 2));

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

      // Naviguer vers la page OTP avec le numéro de téléphone
      await Future.delayed(const Duration(milliseconds: 500));
      Get.toNamed(
        Routes.OTP,
        arguments: {
          'phoneNumber': phoneNumber.value,
        },
      );
    } catch (e) {
      // Erreur
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue. Veuillez réessayer.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigation vers la page d'inscription (Welcomer)
  void goToRegister() {
    Get.offNamed(Routes.WELCOMER);
  }
}
