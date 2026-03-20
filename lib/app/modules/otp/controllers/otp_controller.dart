import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class OtpController extends GetxController {
  // Controllers pour les champs OTP
  late List<TextEditingController> otpControllers;
  late List<FocusNode> focusNodes;

  // États observables
  final phoneNumber = ''.obs;
  final secondsRemaining = 120.obs; // 2 minutes par défaut
  final isLoading = false.obs;
  final isOtpComplete = false.obs;

  // Timer
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();

    // Récupérer le numéro de téléphone depuis les arguments
    if (Get.arguments != null && Get.arguments['phoneNumber'] != null) {
      phoneNumber.value = Get.arguments['phoneNumber'];
    }

    // Initialiser les controllers et focus nodes
    otpControllers = List.generate(6, (index) => TextEditingController());
    focusNodes = List.generate(6, (index) => FocusNode());

    // Démarrer le timer
    _startTimer();
  }

  @override
  void onReady() {
    super.onReady();
    // Focus automatique sur le premier champ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (focusNodes.isNotEmpty) {
        focusNodes[0].requestFocus();
      }
    });
  }

  @override
  void onClose() {
    // Libérer les ressources
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.onClose();
  }

  /// Démarre le timer de countdown
  void _startTimer() {
    secondsRemaining.value = 120;
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        timer.cancel();
      }
    });
  }

  /// Appelé quand un champ OTP change
  void onOtpChanged(String value, int index) {
    if (value.isNotEmpty) {
      // Passer au champ suivant si ce n'est pas le dernier
      if (index < 5) {
        focusNodes[index + 1].requestFocus();
      } else {
        // Dernier champ, retirer le focus
        focusNodes[index].unfocus();
      }
    } else {
      // Si l'utilisateur efface, retourner au champ précédent
      if (index > 0) {
        focusNodes[index - 1].requestFocus();
      }
    }

    // Vérifier si tous les champs sont remplis
    _checkOtpComplete();
  }

  /// Vérifie si tous les champs OTP sont remplis
  void _checkOtpComplete() {
    isOtpComplete.value = otpControllers.every((controller) {
      return controller.text.isNotEmpty;
    });
  }

  /// Récupère le code OTP complet
  String getOtpCode() {
    return otpControllers.map((controller) => controller.text).join();
  }

  /// Renvoie le code OTP
  void resendOtp() {
    // TODO: Implémenter l'appel API pour renvoyer le code

    // Réinitialiser les champs
    for (var controller in otpControllers) {
      controller.clear();
    }
    isOtpComplete.value = false;

    // Redémarrer le timer
    _startTimer();

    // Focus sur le premier champ
    focusNodes[0].requestFocus();

    // Afficher un message de succès
    Get.snackbar(
      'Code renvoyé',
      'Un nouveau code a été envoyé au ${phoneNumber.value}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Get.theme.colorScheme.onPrimary,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  /// Permet de modifier le numéro de téléphone
  void changePhoneNumber() {
    // Retourner à la page précédente (Login ou Welcomer)
    Get.back();
  }

  /// Vérifie le code OTP
  Future<void> verifyOtp() async {
    if (!isOtpComplete.value) {
      Get.snackbar(
        'Code incomplet',
        'Veuillez entrer le code à 6 chiffres',
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
      final otpCode = getOtpCode();

      // TODO: Implémenter l'appel API pour vérifier le code
      // Exemple:
      // final response = await AuthService.verifyOtp(phoneNumber.value, otpCode);

      // Simulation d'un délai réseau
      await Future.delayed(const Duration(seconds: 2));

      // Pour la démo, accepter le code 123456
      if (otpCode == '123456') {
        // Code correct
        Get.snackbar(
          'Succès',
          'Code vérifié avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );

        // Naviguer vers la page des préférences
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(Routes.PREFERENCES);
      } else {
        // Code incorrect
        Get.snackbar(
          'Code incorrect',
          'Le code que vous avez entré est incorrect. Veuillez réessayer.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );

        // Réinitialiser les champs
        for (var controller in otpControllers) {
          controller.clear();
        }
        isOtpComplete.value = false;
        focusNodes[0].requestFocus();
      }
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
}
