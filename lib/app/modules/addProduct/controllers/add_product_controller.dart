import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;
import '../../../core/utils/app_theme_system.dart';
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

  // Edit mode
  final isEditMode = false.obs;
  final editProductId = Rx<int?>(null);
  final Map<String, dynamic>? editProductData = Get.arguments?['product'];

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

    // Check if we're in edit mode
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null && args['isEdit'] == true && args['product'] != null) {
      isEditMode.value = true;
      final product = args['product'] as Map<String, dynamic>;
      editProductId.value = product['id'] as int?;
      print('📝 ADD_PRODUCT: Edit mode detected for product ID: ${editProductId.value}');
    }

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

    // If in edit mode, populate fields with product data
    if (isEditMode.value && editProductData != null) {
      await _populateEditData(editProductData!);
    }

    isLoading.value = false;
  }

  /// Nettoyer les images temporaires
  Future<void> _cleanupTemporaryImages() async {
    try {
      for (var imageFile in productImages) {
        if (await imageFile.exists()) {
          await imageFile.delete();
          print('🗑️ ADD_PRODUCT: Image temporaire supprimée: ${imageFile.path}');
        }
      }
    } catch (e) {
      print('⚠️ ADD_PRODUCT: Erreur lors du nettoyage des images: $e');
    }
  }

  @override
  void onClose() {
    // Nettoyer les images temporaires quand on quitte la page
    _cleanupTemporaryImages();

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
      print('📂 ADD_PRODUCT: Chargement des catégories depuis l\'API...');
      final response = await ProductService.getCategories();

      print('📂 ADD_PRODUCT: Réponse API - success: ${response.success}');
      print('📂 ADD_PRODUCT: Réponse API - data: ${response.data}');

      if (response.success && response.data != null) {
        // La réponse de l'API est: { success: true, categories: [...] }
        final categoriesFromApi = response.data!['categories'];

        print('📂 ADD_PRODUCT: Type de categories: ${categoriesFromApi.runtimeType}');
        print('📂 ADD_PRODUCT: Nombre de catégories: ${categoriesFromApi is List ? categoriesFromApi.length : 'N/A'}');

        if (categoriesFromApi is List && categoriesFromApi.isNotEmpty) {
          // Restructure categories from API format
          final Map<String, List<Map<String, String>>> categories = {};
          final List<Map<String, String>> allSubs = [];

          for (var cat in categoriesFromApi) {
            final catMap = cat as Map<String, dynamic>;
            final catName = catMap['name'] ?? 'Autre';
            final catId = catMap['id']?.toString() ?? '';

            print('📂 ADD_PRODUCT: Traitement catégorie: $catName (ID: $catId)');

            if (!categories.containsKey(catName)) {
              categories[catName] = [];
            }

            // Add subcategories if they exist
            if (catMap['subcategories'] is List) {
              final subcats = catMap['subcategories'] as List;
              print('   └─ Nombre de sous-catégories: ${subcats.length}');

              for (var subcat in subcats) {
                final subMap = subcat as Map<String, dynamic>;
                final subcatData = <String, String>{
                  'id': subMap['id']?.toString() ?? '',
                  'name': subMap['name'] ?? 'Sous-catégorie',
                  'category_name': catName,
                  'category_id': catId,
                };

                print('   └─ Sous-catégorie: ${subcatData['name']} (ID: ${subcatData['id']})');

                categories[catName]!.add(subcatData);
                allSubs.add(subcatData);
              }
            } else {
              print('   └─ Aucune sous-catégorie, ajout de la catégorie comme sous-catégorie');
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

          print('✅ ADD_PRODUCT: ${categories.length} catégories chargées depuis l\'API');
          print('✅ ADD_PRODUCT: ${allSubs.length} sous-catégories au total');
        } else {
          print('⚠️ ADD_PRODUCT: Format de données inattendu ou liste vide, utilisation des données hardcodées');
          _buildAllSubcategoriesFromHardcoded();
        }
      } else {
        print('❌ ADD_PRODUCT: Échec de la réponse API - Message: ${response.message}');
        _buildAllSubcategoriesFromHardcoded();
      }
    } catch (e, stackTrace) {
      print('❌ ADD_PRODUCT: Erreur lors du chargement des catégories: $e');
      print('❌ ADD_PRODUCT: Stack trace: $stackTrace');
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

  /// Populate form with product data for editing
  Future<void> _populateEditData(Map<String, dynamic> product) async {
    try {
      print('📝 ADD_PRODUCT: Populating edit data...');
      print('📝 ADD_PRODUCT: Product data structure: ${product.keys.toList()}');
      print('📝 ADD_PRODUCT: Full product data: $product');

      // Populate text fields
      nameController.text = product['name'] ?? '';
      descriptionController.text = product['description'] ?? '';

      // Price - remove formatting if present
      final price = product['price'];
      if (price != null) {
        priceController.text = price.toString();
        print('📝 ADD_PRODUCT: Price set: $price');
      } else {
        print('⚠️ ADD_PRODUCT: No price found in product data');
      }

      // Stock - check multiple possible field names
      final stock = product['stock'] ?? product['quantity'] ?? product['stock_quantity'];
      if (stock != null) {
        stockController.text = stock.toString();
        print('📝 ADD_PRODUCT: Stock set: $stock');
      } else {
        print('⚠️ ADD_PRODUCT: No stock/quantity found in product data');
        print('📝 ADD_PRODUCT: Available keys: ${product.keys.where((k) => k.toLowerCase().contains('stock') || k.toLowerCase().contains('quantity')).toList()}');
      }

      // Category and Subcategory
      final subcategory = product['subcategory'];
      final category = product['category'];

      if (subcategory != null) {
        final subcatId = subcategory['id']?.toString();
        final subcatName = subcategory['name'];

        if (subcatId != null && subcatName != null) {
          selectedSubcategoryId.value = subcatId;
          selectedSubcategory.value = subcatName;
          print('📝 ADD_PRODUCT: Subcategory set: $subcatName (ID: $subcatId)');
        }
      }

      if (category != null) {
        final catName = category['name'];
        if (catName != null) {
          selectedCategory.value = catName;
          print('📝 ADD_PRODUCT: Category set: $catName');
        }
      }

      // Weight - check multiple possible field names
      final weight = product['weight'] ?? product['weight_kg'] ?? product['product_weight'];
      if (weight != null) {
        final weightStr = weight.toString().trim();
        print('📝 ADD_PRODUCT: Weight found: $weightStr');

        // Check if it matches one of our predefined weights
        bool foundWeight = false;
        for (var entry in weightTypes.entries) {
          // Match exact key or check if the weight string contains the key
          if (entry.key == weightStr || weightStr == entry.key) {
            selectedWeightType.value = entry.key;
            foundWeight = true;
            print('📝 ADD_PRODUCT: Weight set to predefined: ${entry.key}');
            break;
          }
        }

        // If not found, it's a custom weight
        if (!foundWeight) {
          selectedWeightType.value = 'custom';
          // Remove " kg" suffix if present
          final cleanWeight = weightStr.replaceAll(RegExp(r'\s*kg\s*$', caseSensitive: false), '');
          weightKgController.text = cleanWeight;
          print('📝 ADD_PRODUCT: Custom weight set: $cleanWeight kg');
        }
      } else {
        print('⚠️ ADD_PRODUCT: No weight found in product data');
        print('📝 ADD_PRODUCT: Available keys: ${product.keys.where((k) => k.toLowerCase().contains('weight')).toList()}');
      }

      // Download images from URLs
      final images = product['images'] as List?;
      if (images != null && images.isNotEmpty) {
        print('📝 ADD_PRODUCT: Downloading ${images.length} images...');
        for (var i = 0; i < images.length; i++) {
          final imageData = images[i] as Map<String, dynamic>;
          final imageUrl = imageData['url'] as String?;

          if (imageUrl != null) {
            try {
              final imageFile = await _downloadImage(imageUrl);
              if (imageFile != null) {
                productImages.add(imageFile);

                // Set primary image if indicated
                final isPrimary = imageData['is_primary'] ?? false;
                if (isPrimary) {
                  primaryImageIndex.value = i;
                }
              }
            } catch (e) {
              print('⚠️ ADD_PRODUCT: Failed to download image $i: $e');
            }
          }
        }
        print('✅ ADD_PRODUCT: Downloaded ${productImages.length} images');
      }

      print('✅ ADD_PRODUCT: Edit data populated successfully');
    } catch (e, stackTrace) {
      print('❌ ADD_PRODUCT: Error populating edit data: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Erreur',
        'Impossible de charger les données du produit',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Download an image from URL to local file
  Future<File?> _downloadImage(String url) async {
    try {
      // Download image from URL
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Create a temporary file
        final Directory appDir = await getApplicationDocumentsDirectory();
        final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(url)}';
        final String filePath = path.join(appDir.path, 'product_images', fileName);

        // Create directory if it doesn't exist
        final Directory imageDir = Directory(path.join(appDir.path, 'product_images'));
        if (!await imageDir.exists()) {
          await imageDir.create(recursive: true);
        }

        // Write the file
        final File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        print('📷 ADD_PRODUCT: Image downloaded: $fileName');
        return file;
      } else {
        print('❌ ADD_PRODUCT: Failed to download image. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ADD_PRODUCT: Error downloading image: $e');
    }
    return null;
  }

  /// Copier une image dans un répertoire permanent
  Future<File> _copyImageToPermanentStorage(XFile image) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
      final String newPath = path.join(appDir.path, 'product_images', fileName);

      // Créer le dossier s'il n'existe pas
      final Directory imageDir = Directory(path.join(appDir.path, 'product_images'));
      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      // Copier le fichier
      final File sourceFile = File(image.path);
      final File newFile = await sourceFile.copy(newPath);

      print('📷 ADD_PRODUCT: Image copiée vers: $newPath');
      return newFile;
    } catch (e) {
      print('❌ ADD_PRODUCT: Erreur lors de la copie de l\'image: $e');
      // En cas d'erreur, retourner le fichier original
      return File(image.path);
    }
  }

  /// Ajouter des images
  Future<void> pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        for (var image in images) {
          // Copier l'image dans un emplacement permanent
          final File permanentFile = await _copyImageToPermanentStorage(image);
          productImages.add(permanentFile);
        }
        print('📷 ADD_PRODUCT: ${images.length} images sélectionnées depuis la galerie');
      }
    } catch (e) {
      print('❌ ADD_PRODUCT: Erreur lors de la sélection des images: $e');
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
        imageQuality: 85,
      );

      if (image != null) {
        // Copier l'image dans un emplacement permanent
        final File permanentFile = await _copyImageToPermanentStorage(image);
        productImages.add(permanentFile);
        print('📷 ADD_PRODUCT: Photo prise depuis la caméra');
      }
    } catch (e) {
      print('❌ ADD_PRODUCT: Erreur lors de la prise de photo: $e');
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

    // Note: Les champs storage, weight et stock ne sont pas encore requis par l'API
    // Ces validations sont commentées pour le moment

    // if (selectedStorage.value == null) {
    //   Get.snackbar(
    //     'Stockage requis',
    //     'Veuillez sélectionner un espace de stockage',
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    //   return;
    // }

    // if (selectedWeightType.value == null) {
    //   Get.snackbar(
    //     'Poids requis',
    //     'Veuillez sélectionner le poids du produit',
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    //   return;
    // }

    // if (selectedWeightType.value == 'custom' && weightKgController.text.trim().isEmpty) {
    //   Get.snackbar(
    //     'Poids requis',
    //     'Veuillez entrer le poids en KG',
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    //   return;
    // }

    // if (stockController.text.trim().isEmpty) {
    //   Get.snackbar(
    //     'Stock requis',
    //     'Veuillez entrer la quantité en stock',
    //     snackPosition: SnackPosition.BOTTOM,
    //   );
    //   return;
    // }

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

      // Récupérer le category_id depuis les données de la sous-catégorie sélectionnée
      String? categoryId;
      if (selectedSubcategoryId.value != null) {
        final selectedSubcat = allSubcategories.firstWhere(
          (subcat) => subcat['id'] == selectedSubcategoryId.value,
          orElse: () => <String, String>{},
        );
        categoryId = selectedSubcat['category_id'];
      }

      print('📦 ADD_PRODUCT: category_id = $categoryId');
      print('📦 ADD_PRODUCT: subcategory_id = ${selectedSubcategoryId.value}');

      // Préparer les champs (selon ce qu'attend l'API)
      final fieldsMap = <String, String>{
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'type': articleType.value,
        'price': priceController.text.trim(),
        'condition': 'new', // L'API requiert ce champ
      };

      // Ajouter category_id (REQUIS par l'API)
      if (categoryId != null && categoryId.isNotEmpty) {
        fieldsMap['category_id'] = categoryId;
      } else {
        Get.snackbar(
          'Erreur',
          'Une erreur s\'est produite. Veuillez sélectionner à nouveau la catégorie.',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Ajouter subcategory_id si disponible
      if (selectedSubcategoryId.value != null && selectedSubcategoryId.value!.isNotEmpty) {
        fieldsMap['subcategory_id'] = selectedSubcategoryId.value!;
      }

      // Ajouter stock si disponible
      if (stockController.text.trim().isNotEmpty) {
        fieldsMap['stock'] = stockController.text.trim();
      }

      // Ajouter weight si disponible
      if (selectedWeightType.value != null) {
        if (selectedWeightType.value == 'custom') {
          // Poids personnalisé en KG
          if (weightKgController.text.trim().isNotEmpty) {
            fieldsMap['weight'] = '${weightKgController.text.trim()} kg';
          }
        } else {
          // Poids prédéfini
          fieldsMap['weight'] = selectedWeightType.value!;
        }
      }

      // Note: storage_id n'est pas encore supporté par l'API
      // Il sera ajouté dans une future version du backend

      if (primaryImageIndex.value > 0 && primaryImageIndex.value < productImages.length) {
        fieldsMap['primary_image_index'] = primaryImageIndex.value.toString();
      }

      print('📦 ADD_PRODUCT: Envoi de la requête au backend...');
      print('📦 ADD_PRODUCT: Mode: ${isEditMode.value ? "EDIT" : "CREATE"}');
      print('📦 ADD_PRODUCT: Fields: $fieldsMap');
      print('📦 ADD_PRODUCT: Files count: ${filesMap.length}');

      // Appel API multipart pour créer ou modifier le produit
      final response = isEditMode.value && editProductId.value != null
          ? await ApiProvider.multipart(
              '/v1/products/${editProductId.value}',
              method: 'PUT',
              fields: fieldsMap,
              files: filesMap,
            )
          : await ApiProvider.multipart(
              '/v1/products',
              fields: fieldsMap,
              files: filesMap,
            );

      print('📦 ADD_PRODUCT: Réponse reçue - success: ${response.success}');
      print('📦 ADD_PRODUCT: Réponse reçue - message: ${response.message}');
      print('📦 ADD_PRODUCT: Réponse reçue - data: ${response.data}');

      if (response.success) {
        // Afficher info stockage si disponible
        if (response.data?['storage_info'] != null) {
          final storageInfo = response.data!['storage_info'];
          print('📊 Storage used: ${storageInfo['used_mb']} MB');
          print('📊 Storage remaining: ${storageInfo['remaining_mb']} MB');
        }

        // Toast de succès avec style responsive
        Get.snackbar(
          isEditMode.value ? '✅ Produit modifié !' : '✅ Produit créé !',
          isEditMode.value
              ? 'Votre produit a été modifié avec succès'
              : 'Votre produit a été ajouté avec succès',
          snackPosition: SnackPosition.TOP,
          backgroundColor: AppThemeSystem.successColor,
          colorText: Colors.white,
          icon: const Icon(
            Icons.check_circle_rounded,
            color: Colors.white,
            size: 28,
          ),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          duration: const Duration(seconds: 3),
          boxShadows: [
            BoxShadow(
              color: AppThemeSystem.successColor.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        );

        // Retour à la page précédente
        Get.back(); // Ferme la page d'ajout/édition

        // Navigation vers la page de gestion des produits après un court délai (sauf si on est déjà en mode édition depuis product management)
        if (!isEditMode.value) {
          Future.delayed(const Duration(milliseconds: 500), () {
            Get.toNamed('/product-management');
          });
        }
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
