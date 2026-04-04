import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../../../routes/app_pages.dart';
import '../../../data/providers/vendor_service.dart';
import '../../../data/providers/storage_service.dart';
import '../../../data/providers/category_service.dart';
import '../../../data/models/category_model.dart';
import '../views/map_location_picker_view.dart';

class VendorConfigController extends GetxController {
  // Stepper
  final currentStep = 0.obs;

  // Step 1: Profil personnel
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final selectedGender = ''.obs;
  final genders = ['Homme', 'Femme'];

  final selectedAccountType = 'Particulier'.obs;
  final accountTypes = ['Particulier', 'Entreprise'];

  final profileImage = Rx<File?>(null);
  final isPickingProfileImage = false.obs;
  final locationPermissionGranted = false.obs;
  final userLocation = ''.obs;

  // Step 2: Configuration boutique
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController shopDescriptionController = TextEditingController();
  final TextEditingController locationSearchController = TextEditingController();

  final shopLogo = Rx<File?>(null);
  final isPickingShopLogo = false.obs;
  final shopLocation = ''.obs;
  final shopLatitude = 0.0.obs;
  final shopLongitude = 0.0.obs;

  // Categories
  final selectedCategories = <String>[].obs; // Category names selected
  final RxList<CategoryModel> categories = <CategoryModel>[].obs; // Full category objects from API
  final isCategoriesLoading = false.obs;
  final categoriesLoadError = ''.obs;

