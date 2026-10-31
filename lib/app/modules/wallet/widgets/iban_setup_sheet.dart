import 'package:asso/app/core/utils/app_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_theme_system.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../data/providers/storage_service.dart';
import '../controllers/wallet_controller.dart';
import '../../stripeConnect/controllers/stripe_connect_controller.dart';
import 'payout_account_sheet.dart';

/// Ajout d'un IBAN pour les retraits, en deux temps :
///
/// 1. le vendeur saisit son IBAN et l'app le fait vérifier par le serveur ;
/// 2. selon la réponse :
///    - IBAN compatible Stripe → inscription sécurisée Stripe (virements automatiques) ;
///    - IBAN valide mais banque non prise en charge → Mobile Money est RECOMMANDÉ
///      (retrait immédiat), l'IBAN reste possible avec un traitement ≈ 48 h ;
///    - IBAN invalide → message clair, rien n'est enregistré.
class IbanSetupSheet extends StatefulWidget {
  const IbanSetupSheet({super.key});

  static Future<bool?> show() => AppSheet.show<bool>(const IbanSetupSheet());

  @override
  State<IbanSetupSheet> createState() => _IbanSetupSheetState();
}

class _IbanSetupSheetState extends State<IbanSetupSheet> {
  WalletController get _wallet => Get.find<WalletController>();

  final _ibanController = TextEditingController();
  final _holderController = TextEditingController();
  final _bicController = TextEditingController();

  bool _checking = false;
  bool _saving = false;
  Map<String, dynamic>? _check; // réponse de /wallet/iban/check

  bool get _valid => _check?['valid'] == true;
  bool get _stripeSupported => _check?['stripe_supported'] == true;
  int get _hours => _wallet.manualDelayHours.value;

  @override
  void initState() {
    super.initState();
    final user = StorageService.getUser();
    final existing = _wallet.manualBankAccount.value;
    _holderController.text =
        existing?['account_holder']?.toString() ??
        (user == null ? '' : '${user.firstName} ${user.lastName}'.trim());
    _bicController.text = existing?['bic']?.toString() ?? '';
  }

