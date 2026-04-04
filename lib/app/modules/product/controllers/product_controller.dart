import 'dart:math';
import 'package:get/get.dart';
import '../../../data/providers/conversation_service.dart';

class ProductController extends GetxController {
  final RxInt currentImageIndex = 0.obs;
  final RxBool isFavorite = false.obs;

  // Pour la commande
  final RxBool withDelivery = false.obs;
  final RxBool isLoadingLocation = false.obs;
  final RxString currentLocation = 'Récupération de votre position...'.obs;
  final RxDouble deliveryPrice = 2000.0.obs;
  final RxBool isStartingConversation = false.obs;

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

  /// Générer un message initial aléatoire concernant le produit
  String _generateInitialMessage(String productName) {
    final messages = [
      'Bonjour, cet article est-il toujours disponible ?',
      'Bonjour, je suis intéressé(e) par cet article. Est-il disponible ?',
      'Bonjour, le produit est-il encore disponible ?',
      'Bonjour, puis-je avoir plus d\'informations sur cet article ?',
      'Bonjour, ce produit est-il toujours en vente ?',
      'Bonjour, est-ce que cet article est disponible ?',
    ];

    // Choisir un message aléatoire
    final random = Random();
    return messages[random.nextInt(messages.length)];
  }

  /// Ouvrir une conversation avec le vendeur concernant ce produit
  Future<void> openConversationWithSeller({
    required Map<String, dynamic> product,
  }) async {
    if (isStartingConversation.value) return;

    try {
      isStartingConversation.value = true;

      // Extraire les informations nécessaires
      final seller = product['seller'] as Map<String, dynamic>?;
      final sellerId = int.tryParse(seller?['id']?.toString() ?? '');
      final productId = int.tryParse(product['id']?.toString() ?? '');
      final productName = product['name']?.toString() ?? 'le produit';

      if (sellerId == null) {
        Get.snackbar(
          'Erreur',
          'Impossible d\'identifier le vendeur',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Démarrer ou récupérer la conversation
      final response = await ConversationService.startConversation(
        userId: sellerId,
        productId: productId,
      );

      if (response.success && response.data != null) {
        // Extraire la conversation du body
        final conversation = response.data!['conversation'] ?? response.data!;
        final conversationId = int.tryParse(
          (conversation['id'] ?? conversation['conversation_id'] ?? '').toString(),
        );

        if (conversationId != null) {
          // Envoyer automatiquement le premier message avec le produit taggué
          final initialMessage = _generateInitialMessage(productName);

          try {
            await ConversationService.sendMessage(
              conversationId,
              initialMessage,
              productId: productId, // Taguer le produit dans le message
            );
          } catch (e) {
            // Si l'envoi du message échoue, on continue quand même vers le chat
            // L'utilisateur pourra envoyer manuellement
          }
        }

        // Naviguer vers chatdetail avec les infos de conversation
        Get.toNamed(
          '/chatdetail',
          arguments: {
            'id': conversation['id'] ?? conversation['conversation_id'] ?? '',
            'name': seller?['name'] ?? 'Vendeur',
            'avatar': seller?['avatar'] ?? 'V',
            'isOnline': false,
            'product': product,
          },
        );
      } else {
        Get.snackbar(
          'Erreur',
          response.message.isNotEmpty ? response.message : 'Impossible de démarrer la conversation',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue lors de l\'ouverture de la conversation',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isStartingConversation.value = false;
    }
  }
}
