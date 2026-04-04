import 'message_model.dart';

class ConversationModel {
  final int id;
  final int user1Id;
  final int user2Id;
  final int? productId;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final OtherUserModel? otherUser;
  final ProductModel? product;
  final MessageModel? lastMessage;
  final int unreadCount;

  ConversationModel({
    required this.id,
    required this.user1Id,
    required this.user2Id,
    this.productId,
    this.lastMessageAt,
    required this.createdAt,
    this.otherUser,
    this.product,
    this.lastMessage,
    this.unreadCount = 0,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'] ?? 0,
      user1Id: json['user1_id'] ?? 0,
      user2Id: json['user2_id'] ?? 0,
      productId: json['product_id'],
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      otherUser: json['other_user'] != null
          ? OtherUserModel.fromJson(json['other_user'])
          : null,
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'])
          : null,
      lastMessage: json['last_message'] != null
          ? MessageModel.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user1_id': user1Id,
      'user2_id': user2Id,
      'product_id': productId,
      'last_message_at': lastMessageAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'other_user': otherUser?.toJson(),
      'product': product?.toJson(),
      'last_message': lastMessage?.toJson(),
      'unread_count': unreadCount,
    };
  }

  ConversationModel copyWith({
    int? id,
    int? user1Id,
    int? user2Id,
    int? productId,
    DateTime? lastMessageAt,
    DateTime? createdAt,
    OtherUserModel? otherUser,
    ProductModel? product,
    MessageModel? lastMessage,
    int? unreadCount,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      user1Id: user1Id ?? this.user1Id,
      user2Id: user2Id ?? this.user2Id,
      productId: productId ?? this.productId,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
      otherUser: otherUser ?? this.otherUser,
      product: product ?? this.product,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class OtherUserModel {
  final int id;
  final String name;
  final String? avatar;
  final String? phone;
  bool isOnline;
  DateTime? lastSeen;

  OtherUserModel({
    required this.id,
    required this.name,
    this.avatar,
    this.phone,
    this.isOnline = false,
    this.lastSeen,
  });

  factory OtherUserModel.fromJson(Map<String, dynamic> json) {
    return OtherUserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      avatar: json['avatar'],
      phone: json['phone'],
      isOnline: json['is_online'] ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'phone': phone,
      'is_online': isOnline,
      'last_seen': lastSeen?.toIso8601String(),
    };
  }
}

class ProductModel {
  final int id;
  final String name;
  final double? price;
  final String? image;

  ProductModel({
    required this.id,
    required this.name,
    this.price,
    this.image,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Product',
      price: json['price'] != null ? double.tryParse(json['price'].toString()) : null,
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
    };
  }
}
