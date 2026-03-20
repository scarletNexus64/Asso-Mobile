/// Modèle de transaction
class Transaction {
  final String id;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String description;
  final TransactionStatus status;
  final String? orderId;
  final String? reference;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    required this.status,
    this.orderId,
    this.reference,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      type: TransactionType.values.firstWhere(
        (e) => e.toString() == 'TransactionType.${json['type']}',
      ),
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      description: json['description'] as String,
      status: TransactionStatus.values.firstWhere(
        (e) => e.toString() == 'TransactionStatus.${json['status']}',
      ),
      orderId: json['orderId'] as String?,
      reference: json['reference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'status': status.toString().split('.').last,
      'orderId': orderId,
      'reference': reference,
    };
  }
}

/// Type de transaction
enum TransactionType {
  sale, // Vente
  withdrawal, // Retrait
  refund, // Remboursement
  commission, // Commission
}

extension TransactionTypeExtension on TransactionType {
  String get label {
    switch (this) {
      case TransactionType.sale:
        return 'Vente';
      case TransactionType.withdrawal:
        return 'Retrait';
      case TransactionType.refund:
        return 'Remboursement';
      case TransactionType.commission:
        return 'Commission';
    }
  }

  bool get isCredit {
    return this == TransactionType.sale || this == TransactionType.refund;
  }

  bool get isDebit {
    return this == TransactionType.withdrawal || this == TransactionType.commission;
  }
}

/// Statut de transaction
enum TransactionStatus {
  pending,
  completed,
  failed,
  cancelled,
}

extension TransactionStatusExtension on TransactionStatus {
  String get label {
    switch (this) {
      case TransactionStatus.pending:
        return 'En attente';
      case TransactionStatus.completed:
        return 'Complétée';
      case TransactionStatus.failed:
        return 'Échouée';
      case TransactionStatus.cancelled:
        return 'Annulée';
    }
  }
}

/// Statistiques du wallet
class WalletStats {
  final double balance;
  final double totalEarnings;
  final double totalWithdrawals;
  final double pendingAmount;
  final int totalTransactions;
  final List<DailyEarnings> dailyEarnings;

  WalletStats({
    required this.balance,
    required this.totalEarnings,
    required this.totalWithdrawals,
    required this.pendingAmount,
    required this.totalTransactions,
    required this.dailyEarnings,
  });

  double get availableBalance => balance - pendingAmount;

  factory WalletStats.fromJson(Map<String, dynamic> json) {
    return WalletStats(
      balance: (json['balance'] as num).toDouble(),
      totalEarnings: (json['totalEarnings'] as num).toDouble(),
      totalWithdrawals: (json['totalWithdrawals'] as num).toDouble(),
      pendingAmount: (json['pendingAmount'] as num).toDouble(),
      totalTransactions: json['totalTransactions'] as int,
      dailyEarnings: (json['dailyEarnings'] as List)
          .map((item) => DailyEarnings.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'balance': balance,
      'totalEarnings': totalEarnings,
      'totalWithdrawals': totalWithdrawals,
      'pendingAmount': pendingAmount,
      'totalTransactions': totalTransactions,
      'dailyEarnings': dailyEarnings.map((e) => e.toJson()).toList(),
    };
  }
}

/// Gains journaliers
class DailyEarnings {
  final DateTime date;
  final double amount;
  final int transactionCount;

  DailyEarnings({
    required this.date,
    required this.amount,
    required this.transactionCount,
  });

  factory DailyEarnings.fromJson(Map<String, dynamic> json) {
    return DailyEarnings(
      date: DateTime.parse(json['date'] as String),
      amount: (json['amount'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'amount': amount,
      'transactionCount': transactionCount,
    };
  }
}

/// Période de filtre
enum FilterPeriod {
  today,
  week,
  month,
  threeMonths,
  year,
  all,
}

extension FilterPeriodExtension on FilterPeriod {
  String get label {
    switch (this) {
      case FilterPeriod.today:
        return 'Aujourd\'hui';
      case FilterPeriod.week:
        return '7 jours';
      case FilterPeriod.month:
        return '30 jours';
      case FilterPeriod.threeMonths:
        return '3 mois';
      case FilterPeriod.year:
        return '1 an';
      case FilterPeriod.all:
        return 'Tout';
    }
  }

  DateTime get startDate {
    final now = DateTime.now();
    switch (this) {
      case FilterPeriod.today:
        return DateTime(now.year, now.month, now.day);
      case FilterPeriod.week:
        return now.subtract(const Duration(days: 7));
      case FilterPeriod.month:
        return now.subtract(const Duration(days: 30));
      case FilterPeriod.threeMonths:
        return now.subtract(const Duration(days: 90));
      case FilterPeriod.year:
        return now.subtract(const Duration(days: 365));
      case FilterPeriod.all:
        return DateTime(2020, 1, 1);
    }
  }
}

/// Méthode de retrait
enum WithdrawalMethod {
  mobileMoney,
  bankTransfer,
}

extension WithdrawalMethodExtension on WithdrawalMethod {
  String get label {
    switch (this) {
      case WithdrawalMethod.mobileMoney:
        return 'Mobile Money';
      case WithdrawalMethod.bankTransfer:
        return 'Virement bancaire';
    }
  }

  String get icon {
    switch (this) {
      case WithdrawalMethod.mobileMoney:
        return '📱';
      case WithdrawalMethod.bankTransfer:
        return '🏦';
    }
  }
}
