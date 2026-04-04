import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/auth_service.dart';
import '../../../routes/app_pages.dart';

class RegisterController extends GetxController {
  late TextEditingController phoneController;

  final phoneNumber = ''.obs;
  final countryCode = '+237'.obs;
  final isLoading = false.obs;
  final isPhoneValid = false.obs;
  final fullPhoneNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    developer.log('========== REGISTER CONTROLLER INIT ==========', name: 'RegisterController');
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
      name: 'RegisterController',
      error: 'Phone: ${phoneNumber.value}, Valid: ${isPhoneValid.value}',
    );
  }

  void onPhoneChanged(String phone, String dialCode) {
    phoneNumber.value = phone;
    countryCode.value = dialCode;
    fullPhoneNumber.value = dialCode + phone;
    developer.log(
      'Phone changed',
      name: 'RegisterController',
      error: 'Full phone: ${fullPhoneNumber.value}',
    );
  }

  Future<void> register() async {
    developer.log(
      '========== REGISTER ATTEMPT ==========',
      name: 'RegisterController',
      error: 'Phone: ${fullPhoneNumber.value}',
    );

    if (!isPhoneValid.value) {
      developer.log('Invalid phone number', name: 'RegisterController');
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
      // Send OTP for registration
      final response = await AuthService.sendOtp(
        phone: phoneNumber.value,
        countryCode: countryCode.value,
      );

      developer.log(
        'Send OTP response',
        name: 'RegisterController',
        error: 'Success: ${response.success}, Message: ${response.message}',
      );

      if (response.success) {
        final isNewUser = response.data?['is_new_user'] ?? true;
        developer.log(
          'OTP sent successfully for registration',
          name: 'RegisterController',
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

        developer.log('Navigating to OTP screen', name: 'RegisterController');
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
          name: 'RegisterController',
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
        'Register error',
        name: 'RegisterController',
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

  void goToLogin() {
    developer.log('Navigating to login', name: 'RegisterController');
    Get.offNamed(Routes.LOGIN);
  }
}
