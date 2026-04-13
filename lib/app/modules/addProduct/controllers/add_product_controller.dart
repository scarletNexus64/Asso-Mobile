import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/providers/product_service.dart';
import '../../../data/providers/vendor_service.dart';
import '../../../data/providers/api_provider.dart';

class AddProductController extends GetxController {
  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController stockController = TextEditingController();
  final TextEditingController weightKgController = TextEditingController();

  // Images
  final productImages = <File>[].obs;
  final primaryImageIndex = 0.obs;

  // Catégorie et sous-catégorie
  final selectedCategory = Rx<String?>(null);
  final selectedSubcategory = Rx<String?>(null);
  final selectedSubcategoryId = Rx<String?>(null);

  // Liste de toutes les sous-catégories (pour affichage direct)
  final allSubcategories = <Map<String, String>>[].obs;

  // Type d'article
  final articleType = 'article'.obs; // 'article' ou 'service'

  // Type de prix
  final priceType = 'fixed'.obs; // 'fixed', 'discover', 'visit'

  // Poids du produit
  final selectedWeightType = Rx<String?>(null); // 'X-small', '30 Deep', '50 Deep', '60 Deep', 'Rainbow XL', 'Pallet', 'custom'
  final weightTypes = <String, String>{
    'X-small': '~5 kg',
    '30 Deep': '~30 kg',
    '50 Deep': '~50 kg',
    '60 Deep': '~60 kg',
    'Rainbow XL': '~100 kg',
    'Pallet': '~500 kg',
    'custom': 'Poids personnalisé (KG)',
  };

  // Stockage
  final selectedStorage = Rx<Map<String, dynamic>?>(null);
  final storageList = <Map<String, dynamic>>[].obs;

  // Loading
  final isLoading = false.obs;

  final ImagePicker _picker = ImagePicker();

  // Fake data pour les catégories/sous-catégories
  final Map<String, List<Map<String, String>>> categoriesData = {
    'Électronique': [
      {'id': '1', 'name': 'Smartphones'},
      {'id': '2', 'name': 'Ordinateurs portables'},
      {'id': '3', 'name': 'Tablettes'},
      {'id': '4', 'name': 'Accessoires électroniques'},
    ],
    'Mode & Vêtements': [
      {'id': '5', 'name': 'Vêtements homme'},
      {'id': '6', 'name': 'Vêtements femme'},
      {'id': '7', 'name': 'Chaussures'},
      {'id': '8', 'name': 'Accessoires de mode'},
    ],
    'Alimentation': [
      {'id': '9', 'name': 'Fruits et légumes'},
      {'id': '10', 'name': 'Viandes et poissons'},
      {'id': '11', 'name': 'Produits laitiers'},
      {'id': '12', 'name': 'Épicerie'},
    ],
    'Maison & Jardin': [
      {'id': '13', 'name': 'Meubles'},
      {'id': '14', 'name': 'Décoration'},
      {'id': '15', 'name': 'Électroménager'},
      {'id': '16', 'name': 'Jardinage'},
    ],
    'Beauté & Santé': [
      {'id': '17', 'name': 'Soins du visage'},
      {'id': '18', 'name': 'Maquillage'},
      {'id': '19', 'name': 'Parfums'},
      {'id': '20', 'name': 'Produits de santé'},
    ],
  };

  @override
  void onInit() {
    super.onInit();
    // Construire les sous-catégories hardcodées d'abord
    _buildAllSubcategoriesFromHardcoded();
    // Puis charger depuis l'API
    _initializeData();
  }

  /// Initialise les données (catégories et stockage)
  Future<void> _initializeData() async {
    isLoading.value = true;

    await Future.wait([
      _loadCategories(),
      _loadStorages(),
    ]);

    isLoading.value = false;
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    stockController.dispose();
    weightKgController.dispose();
    super.onClose();
  }

