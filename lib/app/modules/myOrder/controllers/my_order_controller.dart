import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/customer_order_models.dart';

class MyOrderController extends GetxController {
  // Liste de toutes les commandes
  final allOrders = <CustomerOrder>[].obs;

  // Liste filtrée
  final filteredOrders = <CustomerOrder>[].obs;

  // Filtre actuel
  final selectedStatus = Rx<CustomerOrderStatus?>(null);

  // État de chargement
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadOrders();

    // Écouter les changements de filtre
    ever(selectedStatus, (_) => _applyFilter());
  }

  /// Charge les commandes
  Future<void> loadOrders() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Générer des données de test
      allOrders.value = _generateMockOrders();

      // Appliquer le filtre
      _applyFilter();
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

  /// Applique le filtre
  void _applyFilter() {
    var orders = allOrders.toList();

    if (selectedStatus.value != null) {
      orders = orders.where((o) => o.status == selectedStatus.value).toList();
    }

    // Trier par date (plus récent en premier)
    orders.sort((a, b) => b.orderDate.compareTo(a.orderDate));

    filteredOrders.value = orders;
  }

  /// Génère des commandes de test
  List<CustomerOrder> _generateMockOrders() {
    final now = DateTime.now();
    final List<CustomerOrder> orders = [];

    // Commande livrée
    orders.add(CustomerOrder(
      id: 'CMD001',
      status: CustomerOrderStatus.delivered,
      items: [
        CustomerOrderItem(
          productId: 'P1',
          productName: 'iPhone 15 Pro',
          quantity: 1,
          unitPrice: 850000,
          totalPrice: 850000,
        ),
        CustomerOrderItem(
          productId: 'P2',
          productName: 'AirPods Pro',
          quantity: 1,
          unitPrice: 180000,
          totalPrice: 180000,
        ),
      ],
      subtotal: 1030000,
      deliveryFee: 2500,
      total: 1032500,
      orderDate: now.subtract(const Duration(days: 7)),
      deliveryDate: now.subtract(const Duration(days: 5)),
      deliveryAddress: 'Akwa, Douala',
      trackingNumber: 'TRK123456',
      deliveryPersonName: 'Jean Martin',
      deliveryPersonPhone: '+237 670 00 00 00',
    ));

    // Commande en cours de livraison
    orders.add(CustomerOrder(
      id: 'CMD002',
      status: CustomerOrderStatus.shipped,
      items: [
        CustomerOrderItem(
          productId: 'P3',
          productName: 'MacBook Air M2',
          quantity: 1,
          unitPrice: 920000,
          totalPrice: 920000,
        ),
      ],
      subtotal: 920000,
      deliveryFee: 3000,
      total: 923000,
      orderDate: now.subtract(const Duration(days: 2)),
      deliveryAddress: 'Bonamoussadi, Douala',
      trackingNumber: 'TRK789012',
      deliveryPersonName: 'Marie Dubois',
      deliveryPersonPhone: '+237 680 00 00 00',
    ));

    // Commande en préparation
    orders.add(CustomerOrder(
      id: 'CMD003',
      status: CustomerOrderStatus.preparing,
      items: [
        CustomerOrderItem(
          productId: 'P4',
          productName: 'Samsung Galaxy S24',
          quantity: 2,
          unitPrice: 650000,
          totalPrice: 1300000,
        ),
      ],
      subtotal: 1300000,
      deliveryFee: 2500,
      total: 1302500,
      orderDate: now.subtract(const Duration(hours: 12)),
      deliveryAddress: 'Bonapriso, Douala',
    ));

    // Commande confirmée
    orders.add(CustomerOrder(
      id: 'CMD004',
      status: CustomerOrderStatus.confirmed,
      items: [
        CustomerOrderItem(
          productId: 'P5',
          productName: 'Sony WH-1000XM5',
          quantity: 1,
          unitPrice: 280000,
          totalPrice: 280000,
        ),
      ],
      subtotal: 280000,
      deliveryFee: 1500,
      total: 281500,
      orderDate: now.subtract(const Duration(hours: 3)),
      deliveryAddress: 'Logbaba, Douala',
    ));

    // Commande en attente
    orders.add(CustomerOrder(
      id: 'CMD005',
      status: CustomerOrderStatus.pending,
      items: [
        CustomerOrderItem(
          productId: 'P6',
          productName: 'iPad Pro 11"',
          quantity: 1,
          unitPrice: 720000,
          totalPrice: 720000,
        ),
      ],
      subtotal: 720000,
      deliveryFee: 2000,
      total: 722000,
      orderDate: now.subtract(const Duration(minutes: 30)),
      deliveryAddress: 'Kotto, Douala',
    ));

    return orders;
  }

  /// Annule une commande
  Future<void> cancelOrder(String orderId) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Annuler la commande'),
          content: const Text('Êtes-vous sûr de vouloir annuler cette commande ?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Non'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Oui', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // TODO: Appel API pour annuler
      await Future.delayed(const Duration(milliseconds: 300));

      Get.snackbar(
        'Succès',
        'Commande annulée',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      await loadOrders();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'annuler la commande',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Ouvre le suivi de commande
  void trackOrder(String orderId) {
    Get.toNamed('/tracking', arguments: {'orderId': orderId});
  }

  /// Contacter le livreur
  void contactDelivery(String phone) {
    Get.snackbar(
      'Appel',
      'Appel vers $phone',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
