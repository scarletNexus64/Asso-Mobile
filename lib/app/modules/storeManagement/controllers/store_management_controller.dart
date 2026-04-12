import 'package:asso/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/store_models.dart';
import '../../../data/providers/shop_service.dart';

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
      // Essayer de charger depuis l'API shop dédiée
      final response = await ShopService.getShop();

      print('📊 CONTROLLER: Response success: ${response.success}');
      print('📊 CONTROLLER: Response data: ${response.data}');

      if (response.success && response.data != null) {
        final data = response.data!;
        final shop = data['shop'];
        final stats = data['stats'];
        final certificationData = data['certification'];
        final package = data['package'];

        print('📊 CONTROLLER: Shop data: $shop');
        print('📊 CONTROLLER: Stats data: $stats');
        print('📊 CONTROLLER: Certification data: $certificationData');
        print('📊 CONTROLLER: Package data: $package');

        // Parser les informations de la boutique
        if (shop != null) {
          // Nettoyer l'adresse (gérer les valeurs placeholder)
          String? address = shop['address']?.toString();
          if (address != null &&
              (address.contains('Chargement de l') || address.isEmpty)) {
            address = '';
          }

          // Extraire la ville de l'adresse si présente
          String city = '';
          if (address != null && address.isNotEmpty && address.contains(',')) {
            city = address.split(',').last.trim();
          }

          storeInfo.value = StoreInfo(
            id: shop['id']?.toString() ?? '',
            name: shop['name'] ?? '',
            logoUrl: shop['logo'],
            description: shop['description'] ?? '',
            latitude: _toDouble(shop['latitude']),
            longitude: _toDouble(shop['longitude']),
            address: address ?? '',
            city: city,
            phone: shop['phone'] ?? '',
          );
          print('✅ CONTROLLER: Store info loaded: ${storeInfo.value?.name}');
        } else {
          print('⚠️ CONTROLLER: No shop data');
          storeInfo.value = null;
        }

        // Parser les statistiques depuis stats et package
        if (stats != null) {
          final totalProducts = stats['total_products'] ?? 0;

          // Parser les stats de stockage depuis le package
          final storageUsedGB = package != null
              ? _toDouble(package['storage_used_gb'])
              : 0.0;
          final storageTotalGB = package != null
              ? _toDouble(package['storage_total_gb'])
              : 0.0;

          storageStats.value = StorageStats(
            usedSpaceGB: storageUsedGB,
            totalSpaceGB: storageTotalGB,
            totalProducts: totalProducts,
            totalImages: 0, // TODO: À calculer depuis les produits
          );
          print('✅ CONTROLLER: Storage stats loaded');

          // Parser les statistiques d'audience depuis stats
          audienceStats.value = AudienceStats(
            totalViews: 0, // TODO: À implémenter dans le backend
            totalClicks: 0, // TODO: À implémenter dans le backend
            totalOrders: stats['total_orders'] ?? 0,
            conversionRate: 0.0, // TODO: À calculer
            dailyStats: [], // TODO: À implémenter dans le backend
            topProducts: {}, // TODO: À implémenter dans le backend
          );
          print('✅ CONTROLLER: Audience stats loaded');
        } else {
          print('⚠️ CONTROLLER: No stats data');
          storageStats.value = null;
          audienceStats.value = null;
        }

        // Parser la certification depuis certificationData (séparé de la vérification)
        if (certificationData != null) {
          final isCertified = certificationData['is_certified'] ?? false;
          final expiresAt = certificationData['certification_expires_at'];

          certification.value = Certification(
            isCertified: isCertified,
            status: isCertified
                ? CertificationStatus.certified
                : CertificationStatus.notCertified,
            expiryDate: expiresAt != null ? DateTime.parse(expiresAt) : null,
          );
          print('✅ CONTROLLER: Certification loaded (isCertified: $isCertified)');
        } else {
          print('⚠️ CONTROLLER: No certification data');
          certification.value = Certification(
            isCertified: false,
            status: CertificationStatus.notCertified,
          );
        }

        // Inventaire vide pour l'instant (TODO: implémenter l'API backend)
        inventoryEntries.value = [];
        print(
          '✅ CONTROLLER: Inventory loaded (empty - waiting for backend implementation)',
        );
      } else {
        print('❌ CONTROLLER: API call failed');
        // Clear all data
        storeInfo.value = null;
        storageStats.value = null;
        audienceStats.value = null;
        certification.value = null;
        inventoryEntries.value = [];
      }
    } catch (e, stackTrace) {
      print('💥 CONTROLLER: Exception occurred!');
      print('  └─ Error: $e');
      print('  └─ Stack trace:');
      print(stackTrace.toString().split('\n').take(5).join('\n'));

      // Clear all data on error
      storeInfo.value = null;
      storageStats.value = null;
      audienceStats.value = null;
      certification.value = null;
      inventoryEntries.value = [];

      Get.snackbar(
        'Erreur',
        'Impossible de charger les données: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Convert dynamic value to double (handles both String and num)
  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
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
    double? latitude,
    double? longitude,
  }) async {
    try {
      isLoading.value = true;

      // Appel API pour sauvegarder
      final response = await ShopService.updateShop(
        shopName: name,
        shopDescription: description,
        shopAddress: address,
        shopPhone: phone,
        shopLatitude: latitude ?? storeInfo.value?.latitude,
        shopLongitude: longitude ?? storeInfo.value?.longitude,
        shopLogo: selectedLogo.value,
      );

      if (response.success) {
        // Recharger les données depuis l'API
        await loadData();

        // Réinitialiser le logo sélectionné
        selectedLogo.value = null;

        Get.back(); // Fermer le formulaire d'édition

        Get.snackbar(
          'Succès',
          'Informations de la boutique mises à jour',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Erreur',
          response.message.isNotEmpty
              ? response.message
              : 'Impossible de sauvegarder les informations',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sauvegarder les informations: ${e.toString()}',
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

  /// Voir les détails de l'inventaire
  void viewInventoryDetails(InventoryEntry entry) {
    Get.snackbar(
      'Inventaire',
      '${entry.type.label}: ${entry.productName} (${entry.quantity})',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
