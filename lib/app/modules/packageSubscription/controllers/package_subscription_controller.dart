import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../../data/providers/package_service.dart';
import '../../../core/utils/app_theme_system.dart';

class PackageSubscriptionController extends GetxController {
  // Observable variables
  final packages = <Map<String, dynamic>>[].obs;
  final selectedPackage = Rx<Map<String, dynamic>?>(null);
  final isLoading = false.obs;
  final currentVendorPackage = Rx<Map<String, dynamic>?>(null);
  final hasPackage = false.obs;

  @override
  void onInit() {
    super.onInit();
    print('');
    print('========================================');
    print('🎯 PACKAGE SUBSCRIPTION CONTROLLER: Init');
    print('========================================');
    loadPackages();
    loadCurrentPackage();
  }

  /// Load all available packages
  Future<void> loadPackages() async {
    print('');
    print('📦 Loading packages...');
    isLoading.value = true;

    try {
      final response = await PackageService.getPackages();

      if (response.success && response.data != null) {
        final packagesData = response.data!['packages'] as List?;

        if (packagesData != null) {
          packages.value = packagesData
              .map((e) => e as Map<String, dynamic>)
              .toList();
          print('✅ Loaded ${packages.length} packages');
        }
      } else {
        print('❌ Failed to load packages: ${response.message}');
        Get.snackbar(
          'Erreur',
          response.message ?? 'Impossible de charger les packages',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('💥 Exception loading packages: $e');
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load current vendor package
  Future<void> loadCurrentPackage() async {
    print('');
    print('📊 Loading current package...');

    try {
      final response = await PackageService.getCurrentPackage();

      if (response.success && response.data != null) {
        hasPackage.value = response.data!['has_package'] ?? false;

        if (hasPackage.value) {
          currentVendorPackage.value = response.data!['vendor_package'];
          print('✅ Current package loaded');
          print('  └─ Storage used: ${currentVendorPackage.value!['storage_used_mb']} MB');
          print('  └─ Storage total: ${currentVendorPackage.value!['storage_total_mb']} MB');
        } else {
          print('ℹ️ No active package');
        }
      }
    } catch (e) {
      print('💥 Exception loading current package: $e');
      // Don't show error to user, just log it
    }
  }

  /// Select a package
  void selectPackage(Map<String, dynamic> package) {
    print('');
    print('✅ Package selected: ${package['name']}');
    selectedPackage.value = package;
  }

  /// Subscribe to the selected package
  Future<void> subscribe() async {
    if (selectedPackage.value == null) {
      Get.snackbar(
        'Erreur',
        'Veuillez sélectionner un package',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    print('');
    print('========================================');
    print('💳 Subscribing to package...');
    print('  └─ Package: ${selectedPackage.value!['name']}');
    print('========================================');

    isLoading.value = true;

    try {
      final packageId = selectedPackage.value!['id'] as int;
      final response = await PackageService.subscribeToPackage(packageId);

      if (response.success) {
        print('✅ Subscription successful!');

        Get.snackbar(
          'Succès',
          'Abonnement au package ${selectedPackage.value!['name']} effectué avec succès!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppThemeSystem.successColor,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );

        // Wait a bit for the snackbar to be visible
        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate back to vendor dashboard
        Get.offAllNamed('/vendor-dashboard');
      } else {
        print('❌ Subscription failed: ${response.message}');

        Get.snackbar(
          'Erreur',
          response.message ?? 'Impossible de souscrire au package',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppThemeSystem.errorColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('💥 Exception during subscription: $e');

      Get.snackbar(
        'Erreur',
        'Une erreur est survenue: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppThemeSystem.errorColor,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh packages
  Future<void> refreshPackages() async {
    await loadPackages();
    await loadCurrentPackage();
  }
}
