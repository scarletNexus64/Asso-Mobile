class MessageModel {
  final int id;
  final int conversationId;
  final int senderId;
  final String message;
  final int? productId;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;
  final SenderModel? sender;

  MessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.message,
    this.productId,
    required this.isRead,
    this.readAt,
    required this.createdAt,
    this.sender,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      conversationId: json['conversation_id'] ?? 0,
      senderId: json['sender_id'] ?? 0,
      message: json['message'] ?? '',
      productId: json['product_id'],
      isRead: json['is_read'] ?? false,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      sender: json['sender'] != null
          ? SenderModel.fromJson(json['sender'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'conversation_id': conversationId,
      'sender_id': senderId,
      'message': message,
      'product_id': productId,
      'is_read': isRead,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'sender': sender?.toJson(),
    };
  }

  MessageModel copyWith({
    int? id,
    int? conversationId,
    int? senderId,
    String? message,
    int? productId,
    bool? isRead,
    DateTime? readAt,
    DateTime? createdAt,
    SenderModel? sender,
  }) {
    return MessageModel(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderId: senderId ?? this.senderId,
      message: message ?? this.message,
      productId: productId ?? this.productId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      createdAt: createdAt ?? this.createdAt,
      sender: sender ?? this.sender,
    );
  }
}

class SenderModel {
  final int id;
  final String name;
  final String? avatar;

  SenderModel({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory SenderModel.fromJson(Map<String, dynamic> json) {
    return SenderModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown',
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
    };
  }
}
