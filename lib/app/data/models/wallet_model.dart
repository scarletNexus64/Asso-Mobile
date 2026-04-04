/// Wallet model matching backend structure
class WalletModel {
  final double currentBalance;
  final double freemopayBalance;
  final double paypalBalance;
  final double totalCredits;
  final double totalDebits;
  final int totalTransactions;
  final String? lastTransactionDate;

  WalletModel({
    required this.currentBalance,
    required this.freemopayBalance,
    required this.paypalBalance,
    required this.totalCredits,
    required this.totalDebits,
    required this.totalTransactions,
    this.lastTransactionDate,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      currentBalance: _parseDouble(json['current_balance']),
      freemopayBalance: _parseDouble(json['freemopay_balance']),
      paypalBalance: _parseDouble(json['paypal_balance']),
      totalCredits: _parseDouble(json['total_credits']),
      totalDebits: _parseDouble(json['total_debits']),
      totalTransactions: json['total_transactions'] ?? 0,
      lastTransactionDate: json['last_transaction_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_balance': currentBalance,
      'freemopay_balance': freemopayBalance,
      'paypal_balance': paypalBalance,
      'total_credits': totalCredits,
      'total_debits': totalDebits,
      'total_transactions': totalTransactions,
      'last_transaction_date': lastTransactionDate,
    };
  }

  String get formattedBalance {
    return '${currentBalance.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]} ',
        )} FCFA';
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

/// Wallet transaction model
class WalletTransactionModel {
  final int id;
  final int userId;
  final String type; // credit, debit, refund, bonus, adjustment
  final double amount;
  final String? paymentProvider; // freemopay, paypal
  final String status; // pending, completed, failed
  final String description;
  final String? referenceType; // order, subscription, withdrawal, recharge
  final int? referenceId;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? completedAt;

  WalletTransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    this.paymentProvider,
    required this.status,
    required this.description,
    this.referenceType,
    this.referenceId,
    this.metadata,
    required this.createdAt,
    this.completedAt,
  });

  factory WalletTransactionModel.fromJson(Map<String, dynamic> json) {
    return WalletTransactionModel(
      id: json['id'],
      userId: json['user_id'],
      type: json['type'],
      amount: WalletModel._parseDouble(json['amount']),
      paymentProvider: json['payment_provider'],
      status: json['status'],
      description: json['description'] ?? '',
      referenceType: json['reference_type'],
      referenceId: json['reference_id'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'amount': amount,
      'payment_provider': paymentProvider,
      'status': status,
      'description': description,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  /// Check if transaction is a credit (incoming money)
  bool get isCredit => type == 'credit' || type == 'refund' || type == 'bonus';

  /// Get formatted amount with sign
  String get formattedAmount {
    final sign = isCredit ? '+' : '-';
    final absAmount = amount.abs();
    return '$sign ${absAmount.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]} ',
        )} F';
  }

  /// Get type label in French
  String get typeLabel {
    switch (type) {
      case 'credit':
        return 'Recharge';
      case 'debit':
        return 'Paiement';
      case 'refund':
        return 'Remboursement';
      case 'bonus':
        return 'Bonus';
      case 'adjustment':
        return 'Ajustement';
      default:
        return 'Transaction';
    }
  }

  /// Get type icon emoji
  String get typeIcon {
    switch (type) {
      case 'credit':
        return '💵';
      case 'debit':
        return '💸';
      case 'refund':
        return '↩️';
      case 'bonus':
        return '🎁';
      case 'adjustment':
        return '⚙️';
      default:
        return '💰';
    }
  }

  /// Get status text in French
  String get statusText {
    switch (status) {
      case 'completed':
        return 'Complété';
      case 'pending':
        return 'En attente';
      case 'failed':
        return 'Échoué';
      default:
        return status;
    }
  }
}
