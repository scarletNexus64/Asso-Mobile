import 'package:get/get.dart';

class ProfileController extends GetxController {
  final RxMap<String, dynamic> userProfile = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    userProfile.value = {
      'name': 'Jean Dupont',
      'email': 'jean.dupont@email.com',
      'phone': '+237 6 XX XX XX XX',
      'avatar': 'JD',
      'memberSince': 'Membre depuis Mars 2025',
      'location': 'Douala, Cameroun',
      'stats': {
        'orders': 12,
        'reviews': 8,
        'favorites': 24,
      },
    };
  }

  void editProfile() {
    Get.snackbar(
      'Modification du profil',
      'Fonction en cours de développement',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToMyProducts() {
    Get.snackbar(
      'Mes produits',
      'Fonction en cours de développement',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToFavorites() {
    Get.toNamed('/favorites');
  }

  void goToOrders() {
    Get.snackbar(
      'Mes commandes',
      'Fonction en cours de développement',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToAddresses() {
    Get.snackbar(
      'Mes adresses',
      'Fonction en cours de développement',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToPaymentMethods() {
    Get.snackbar(
      'Moyens de paiement',
      'Fonction en cours de développement',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToSettings() {
    Get.toNamed('/settings');
  }

  void goToHelp() {
    Get.snackbar(
      'Aide & Support',
      'Fonction en cours de développement',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void goToAbout() {
    Get.snackbar(
      'À propos',
      'Asso - Version 1.0.0',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void logout() {
    Get.defaultDialog(
      title: 'Déconnexion',
      middleText: 'Êtes-vous sûr de vouloir vous déconnecter ?',
      textCancel: 'Annuler',
      textConfirm: 'Déconnexion',
      confirmTextColor: Get.theme.colorScheme.onError,
      buttonColor: Get.theme.colorScheme.error,
      onConfirm: () {
        Get.back();
        Get.offAllNamed('/login');
      },
    );
  }
}