  @override
  void dispose() {
    _ibanController.dispose();
    _holderController.dispose();
    _bicController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final iban = _ibanController.text.trim();
    if (iban.isEmpty) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _checking = true;
      _check = null;
    });
    final result = await _wallet.checkIban(iban);
    if (!mounted) return;
    setState(() {
      _checking = false;
      _check =
          result ??
          {
            'valid': false,
            'message': 'wallet.payout_methods.check_unavailable'.tr,
          };
    });
  }

  /// IBAN couvert : inscription Stripe directement, avec le pays de l'IBAN.
  void _openStripe() {
    final country = _check?['country']?.toString();
    final last4 = _check?['last4']?.toString();
    Get.back(result: false);
    StripeConnectController.startVerified(country: country, last4: last4);
  }

  void _openMobileMoney() {
    Get.back(result: false);
    PayoutAccountSheet.show();
  }

  Future<void> _saveManual() async {
    final holder = _holderController.text.trim();
    if (holder.length < 2) {
      AppFeedback.show(
        'wallet.payout_methods.holder_required_title'.tr,
        'wallet.payout_methods.holder_required_message'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppThemeSystem.errorColor,
        colorText: Colors.white,
      );
      return;
    }
    setState(() => _saving = true);
    final error = await _wallet.saveBankAccount(
      iban: _ibanController.text.trim(),
      accountHolder: holder,
      bic: _bicController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      AppFeedback.show(
        'wallet.payout_sheet.error'.tr,
        error,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppThemeSystem.errorColor,
        colorText: Colors.white,
      );
      return;
    }
    Get.back(result: true);
    AppFeedback.show(
      'wallet.payout_methods.iban_saved_title'.tr,
      'wallet.payout_methods.iban_saved_message'.trParams({'hours': '$_hours'}),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppThemeSystem.successColor,
      colorText: Colors.white,
    );
  }

  Future<void> _deleteManual() async {
    final ok = await _wallet.deleteBankAccount();
    if (!mounted) return;
    if (ok) {
      Get.back(result: true);
    }
  }

  InputDecoration _decoration(
    BuildContext context,
    String label, {
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon),
      filled: true,
      fillColor: AppThemeSystem.getSurfaceColor(context),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppThemeSystem.getBorderColor(context)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppThemeSystem.primaryColor,
          width: 2,
        ),
      ),
    );
  }

  Widget _notice(
    BuildContext context, {
    required Color color,
    required IconData icon,
    required String text,
    String? title,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                        color: AppThemeSystem.getPrimaryTextColor(context),
                      ),
                    ),
                  ),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12.5,
                    height: 1.35,
                    color: AppThemeSystem.getSecondaryTextColor(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final existing = _wallet.manualBankAccount.value;

    return AppSheet(
      title: 'wallet.payout_methods.iban_title'.tr,
      color: AppThemeSystem.getBackgroundColor(context),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (existing != null) ...[
            _notice(
              context,
              color: AppThemeSystem.warningColor,
              icon: Icons.account_balance_rounded,
              title: 'wallet.payout_methods.current_manual_iban'.trParams({
                'iban': existing['masked_iban']?.toString() ?? '••••',
              }),
              text: 'wallet.payout_methods.manual_delay'.trParams({
                'hours': '$_hours',
              }),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _deleteManual,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                label: Text('wallet.payout_methods.delete_iban'.tr),
                style: TextButton.styleFrom(
                  foregroundColor: AppThemeSystem.errorColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
          Text(
            'wallet.payout_methods.iban_intro'.tr,
            style: TextStyle(
              fontSize: 13,
              color: AppThemeSystem.getSecondaryTextColor(context),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ibanController,
            textCapitalization: TextCapitalization.characters,
            autocorrect: false,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9 ]')),
              LengthLimitingTextInputFormatter(42),
            ],
            onChanged: (_) {
              if (_check != null) setState(() => _check = null);
            },
            onSubmitted: (_) => _verify(),
            style: TextStyle(
              fontFamily: 'monospace',
              color: AppThemeSystem.getPrimaryTextColor(context),
            ),
            decoration: _decoration(
              context,
              'wallet.payout_methods.iban_label'.tr,
              hint: 'FR76 3000 6000 … / 10033 00001 …',
              icon: Icons.account_balance_outlined,
            ),
          ),
          const SizedBox(height: 12),
          if (_check == null)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _checking ? null : _verify,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeSystem.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _checking
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'wallet.payout_methods.verify_iban'.tr,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),

          // 1) IBAN invalide
          if (_check != null && !_valid)
            _notice(
              context,
              color: AppThemeSystem.errorColor,
              icon: Icons.error_outline_rounded,
              text:
                  _check?['message']?.toString() ??
                  'wallet.payout_methods.iban_invalid'.tr,
            ),

          // 2) IBAN compatible Stripe : virements automatiques
          if (_valid && _stripeSupported) ...[
            _notice(
              context,
              color: AppThemeSystem.successColor,
              icon: Icons.verified_rounded,
              title: 'wallet.payout_methods.stripe_ok_title'.tr,
              text: 'wallet.payout_methods.stripe_ok_message'.tr,
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _openStripe,
                icon: const Icon(Icons.lock_outline_rounded, size: 18),
                label: Text(
                  'wallet.payout_methods.continue_stripe'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeSystem.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],

          // 3) IBAN valide, banque non prise en charge : Mobile Money recommandé
          if (_valid && !_stripeSupported) ...[
            _notice(
              context,
              color: AppThemeSystem.warningColor,
              icon: Icons.info_outline_rounded,
              title: 'wallet.payout_methods.bank_unsupported_title'.tr,
              text: 'wallet.payout_methods.bank_unsupported_message'.tr,
            ),
            const SizedBox(height: 14),
            _RecommendedMobileCard(onTap: _openMobileMoney),
            const SizedBox(height: 18),
            Text(
              'wallet.payout_methods.keep_iban_title'.tr,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppThemeSystem.getPrimaryTextColor(context),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'wallet.payout_methods.manual_delay'.trParams({
                'hours': '$_hours',
              }),
              style: TextStyle(
                fontSize: 12.5,
                color: AppThemeSystem.getSecondaryTextColor(context),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _holderController,
              textCapitalization: TextCapitalization.words,
              decoration: _decoration(
                context,
                'wallet.payout_methods.holder_label'.tr,
                icon: Icons.person_outline_rounded,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _bicController,
              textCapitalization: TextCapitalization.characters,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                LengthLimitingTextInputFormatter(11),
              ],
              decoration: _decoration(
                context,
                'wallet.payout_methods.bic_label'.tr,
                icon: Icons.tag_rounded,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: _saving ? null : _saveManual,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppThemeSystem.primaryColor,
                  side: const BorderSide(color: AppThemeSystem.primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        'wallet.payout_methods.save_manual_iban'.trParams({
                          'hours': '$_hours',
                        }),
                      ),
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// Carte « Mobile Money — recommandé » mise en avant quand l'IBAN n'est pas
/// pris en charge pour les virements automatiques.
class _RecommendedMobileCard extends StatelessWidget {
  const _RecommendedMobileCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppThemeSystem.kpayColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppThemeSystem.kpayColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppThemeSystem.kpayColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.phone_android_rounded,
                color: AppThemeSystem.kpayColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'wallet.payout_methods.mobile_title'.tr,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppThemeSystem.getPrimaryTextColor(context),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const _RecommendedBadge(),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'wallet.payout_methods.mobile_recommended_hint'.tr,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppThemeSystem.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppThemeSystem.kpayColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendedBadge extends StatelessWidget {
  const _RecommendedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppThemeSystem.kpayColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        'wallet.payout_methods.recommended'.tr,
        style: const TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Badge réutilisable (écran portefeuille).
class RecommendedBadge extends StatelessWidget {
  const RecommendedBadge({super.key});

  @override
  Widget build(BuildContext context) => const _RecommendedBadge();
}
