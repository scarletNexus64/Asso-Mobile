import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/delivery_person_models.dart';
import '../../vendorConfig/views/map_location_picker_view.dart';

class ShipConfigController extends GetxController {
  // Stepper
  final currentStep = 0.obs;

  // Step 0: Acceptation des termes
  final termsAccepted = false.obs;
  final locationSharingAccepted = false.obs;
  final locationPermissionGranted = false.obs;

  // Step 1: Type de livreur
  final selectedType = Rx<DeliveryPersonType?>(null);

  // Step 2: Configuration entreprise (si applicable)
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController companyDescriptionController = TextEditingController();
  final TextEditingController locationSearchController = TextEditingController();

  final companyLogo = Rx<File?>(null);
  final companyLocation = ''.obs;
  final companyLatitude = 0.0.obs;
  final companyLongitude = 0.0.obs;

  // État de chargement
  final isLoading = false.obs;

  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _checkLocationPermission();
  }

  @override
  void onClose() {
    companyNameController.dispose();
    companyDescriptionController.dispose();
    locationSearchController.dispose();
    super.onClose();
  }

  /// Vérifie la permission de localisation
  Future<void> _checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      locationPermissionGranted.value = status.isGranted;
    } catch (e) {
      locationPermissionGranted.value = false;
    }
  }

  /// Demande la permission de localisation
  Future<void> requestLocationPermission() async {
    try {
      PermissionStatus status = await Permission.location.status;

      if (status.isDenied) {
        status = await Permission.location.request();
      }

      if (status.isGranted) {
        locationPermissionGranted.value = true;
        locationSharingAccepted.value = true;
        Get.snackbar(
          'Permission accordée',
          'Vous pourrez recevoir des demandes de livraison',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else if (status.isPermanentlyDenied) {
        locationPermissionGranted.value = false;
        Get.snackbar(
          'Permission requise',
          'Veuillez autoriser l\'accès à la localisation dans les paramètres',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
        );
      } else {
        locationPermissionGranted.value = false;
        locationSharingAccepted.value = false;
      }
    } catch (e) {
      locationPermissionGranted.value = false;
    }
  }

  /// Sélectionne le logo de l'entreprise
  Future<void> pickCompanyLogo() async {
    try {
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
              Text(
                'Choisir un logo',
                style: Get.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.camera_alt, size: 30),
                title: const Text('Prendre une photo'),
                onTap: () => Get.back(result: ImageSource.camera),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo_library, size: 30),
                title: const Text('Choisir depuis la galerie'),
                onTap: () => Get.back(result: ImageSource.gallery),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 8),
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
          companyLogo.value = File(image.path);
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

  /// Ouvre la carte pour sélectionner la position
  Future<void> openMapPicker() async {
    try {
      LatLng? initialPosition;

      if (companyLatitude.value != 0.0 && companyLongitude.value != 0.0) {
        initialPosition = LatLng(companyLatitude.value, companyLongitude.value);
      } else {
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
          // Position par défaut: Douala
          initialPosition = const LatLng(4.0511, 9.7679);
        }
      }

      final result = await Get.to<Map<String, dynamic>>(
        () => MapLocationPickerView(
          initialPosition: initialPosition,
          initialAddress: companyLocation.value.isEmpty ? null : companyLocation.value,
        ),
      );

      if (result != null) {
        companyLatitude.value = result['latitude'] as double;
        companyLongitude.value = result['longitude'] as double;
        companyLocation.value = result['address'] as String;
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ouvrir la carte',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Valide l'étape 0 (acceptation)
  bool validateStep0() {
    if (!termsAccepted.value) {
      Get.snackbar(
        'Conditions requises',
        'Veuillez accepter les conditions pour devenir livreur',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (!locationPermissionGranted.value) {
      Get.snackbar(
        'Attention',
        'Sans la permission de localisation, vous ne pourrez pas recevoir de demandes de livraison à proximité',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      // On continue quand même, mais avec un avertissement
    }

    return true;
  }

  /// Valide l'étape 1 (choix du type)
  bool validateStep1() {
    if (selectedType.value == null) {
      Get.snackbar(
        'Choix requis',
        'Veuillez sélectionner un type de livreur',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    return true;
  }

  /// Valide l'étape 2 (configuration entreprise)
  bool validateStep2() {
    // Cette étape n'est requise que pour les entreprises
    if (selectedType.value != DeliveryPersonType.company) {
      return true;
    }

    if (companyNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Champ requis',
        'Veuillez entrer le nom de votre entreprise',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (companyDescriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Champ requis',
        'Veuillez décrire votre entreprise',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (companyLogo.value == null) {
      Get.snackbar(
        'Logo requis',
        'Veuillez ajouter le logo de votre entreprise',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (companyLocation.value.isEmpty) {
      Get.snackbar(
        'Emplacement requis',
        'Veuillez sélectionner l\'emplacement de votre entreprise',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  /// Passe à l'étape suivante
  void nextStep() async {
    if (currentStep.value == 0) {
      if (validateStep0()) {
        currentStep.value++;
      }
    } else if (currentStep.value == 1) {
      if (validateStep1()) {
        // Si personnel, aller directement au dashboard
        if (selectedType.value == DeliveryPersonType.personal) {
          await submitConfig();
          navigateToDeliveryDashboard();
        } else {
          // Si entreprise, passer à la configuration entreprise
          currentStep.value++;
        }
      }
    } else if (currentStep.value == 2) {
      // Configuration entreprise terminée
      if (validateStep2()) {
        await submitConfig();
        navigateToDeliveryDashboard();
      }
    }
  }

  /// Retourne à l'étape précédente
  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  /// Soumet la configuration
  Future<void> submitConfig() async {
    isLoading.value = true;

    try {
      // TODO: Appel API pour enregistrer la configuration
      await Future.delayed(const Duration(seconds: 2));

      Get.snackbar(
        'Succès',
        'Votre configuration a été enregistrée',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue. Veuillez réessayer.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Navigation vers le dashboard de livraison
  void navigateToDeliveryDashboard() {
    Get.offAllNamed('/delivery-dashboard');
  }
}
