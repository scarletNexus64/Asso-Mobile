import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/providers/product_service.dart';
import '../../../data/providers/api_provider.dart';

class AddProductController extends GetxController {
  // Form controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  // Images
  final productImages = <File>[].obs;
  final primaryImageIndex = 0.obs;

  // Catégorie et sous-catégorie
  final selectedCategory = Rx<String?>(null);
  final selectedSubcategory = Rx<String?>(null);

  // Type d'article
  final articleType = 'article'.obs; // 'article' ou 'service'

  // Type de prix
  final priceType = 'fixed'.obs; // 'fixed', 'discover', 'visit'

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
    _loadCategories();
    _loadStorages();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    super.onClose();
  }

  /// Charge les catégories depuis l'API
  void _loadCategories() async {
    try {
      final response = await ProductService.getCategories();

      if (response.success && response.data != null) {
        final data = response.data!['data'] ?? response.data!;

        if (data is List) {
          // Restructure categories from API format
          final Map<String, List<Map<String, String>>> categories = {};
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
                categories[catName]!.add({
                  'id': subMap['id']?.toString() ?? '',
                  'name': subMap['name'] ?? subMap['subcategory_name'] ?? 'Sous-catégorie',
                });
              }
            } else {
              // If no subcategories, add the category itself as a subcategory
              categories[catName]!.add({
                'id': catId,
                'name': catName,
              });
            }
          }
          categoriesData.clear();
          categoriesData.addAll(categories);
        } else if (data is Map) {
          // Alternative format
          final Map<String, List<Map<String, String>>> categories = {};
          data.forEach((key, value) {
            if (value is List) {
              categories[key] = (value as List)
                  .map<Map<String, String>>((item) {
                    if (item is Map<String, dynamic>) {
                      return {
                        'id': item['id']?.toString() ?? '',
                        'name': item['name']?.toString() ?? 'Sous-catégorie',
                      };
                    }
                    return {'id': '', 'name': item.toString()};
                  })
                  .toList();
            }
          });
          categoriesData.clear();
          categoriesData.addAll(categories);
        }
      }
    } catch (e) {
      // Keep the hardcoded categories as fallback
    }
  }

  /// Charge les espaces de stockage (fake data - client-side info)
  void _loadStorages() {
    storageList.value = [
      {
        'id': '1',
        'name': 'Stockage Principal',
        'available': 150.5, // GB
        'total': 500.0,
      },
      {
        'id': '2',
        'name': 'Stockage Secondaire',
        'available': 280.0,
        'total': 1000.0,
      },
    ];

    // Sélectionner le premier par défaut
    if (storageList.isNotEmpty) {
      selectedStorage.value = storageList.first;
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

  /// Ajouter un nouvel espace de stockage
  void addNewStorage() {
    final nameController = TextEditingController();
    final availableController = TextEditingController();
    final totalController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Ajouter un espace de stockage'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom du disque',
                  hintText: 'Ex: Stockage Externe',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: availableController,
                decoration: const InputDecoration(
                  labelText: 'Espace disponible (GB)',
                  hintText: 'Ex: 500',
                  border: OutlineInputBorder(),
                  suffixText: 'GB',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: totalController,
                decoration: const InputDecoration(
                  labelText: 'Espace total (GB)',
                  hintText: 'Ex: 1000',
                  border: OutlineInputBorder(),
                  suffixText: 'GB',
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              nameController.dispose();
              availableController.dispose();
              totalController.dispose();
              Get.back();
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final available = double.tryParse(availableController.text) ?? 0;
              final total = double.tryParse(totalController.text) ?? 0;

              if (name.isEmpty) {
                Get.snackbar(
                  'Erreur',
                  'Veuillez entrer un nom pour le stockage',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              if (available <= 0 || total <= 0) {
                Get.snackbar(
                  'Erreur',
                  'Veuillez entrer des valeurs valides',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              if (available > total) {
                Get.snackbar(
                  'Erreur',
                  'L\'espace disponible ne peut pas être supérieur à l\'espace total',
                  snackPosition: SnackPosition.BOTTOM,
                );
                return;
              }

              storageList.add({
                'id': '${storageList.length + 1}',
                'name': name,
                'available': available,
                'total': total,
              });

              nameController.dispose();
              availableController.dispose();
              totalController.dispose();

              Get.back();

              Get.snackbar(
                'Succès',
                'Espace de stockage ajouté',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Get.theme.colorScheme.primary,
                colorText: Get.theme.colorScheme.onPrimary,
              );
            },
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
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

    if (selectedCategory.value == null) {
      Get.snackbar(
        'Catégorie requise',
        'Veuillez sélectionner une catégorie',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (selectedSubcategory.value == null) {
      Get.snackbar(
        'Sous-catégorie requise',
        'Veuillez sélectionner une sous-catégorie',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (priceType.value == 'fixed' && priceController.text.trim().isEmpty) {
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
        'category_id': selectedCategory.value ?? '',
        'subcategory_id': selectedSubcategory.value ?? '',
        'type': articleType.value,
        'price_type': priceType.value,
        'storage_id': selectedStorage.value?['id']?.toString() ?? '',
      };

      if (priceType.value == 'fixed') {
        fieldsMap['price'] = priceController.text.trim();
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
