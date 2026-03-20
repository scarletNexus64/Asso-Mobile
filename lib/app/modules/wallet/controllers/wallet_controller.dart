import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/wallet_models.dart';

class WalletController extends GetxController {
  // État de chargement
  final RxBool isLoading = false.obs;

  // Statistiques du wallet
  final Rx<WalletStats?> walletStats = Rx<WalletStats?>(null);

  // Liste complète des transactions
  final RxList<Transaction> allTransactions = <Transaction>[].obs;

  // Liste filtrée des transactions
  final RxList<Transaction> filteredTransactions = <Transaction>[].obs;

  // Période de filtre sélectionnée
  final Rx<FilterPeriod> selectedPeriod = FilterPeriod.month.obs;

  // Type de transaction filtré
  final Rx<TransactionType?> selectedType = Rx<TransactionType?>(null);

  // Contrôleur pour le montant de retrait
  final TextEditingController withdrawalAmountController =
      TextEditingController();

  // Méthode de retrait sélectionnée
  final Rx<WithdrawalMethod> selectedWithdrawalMethod =
      WithdrawalMethod.mobileMoney.obs;

  @override
  void onInit() {
    super.onInit();
    loadWalletData();

    // Écouter les changements de filtres
    ever(selectedPeriod, (_) => applyFilters());
    ever(selectedType, (_) => applyFilters());
  }

  @override
  void onClose() {
    withdrawalAmountController.dispose();
    super.onClose();
  }

