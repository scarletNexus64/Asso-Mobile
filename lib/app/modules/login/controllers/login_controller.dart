import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/auth_service.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  late TextEditingController phoneController;

  final phoneNumber = ''.obs;
  final countryCode = '+237'.obs;
  final isLoading = false.obs;
  final isPhoneValid = false.obs;
  final fullPhoneNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    developer.log('========== LOGIN CONTROLLER INIT ==========', name: 'LoginController');
    phoneController = TextEditingController();
    ever(phoneNumber, (_) => _validatePhone());
  }

  @override
  void onClose() {
    phoneController.dispose();
    super.onClose();
  }

  void _validatePhone() {
    isPhoneValid.value = phoneNumber.value.length >= 8;
    developer.log(
      'Phone validation',
      name: 'LoginController',
      error: 'Phone: ${phoneNumber.value}, Valid: ${isPhoneValid.value}',
    );
  }

  void onPhoneChanged(String phone, String dialCode) {
    phoneNumber.value = phone;
    countryCode.value = dialCode;
    fullPhoneNumber.value = dialCode + phone;
    developer.log(
      'Phone changed',
      name: 'LoginController',
      error: 'Full phone: ${fullPhoneNumber.value}',
    );
  }

  Future<void> login() async {
    developer.log(
      '========== LOGIN ATTEMPT ==========',
      name: 'LoginController',
      error: 'Phone: ${fullPhoneNumber.value}',
    );

    if (!isPhoneValid.value) {
      developer.log('Invalid phone number', name: 'LoginController');
      Get.snackbar(
        'Numéro invalide',
        'Veuillez entrer un numéro de téléphone valide',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return;
    }

    isLoading.value = true;

    try {
      final response = await AuthService.sendOtp(
        phone: phoneNumber.value,
        countryCode: countryCode.value,
      );

      developer.log(
        'Send OTP response',
        name: 'LoginController',
        error: 'Success: ${response.success}, Message: ${response.message}',
      );

      if (response.success) {
        final isNewUser = response.data?['is_new_user'] ?? false;
        developer.log(
          'OTP sent successfully',
          name: 'LoginController',
          error: 'Is new user: $isNewUser',
        );

        Get.snackbar(
          'Code envoyé',
          'Un code de vérification a été envoyé au ${fullPhoneNumber.value}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );

        await Future.delayed(const Duration(milliseconds: 500));

        developer.log('Navigating to OTP screen', name: 'LoginController');
        Get.toNamed(
          Routes.OTP,
          arguments: {
            'phoneNumber': fullPhoneNumber.value,
            'isNewUser': isNewUser,
          },
        );
      } else {
        developer.log(
          'OTP send failed',
          name: 'LoginController',
          error: response.message,
        );
        Get.snackbar(
          'Erreur',
          response.message,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Login error',
        name: 'LoginController',
        error: e,
        stackTrace: stackTrace,
      );
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue. Veuillez réessayer.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() {
    developer.log('Navigating to register/welcomer', name: 'LoginController');
    Get.offNamed(Routes.WELCOMER);
  }
}