  // Validation
  final isLoading = false.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _requestLocationPermission();
    _loadCategories();
  }

  /// Charge les catégories depuis l'API
  Future<void> _loadCategories() async {
    print('');
    print('========================================');
    print('📂 VENDOR CONFIG: Load Categories START');
    print('========================================');

    isCategoriesLoading.value = true;
    categoriesLoadError.value = '';

    try {
      print('🌐 VENDOR CONFIG: Fetching categories from API...');
      final loadedCategories = await CategoryService.getCategories();

      if (loadedCategories.isNotEmpty) {
        categories.value = loadedCategories;
        print('✅ VENDOR CONFIG: Categories loaded successfully');
        print('  └─ Total: ${loadedCategories.length}');
        for (var cat in loadedCategories) {
          print('  └─ ${cat.name} (${cat.productsCount ?? 0} produits)');
        }
      } else {
        print('⚠️ VENDOR CONFIG: No categories loaded, using fallback');
        // Fallback si l'API ne retourne rien
        _useFallbackCategories();
      }

      isCategoriesLoading.value = false;
      print('========================================');
    } catch (e, stackTrace) {
      print('💥 VENDOR CONFIG: Categories load failed!');
      print('  └─ Error: $e');
      print('  └─ Stack Trace:');
      print(stackTrace.toString().split('\n').take(3).join('\n'));
      print('  └─ Using fallback categories');

      categoriesLoadError.value = 'Impossible de charger les catégories';
      _useFallbackCategories();
      isCategoriesLoading.value = false;
      print('========================================');
    }
  }

  /// Catégories de secours si l'API échoue
  void _useFallbackCategories() {
    categories.value = [
      CategoryModel(id: 0, name: 'Électronique', slug: 'electronique'),
      CategoryModel(id: 0, name: 'Mode & Vêtements', slug: 'mode-vetements'),
      CategoryModel(id: 0, name: 'Alimentation', slug: 'alimentation'),
      CategoryModel(id: 0, name: 'Maison & Jardin', slug: 'maison-jardin'),
      CategoryModel(id: 0, name: 'Beauté & Santé', slug: 'beaute-sante'),
      CategoryModel(id: 0, name: 'Sports & Loisirs', slug: 'sports-loisirs'),
      CategoryModel(id: 0, name: 'Automobile', slug: 'automobile'),
      CategoryModel(id: 0, name: 'Livres & Médias', slug: 'livres-medias'),
      CategoryModel(id: 0, name: 'Artisanat', slug: 'artisanat'),
      CategoryModel(id: 0, name: 'Services', slug: 'services'),
    ];
    print('  └─ Fallback: ${categories.length} categories');
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    shopNameController.dispose();
    shopDescriptionController.dispose();
    locationSearchController.dispose();
    super.onClose();
  }

  /// Demande la permission de localisation
  Future<void> _requestLocationPermission() async {
    try {
      // Vérifier d'abord le statut de la permission
      PermissionStatus status = await Permission.location.status;

      if (status.isDenied) {
        // Demander la permission
        status = await Permission.location.request();
      }

      if (status.isGranted) {
        locationPermissionGranted.value = true;
        // Obtenir la position actuelle
        await _getCurrentLocation();
      } else if (status.isPermanentlyDenied) {
        // Permission refusée de façon permanente
        locationPermissionGranted.value = false;
        Get.snackbar(
          'Permission requise',
          'Veuillez autoriser l\'accès à la localisation dans les paramètres',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      } else {
        locationPermissionGranted.value = false;
        userLocation.value = '';
      }
    } catch (e) {
      locationPermissionGranted.value = false;
      userLocation.value = '';
    }
  }

  /// Obtenir la position actuelle
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Pour l'instant, on affiche juste les coordonnées
      // Dans une vraie app, on utiliserait un service de géocodage inversé
      userLocation.value = 'Position: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';

      // Simuler une adresse pour le moment
      userLocation.value = 'Douala, Cameroun';
    } catch (e) {
      userLocation.value = 'Localisation non disponible';
    }
  }

  /// Sélectionne une photo de profil
  Future<void> pickProfileImage() async {
    try {
      // Afficher le choix caméra ou galerie
      final source = await Get.bottomSheet<ImageSource>(
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Get.theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titre
              Text(
                'Choisir une photo',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Bouton Caméra
              ListTile(
                leading: const Icon(Icons.camera_alt, size: 30),
                title: const Text('Prendre une photo'),
                onTap: () => Get.back(result: ImageSource.camera),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              const SizedBox(height: 8),

              // Bouton Galerie
              ListTile(
                leading: const Icon(Icons.photo_library, size: 30),
                title: const Text('Choisir depuis la galerie'),
                onTap: () => Get.back(result: ImageSource.gallery),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              const SizedBox(height: 8),

              // Bouton Annuler
              ListTile(
                leading: const Icon(Icons.close, size: 30),
                title: const Text('Annuler'),
                onTap: () => Get.back(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
        isDismissible: true,
      );

      if (source != null) {
        isPickingProfileImage.value = true;

        try {
          final XFile? image = await _picker.pickImage(
            source: source,
            maxWidth: 1024,
            maxHeight: 1024,
            imageQuality: 85,
          );

          if (image != null) {
            print('📸 Profile image picked: ${image.path}');

            // Copier vers un emplacement permanent pour éviter la suppression du cache
            final permanentFile = await _copyToAppDirectory(
              image.path,
              'profile_${DateTime.now().millisecondsSinceEpoch}.jpg'
            );
            profileImage.value = permanentFile;

            print('✅ Profile image set successfully');
          }
        } finally {
          isPickingProfileImage.value = false;
        }
      }
    } catch (e) {
      isPickingProfileImage.value = false;
      print('❌ Error picking profile image: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de sélectionner l\'image',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Sélectionne le logo de la boutique
  Future<void> pickShopLogo() async {
    try {
      // Afficher le choix caméra ou galerie
      final source = await Get.bottomSheet<ImageSource>(
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Get.theme.scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Titre
              Text(
                'Choisir un logo',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Bouton Caméra
              ListTile(
                leading: const Icon(Icons.camera_alt, size: 30),
                title: const Text('Prendre une photo'),
                onTap: () => Get.back(result: ImageSource.camera),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              const SizedBox(height: 8),

              // Bouton Galerie
              ListTile(
                leading: const Icon(Icons.photo_library, size: 30),
                title: const Text('Choisir depuis la galerie'),
                onTap: () => Get.back(result: ImageSource.gallery),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              const SizedBox(height: 8),

              // Bouton Annuler
              ListTile(
                leading: const Icon(Icons.close, size: 30),
                title: const Text('Annuler'),
                onTap: () => Get.back(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
        isDismissible: true,
      );

      if (source != null) {
        isPickingShopLogo.value = true;

        try {
          final XFile? image = await _picker.pickImage(
            source: source,
            maxWidth: 512,
            maxHeight: 512,
            imageQuality: 85,
          );

          if (image != null) {
            print('📸 Shop logo picked: ${image.path}');

            // Copier vers un emplacement permanent pour éviter la suppression du cache
            final permanentFile = await _copyToAppDirectory(
              image.path,
              'shop_logo_${DateTime.now().millisecondsSinceEpoch}.jpg'
            );
            shopLogo.value = permanentFile;

            print('✅ Shop logo set successfully');
          }
        } finally {
          isPickingShopLogo.value = false;
        }
      }
    } catch (e) {
      isPickingShopLogo.value = false;
      print('❌ Error picking shop logo: $e');
      Get.snackbar(
        'Erreur',
        'Impossible de sélectionner le logo',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    }
  }

  /// Valide l'étape 1
  bool validateStep1() {
    if (firstNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Champ requis',
        'Veuillez entrer votre prénom',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (lastNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Champ requis',
        'Veuillez entrer votre nom',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (selectedGender.value.isEmpty) {
      Get.snackbar(
        'Champ requis',
        'Veuillez sélectionner votre genre',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (profileImage.value == null) {
      Get.snackbar(
        'Photo requise',
        'Veuillez ajouter une photo de profil',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  /// Valide l'étape 2
  bool validateStep2() {
    if (shopNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Champ requis',
        'Veuillez entrer le nom de votre boutique',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (shopDescriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Champ requis',
        'Veuillez décrire votre activité',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (shopLogo.value == null) {
      Get.snackbar(
        'Logo requis',
        'Veuillez ajouter le logo de votre boutique',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (shopLocation.value.isEmpty) {
      Get.snackbar(
        'Emplacement requis',
        'Veuillez sélectionner l\'emplacement de votre boutique',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (selectedCategories.isEmpty) {
      Get.snackbar(
        'Catégorie requise',
        'Veuillez sélectionner au moins une catégorie',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  /// Passe à l'étape suivante
  void nextStep() async {
    if (currentStep.value == 0) {
      if (validateStep1()) {
        currentStep.value++;
      }
    } else if (currentStep.value == 1) {
      if (validateStep2()) {
        // Soumettre la configuration
        await submitVendorConfig();
        // Si la soumission réussit, passer au step 3
        currentStep.value++;
      }
    } else if (currentStep.value == 2) {
      // Step 3 - Rediriger vers la boutique
      navigateToShop();
    }
  }

  /// Retourne à l'étape précédente
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  /// Toggle catégorie
  void toggleCategory(String categoryName) {
    if (selectedCategories.contains(categoryName)) {
      selectedCategories.remove(categoryName);
      print('✖️ Category unselected: $categoryName');
    } else {
      selectedCategories.add(categoryName);
      print('✔️ Category selected: $categoryName');
    }
    print('  └─ Total selected: ${selectedCategories.length}');
  }

  /// Rafraîchir les catégories
  Future<void> refreshCategories() async {
    print('🔄 VENDOR CONFIG: Refreshing categories...');
    await _loadCategories();
  }

  /// Sélectionne un emplacement sur la carte
  void selectLocation(double lat, double lng, String address) {
    shopLatitude.value = lat;
    shopLongitude.value = lng;
    shopLocation.value = address;
  }

  /// Ouvre la carte pour sélectionner la position
  Future<void> openMapPicker() async {
    try {
      // Préparer la position initiale
      LatLng? initialPosition;

      // Si une position de boutique est déjà sélectionnée, l'utiliser
      if (shopLatitude.value != 0.0 && shopLongitude.value != 0.0) {
        initialPosition = LatLng(shopLatitude.value, shopLongitude.value);
      } else {
        // Sinon, essayer d'obtenir la position actuelle de l'utilisateur
        try {
          if (locationPermissionGranted.value) {
            Position position = await Geolocator.getCurrentPosition(
              locationSettings: const LocationSettings(
                accuracy: LocationAccuracy.high,
              ),
            );
            initialPosition = LatLng(position.latitude, position.longitude);
          }
        } catch (e) {
          // Si la position actuelle n'est pas disponible, utiliser Douala par défaut
          initialPosition = const LatLng(4.0511, 9.7679);
        }
      }

      // Ouvrir la carte
      final result = await Get.to<Map<String, dynamic>>(
        () => MapLocationPickerView(
          initialPosition: initialPosition,
          initialAddress: shopLocation.value.isEmpty ? null : shopLocation.value,
        ),
      );

      // Si l'utilisateur a confirmé une position
      if (result != null) {
        shopLatitude.value = result['latitude'] as double;
        shopLongitude.value = result['longitude'] as double;
        shopLocation.value = result['address'] as String;
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ouvrir la carte',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Soumet la configuration vendeur
  Future<void> submitVendorConfig() async {
    print('');
    print('========================================');
    print('🏪 VENDOR CONFIG: SUBMIT START');
    print('========================================');

    isLoading.value = true;

    try {
      // Log data being sent
      print('📤 VENDOR CONFIG: Preparing data to send...');
      print('  └─ Shop Name: ${shopNameController.text.trim()}');
      print('  └─ Shop Description: ${shopDescriptionController.text.trim().isNotEmpty ? "YES" : "NO"}');
      print('  └─ Shop Address: ${shopLocation.value}');
      print('  └─ Shop Coordinates: (${shopLatitude.value}, ${shopLongitude.value})');
      print('  └─ Categories: ${selectedCategories.toList()}');
      print('  └─ First Name: ${firstNameController.text.trim()}');
      print('  └─ Last Name: ${lastNameController.text.trim()}');
      print('  └─ Gender: ${selectedGender.value}');
      print('  └─ Account Type: ${selectedAccountType.value}');
      print('  └─ Has Shop Logo: ${shopLogo.value != null}');
      print('  └─ Has Profile Image: ${profileImage.value != null}');

      print('🌐 VENDOR CONFIG: Calling API...');
      final response = await VendorService.applyVendor(
        shopName: shopNameController.text.trim(),
        shopDescription: shopDescriptionController.text.trim(),
        shopAddress: shopLocation.value,
        shopLatitude: shopLatitude.value,
        shopLongitude: shopLongitude.value,
        categories: selectedCategories.toList(),
        firstName: firstNameController.text.trim(),
        lastName: lastNameController.text.trim(),
        gender: selectedGender.value,
        accountType: selectedAccountType.value,
        companyName: selectedAccountType.value == 'Entreprise' ? shopNameController.text.trim() : null,
        shopLogo: shopLogo.value,
        profileImage: profileImage.value,
      );

      print('📥 VENDOR CONFIG: API Response received');
      print('  └─ Success: ${response.success}');
      print('  └─ Status Code: ${response.statusCode}');
      print('  └─ Message: ${response.message}');

      if (response.success) {
        print('✅ VENDOR CONFIG: Success!');
        if (response.data != null) {
          print('  └─ Shop ID: ${response.data!['shop']?['id']}');
          print('  └─ Shop Name: ${response.data!['shop']?['name']}');
          print('  └─ User Role: ${response.data!['user']?['role']}');

          // IMPORTANT: Update user in storage with new role
          if (response.data!['user'] != null) {
            print('💾 VENDOR CONFIG: Updating user in storage...');
            try {
              final currentUser = StorageService.getUser();
              if (currentUser != null) {
                final userData = response.data!['user'];
                List<String>? roles;
                if (userData['roles'] != null) {
                  roles = List<String>.from(userData['roles'] as List);
                }

                final updatedUser = currentUser.copyWith(
                  role: userData['role'],
                  roles: roles,
                  firstName: userData['first_name'],
                  lastName: userData['last_name'],
                  gender: userData['gender'],
                  companyName: userData['company_name'],
                  avatar: userData['avatar'],
                );
                StorageService.saveUser(updatedUser);
                print('  └─ User updated in storage');
                print('  └─ Role: ${updatedUser.role}');
                print('  └─ Roles: ${updatedUser.roles}');
                print('  └─ Is Vendor: ${updatedUser.isVendor}');
              }
            } catch (e) {
              print('  └─ ⚠️ Failed to update user in storage: $e');
              // Non-blocking, continue anyway
            }
          }
        }

        Get.snackbar('Succès', 'Vous êtes maintenant vendeur !',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        isLoading.value = false;
        print('========================================');
      } else {
        print('❌ VENDOR CONFIG: Failed');
        print('  └─ Error Message: ${response.message}');

        Get.snackbar('Erreur', response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
        isLoading.value = false;
        print('========================================');
      }
    } catch (e, stackTrace) {
      print('💥 VENDOR CONFIG: Exception caught!');
      print('  └─ Error: $e');
      print('  └─ Stack Trace:');
      print(stackTrace.toString().split('\n').take(5).join('\n'));

      Get.snackbar('Erreur', 'Une erreur est survenue: $e',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      isLoading.value = false;
      print('========================================');
    }
  }

  /// Navigation vers la boutique
  void navigateToShop() {
    // Naviguer vers le dashboard vendeur
    Get.offAllNamed(Routes.VENDOR_DASHBOARD);
  }

  /// Copie un fichier du cache vers le répertoire de l'application
  Future<File> _copyToAppDirectory(String sourcePath, String fileName) async {
    try {
      final sourceFile = File(sourcePath);

      // Vérifier que le fichier source existe
      if (!await sourceFile.exists()) {
        print('⚠️ Source file does not exist: $sourcePath');
        throw Exception('Source file does not exist');
      }

      final appDir = await getApplicationDocumentsDirectory();
      final newPath = path.join(appDir.path, fileName);

      // Copier le fichier immédiatement
      final copiedFile = await sourceFile.copy(newPath);

      print('📁 File copied to permanent location:');
      print('  └─ From: $sourcePath');
      print('  └─ To: $newPath');
      print('  └─ Size: ${await copiedFile.length()} bytes');

      return copiedFile;
    } catch (e) {
      print('❌ Error copying file: $e');
      // Si la copie échoue, essayer de retourner le fichier original si il existe toujours
      final sourceFile = File(sourcePath);
      if (await sourceFile.exists()) {
        print('  └─ Returning original file as fallback');
        return sourceFile;
      }

      // Si même le fichier source n'existe pas, propager l'erreur
      rethrow;
    }
  }
}