  /// Charge les données du wallet
  Future<void> loadWalletData() async {
    isLoading.value = true;
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      // Générer des données de test
      allTransactions.value = _generateMockTransactions();

      // Calculer les statistiques
      walletStats.value = _calculateStats();

      // Appliquer les filtres
      applyFilters();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de charger les données du wallet',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Applique les filtres sur les transactions
  void applyFilters() {
    var transactions = allTransactions.toList();

    // Filtre par période
    final startDate = selectedPeriod.value.startDate;
    transactions =
        transactions.where((t) => t.date.isAfter(startDate)).toList();

    // Filtre par type
    if (selectedType.value != null) {
      transactions =
          transactions.where((t) => t.type == selectedType.value).toList();
    }

    // Trier par date (plus récent en premier)
    transactions.sort((a, b) => b.date.compareTo(a.date));

    filteredTransactions.value = transactions;
  }

  /// Calcule les statistiques
  WalletStats _calculateStats() {
    final completedTransactions = allTransactions
        .where((t) => t.status == TransactionStatus.completed)
        .toList();

    final totalEarnings = completedTransactions
        .where((t) => t.type.isCredit)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalWithdrawals = completedTransactions
        .where((t) => t.type == TransactionType.withdrawal)
        .fold(0.0, (sum, t) => sum + t.amount);

    final pendingAmount = allTransactions
        .where((t) => t.status == TransactionStatus.pending)
        .fold(0.0, (sum, t) => sum + t.amount);

    final balance = totalEarnings - totalWithdrawals;

    // Générer les gains journaliers pour les 30 derniers jours
    final dailyEarnings = _calculateDailyEarnings();

    return WalletStats(
      balance: balance,
      totalEarnings: totalEarnings,
      totalWithdrawals: totalWithdrawals,
      pendingAmount: pendingAmount,
      totalTransactions: allTransactions.length,
      dailyEarnings: dailyEarnings,
    );
  }

  /// Calcule les gains journaliers
  List<DailyEarnings> _calculateDailyEarnings() {
    final Map<String, DailyEarnings> earningsMap = {};
    final now = DateTime.now();

    // Initialiser les 30 derniers jours avec 0
    for (int i = 29; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
      final key = '${date.year}-${date.month}-${date.day}';
      earningsMap[key] = DailyEarnings(
        date: date,
        amount: 0,
        transactionCount: 0,
      );
    }

    // Ajouter les ventes complétées
    for (final transaction in allTransactions) {
      if (transaction.type == TransactionType.sale &&
          transaction.status == TransactionStatus.completed) {
        final date = transaction.date;
        final key = '${date.year}-${date.month}-${date.day}';

        if (earningsMap.containsKey(key)) {
          final current = earningsMap[key]!;
          earningsMap[key] = DailyEarnings(
            date: current.date,
            amount: current.amount + transaction.amount,
            transactionCount: current.transactionCount + 1,
          );
        }
      }
    }

    return earningsMap.values.toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Génère des transactions de test
  List<Transaction> _generateMockTransactions() {
    final List<Transaction> transactions = [];
    final now = DateTime.now();

    // Ventes
    for (int i = 0; i < 30; i++) {
      transactions.add(Transaction(
        id: 'TXN${1000 + i}',
        type: TransactionType.sale,
        amount: 15000 + (i * 500),
        date: now.subtract(Duration(days: i)),
        description: 'Vente commande #CMD${1000 + i}',
        status: TransactionStatus.completed,
        orderId: 'CMD${1000 + i}',
      ));
    }

    // Retraits
    transactions.add(Transaction(
      id: 'TXN2000',
      type: TransactionType.withdrawal,
      amount: 50000,
      date: now.subtract(const Duration(days: 5)),
      description: 'Retrait vers Mobile Money',
      status: TransactionStatus.completed,
      reference: 'WD2000',
    ));

    transactions.add(Transaction(
      id: 'TXN2001',
      type: TransactionType.withdrawal,
      amount: 30000,
      date: now.subtract(const Duration(days: 15)),
      description: 'Retrait vers compte bancaire',
      status: TransactionStatus.completed,
      reference: 'WD2001',
    ));

    // Retrait en attente
    transactions.add(Transaction(
      id: 'TXN2002',
      type: TransactionType.withdrawal,
      amount: 25000,
      date: now.subtract(const Duration(days: 1)),
      description: 'Retrait en cours de traitement',
      status: TransactionStatus.pending,
      reference: 'WD2002',
    ));

    // Commissions
    transactions.add(Transaction(
      id: 'TXN3000',
      type: TransactionType.commission,
      amount: 2500,
      date: now.subtract(const Duration(days: 3)),
      description: 'Commission plateforme',
      status: TransactionStatus.completed,
    ));

    return transactions;
  }

  /// Demande un retrait
  Future<void> requestWithdrawal() async {
    final amountText = withdrawalAmountController.text.trim();

    if (amountText.isEmpty) {
      Get.snackbar(
        'Erreur',
        'Veuillez entrer un montant',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Get.snackbar(
        'Erreur',
        'Montant invalide',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final stats = walletStats.value;
    if (stats == null) return;

    if (amount > stats.availableBalance) {
      Get.snackbar(
        'Erreur',
        'Solde insuffisant. Disponible: ${stats.availableBalance.toStringAsFixed(0)} XAF',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Montant minimum
    if (amount < 5000) {
      Get.snackbar(
        'Erreur',
        'Le montant minimum de retrait est de 5 000 XAF',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isLoading.value = true;

      // TODO: Appel API pour demander le retrait
      await Future.delayed(const Duration(milliseconds: 500));

      withdrawalAmountController.clear();
      Get.back(); // Fermer le formulaire

      Get.snackbar(
        'Succès',
        'Votre demande de retrait de ${amount.toStringAsFixed(0)} XAF a été envoyée',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      // Recharger les données
      await loadWalletData();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible de traiter votre demande',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Affiche le formulaire de retrait
  void showWithdrawalForm() {
    Get.bottomSheet(
      _WithdrawalFormSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  /// Obtient la couleur selon le type de transaction
  Color getTransactionColor(TransactionType type) {
    switch (type) {
      case TransactionType.sale:
        return const Color(0xFF4CAF50); // Vert
      case TransactionType.withdrawal:
        return const Color(0xFFF44336); // Rouge
      case TransactionType.refund:
        return const Color(0xFF2196F3); // Bleu
      case TransactionType.commission:
        return const Color(0xFFFF9800); // Orange
    }
  }
}

/// Formulaire de retrait en bottom sheet
class _WithdrawalFormSheet extends StatelessWidget {
  final WalletController controller;

  const _WithdrawalFormSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 100),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Demande de retrait',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Obx(() {
              final stats = controller.walletStats.value;
              if (stats == null) return const SizedBox.shrink();

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF58A3A).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.account_balance_wallet, size: 32),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Solde disponible',
                          style: TextStyle(fontSize: 12),
                        ),
                        Text(
                          '${stats.availableBalance.toStringAsFixed(0)} XAF',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            const Text(
              'Montant à retirer',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: controller.withdrawalAmountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Ex: 50000',
                suffixText: 'XAF',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Méthode de retrait',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Obx(() => Column(
              children: [
                _buildMethodTile(
                  WithdrawalMethod.mobileMoney,
                  controller.selectedWithdrawalMethod.value ==
                      WithdrawalMethod.mobileMoney,
                  () => controller.selectedWithdrawalMethod.value =
                      WithdrawalMethod.mobileMoney,
                ),
                const SizedBox(height: 8),
                _buildMethodTile(
                  WithdrawalMethod.bankTransfer,
                  controller.selectedWithdrawalMethod.value ==
                      WithdrawalMethod.bankTransfer,
                  () => controller.selectedWithdrawalMethod.value =
                      WithdrawalMethod.bankTransfer,
                ),
              ],
            )),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Obx(() => ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : controller.requestWithdrawal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF58A3A),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: controller.isLoading.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Demander le retrait',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              )),
            ),
            const SizedBox(height: 8),
            const Text(
              'Montant minimum: 5 000 XAF\nDélai de traitement: 24-48h',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile(
    WithdrawalMethod method,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFFF58A3A) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? const Color(0xFFF58A3A).withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Row(
          children: [
            Text(
              method.icon,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            Text(
              method.label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFFF58A3A),
              ),
          ],
        ),
      ),
    );
  }
}
