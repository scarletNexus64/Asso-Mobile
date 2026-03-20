import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/app_theme_system.dart';
import '../controllers/wallet_controller.dart';
import '../models/wallet_models.dart';

class WalletView extends GetView<WalletController> {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.primaryTextColor),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Mon Wallet',
          style: context.h5.copyWith(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: context.primaryTextColor),
            onPressed: controller.loadWalletData,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.walletStats.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadWalletData,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(context.horizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BalanceCard(),
                SizedBox(height: context.sectionSpacing),
                _StatisticsCards(),
                SizedBox(height: context.sectionSpacing),
                _SimpleChart(),
                SizedBox(height: context.sectionSpacing),
                _FiltersSection(),
                SizedBox(height: context.elementSpacing),
                _TransactionsList(),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _BalanceCard extends GetView<WalletController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.walletStats.value;
      if (stats == null) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(context.horizontalPadding * 1.5),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF58A3A), Color(0xFFFF6F00)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: context.borderRadius(BorderRadiusType.medium),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF58A3A).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.white, size: 28),
                const Spacer(),
                if (stats.pendingAmount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${stats.pendingAmount.toStringAsFixed(0)} XAF en attente',
                      style: const TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Solde disponible',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '${NumberFormat('#,###').format(stats.availableBalance)} XAF',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: controller.showWithdrawalForm,
                icon: const Icon(Icons.money_off),
                label: const Text('Retirer des fonds'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFF58A3A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _StatisticsCards extends GetView<WalletController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.walletStats.value;
      if (stats == null) return const SizedBox.shrink();

      return Row(
        children: [
          Expanded(
            child: _StatCard(
              icon: Icons.arrow_upward,
              label: 'Gains totaux',
              value: '${NumberFormat('#,###').format(stats.totalEarnings)} XAF',
              color: AppThemeSystem.successColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              icon: Icons.arrow_downward,
              label: 'Retraits',
              value: '${NumberFormat('#,###').format(stats.totalWithdrawals)} XAF',
              color: AppThemeSystem.errorColor,
            ),
          ),
        ],
      );
    });
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: context.borderRadius(BorderRadiusType.medium),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: context.body1.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: context.caption.copyWith(color: context.secondaryTextColor)),
        ],
      ),
    );
  }
}

class _SimpleChart extends GetView<WalletController> {
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.walletStats.value;
      if (stats == null || stats.dailyEarnings.isEmpty) return const SizedBox.shrink();

      final maxAmount = stats.dailyEarnings.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
      if (maxAmount == 0) return const SizedBox.shrink();

      return Container(
        padding: EdgeInsets.all(context.horizontalPadding),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: context.borderRadius(BorderRadiusType.medium),
          border: Border.all(color: context.borderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gains des 30 derniers jours', style: context.h6.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: stats.dailyEarnings.map((earning) {
                  final heightPercent = earning.amount / maxAmount;
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      height: heightPercent * 150,
                      decoration: BoxDecoration(
                        color: AppThemeSystem.primaryColor.withValues(alpha: 0.7),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _FiltersSection extends GetView<WalletController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Filtrer par période', style: context.body1.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: FilterPeriod.values.map((period) {
            final isSelected = controller.selectedPeriod.value == period;
            return GestureDetector(
              onTap: () => controller.selectedPeriod.value = period,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppThemeSystem.primaryColor : AppThemeSystem.grey100,
                  borderRadius: context.borderRadius(BorderRadiusType.small),
                  border: Border.all(
                    color: isSelected ? AppThemeSystem.primaryColor : AppThemeSystem.grey300,
                  ),
                ),
                child: Text(
                  period.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : context.secondaryTextColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        )),
      ],
    );
  }
}

class _TransactionsList extends GetView<WalletController> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Historique des transactions', style: context.body1.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Obx(() {
          if (controller.filteredTransactions.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(40),
              alignment: Alignment.center,
              child: Text('Aucune transaction', style: context.body2.copyWith(color: context.secondaryTextColor)),
            );
          }

          return Column(
            children: controller.filteredTransactions.map((transaction) {
              return _TransactionItem(transaction: transaction);
            }).toList(),
          );
        }),
      ],
    );
  }
}

class _TransactionItem extends GetView<WalletController> {
  final Transaction transaction;

  const _TransactionItem({required this.transaction});

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type.isCredit;
    final color = controller.getTransactionColor(transaction.type);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: context.borderRadius(BorderRadiusType.small),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: context.borderRadius(BorderRadiusType.small),
            ),
            child: Icon(
              isCredit ? Icons.add : Icons.remove,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: context.body2.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd/MM/yyyy à HH:mm').format(transaction.date),
                  style: context.caption.copyWith(color: context.secondaryTextColor),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}${NumberFormat('#,###').format(transaction.amount)} XAF',
                style: context.body1.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(transaction.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  transaction.status.label,
                  style: TextStyle(
                    fontSize: 10,
                    color: _getStatusColor(transaction.status),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(TransactionStatus status) {
    switch (status) {
      case TransactionStatus.completed:
        return AppThemeSystem.successColor;
      case TransactionStatus.pending:
        return AppThemeSystem.warningColor;
      case TransactionStatus.failed:
      case TransactionStatus.cancelled:
        return AppThemeSystem.errorColor;
    }
  }
}
