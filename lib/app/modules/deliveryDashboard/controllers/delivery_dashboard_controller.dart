import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../models/delivery_models.dart';

class DeliveryDashboardController extends GetxController {
  // Statut du livreur
  final isOnline = false.obs;

  // Position actuelle du livreur
  final currentPosition = Rx<LatLng?>(null);
  StreamSubscription<Position>? _positionStreamSubscription;

  // Liste de toutes les demandes
  final allRequests = <DeliveryRequest>[].obs;

  // Liste filtrée
  final filteredRequests = <DeliveryRequest>[].obs;

  // Filtre actuel
  final selectedStatus = Rx<DeliveryStatus?>(null);

  // Statistiques
  final stats = Rx<DeliveryStats?>(null);

  // État de chargement
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeLocation();
    loadDeliveries();

    // Écouter les changements de filtre
    ever(selectedStatus, (_) => _applyFilter());
  }

  @override
  void onClose() {
    _positionStreamSubscription?.cancel();
    super.onClose();
  }

  /// Initialise le suivi de position
  Future<void> _initializeLocation() async {
    try {
      // Obtenir la position actuelle
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      currentPosition.value = LatLng(position.latitude, position.longitude);

      // Démarrer le suivi de position
      _startLocationTracking();
    } catch (e) {
      // Position par défaut (Douala)
      currentPosition.value = const LatLng(4.0511, 9.7679);
    }
  }

  /// Démarre le suivi de position
  void _startLocationTracking() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // Mise à jour tous les 10 mètres
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) {
      currentPosition.value = LatLng(position.latitude, position.longitude);
    });
  }

  /// Charge les demandes de livraison
  Future<void> loadDeliveries() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Générer des données de test
      allRequests.value = _generateMockRequests();

      // Calculer les statistiques
      stats.value = _calculateStats();

      // Appliquer le filtre
      _applyFilter();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les demandes',
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
    var requests = allRequests.toList();

    if (selectedStatus.value != null) {
      requests = requests.where((r) => r.status == selectedStatus.value).toList();
    }

    // Trier par date (plus récent en premier)
    requests.sort((a, b) => b.requestDate.compareTo(a.requestDate));

    filteredRequests.value = requests;
  }

  /// Calcule les statistiques
  DeliveryStats _calculateStats() {
    final pending = allRequests.where((r) => r.status == DeliveryStatus.pending).length;
    final inProgress = allRequests.where((r) => r.status == DeliveryStatus.inProgress).length;
    final completed = allRequests.where((r) => r.status == DeliveryStatus.delivered).length;
    final cancelled = allRequests.where((r) => r.status == DeliveryStatus.cancelled).length;

    final totalCommissions = allRequests
        .where((r) => r.status == DeliveryStatus.delivered)
        .fold(0.0, (sum, r) => sum + r.commission);

    final today = DateTime.now();
    final todayCommissions = allRequests
        .where((r) =>
            r.status == DeliveryStatus.delivered &&
            r.deliveredDate != null &&
            r.deliveredDate!.year == today.year &&
            r.deliveredDate!.month == today.month &&
            r.deliveredDate!.day == today.day)
        .fold(0.0, (sum, r) => sum + r.commission);

    return DeliveryStats(
      totalDeliveries: allRequests.length,
      pendingDeliveries: pending,
      inProgressDeliveries: inProgress,
      completedDeliveries: completed,
      cancelledDeliveries: cancelled,
      totalCommissions: totalCommissions,
      todayCommissions: todayCommissions,
      averageRating: 4.7,
    );
  }

  /// Génère des demandes de test
  List<DeliveryRequest> _generateMockRequests() {
    final now = DateTime.now();
    final List<DeliveryRequest> requests = [];

    // Demandes en attente
    for (int i = 0; i < 3; i++) {
      requests.add(DeliveryRequest(
        id: 'DEL${1000 + i}',
        orderId: 'CMD${2000 + i}',
        status: DeliveryStatus.pending,
        customerName: ['Jean Dupont', 'Marie Martin', 'Paul Dubois'][i],
        customerPhone: '+237 6${70 + i} 00 00 00',
        pickupAddress: 'Boutique Centre-ville, Douala',
        pickupLocation: const LatLng(4.0511, 9.7679),
        deliveryAddress: ['Akwa, Douala', 'Bonamoussadi, Douala', 'Bonapriso, Douala'][i],
        deliveryLocation: LatLng(4.05 + (i * 0.01), 9.77 + (i * 0.01)),
        distance: 3.5 + i,
        commission: 1500 + (i * 500),
        requestDate: now.subtract(Duration(minutes: 10 + i * 5)),
      ));
    }

    // Demandes en cours
    for (int i = 0; i < 2; i++) {
      requests.add(DeliveryRequest(
        id: 'DEL${2000 + i}',
        orderId: 'CMD${3000 + i}',
        status: DeliveryStatus.inProgress,
        customerName: ['Sophie Laurent', 'Luc Bernard'][i],
        customerPhone: '+237 6${80 + i} 00 00 00',
        pickupAddress: 'Boutique Bepanda, Douala',
        pickupLocation: const LatLng(4.0611, 9.7579),
        deliveryAddress: ['Kotto, Douala', 'Logbaba, Douala'][i],
        deliveryLocation: LatLng(4.06 + (i * 0.02), 9.76 + (i * 0.02)),
        distance: 5.0 + i,
        commission: 2000 + (i * 500),
        requestDate: now.subtract(Duration(hours: 1 + i)),
        acceptedDate: now.subtract(Duration(minutes: 45 + i * 10)),
      ));
    }

    // Demandes livrées
    for (int i = 0; i < 5; i++) {
      requests.add(DeliveryRequest(
        id: 'DEL${3000 + i}',
        orderId: 'CMD${4000 + i}',
        status: DeliveryStatus.delivered,
        customerName: 'Client ${i + 1}',
        customerPhone: '+237 690 00 00 0$i',
        pickupAddress: 'Boutique Test, Douala',
        pickupLocation: const LatLng(4.0511, 9.7679),
        deliveryAddress: 'Adresse livraison $i',
        deliveryLocation: LatLng(4.05 + (i * 0.01), 9.77 + (i * 0.01)),
        distance: 4.0 + i,
        commission: 1800 + (i * 200),
        requestDate: now.subtract(Duration(days: i + 1, hours: 2)),
        acceptedDate: now.subtract(Duration(days: i + 1, hours: 1)),
        deliveredDate: now.subtract(Duration(days: i + 1)),
      ));
    }

    return requests;
  }

  /// Toggle le statut online/offline
  void toggleOnlineStatus() {
    isOnline.value = !isOnline.value;

    Get.snackbar(
      isOnline.value ? 'Vous êtes en ligne' : 'Vous êtes hors ligne',
      isOnline.value
          ? 'Vous pouvez recevoir des demandes de livraison'
          : 'Vous ne recevrez plus de demandes',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isOnline.value ? Colors.green : Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Accepte une demande de livraison
  Future<void> acceptRequest(String requestId) async {
    try {
      final index = allRequests.indexWhere((r) => r.id == requestId);
      if (index == -1) return;

      // TODO: Appel API pour accepter la demande

      await Future.delayed(const Duration(milliseconds: 300));

      // Mettre à jour le statut
      final request = allRequests[index];
      allRequests[index] = DeliveryRequest(
        id: request.id,
        orderId: request.orderId,
        status: DeliveryStatus.inProgress,
        customerName: request.customerName,
        customerPhone: request.customerPhone,
        pickupAddress: request.pickupAddress,
        pickupLocation: request.pickupLocation,
        deliveryAddress: request.deliveryAddress,
        deliveryLocation: request.deliveryLocation,
        distance: request.distance,
        commission: request.commission,
        requestDate: request.requestDate,
        acceptedDate: DateTime.now(),
        notes: request.notes,
      );

      stats.value = _calculateStats();
      _applyFilter();

      Get.snackbar(
        'Demande acceptée',
        'Vous pouvez maintenant commencer la livraison',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'accepter la demande',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Refuse une demande de livraison
  Future<void> rejectRequest(String requestId) async {
    try {
      final index = allRequests.indexWhere((r) => r.id == requestId);
      if (index == -1) return;

      // TODO: Appel API pour refuser la demande

      await Future.delayed(const Duration(milliseconds: 300));

      // Mettre à jour le statut
      final request = allRequests[index];
      allRequests[index] = DeliveryRequest(
        id: request.id,
        orderId: request.orderId,
        status: DeliveryStatus.cancelled,
        customerName: request.customerName,
        customerPhone: request.customerPhone,
        pickupAddress: request.pickupAddress,
        pickupLocation: request.pickupLocation,
        deliveryAddress: request.deliveryAddress,
        deliveryLocation: request.deliveryLocation,
        distance: request.distance,
        commission: request.commission,
        requestDate: request.requestDate,
        acceptedDate: request.acceptedDate,
        notes: request.notes,
      );

      stats.value = _calculateStats();
      _applyFilter();

      Get.snackbar(
        'Demande refusée',
        'La demande a été refusée',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de refuser la demande',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Marque une livraison comme terminée
  Future<void> markAsDelivered(String requestId) async {
    try {
      final index = allRequests.indexWhere((r) => r.id == requestId);
      if (index == -1) return;

      // TODO: Appel API pour marquer comme livré

      await Future.delayed(const Duration(milliseconds: 300));

      // Mettre à jour le statut
      final request = allRequests[index];
      allRequests[index] = DeliveryRequest(
        id: request.id,
        orderId: request.orderId,
        status: DeliveryStatus.delivered,
        customerName: request.customerName,
        customerPhone: request.customerPhone,
        pickupAddress: request.pickupAddress,
        pickupLocation: request.pickupLocation,
        deliveryAddress: request.deliveryAddress,
        deliveryLocation: request.deliveryLocation,
        distance: request.distance,
        commission: request.commission,
        requestDate: request.requestDate,
        acceptedDate: request.acceptedDate,
        deliveredDate: DateTime.now(),
        notes: request.notes,
      );

      stats.value = _calculateStats();
      _applyFilter();

      Get.snackbar(
        'Livraison terminée',
        'Vous avez gagné ${request.commission.toStringAsFixed(0)} XAF',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de marquer comme livré',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  /// Ouvre le chat avec le client
  void openChat(String requestId) {
    // TODO: Implémenter le chat
    Get.snackbar(
      'Chat',
      'Fonctionnalité en cours de développement',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Appelle le client
  void callCustomer(String phone) {
    // TODO: Implémenter l'appel
    Get.snackbar(
      'Appel',
      'Appel vers $phone',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Ouvre le wallet
  void openWallet() {
    // Réutiliser le wallet créé précédemment
    Get.toNamed('/wallet');
  }
}
