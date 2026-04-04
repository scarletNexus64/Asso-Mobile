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

  factory CustomerOrderItem.fromMap(Map<String, dynamic> map) {
    return CustomerOrderItem(
      productId: (map['product_id'] ?? map['id'] ?? '').toString(),
      productName: map['product']?['name'] ?? 'Produit',
      productImage: map['product']?['main_image'],
      quantity: map['quantity'] ?? 1,
      unitPrice: double.tryParse(map['unit_price']?.toString() ?? '0') ?? 0,
      totalPrice: double.tryParse(map['total_price']?.toString() ?? '0') ?? 0,
    );
  }
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

  factory CustomerOrder.fromMap(Map<String, dynamic> map) {
    final statusStr = map['status']?.toString() ?? 'pending';
    return CustomerOrder(
      id: (map['id'] ?? '').toString(),
      status: _parseStatus(statusStr),
      items: (map['items'] as List?)?.map((i) => CustomerOrderItem.fromMap(Map<String, dynamic>.from(i))).toList() ?? [],
      subtotal: double.tryParse(map['subtotal']?.toString() ?? '0') ?? 0,
      deliveryFee: double.tryParse(map['delivery_fee']?.toString() ?? '0') ?? 0,
      total: double.tryParse(map['total']?.toString() ?? '0') ?? 0,
      orderDate: DateTime.tryParse(map['created_at'] ?? '') ?? DateTime.now(),
      deliveryDate: map['delivered_at'] != null ? DateTime.tryParse(map['delivered_at']) : null,
      deliveryAddress: map['delivery_address'] ?? '',
      trackingNumber: map['tracking_number'],
      deliveryPersonName: map['delivery_person'] != null ? '${map['delivery_person']['first_name']} ${map['delivery_person']['last_name']}' : null,
      deliveryPersonPhone: map['delivery_person']?['phone'],
    );
  }

  static CustomerOrderStatus _parseStatus(String status) {
    switch (status) {
      case 'pending': return CustomerOrderStatus.pending;
      case 'confirmed': return CustomerOrderStatus.confirmed;
      case 'preparing': return CustomerOrderStatus.preparing;
      case 'shipped': return CustomerOrderStatus.shipped;
      case 'delivered': return CustomerOrderStatus.delivered;
      case 'cancelled': return CustomerOrderStatus.cancelled;
      default: return CustomerOrderStatus.pending;
    }
  }
}
