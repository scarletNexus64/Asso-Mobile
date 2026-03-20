import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/store_models.dart';

class StoreManagementController extends GetxController {
  // État de chargement
  final RxBool isLoading = false.obs;

  // Informations de la boutique
  final Rx<StoreInfo?> storeInfo = Rx<StoreInfo?>(null);

  // Statistiques de stockage
  final Rx<StorageStats?> storageStats = Rx<StorageStats?>(null);

  // Certification
  final Rx<Certification?> certification = Rx<Certification?>(null);

  // Statistiques d'audience
  final Rx<AudienceStats?> audienceStats = Rx<AudienceStats?>(null);

  // Inventaire
  final RxList<InventoryEntry> inventoryEntries = <InventoryEntry>[].obs;
  final Rx<InventoryType?> selectedInventoryFilter = Rx<InventoryType?>(null);

  // Bannières promotionnelles
  final RxList<PromotionalBanner> banners = <PromotionalBanner>[].obs;
  final RxInt currentBannerIndex = 0.obs;

  // Image picker
  final ImagePicker _picker = ImagePicker();
  final Rx<File?> selectedLogo = Rx<File?>(null);

  @override
  void onInit() {
    super.onInit();
    loadData();
    _setupBanners();
  }

  /// Charge toutes les données
  Future<void> loadData() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Charger les informations de la boutique
      storeInfo.value = StoreInfo(
        id: 'store_001',
        name: 'Ma Boutique',
        logoUrl: null,
        description: 'Une boutique de qualité',
        latitude: 4.0511,
        longitude: 9.7679,
        address: 'Avenue de la République',
        city: 'Douala',
        phone: '+237 690000000',
      );

      // Charger les statistiques de stockage
      storageStats.value = StorageStats(
        usedSpaceGB: 3.2,
        totalSpaceGB: 5.0,
        totalProducts: 45,
        totalImages: 180,
      );

      // Charger la certification
      certification.value = Certification(
        isCertified: false,
        status: CertificationStatus.notCertified,
      );

      // Charger les statistiques d'audience
      audienceStats.value = AudienceStats(
        totalViews: 12450,
        totalClicks: 3890,
        totalOrders: 234,
        conversionRate: 6.02,
        dailyStats: _generateDailyStats(),
        topProducts: {
          'Smartphone Galaxy A54': 45,
          'Écouteurs Bluetooth': 32,
          'Montre connectée': 28,
          'Chargeur rapide': 21,
          'Câble USB-C': 18,
        },
      );

      // Charger l'inventaire
      inventoryEntries.value = _generateInventoryEntries();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les données',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Configure les bannières promotionnelles
  void _setupBanners() {
    banners.value = [
      PromotionalBanner(
        id: 'banner_1',
        title: 'Augmentez votre espace',
        description: 'Passez à 50 GB de stockage',
        imageUrl: '',
        type: BannerType.storage,
        actionLabel: 'Voir les offres',
        onTap: upgradeStorage,
      ),
      PromotionalBanner(
        id: 'banner_2',
        title: 'Boostez vos produits',
        description: 'Augmentez votre visibilité de 300%',
        imageUrl: '',
        type: BannerType.boost,
        actionLabel: 'Booster maintenant',
        onTap: boostProducts,
      ),
      PromotionalBanner(
        id: 'banner_3',
        title: 'Devenez certifié',
        description: 'Gagnez la confiance des clients',
        imageUrl: '',
        type: BannerType.certification,
        actionLabel: 'Demander certification',
        onTap: requestCertification,
      ),
      PromotionalBanner(
        id: 'banner_4',
        title: 'Passez Premium',
        description: 'Accédez à toutes les fonctionnalités',
        imageUrl: '',
        type: BannerType.premium,
        actionLabel: 'Découvrir',
        onTap: upgradeToPremium,
      ),
    ];
  }

  /// Génère des statistiques journalières de test
  List<DailyStats> _generateDailyStats() {
    final now = DateTime.now();
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return DailyStats(
        date: date,
        views: 1500 + (index * 200),
        clicks: 450 + (index * 50),
        orders: 25 + (index * 5),
      );
    });
  }

  /// Génère des entrées d'inventaire de test
  List<InventoryEntry> _generateInventoryEntries() {
    return [
      InventoryEntry(
        id: 'inv_001',
        productId: 'prod_001',
        productName: 'Smartphone Galaxy A54',
        type: InventoryType.entry,
        quantity: 50,
        date: DateTime.now().subtract(const Duration(days: 5)),
        notes: 'Réapprovisionnement',
      ),
      InventoryEntry(
        id: 'inv_002',
        productId: 'prod_001',
        productName: 'Smartphone Galaxy A54',
        type: InventoryType.exit,
        quantity: 3,
        date: DateTime.now().subtract(const Duration(days: 2)),
        orderId: 'CMD1001',
        notes: 'Commande validée',
      ),
      InventoryEntry(
        id: 'inv_003',
        productId: 'prod_002',
        productName: 'Écouteurs Bluetooth',
        type: InventoryType.entry,
        quantity: 100,
        date: DateTime.now().subtract(const Duration(days: 7)),
        notes: 'Stock initial',
      ),
      InventoryEntry(
        id: 'inv_004',
        productId: 'prod_002',
        productName: 'Écouteurs Bluetooth',
        type: InventoryType.exit,
        quantity: 5,
        date: DateTime.now().subtract(const Duration(days: 1)),
        orderId: 'CMD1015',
      ),
    ];
  }

  /// Filtre l'inventaire
  List<InventoryEntry> get filteredInventory {
    if (selectedInventoryFilter.value == null) {
      return inventoryEntries;
    }
    return inventoryEntries
        .where((entry) => entry.type == selectedInventoryFilter.value)
        .toList();
  }

  /// Sélectionne une image pour le logo
  Future<void> pickLogo() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (image != null) {
        selectedLogo.value = File(image.path);
        Get.snackbar(
          'Succès',
          'Logo sélectionné. N\'oubliez pas de sauvegarder.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sélectionner l\'image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Sauvegarde les informations de la boutique
  Future<void> saveStoreInfo({
    required String name,
    String? description,
    required String address,
    required String city,
    required String phone,
  }) async {
    try {
      isLoading.value = true;

      // TODO: Appel API pour sauvegarder
      await Future.delayed(const Duration(milliseconds: 500));

      storeInfo.value = storeInfo.value?.copyWith(
        name: name,
        description: description,
        address: address,
        city: city,
        phone: phone,
      );

      Get.snackbar(
        'Succès',
        'Informations de la boutique mises à jour',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sauvegarder les informations',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Améliorer le stockage
  void upgradeStorage() {
    Get.snackbar(
      'Stockage',
      'Fonctionnalité d\'upgrade en cours de développement',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Booster les produits
  void boostProducts() {
    Get.snackbar(
      'Boost',
      'Fonctionnalité de boost en cours de développement',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Demander la certification
  void requestCertification() {
    Get.snackbar(
      'Certification',
      'Demande de certification en cours de développement',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Passer en premium
  void upgradeToPremium() {
    Get.snackbar(
      'Premium',
      'Upgrade premium en cours de développement',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Ajouter une entrée d'inventaire
  void addInventoryEntry() {
    Get.snackbar(
      'Inventaire',
      'Ajout d\'entrée d\'inventaire en cours de développement',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Voir les détails de l'inventaire
  void viewInventoryDetails(InventoryEntry entry) {
    Get.snackbar(
      'Inventaire',
      '${entry.type.label}: ${entry.productName} (${entry.quantity})',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
