import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../models/cameroon_cities.dart';

class OrderManagementController extends GetxController {
  // Liste complète des commandes
  final RxList<OrderModel> allOrders = <OrderModel>[].obs;

  // Liste filtrée des commandes
  final RxList<OrderModel> filteredOrders = <OrderModel>[].obs;

  // Filtres
  final Rx<OrderStatus?> selectedStatus = Rx<OrderStatus?>(null);
  final RxString selectedCity = 'Toutes les villes'.obs;
  final Rx<DateTime?> selectedDate = Rx<DateTime?>(null);

  // État de chargement
  final RxBool isLoading = false.obs;

  // Recherche
  final RxString searchQuery = ''.obs;
  final searchController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadOrders();

    // Écouter les changements de filtres
    ever(selectedStatus, (_) => applyFilters());
    ever(selectedCity, (_) => applyFilters());
    ever(selectedDate, (_) => applyFilters());
    ever(searchQuery, (_) => applyFilters());
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  /// Charge les commandes (pour l'instant des données de test)
  Future<void> loadOrders() async {
    isLoading.value = true;

    try {
      // Simuler un délai de chargement
      await Future.delayed(const Duration(milliseconds: 500));

      // Données de test
      allOrders.value = _generateMockOrders();
      applyFilters();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les commandes',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Applique les filtres
  void applyFilters() {
    var orders = allOrders.toList();

    // Filtre par statut
    if (selectedStatus.value != null) {
      orders = orders.where((order) => order.status == selectedStatus.value).toList();
    }

    // Filtre par ville
    if (selectedCity.value != 'Toutes les villes') {
      orders = orders.where((order) => order.city == selectedCity.value).toList();
    }

    // Filtre par date
    if (selectedDate.value != null) {
      orders = orders.where((order) {
        return order.orderDate.year == selectedDate.value!.year &&
               order.orderDate.month == selectedDate.value!.month &&
               order.orderDate.day == selectedDate.value!.day;
      }).toList();
    }

    // Filtre par recherche
    if (searchQuery.value.isNotEmpty) {
      final query = searchQuery.value.toLowerCase();
      orders = orders.where((order) {
        return order.clientName.toLowerCase().contains(query) ||
               order.id.toLowerCase().contains(query) ||
               order.clientPhone.contains(query);
      }).toList();
    }

    filteredOrders.value = orders;
  }

  /// Réinitialise tous les filtres
  void resetFilters() {
    selectedStatus.value = null;
    selectedCity.value = 'Toutes les villes';
    selectedDate.value = null;
    searchQuery.value = '';
    searchController.clear();
  }

  /// Valide une commande
  Future<void> validateOrder(OrderModel order) async {
    try {
      // Afficher un dialogue de confirmation
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Valider la commande'),
          content: Text(
            'Voulez-vous valider la commande #${order.id} de ${order.clientName} ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Valider'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        isLoading.value = true;

        // TODO: Appel API pour valider la commande
        await Future.delayed(const Duration(milliseconds: 500));

        // Mettre à jour la commande
        final index = allOrders.indexWhere((o) => o.id == order.id);
        if (index != -1) {
          allOrders[index] = order.copyWith(
            status: OrderStatus.validated,
            validatedDate: DateTime.now(),
          );
          applyFilters();
        }

        Get.snackbar(
          'Succès',
          'Commande validée avec succès',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de valider la commande',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Annule une commande
  Future<void> cancelOrder(OrderModel order) async {
    try {
      // Demander la raison de l'annulation
      final reasonController = TextEditingController();
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Annuler la commande'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Voulez-vous annuler la commande #${order.id} de ${order.clientName} ?',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Raison de l\'annulation',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Non'),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Annuler la commande'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        isLoading.value = true;

        // TODO: Appel API pour annuler la commande
        await Future.delayed(const Duration(milliseconds: 500));

        // Mettre à jour la commande
        final index = allOrders.indexWhere((o) => o.id == order.id);
        if (index != -1) {
          allOrders[index] = order.copyWith(
            status: OrderStatus.cancelled,
            cancelledDate: DateTime.now(),
            cancelReason: reasonController.text,
          );
          applyFilters();
        }

        Get.snackbar(
          'Succès',
          'Commande annulée',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }

      reasonController.dispose();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'annuler la commande',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Ouvre la conversation avec le client
  void openChat(OrderModel order) {
    // TODO: Implémenter l'ouverture du chat
    Get.snackbar(
      'Chat',
      'Conversation avec ${order.clientName}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Contacter un livreur
  void contactDelivery(OrderModel order) {
    // TODO: Implémenter la sélection d'un livreur
    Get.snackbar(
      'Livreur',
      'Fonctionnalité en cours de développement',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Afficher les détails d'une commande
  void showOrderDetails(OrderModel order) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Commande #${order.id}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text('Client: ${order.clientName}'),
            Text('Téléphone: ${order.clientPhone}'),
            Text('Ville: ${order.city}'),
            Text('Adresse: ${order.address}'),
            const SizedBox(height: 16),
            const Text(
              'Articles:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('• ${item.productName} x${item.quantity} - ${item.totalPrice} XAF'),
            )),
            const SizedBox(height: 16),
            Text(
              'Total: ${order.totalAmount} XAF',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Génère des commandes de test
  List<OrderModel> _generateMockOrders() {
    final cities = ['Yaoundé', 'Douala', 'Bafoussam', 'Garoua', 'Bamenda'];
    final statuses = [OrderStatus.pending, OrderStatus.validated, OrderStatus.cancelled];
    final names = ['Jean Dupont', 'Marie Claire', 'Paul Kamga', 'Fatima Bello', 'André Tchuente'];

    return List.generate(20, (index) {
      final city = cities[index % cities.length];
      final status = statuses[index % statuses.length];
      final name = names[index % names.length];
      final date = DateTime.now().subtract(Duration(days: index));

      return OrderModel(
        id: 'CMD${1000 + index}',
        clientId: 'client_$index',
        clientName: name,
        clientPhone: '+237 6${70000000 + index}',
        clientAvatar: '',
        items: [
          OrderItem(
            productId: 'prod_1',
            productName: 'Smartphone Galaxy A54',
            quantity: 1,
            unitPrice: 250000,
            totalPrice: 250000,
          ),
          OrderItem(
            productId: 'prod_2',
            productName: 'Écouteurs Bluetooth',
            quantity: 2,
            unitPrice: 15000,
            totalPrice: 30000,
          ),
        ],
        totalAmount: 280000 + (index * 1000),
        status: status,
        city: city,
        address: '${index + 1} Avenue de la République, $city',
        orderDate: date,
        validatedDate: status == OrderStatus.validated ? date.add(const Duration(hours: 2)) : null,
        cancelledDate: status == OrderStatus.cancelled ? date.add(const Duration(hours: 1)) : null,
        cancelReason: status == OrderStatus.cancelled ? 'Produit non disponible' : null,
      );
    });
  }

  /// Obtient le nombre de commandes par statut
  int getOrderCountByStatus(OrderStatus status) {
    return allOrders.where((order) => order.status == status).length;
  }

  /// Obtient les villes disponibles
  List<String> get availableCities => CameroonCities.all;
}
