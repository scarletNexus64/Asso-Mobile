import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../../routes/app_pages.dart';
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
  final locationPermissionGranted = false.obs;
  final userLocation = ''.obs;

  // Step 2: Configuration boutique
  final TextEditingController shopNameController = TextEditingController();
  final TextEditingController shopDescriptionController = TextEditingController();
  final TextEditingController locationSearchController = TextEditingController();

  final shopLogo = Rx<File?>(null);
  final shopLocation = ''.obs;
  final shopLatitude = 0.0.obs;
  final shopLongitude = 0.0.obs;

  final selectedCategories = <String>[].obs;
  final categories = [
    'Électronique',
    'Mode & Vêtements',
    'Alimentation',
    'Maison & Jardin',
    'Beauté & Santé',
    'Sports & Loisirs',
    'Automobile',
    'Livres & Médias',
    'Artisanat',
    'Services',
  ].obs;

  // Validation
  final isLoading = false.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _requestLocationPermission();
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
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );

        if (image != null) {
          profileImage.value = File(image.path);
        }
      }
    } catch (e) {
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
        final XFile? image = await _picker.pickImage(
          source: source,
          maxWidth: 512,
          maxHeight: 512,
          imageQuality: 85,
        );

        if (image != null) {
          shopLogo.value = File(image.path);
        }
      }
    } catch (e) {
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
  void toggleCategory(String category) {
    if (selectedCategories.contains(category)) {
      selectedCategories.remove(category);
    } else {
      selectedCategories.add(category);
    }
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
    isLoading.value = true;

    try {
      // TODO: Implémenter l'appel API pour soumettre la configuration

      // Simulation d'un délai réseau
      await Future.delayed(const Duration(seconds: 2));

      // Succès - passage au step 3
      isLoading.value = false;
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue. Veuillez réessayer.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
      isLoading.value = false;
    }
  }

  /// Navigation vers la boutique
  void navigateToShop() {
    // Naviguer vers le dashboard vendeur
    Get.offAllNamed(Routes.VENDOR_DASHBOARD);
  }
}
