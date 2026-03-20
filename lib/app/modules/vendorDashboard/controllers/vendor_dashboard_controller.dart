import 'package:get/get.dart';
import 'dart:io';

class VendorDashboardController extends GetxController {
  // Statut de vérification
  final verificationStatus = 'pending'.obs; // pending, approved, rejected
  final verificationMessage = 'Votre demande est en cours de vérification'.obs;

  // Données du vendeur
  final shopName = ''.obs;
  final shopDescription = ''.obs;
  final shopLogo = Rx<File?>(null);
  final selectedCategories = <String>[].obs;

  // Statistiques (fake data)
  final totalOrders = 0.obs;
  final totalSales = 0.0.obs;
  final totalProducts = 0.obs;
  final rating = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadVendorData();
    _generateFakeStats();
  }

  /// Charge les données du vendeur
  void _loadVendorData() {
    // TODO: Charger les données depuis l'API ou le stockage local
    shopName.value = 'Boutique Kira';
    shopDescription.value = 'Vente d\'articles de mode et électronique';
    selectedCategories.value = ['Électronique', 'Mode & Vêtements'];
  }

  /// Génère des statistiques fictives pour la démo
  void _generateFakeStats() {
    totalOrders.value = 47;
    totalSales.value = 285000; // XAF
    totalProducts.value = 23;
    rating.value = 4.5;
  }

  /// Vérifie le statut de vérification
  Future<void> checkVerificationStatus() async {
    // TODO: Implémenter l'appel API pour vérifier le statut
    // Pour l'instant, simulation
    await Future.delayed(const Duration(seconds: 1));

    // Exemple de changement de statut
    // verificationStatus.value = 'approved';
    // verificationMessage.value = 'Votre compte vendeur est activé!';
  }

  /// Rafraîchit les données
  Future<void> refreshData() async {
    await checkVerificationStatus();
    _loadVendorData();
  }
}
