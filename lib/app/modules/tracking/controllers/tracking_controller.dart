import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/storage_service.dart';

class TrackingController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  final RxList<Map<String, dynamic>> shipments = <Map<String, dynamic>>[].obs;
  final RxString selectedFilter = 'Tous'.obs;
  final RxString searchQuery = ''.obs;

  final List<String> filters = ['Tous', 'En cours', 'Livré', 'Annulé'];

  @override
  void onInit() {
    super.onInit();
    // Charger les expéditions uniquement si l'utilisateur est connecté
    if (StorageService.isAuthenticated) {
      _loadShipments();
    }
    searchController.addListener(() {
      searchQuery.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  void _loadShipments() {
    shipments.value = [
      {
        'id': 'CMD-001',
        'productName': 'T-shirt Design Artistique',
        'productImage': 'assets/images/p1.jpeg',
        'status': 'En cours',
        'statusColor': 0xFF3B82F6, // Blue
        'orderDate': '15 Mars 2026',
        'estimatedDelivery': '18 Mars 2026',
        'currentLocation': 'Centre de tri - Douala',
        'trackingSteps': [
          {'title': 'Commande confirmée', 'date': '15 Mars, 10:30', 'completed': true},
          {'title': 'En cours de préparation', 'date': '15 Mars, 14:20', 'completed': true},
          {'title': 'Expédiée', 'date': '16 Mars, 09:15', 'completed': true},
          {'title': 'En transit', 'date': '16 Mars, 15:00', 'completed': true},
          {'title': 'Livraison en cours', 'date': 'Aujourd\'hui', 'completed': false},
          {'title': 'Livrée', 'date': 'En attente', 'completed': false},
        ],
        'seller': 'Boutique Fashion',
        'price': '15 000 FCFA',
        'deliveryAddress': 'Douala, Bonapriso - Rue des Cocotiers',
      },
      {
        'id': 'CMD-002',
        'productName': 'Casque Audio Bluetooth',
        'productImage': 'assets/images/p4.jpeg',
        'status': 'Livré',
        'statusColor': 0xFF10B981, // Green
        'orderDate': '12 Mars 2026',
        'estimatedDelivery': '14 Mars 2026',
        'deliveredDate': '14 Mars 2026',
        'currentLocation': 'Livré',
        'trackingSteps': [
          {'title': 'Commande confirmée', 'date': '12 Mars, 11:00', 'completed': true},
          {'title': 'En cours de préparation', 'date': '12 Mars, 16:30', 'completed': true},
          {'title': 'Expédiée', 'date': '13 Mars, 08:00', 'completed': true},
          {'title': 'En transit', 'date': '13 Mars, 14:30', 'completed': true},
          {'title': 'Livraison en cours', 'date': '14 Mars, 09:00', 'completed': true},
          {'title': 'Livrée', 'date': '14 Mars, 11:20', 'completed': true},
        ],
        'seller': 'Tech Store',
        'price': '28 000 FCFA',
        'deliveryAddress': 'Yaoundé, Bastos - Avenue Kennedy',
      },
      {
        'id': 'CMD-003',
        'productName': 'Sneakers Sport Premium',
        'productImage': 'assets/images/p2.jpeg',
        'status': 'En cours',
        'statusColor': 0xFF3B82F6, // Blue
        'orderDate': '14 Mars 2026',
        'estimatedDelivery': '17 Mars 2026',
        'currentLocation': 'En préparation',
        'trackingSteps': [
          {'title': 'Commande confirmée', 'date': '14 Mars, 15:45', 'completed': true},
          {'title': 'En cours de préparation', 'date': 'En cours', 'completed': false},
          {'title': 'Expédiée', 'date': 'En attente', 'completed': false},
          {'title': 'En transit', 'date': 'En attente', 'completed': false},
          {'title': 'Livraison en cours', 'date': 'En attente', 'completed': false},
          {'title': 'Livrée', 'date': 'En attente', 'completed': false},
        ],
        'seller': 'Sports Plus',
        'price': '35 000 FCFA',
        'deliveryAddress': 'Douala, Akwa - Rue Joffre',
      },
      {
        'id': 'CMD-004',
        'productName': 'Sac à Main Cuir',
        'productImage': 'assets/images/p5.jpeg',
        'status': 'Annulé',
        'statusColor': 0xFFEF4444, // Red
        'orderDate': '10 Mars 2026',
        'estimatedDelivery': '13 Mars 2026',
        'cancelledDate': '11 Mars 2026',
        'currentLocation': 'Annulé',
        'trackingSteps': [
          {'title': 'Commande confirmée', 'date': '10 Mars, 09:30', 'completed': true},
          {'title': 'Annulée', 'date': '11 Mars, 10:00', 'completed': true},
        ],
        'seller': 'Luxury Bags',
        'price': '32 000 FCFA',
        'cancelReason': 'Produit non disponible',
      },
      {
        'id': 'CMD-005',
        'productName': 'Montre Élégante',
        'productImage': 'assets/images/p3.jpeg',
        'status': 'Livré',
        'statusColor': 0xFF10B981, // Green
        'orderDate': '08 Mars 2026',
        'estimatedDelivery': '10 Mars 2026',
        'deliveredDate': '10 Mars 2026',
        'currentLocation': 'Livré',
        'trackingSteps': [
          {'title': 'Commande confirmée', 'date': '08 Mars, 13:20', 'completed': true},
          {'title': 'En cours de préparation', 'date': '08 Mars, 17:00', 'completed': true},
          {'title': 'Expédiée', 'date': '09 Mars, 07:30', 'completed': true},
          {'title': 'En transit', 'date': '09 Mars, 13:45', 'completed': true},
          {'title': 'Livraison en cours', 'date': '10 Mars, 08:30', 'completed': true},
          {'title': 'Livrée', 'date': '10 Mars, 10:15', 'completed': true},
        ],
        'seller': 'Time Boutique',
        'price': '45 000 FCFA',
        'deliveryAddress': 'Bafoussam, Centre-ville',
      },
    ];
  }

  List<Map<String, dynamic>> get filteredShipments {
    var results = shipments.toList();

    // Filtrer par statut
    if (selectedFilter.value != 'Tous') {
      results = results.where((shipment) => shipment['status'] == selectedFilter.value).toList();
    }

    // Filtrer par numéro de commande/suivi
    if (searchQuery.value.isNotEmpty) {
      results = results.where((shipment) {
        final id = shipment['id'].toString().toLowerCase();
        final productName = shipment['productName'].toString().toLowerCase();
        final query = searchQuery.value.toLowerCase();
        return id.contains(query) || productName.contains(query);
      }).toList();
    }

    return results;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
  }

  void selectFilter(String filter) {
    selectedFilter.value = filter;
  }

  void openShipmentDetails(Map<String, dynamic> shipment) {
    // Cette méthode sera utilisée par la vue pour ouvrir les détails
    // La vue gère l'affichage du bottom sheet
  }

  void contactSupport() {
    Get.snackbar(
      'Support',
      'Fonction de contact support en cours de développement',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