  /// Charge les catégories depuis l'API
  Future<void> _loadCategories() async {
    try {
      final response = await ProductService.getCategories();

      if (response.success && response.data != null) {
        final data = response.data!['data'] ?? response.data!;

        if (data is List) {
          // Restructure categories from API format
          final Map<String, List<Map<String, String>>> categories = {};
          final List<Map<String, String>> allSubs = [];

          for (var cat in data) {
            final catMap = cat as Map<String, dynamic>;
            final catName = catMap['name'] ?? catMap['category_name'] ?? 'Autre';
            final catId = catMap['id']?.toString() ?? catMap['category_id']?.toString() ?? '';

            if (!categories.containsKey(catName)) {
              categories[catName] = [];
            }

            // Add subcategories if they exist
            if (catMap['subcategories'] is List) {
              for (var subcat in catMap['subcategories']) {
                final subMap = subcat as Map<String, dynamic>;
                final subcatData = <String, String>{
                  'id': subMap['id']?.toString() ?? '',
                  'name': subMap['name'] ?? subMap['subcategory_name'] ?? 'Sous-catégorie',
                  'category_name': catName,
                  'category_id': catId,
                };

                categories[catName]!.add(subcatData);
                allSubs.add(subcatData);
              }
            } else {
              // If no subcategories, add the category itself as a subcategory
              final subcatData = <String, String>{
                'id': catId,
                'name': catName,
                'category_name': catName,
                'category_id': catId,
              };
              categories[catName]!.add(subcatData);
              allSubs.add(subcatData);
            }
          }

          categoriesData.clear();
          categoriesData.addAll(categories);

          allSubcategories.value = allSubs;
        } else if (data is Map) {
          // Alternative format
          final Map<String, List<Map<String, String>>> categories = {};
          final List<Map<String, String>> allSubs = [];

          data.forEach((key, value) {
            if (value is List) {
              final categoryList = (value as List).map<Map<String, String>>((item) {
                if (item is Map<String, dynamic>) {
                  return <String, String>{
                    'id': item['id']?.toString() ?? '',
                    'name': item['name']?.toString() ?? 'Sous-catégorie',
                    'category_name': key,
                    'category_id': key,
                  };
                }
                return <String, String>{
                  'id': '',
                  'name': item.toString(),
                  'category_name': key,
                  'category_id': key,
                };
              }).toList();

              categories[key] = categoryList;
              allSubs.addAll(categoryList);
            }
          });

          categoriesData.clear();
          categoriesData.addAll(categories);

          allSubcategories.value = allSubs;
        }
      }
    } catch (e) {
      print('Erreur lors du chargement des catégories: $e');
      // Keep the hardcoded categories as fallback
      _buildAllSubcategoriesFromHardcoded();
    }
  }

  /// Construit la liste de toutes les sous-catégories depuis les données hardcodées
  void _buildAllSubcategoriesFromHardcoded() {
    final List<Map<String, String>> allSubs = [];

    categoriesData.forEach((categoryName, subcategories) {
      for (var subcat in subcategories) {
        allSubs.add(<String, String>{
          'id': subcat['id'] ?? '',
          'name': subcat['name'] ?? '',
          'category_name': categoryName,
          'category_id': categoryName,
        });
      }
    });

    allSubcategories.value = allSubs;
  }

  /// Charge les espaces de stockage depuis l'API
  Future<void> _loadStorages() async {
    try {
      final response = await VendorService.getVendorDashboard();

      if (response.success && response.data != null) {
        final data = response.data!['data'] ?? response.data!;

        if (data['package'] != null && data['package']['vendor_package'] != null) {
          final vendorPackage = data['package']['vendor_package'];
          final storageTotalMb = (vendorPackage['storage_total_mb'] ?? 0).toDouble();
          final storageRemainingMb = (vendorPackage['storage_remaining_mb'] ?? 0).toDouble();
          final packageName = vendorPackage['package']?['name'] ?? 'Package actif';

          storageList.value = [
            {
              'id': vendorPackage['id']?.toString() ?? '1',
              'name': packageName,
              'available': storageRemainingMb / 1024, // Convert MB to GB
              'total': storageTotalMb / 1024, // Convert MB to GB
            }
          ];

          // Sélectionner automatiquement
          if (storageList.isNotEmpty) {
            selectedStorage.value = storageList.first;
          }
        }
      }
    } catch (e) {
      print('Erreur lors du chargement du stockage: $e');
      // Si erreur, on laisse vide - l'utilisateur devra souscrire à un package
    }
  }

  /// Ajouter des images
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        for (var image in images) {
          productImages.add(File(image.path));
        }
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de sélectionner les images',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Ajouter une image depuis la caméra
  Future<void> takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        productImages.add(File(image.path));
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de prendre une photo',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Supprimer une image
  void removeImage(int index) {
    productImages.removeAt(index);

    // Ajuster l'index de l'image primaire si nécessaire
    if (primaryImageIndex.value >= productImages.length && productImages.isNotEmpty) {
      primaryImageIndex.value = 0;
    }
  }

  /// Définir l'image primaire
  void setPrimaryImage(int index) {
    primaryImageIndex.value = index;
  }

  /// Naviguer vers la page de souscription de package
  void addNewStorage() {
    Get.toNamed('/package-subscription');
  }

