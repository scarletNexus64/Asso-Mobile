/// Statut de commande client
enum CustomerOrderStatus {
  pending,
  confirmed,
  preparing,
  shipped,
  delivered,
  cancelled,
}

extension CustomerOrderStatusExtension on CustomerOrderStatus {
  String get label {
    switch (this) {
      case CustomerOrderStatus.pending:
        return 'En attente';
      case CustomerOrderStatus.confirmed:
        return 'Confirmée';
      case CustomerOrderStatus.preparing:
        return 'En préparation';
      case CustomerOrderStatus.shipped:
        return 'Expédiée';
      case CustomerOrderStatus.delivered:
        return 'Livrée';
      case CustomerOrderStatus.cancelled:
        return 'Annulée';
    }
  }

  String get icon {
    switch (this) {
      case CustomerOrderStatus.pending:
        return '⏳';
      case CustomerOrderStatus.confirmed:
        return '✅';
      case CustomerOrderStatus.preparing:
        return '📦';
      case CustomerOrderStatus.shipped:
        return '🚚';
      case CustomerOrderStatus.delivered:
        return '✨';
      case CustomerOrderStatus.cancelled:
        return '❌';
    }
  }
}

/// Article de commande
class CustomerOrderItem {
  final String productId;
  final String productName;
  final String? productImage;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  CustomerOrderItem({
    required this.productId,
    required this.productName,
    this.productImage,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });
}

/// Commande client
class CustomerOrder {
  final String id;
  final CustomerOrderStatus status;
  final List<CustomerOrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final DateTime orderDate;
  final DateTime? deliveryDate;
  final String deliveryAddress;
  final String? trackingNumber;
  final String? deliveryPersonName;
  final String? deliveryPersonPhone;

  CustomerOrder({
    required this.id,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.orderDate,
    this.deliveryDate,
    required this.deliveryAddress,
    this.trackingNumber,
    this.deliveryPersonName,
    this.deliveryPersonPhone,
  });
}
