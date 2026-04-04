import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/auth_service.dart';
import '../../../data/providers/api_provider.dart';
import '../../../routes/app_pages.dart';

class CompleteProfileController extends GetxController {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();

  final RxString selectedGender = ''.obs;
  final Rx<DateTime?> birthDate = Rx<DateTime?>(null);
  final RxString address = ''.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Pre-fill from cached user data
    final user = ApiProvider.cachedUser;
    if (user != null) {
      firstNameController.text = user['first_name'] ?? '';
      lastNameController.text = user['last_name'] ?? '';
      emailController.text = user['email'] ?? '';
      selectedGender.value = user['gender'] ?? '';
      address.value = user['address'] ?? '';
    }
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  Future<void> saveProfile() async {
    if (firstNameController.text.isEmpty || lastNameController.text.isEmpty) {
      Get.snackbar(
        'Champs requis',
        'Veuillez remplir votre prénom et nom',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    isLoading.value = true;

    try {
      final data = <String, dynamic>{
        'first_name': firstNameController.text.trim(),
        'last_name': lastNameController.text.trim(),
      };

      if (emailController.text.isNotEmpty) {
        data['email'] = emailController.text.trim();
      }
      if (selectedGender.value.isNotEmpty) {
        data['gender'] = selectedGender.value;
      }
      if (birthDate.value != null) {
        data['birth_date'] = birthDate.value!.toIso8601String().split('T')[0];
      }
      if (address.value.isNotEmpty) {
        data['address'] = address.value;
      }

      final response = await AuthService.updateProfile(data);

      if (response.success) {
        Get.snackbar(
          'Profil complété',
          'Votre profil a été mis à jour avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );

        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed(Routes.HOME);
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
        'Une erreur est survenue',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void selectGender(String gender) {
    selectedGender.value = gender;
  }

  void selectBirthDate(DateTime date) {
    birthDate.value = date;
  }
}