  /// Valider et soumettre le produit
  Future<void> submitProduct() async {
    // Validation
    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Champ requis',
        'Veuillez entrer le nom du produit',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (productImages.isEmpty) {
      Get.snackbar(
        'Image requise',
        'Veuillez ajouter au moins une image du produit',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedSubcategoryId.value == null || selectedSubcategoryId.value!.isEmpty) {
      Get.snackbar(
        'Catégorie requise',
        'Veuillez sélectionner une catégorie',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (priceController.text.trim().isEmpty) {
      Get.snackbar(
        'Prix requis',
        'Veuillez entrer le prix du produit',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Description requise',
        'Veuillez entrer une description du produit',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedStorage.value == null) {
      Get.snackbar(
        'Stockage requis',
        'Veuillez sélectionner un espace de stockage',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedWeightType.value == null) {
      Get.snackbar(
        'Poids requis',
        'Veuillez sélectionner le poids du produit',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedWeightType.value == 'custom' && weightKgController.text.trim().isEmpty) {
      Get.snackbar(
        'Poids requis',
        'Veuillez entrer le poids en KG',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (stockController.text.trim().isEmpty) {
      Get.snackbar(
        'Stock requis',
        'Veuillez entrer la quantité en stock',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Calculer la taille estimée des images
      double totalSizeMb = 0;
      for (var image in productImages) {
        final bytes = await image.length();
        totalSizeMb += bytes / 1048576;
      }

      print('');
      print('📦 ADD PRODUCT: Total images size: ${totalSizeMb.toStringAsFixed(2)} MB');

      // Préparer les fichiers pour l'upload
      final filesMap = <String, String>{};
      for (int i = 0; i < productImages.length; i++) {
        filesMap['images[$i]'] = productImages[i].path;
      }

      // Préparer les champs
      final fieldsMap = <String, String>{
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'subcategory_id': selectedSubcategoryId.value ?? '',
        'type': articleType.value,
        'price_type': 'fixed',
        'price': priceController.text.trim(),
        'storage_id': selectedStorage.value?['id']?.toString() ?? '',
        'stock': stockController.text.trim(),
      };

      // Ajouter le poids
      if (selectedWeightType.value == 'custom') {
        fieldsMap['weight_kg'] = weightKgController.text.trim();
        fieldsMap['weight_type'] = 'custom';
      } else {
        fieldsMap['weight_type'] = selectedWeightType.value ?? '';
      }

      if (primaryImageIndex.value > 0 && primaryImageIndex.value < productImages.length) {
        fieldsMap['primary_image_index'] = primaryImageIndex.value.toString();
      }

      // Appel API multipart pour créer le produit
      final response = await ApiProvider.multipart(
        '/v1/products',
        fields: fieldsMap,
        files: filesMap,
      );

      if (response.success) {
        Get.snackbar(
          'Succès',
          'Produit ajouté avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF4CAF50),
          colorText: Colors.white,
        );

        // Afficher info stockage si disponible
        if (response.data?['storage_info'] != null) {
          final storageInfo = response.data!['storage_info'];
          print('📊 Storage used: ${storageInfo['used_mb']} MB');
          print('📊 Storage remaining: ${storageInfo['remaining_mb']} MB');
        }

        // Retour au dashboard
        Get.back();
      } else {
        // Gérer les erreurs spécifiques
        if (response.data?['error_code'] == 'NO_ACTIVE_PACKAGE') {
          Get.dialog(
            AlertDialog(
              title: const Text('Package requis'),
              content: Text(
                response.message ?? 'Vous devez souscrire à un package de stockage',
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.back(); // Fermer addProduct
                    Get.toNamed('/package-subscription');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF58A3A),
                  ),
                  child: const Text(
                    'Voir les packages',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        } else if (response.data?['error_code'] == 'INSUFFICIENT_STORAGE') {
          final requiredMb = response.data?['required_mb'] ?? 0;
          final availableMb = response.data?['available_mb'] ?? 0;

          Get.dialog(
            AlertDialog(
              title: const Text('Espace insuffisant'),
              content: Text(
                'Espace requis : ${requiredMb.toStringAsFixed(2)} MB\n'
                'Espace disponible : ${availableMb.toStringAsFixed(2)} MB\n\n'
                'Veuillez souscrire à un package supplémentaire.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Annuler'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                    Get.toNamed('/package-subscription');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF58A3A),
                  ),
                  child: const Text(
                    'Voir les packages',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        } else {
          Get.snackbar(
            'Erreur',
            response.message ?? 'Impossible d\'ajouter le produit',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFFF44336),
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de l\'ajout du produit: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
