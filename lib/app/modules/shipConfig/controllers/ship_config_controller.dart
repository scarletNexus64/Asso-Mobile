import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/providers/vendor_service.dart';

class ShipConfigController extends GetxController {
  // État de chargement
  final isLoading = false.obs;
  final isSyncing = false.obs;

  // Numéro de série du livreur
  final deliverySerialNumber = ''.obs;
  final TextEditingController serialNumberController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadUserDeliveryInfo();
  }

  @override
  void onClose() {
    serialNumberController.dispose();
    super.onClose();
  }

  /// Charge les informations de livraison de l'utilisateur
  Future<void> _loadUserDeliveryInfo() async {
    // TODO: Charger le numéro de série depuis le profil utilisateur
    // Pour l'instant on laisse vide
  }

  /// Valide le format du numéro de série (XX-XXXX-XXXX-XXXX-XX)
  bool validateSerialNumber(String serial) {
    // Format: XX-XXXX-XXXX-XXXX-XX
    final pattern = RegExp(r'^[A-Z0-9]{2}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{2}$');
    return pattern.hasMatch(serial);
  }

  /// Synchronise le profil pour devenir livreur
  Future<void> syncProfileToDelivery() async {
    final serial = serialNumberController.text.trim().toUpperCase();

    // Valider le numéro de série
    if (serial.isEmpty) {
      Get.snackbar(
        'Champ requis',
        'Veuillez entrer votre numéro de série livreur',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    if (!validateSerialNumber(serial)) {
      Get.snackbar(
        'Format invalide',
        'Le numéro de série doit être au format: XX-XXXX-XXXX-XXXX-XX',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    isSyncing.value = true;

    try {
      // TODO: Envoyer le numéro de série au backend
      final response = await VendorService.applyDelivery(
        vehicleType: 'personal',
        // serialNumber: serial, // À ajouter dans le service
      );

      if (response.success) {
        deliverySerialNumber.value = serial;
        Get.snackbar(
          'Succès',
          'Votre profil a été synchronisé avec succès !',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );

        // Naviguer vers le dashboard de livraison
        navigateToDeliveryDashboard();
      } else {
        Get.snackbar(
          'Erreur',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de la synchronisation',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isSyncing.value = false;
    }
  }

  /// Contacte le support pour obtenir un numéro de série
  Future<void> contactSupport() async {
    try {
      // TODO: Remplacer par l'URL de support appropriée
      final Uri supportUri = Uri.parse('mailto:support@example.com?subject=Demande de numéro de série livreur');

      if (await canLaunchUrl(supportUri)) {
        await launchUrl(supportUri);
      } else {
        Get.snackbar(
          'Erreur',
          'Impossible d\'ouvrir le client mail',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Navigation vers le dashboard de livraison
  void navigateToDeliveryDashboard() {
    Get.offAllNamed('/delivery-dashboard');
  }
}
