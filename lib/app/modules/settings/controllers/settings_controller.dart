import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/auth_service.dart';
import '../../../data/providers/api_provider.dart';

class SettingsController extends GetxController {
  // États
  final isLoading = false.obs;

  // Informations utilisateur (simulées)
  final userName = 'Jean Dupont'.obs;
  final userEmail = 'jean.dupont@example.com'.obs;
  final userPhone = '+237 670 00 00 00'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  /// Charge les données utilisateur
  void _loadUserData() {
    // TODO: Charger depuis le stockage local ou API
  }

  /// Éditer le profil
  Future<void> editProfile() async {
    Get.toNamed('/profile-edit');
  }

  /// Changer le mot de passe
  Future<void> changePassword() async {
    try {
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Changer le mot de passe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe actuel',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Modifier'),
            ),
          ],
        ),
      );

      if (result == true) {
        // TODO: Appel API
        await Future.delayed(const Duration(milliseconds: 500));

        Get.snackbar(
          'Succès',
          'Mot de passe modifié avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de modifier le mot de passe',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Effacer le cache
  Future<void> clearCache() async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Effacer le cache'),
          content: const Text('Êtes-vous sûr de vouloir effacer le cache de l\'application ?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Effacer', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      isLoading.value = true;

      // TODO: Effacer le cache
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'Succès',
        'Cache effacé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'effacer le cache',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Exporter les données
  Future<void> exportData() async {
    try {
      isLoading.value = true;

      // TODO: Exporter les données
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'Succès',
        'Données exportées avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'exporter les données',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Supprimer le compte
  Future<void> deleteAccount() async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Supprimer le compte'),
          content: const Text(
            'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      isLoading.value = true;

      // TODO: Appel API pour supprimer le compte
      await Future.delayed(const Duration(seconds: 1));

      Get.snackbar(
        'Compte supprimé',
        'Votre compte a été supprimé avec succès',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      // Rediriger vers la page de connexion
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de supprimer le compte',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Se déconnecter
  Future<void> logout() async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Déconnexion'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      try {
        await AuthService.logout();
      } catch (e) {
        ApiProvider.clearAuth();
      }

      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de se déconnecter',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Naviguer vers les préférences
  void goToPreferences() {
    Get.toNamed('/favorites');
  }

  /// Naviguer vers Aide et Support
  void goToHelp() {
    Get.toNamed('/help');
  }

  /// Naviguer vers FAQ
  void goToFAQ() {
    Get.toNamed('/faq');
  }

  /// Naviguer vers À propos
  void goToAbout() {
    Get.toNamed('/about');
  }
}
