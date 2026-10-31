import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_design.dart';
import '../../../core/utils/app_feedback.dart';
import '../../../core/utils/app_theme_system.dart';
import '../../../core/widgets/app_ui.dart';
import '../../stripeConnect/controllers/stripe_connect_controller.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../../../core/values/kpay_catalog.dart';
import '../../wallet/widgets/payout_account_sheet.dart';

/// Profil → Moyens de paiement : le vendeur ajoute, modifie ou retire son IBAN
/// et son numéro Mobile Money à tout moment.
class PaymentMethodsView extends StatelessWidget {
  const PaymentMethodsView({super.key});

  StripeConnectController get _iban => Get.find<StripeConnectController>();
  WalletController get _wallet => Get.find<WalletController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('payment_methods.title'.tr),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            _iban.loadStatus(silent: true),
            _wallet.loadPayoutAccount(),
            // IBAN manuel (banque non prise en charge par Stripe).
            _wallet.loadWithdrawalBalances(),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'payment_methods.intro'.tr,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: AppThemeSystem.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 20),
            _sectionTitle(context, 'payment_methods.iban_section'.tr),
            _ibanCard(context),
            const SizedBox(height: 24),
            _sectionTitle(context, 'payment_methods.mobile_section'.tr),
            _mobileCard(context),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppThemeSystem.getPrimaryTextColor(context),
          ),
        ),
      );

  Widget _card(BuildContext context, {required List<Widget> children}) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppThemeSystem.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppThemeSystem.getBorderColor(context)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );

  Widget _header(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    Widget? badge,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppThemeSystem.getPrimaryTextColor(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppThemeSystem.getSecondaryTextColor(context),
                ),
              ),
            ],
          ),
        ),
        if (badge != null) badge,
      ],
    );
  }

  Widget _badge(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: color),
        ),
      );

  /// Boutons « Modifier » / « Retirer » (ou « Ajouter » seul).
  Widget _actions({
    required bool has,
    required bool busy,
    required bool removing,
    required String addLabel,
    required VoidCallback onEdit,
    required VoidCallback onRemove,
  }) {
    final spinner = const SizedBox(
      width: 16,
      height: 16,
      child: CircularProgressIndicator(strokeWidth: 2),
    );
    if (!has) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: busy ? null : onEdit,
          icon: busy ? spinner : const Icon(Icons.add_rounded, size: 18),
          label: Text(addLabel),
          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 13)),
        ),
      );
    }
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: busy || removing ? null : onEdit,
            icon: busy ? spinner : const Icon(Icons.edit_rounded, size: 18),
            label: Text('payment_methods.edit'.tr),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextButton.icon(
            onPressed: busy || removing ? null : onRemove,
            icon: removing ? spinner : const Icon(Icons.delete_outline_rounded, size: 18),
            label: Text('payment_methods.remove'.tr),
            style: TextButton.styleFrom(
              foregroundColor: AppDesign.danger,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  // ─── IBAN ────────────────────────────────────────────────────────────────

  Widget _ibanCard(BuildContext context) {
    return Obx(() {
      final c = _iban;
      if (c.isLoading.value) {
        return _card(context, children: const [
          Center(child: Padding(padding: EdgeInsets.all(8), child: CircularProgressIndicator())),
        ]);
      }
      if (c.loadError.value != null && c.status.value == null) {
        return _card(context, children: [
          Text(c.loadError.value!, style: const TextStyle(color: AppDesign.danger)),
          const SizedBox(height: 8),
          TextButton(onPressed: c.loadStatus, child: Text('payment_methods.retry'.tr)),
        ]);
      }

      final has = c.hasAccount.value;
      // IBAN hors Stripe (banque non couverte) : virements faits à la main par ASSO.
      final manual = _wallet.manualBankAccount.value;
      if (!has && manual != null) return _manualIbanCard(context, manual);

      final last4 = c.ibanLast4.value;
      final holder = c.holderName.value;
      final (String label, Color color) = c.isApproved
          ? ('payment_methods.status_approved'.tr, AppDesign.success)
          : c.isPending
              ? ('payment_methods.status_pending'.tr, AppDesign.accent)
              : c.isRejected
                  ? ('payment_methods.status_rejected'.tr, AppDesign.danger)
                  : ('payment_methods.status_unfinished'.tr, AppDesign.accent);

      final subtitle = last4 != null
          ? [
              '•••• $last4',
              if ((holder ?? '').isNotEmpty) holder!,
            ].join(' · ')
          : has
              ? 'payment_methods.iban_unfinished'.tr
              : 'payment_methods.iban_none'.tr;

      return _card(context, children: [
        _header(
          context,
          icon: Icons.account_balance_rounded,
          color: AppDesign.success,
          title: has ? 'IBAN${c.bankCountry.value != null ? ' · ${c.bankCountry.value}' : ''}' : 'payment_methods.iban_title'.tr,
          subtitle: subtitle,
          badge: has ? _badge(label, color) : null,
        ),
        if (c.isRejected && (c.rejectionReason.value ?? '').isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(c.rejectionReason.value!, style: const TextStyle(fontSize: 12.5, color: AppDesign.danger)),
        ],
        if (has && (c.isApproved || c.isPending)) ...[
          const SizedBox(height: 10),
          Text(
            'payment_methods.iban_change_hint'.tr,
            style: TextStyle(fontSize: 12, color: AppThemeSystem.getSecondaryTextColor(context)),
          ),
        ],
        const SizedBox(height: 14),
        _actions(
          has: has,
          busy: c.isOpening.value,
          removing: c.isUnlinking.value,
          addLabel: 'payment_methods.add_iban'.tr,
          // Ajout ou changement d'IBAN : vérification d'abord. Inscription en cours
          // ou refusée : on reprend directement le formulaire Stripe.
          onEdit: !has || c.isApproved || c.isPending ? c.checkIban : c.openStripe,
          onRemove: c.unlink,
        ),
        if (c.showHostedFallback.value)
          TextButton.icon(
            onPressed: c.openHostedPage,
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: Text('stripe_connect.hosted.open_secure_page'.tr),
          ),
        if (c.formError.value != null) ...[
          const SizedBox(height: 10),
          Text(c.formError.value!, style: const TextStyle(fontSize: 12.5, color: AppDesign.danger)),
        ],
      ]);
    });
  }

  Widget _manualIbanCard(BuildContext context, Map<String, dynamic> manual) {
    final hours = _wallet.manualDelayHours.value;
    final subtitle = [
      manual['masked_iban']?.toString() ?? '•••• ${manual['iban_last4'] ?? ''}',
      if ((manual['account_holder'] ?? '').toString().isNotEmpty) manual['account_holder'].toString(),
    ].join(' · ');

    return _card(context, children: [
      _header(
        context,
        icon: Icons.account_balance_rounded,
        color: AppThemeSystem.warningColor,
        title: 'IBAN${manual['country'] != null ? ' · ${manual['country']}' : ''}',
        subtitle: subtitle,
        badge: _badge('payment_methods.status_manual'.tr, AppThemeSystem.warningColor),
      ),
      const SizedBox(height: 10),
      Text(
        'payment_methods.manual_hint'.trParams({'hours': '$hours'}),
        style: TextStyle(fontSize: 12, color: AppThemeSystem.getSecondaryTextColor(context)),
      ),
      const SizedBox(height: 14),
      _actions(
        has: true,
        busy: false,
        removing: false,
        addLabel: 'payment_methods.add_iban'.tr,
        onEdit: _iban.checkIban,
        onRemove: _removeManualIban,
      ),
    ]);
  }

  Future<void> _removeManualIban() async {
    final ok = await Get.dialog<bool>(AlertDialog(
      title: Text('payment_methods.remove_iban_title'.tr),
      content: Text('payment_methods.remove_iban_confirm'.tr),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: Text('common.cancel'.tr)),
        TextButton(
          onPressed: () => Get.back(result: true),
          style: TextButton.styleFrom(foregroundColor: AppDesign.danger),
          child: Text('payment_methods.remove'.tr),
        ),
      ],
    ));
    if (ok != true) return;

    final done = await _wallet.deleteBankAccount();
    AppFeedback.show(
      done ? 'payment_methods.removed_title'.tr : 'payment_methods.error'.tr,
      done ? 'payment_methods.iban_removed'.tr : 'payment_methods.error_retry'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: done ? AppDesign.success : AppDesign.danger,
      colorText: Colors.white,
    );
  }

  // ─── Mobile Money ────────────────────────────────────────────────────────

  Widget _mobileCard(BuildContext context) {
    return Obx(() {
      final account = _wallet.payoutAccount.value;
      final has = account != null;
      final subtitle = has
          ? [
              '+${account['masked_phone'] ?? account['phone_number']}',
              if ((account['account_holder'] ?? '').toString().isNotEmpty)
                account['account_holder'].toString(),
            ].join(' · ')
          : 'payment_methods.mobile_none'.tr;

      return _card(context, children: [
        _header(
          context,
          icon: Icons.phone_android_rounded,
          color: AppThemeSystem.kpayColor,
          title: has
              ? KPayCatalog.labelFor(account['provider']?.toString())
              : 'payment_methods.mobile_title'.tr,
          subtitle: subtitle,
        ),
        const SizedBox(height: 14),
        _actions(
          has: has,
          busy: _wallet.isSavingPayoutAccount.value,
          removing: false,
          addLabel: 'payment_methods.add_mobile'.tr,
          onEdit: () => PayoutAccountSheet.show(),
          onRemove: _removeMobile,
        ),
      ]);
    });
  }

  Future<void> _removeMobile() async {
    final ok = await Get.dialog<bool>(AlertDialog(
      title: Text('payment_methods.remove_mobile_title'.tr),
      content: Text('payment_methods.remove_mobile_confirm'.tr),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: Text('common.cancel'.tr)),
        TextButton(
          onPressed: () => Get.back(result: true),
          style: TextButton.styleFrom(foregroundColor: AppDesign.danger),
          child: Text('payment_methods.remove'.tr),
        ),
      ],
    ));
    if (ok != true) return;

    final done = await _wallet.deletePayoutAccount();
    AppFeedback.show(
      done ? 'payment_methods.removed_title'.tr : 'payment_methods.error'.tr,
      done ? 'payment_methods.mobile_removed'.tr : 'payment_methods.error_retry'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: done ? AppDesign.success : AppDesign.danger,
      colorText: Colors.white,
    );
  }
}
