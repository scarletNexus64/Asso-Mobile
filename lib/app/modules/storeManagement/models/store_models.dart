import 'package:flutter/material.dart';

/// Modèle de statistiques de stockage
class StorageStats {
  final double usedSpaceGB;
  final double totalSpaceGB;
  final int totalProducts;
  final int totalImages;

  StorageStats({
    required this.usedSpaceGB,
    required this.totalSpaceGB,
    required this.totalProducts,
    required this.totalImages,
  });

  double get usagePercentage => (usedSpaceGB / totalSpaceGB) * 100;
  double get availableSpaceGB => totalSpaceGB - usedSpaceGB;
  bool get isAlmostFull => usagePercentage > 80;

  factory StorageStats.fromJson(Map<String, dynamic> json) {
    return StorageStats(
      usedSpaceGB: (json['usedSpaceGB'] as num).toDouble(),
      totalSpaceGB: (json['totalSpaceGB'] as num).toDouble(),
      totalProducts: json['totalProducts'] as int,
      totalImages: json['totalImages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'usedSpaceGB': usedSpaceGB,
      'totalSpaceGB': totalSpaceGB,
      'totalProducts': totalProducts,
      'totalImages': totalImages,
    };
  }
}

/// Modèle de certification
class Certification {
  final bool isCertified;
  final DateTime? certificationDate;
  final DateTime? expiryDate;
  final CertificationStatus status;
  final String? certificationId;

  Certification({
    required this.isCertified,
    this.certificationDate,
    this.expiryDate,
    required this.status,
    this.certificationId,
  });

  int? get daysUntilExpiry {
    if (expiryDate == null) return null;
    return expiryDate!.difference(DateTime.now()).inDays;
  }

  bool get isExpiringSoon {
    final days = daysUntilExpiry;
    return days != null && days <= 30 && days > 0;
  }

  bool get isExpired {
    final days = daysUntilExpiry;
    return days != null && days <= 0;
  }

  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      isCertified: json['isCertified'] as bool,
      certificationDate: json['certificationDate'] != null
          ? DateTime.parse(json['certificationDate'] as String)
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      status: CertificationStatus.values.firstWhere(
        (e) => e.toString() == 'CertificationStatus.${json['status']}',
        orElse: () => CertificationStatus.notCertified,
      ),
      certificationId: json['certificationId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isCertified': isCertified,
      'certificationDate': certificationDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
      'status': status.toString().split('.').last,
      'certificationId': certificationId,
    };
  }
}

/// Statut de certification
enum CertificationStatus {
  notCertified,
  pending,
  certified,
  expiringSoon,
  expired,
}

extension CertificationStatusExtension on CertificationStatus {
  String get label {
    switch (this) {
      case CertificationStatus.notCertified:
        return 'Non certifié';
      case CertificationStatus.pending:
        return 'En attente';
      case CertificationStatus.certified:
        return 'Certifié';
      case CertificationStatus.expiringSoon:
        return 'Expire bientôt';
      case CertificationStatus.expired:
        return 'Expiré';
    }
  }
}

/// Modèle d'entrée d'inventaire
class InventoryEntry {
  final String id;
  final String productId;
  final String productName;
  final InventoryType type;
  final int quantity;
  final DateTime date;
  final String? orderId;
  final String? notes;

  InventoryEntry({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.date,
    this.orderId,
    this.notes,
  });

  factory InventoryEntry.fromJson(Map<String, dynamic> json) {
    return InventoryEntry(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      type: InventoryType.values.firstWhere(
        (e) => e.toString() == 'InventoryType.${json['type']}',
      ),
      quantity: json['quantity'] as int,
      date: DateTime.parse(json['date'] as String),
      orderId: json['orderId'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'type': type.toString().split('.').last,
      'quantity': quantity,
      'date': date.toIso8601String(),
      'orderId': orderId,
      'notes': notes,
    };
  }
}

/// Type de mouvement d'inventaire
enum InventoryType {
  entry, // Entrée
  exit, // Sortie (commande)
  adjustment, // Ajustement
}

extension InventoryTypeExtension on InventoryType {
  String get label {
    switch (this) {
      case InventoryType.entry:
        return 'Entrée';
      case InventoryType.exit:
        return 'Sortie';
      case InventoryType.adjustment:
        return 'Ajustement';
    }
  }
}

/// Modèle de statistiques d'audience
class AudienceStats {
  final int totalViews;
  final int totalClicks;
  final int totalOrders;
  final double conversionRate;
  final List<DailyStats> dailyStats;
  final Map<String, int> topProducts;

  AudienceStats({
    required this.totalViews,
    required this.totalClicks,
    required this.totalOrders,
    required this.conversionRate,
    required this.dailyStats,
    required this.topProducts,
  });

  factory AudienceStats.fromJson(Map<String, dynamic> json) {
    return AudienceStats(
      totalViews: json['totalViews'] as int,
      totalClicks: json['totalClicks'] as int,
      totalOrders: json['totalOrders'] as int,
      conversionRate: (json['conversionRate'] as num).toDouble(),
      dailyStats: (json['dailyStats'] as List)
          .map((item) => DailyStats.fromJson(item as Map<String, dynamic>))
          .toList(),
      topProducts: Map<String, int>.from(json['topProducts'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalViews': totalViews,
      'totalClicks': totalClicks,
      'totalOrders': totalOrders,
      'conversionRate': conversionRate,
      'dailyStats': dailyStats.map((stat) => stat.toJson()).toList(),
      'topProducts': topProducts,
    };
  }
}

/// Statistiques journalières
class DailyStats {
  final DateTime date;
  final int views;
  final int clicks;
  final int orders;

  DailyStats({
    required this.date,
    required this.views,
    required this.clicks,
    required this.orders,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      date: DateTime.parse(json['date'] as String),
      views: json['views'] as int,
      clicks: json['clicks'] as int,
      orders: json['orders'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'views': views,
      'clicks': clicks,
      'orders': orders,
    };
  }
}

/// Modèle de bannière promotionnelle
class PromotionalBanner {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final BannerType type;
  final String actionLabel;
  final VoidCallback? onTap;

  PromotionalBanner({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.type,
    required this.actionLabel,
    this.onTap,
  });
}

/// Type de bannière
enum BannerType {
  storage,
  boost,
  certification,
  premium,
}

extension BannerTypeExtension on BannerType {
  String get colorCode {
    switch (this) {
      case BannerType.storage:
        return '#FF9800'; // Orange
      case BannerType.boost:
        return '#2196F3'; // Bleu
      case BannerType.certification:
        return '#4CAF50'; // Vert
      case BannerType.premium:
        return '#9C27B0'; // Violet
    }
  }
}

/// Modèle d'informations de boutique
class StoreInfo {
  final String id;
  final String name;
  final String? logoUrl;
  final String? description;
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String phone;

  StoreInfo({
    required this.id,
    required this.name,
    this.logoUrl,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.phone,
  });

  factory StoreInfo.fromJson(Map<String, dynamic> json) {
    return StoreInfo(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logoUrl'] as String?,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      city: json['city'] as String,
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logoUrl': logoUrl,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'phone': phone,
    };
  }

  StoreInfo copyWith({
    String? name,
    String? logoUrl,
    String? description,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? phone,
  }) {
    return StoreInfo(
      id: id,
      name: name ?? this.name,
      logoUrl: logoUrl ?? this.logoUrl,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      phone: phone ?? this.phone,
    );
  }
}
