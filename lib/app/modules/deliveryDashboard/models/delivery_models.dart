import 'package:latlong2/latlong.dart';

/// Statut de livraison
enum DeliveryStatus {
  pending, // En attente
  inProgress, // En cours
  delivered, // Livré
  cancelled, // Annulé
}

extension DeliveryStatusExtension on DeliveryStatus {
  String get label {
    switch (this) {
      case DeliveryStatus.pending:
        return 'En attente';
      case DeliveryStatus.inProgress:
        return 'En cours';
      case DeliveryStatus.delivered:
        return 'Livré';
      case DeliveryStatus.cancelled:
        return 'Annulé';
    }
  }

  String get icon {
    switch (this) {
      case DeliveryStatus.pending:
        return '⏳';
      case DeliveryStatus.inProgress:
        return '🚚';
      case DeliveryStatus.delivered:
        return '✅';
      case DeliveryStatus.cancelled:
        return '❌';
    }
  }
}

/// Demande de livraison
class DeliveryRequest {
  final String id;
  final String orderId;
  final DeliveryStatus status;
  final String customerName;
  final String customerPhone;
  final String pickupAddress;
  final LatLng pickupLocation;
  final String deliveryAddress;
  final LatLng deliveryLocation;
  final double distance; // en km
  final double commission; // Commission en XAF
  final DateTime requestDate;
  final DateTime? acceptedDate;
  final DateTime? deliveredDate;
  final String? notes;

  DeliveryRequest({
    required this.id,
    required this.orderId,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.pickupAddress,
    required this.pickupLocation,
    required this.deliveryAddress,
    required this.deliveryLocation,
    required this.distance,
    required this.commission,
    required this.requestDate,
    this.acceptedDate,
    this.deliveredDate,
    this.notes,
  });

  factory DeliveryRequest.fromJson(Map<String, dynamic> json) {
    return DeliveryRequest(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      status: DeliveryStatus.values.firstWhere(
        (e) => e.toString() == 'DeliveryStatus.${json['status']}',
      ),
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String,
      pickupAddress: json['pickupAddress'] as String,
      pickupLocation: LatLng(
        json['pickupLatitude'] as double,
        json['pickupLongitude'] as double,
      ),
      deliveryAddress: json['deliveryAddress'] as String,
      deliveryLocation: LatLng(
        json['deliveryLatitude'] as double,
        json['deliveryLongitude'] as double,
      ),
      distance: (json['distance'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      requestDate: DateTime.parse(json['requestDate'] as String),
      acceptedDate: json['acceptedDate'] != null
          ? DateTime.parse(json['acceptedDate'] as String)
          : null,
      deliveredDate: json['deliveredDate'] != null
          ? DateTime.parse(json['deliveredDate'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'status': status.toString().split('.').last,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'pickupAddress': pickupAddress,
      'pickupLatitude': pickupLocation.latitude,
      'pickupLongitude': pickupLocation.longitude,
      'deliveryAddress': deliveryAddress,
      'deliveryLatitude': deliveryLocation.latitude,
      'deliveryLongitude': deliveryLocation.longitude,
      'distance': distance,
      'commission': commission,
      'requestDate': requestDate.toIso8601String(),
      'acceptedDate': acceptedDate?.toIso8601String(),
      'deliveredDate': deliveredDate?.toIso8601String(),
      'notes': notes,
    };
  }
}

/// Statistiques du livreur
class DeliveryStats {
  final int totalDeliveries;
  final int pendingDeliveries;
  final int inProgressDeliveries;
  final int completedDeliveries;
  final int cancelledDeliveries;
  final double totalCommissions;
  final double todayCommissions;
  final double averageRating;

  DeliveryStats({
    required this.totalDeliveries,
    required this.pendingDeliveries,
    required this.inProgressDeliveries,
    required this.completedDeliveries,
    required this.cancelledDeliveries,
    required this.totalCommissions,
    required this.todayCommissions,
    required this.averageRating,
  });

  factory DeliveryStats.fromJson(Map<String, dynamic> json) {
    return DeliveryStats(
      totalDeliveries: json['totalDeliveries'] as int,
      pendingDeliveries: json['pendingDeliveries'] as int,
      inProgressDeliveries: json['inProgressDeliveries'] as int,
      completedDeliveries: json['completedDeliveries'] as int,
      cancelledDeliveries: json['cancelledDeliveries'] as int,
      totalCommissions: (json['totalCommissions'] as num).toDouble(),
      todayCommissions: (json['todayCommissions'] as num).toDouble(),
      averageRating: (json['averageRating'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalDeliveries': totalDeliveries,
      'pendingDeliveries': pendingDeliveries,
      'inProgressDeliveries': inProgressDeliveries,
      'completedDeliveries': completedDeliveries,
      'cancelledDeliveries': cancelledDeliveries,
      'totalCommissions': totalCommissions,
      'todayCommissions': todayCommissions,
      'averageRating': averageRating,
    };
  }
}
