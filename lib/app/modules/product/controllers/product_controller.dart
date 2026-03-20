import 'package:get/get.dart';

class ProductController extends GetxController {
  final RxInt currentImageIndex = 0.obs;
  final RxBool isFavorite = false.obs;

  // Pour la commande
  final RxBool withDelivery = false.obs;
  final RxBool isLoadingLocation = false.obs;
  final RxString currentLocation = 'Récupération de votre position...'.obs;
  final RxDouble deliveryPrice = 2000.0.obs;

  void toggleFavorite() {
    isFavorite.value = !isFavorite.value;
    Get.snackbar(
      isFavorite.value ? 'Ajouté aux favoris' : 'Retiré des favoris',
      isFavorite.value
          ? 'Ce produit a été ajouté à vos favoris'
          : 'Ce produit a été retiré de vos favoris',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void toggleDelivery() {
    withDelivery.value = !withDelivery.value;
  }

  Future<void> fetchCurrentLocation() async {
    isLoadingLocation.value = true;
    currentLocation.value = 'Récupération de votre position...';

    // Simuler la récupération GPS
    await Future.delayed(Duration(seconds: 2));

    isLoadingLocation.value = false;
    currentLocation.value = 'Douala, Bonapriso - Rue des Cocotiers';
  }

  double calculateTotal(double productPrice) {
    if (withDelivery.value) {
      return productPrice + deliveryPrice.value;
    }
    return productPrice;
  }
}
