import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/product_service.dart';
import '../../../data/providers/auth_service.dart';

class FavoritesController extends GetxController {
  final RxList<Map<String, dynamic>> favorites = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  int _currentPage = 1;

  // Préférences utilisateur
  final pushNotifications = true.obs;
  final emailNotifications = true.obs;
  final notificationSounds = true.obs;
  final themeMode = 'light'.obs;
  final language = 'fr'.obs;
  final locationSharing = false.obs;
  final analytics = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadFavorites();
  }

  Future<void> loadFavorites({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      hasMore.value = true;
    }

    isLoading.value = true;

    try {
      final response = await ProductService.getFavorites(page: _currentPage);

      if (response.success && response.data != null) {
        final products = response.data!['products'] as List? ?? [];
        final pagination = response.data!['pagination'] as Map<String, dynamic>? ?? {};

        if (refresh || _currentPage == 1) {
          favorites.value = products.map((p) => Map<String, dynamic>.from(p)).toList();
        } else {
          favorites.addAll(products.map((p) => Map<String, dynamic>.from(p)));
        }

        hasMore.value = pagination['has_more'] ?? false;
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de charger les favoris',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFavorite(int productId) async {
    try {
      final response = await ProductService.toggleFavorite(productId);

      if (response.success) {
        final isFav = response.data?['is_favorite'] ?? false;
        if (!isFav) {
          favorites.removeWhere((p) => p['id'] == productId);
        }

        Get.snackbar(
          isFav ? 'Ajouté' : 'Retiré',
          response.data?['message'] ?? (isFav ? 'Ajouté aux favoris' : 'Retiré des favoris'),
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.primary,
          colorText: Get.theme.colorScheme.onPrimary,
          duration: const Duration(seconds: 2),
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de modifier les favoris',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    }
  }

  void onProductTap(Map<String, dynamic> product) {
    Get.toNamed('/product', arguments: product);
  }

  /// Sauvegarde les préférences utilisateur
  Future<void> savePreferences() async {
    try {
      isLoading.value = true;
      final response = await AuthService.updatePreferences({
        'push_notifications': pushNotifications.value,
        'email_notifications': emailNotifications.value,
        'notification_sounds': notificationSounds.value,
        'theme_mode': themeMode.value,
        'language': language.value,
        'location_sharing': locationSharing.value,
        'analytics': analytics.value,
      });

      if (response.success) {
        Get.snackbar('Succès', 'Préférences sauvegardées',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      } else {
        Get.snackbar('Erreur', response.message,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
        );
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible de sauvegarder les préférences',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
