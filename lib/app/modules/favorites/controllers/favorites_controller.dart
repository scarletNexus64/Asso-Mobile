import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavoritesController extends GetxController {
  // Notifications
  final pushNotifications = true.obs;
  final emailNotifications = true.obs;
  final notificationSounds = true.obs;

  // Apparence
  final themeMode = 'system'.obs; // 'dark', 'light', 'system'

  // Langue
  final language = 'fr'.obs; // 'fr', 'en'

  // Confidentialité
  final locationSharing = false.obs;
  final analytics = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadPreferences();
  }

  /// Charge les préférences sauvegardées
  void _loadPreferences() {
    // TODO: Charger depuis le stockage local
    // Pour l'instant, on utilise des valeurs par défaut
  }

  /// Sauvegarde les préférences
  Future<void> savePreferences() async {
    try {
      // TODO: Sauvegarder dans le stockage local
      await Future.delayed(const Duration(milliseconds: 300));

      Get.snackbar(
        'Succès',
        'Vos préférences ont été sauvegardées',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sauvegarder les préférences',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
