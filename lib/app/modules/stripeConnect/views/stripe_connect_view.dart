import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/stripe_connect_controller.dart';
import '../../../core/utils/app_design.dart';
import '../../../core/widgets/app_ui.dart';

/// Écran vendeur : configurer son compte de virement (IBAN) sur la page
/// sécurisée de Stripe, et suivre le statut de validation par ASSO.
class StripeConnectView extends GetView<StripeConnectController> {
  const StripeConnectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('stripe_connect.view.title'.tr),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.loadStatus,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _intro(context),
              const SizedBox(height: 16),
              if (controller.isRejected) ...[
                _statusBanner(context),
                const SizedBox(height: 16),
              ],
              // Statut inconnu : ne PAS proposer l'inscription, qui laisserait
              // croire qu'aucun IBAN n'est enregistré.
              if (controller.loadError.value != null && controller.status.value == null)
                _loadErrorCard(context)
              else if (controller.isApproved) ...[
                if (controller.needsMoreInfo) ...[
                  _moreInfoBanner(context),
                  const SizedBox(height: 16),
                ],
                _approvedCard(context),
              ] else if (controller.isPending) ...[
                // Dossier en cours d'examen. Si Stripe réclame des précisions, le
                // vendeur les fournit lui-même sur la page Stripe.
                if (controller.needsMoreInfo) ...[
                  _moreInfoBanner(context),
                  const SizedBox(height: 16),
                ],
                _pendingCard(context),
              ] else
                _setupCard(context),
            ],
          ),
        );
      }),
    );
  }

  Widget _intro(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.account_balance, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'stripe_connect.view.intro'.tr,
              style: const TextStyle(fontSize: 13.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }

  /// Bandeau « informations complémentaires demandées », au-dessus du formulaire.
  Widget _moreInfoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppDesign.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppDesign.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.assignment_late_outlined, color: AppDesign.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'stripe_connect.view.more_info_title'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppDesign.accent),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.partnerVerification.value ??
                      'stripe_connect.view.more_info_default'.tr,
                  style: const TextStyle(fontSize: 13, height: 1.3),
                ),
                const SizedBox(height: 4),
                Text(
                  'stripe_connect.view.more_info_contact'.tr,
                  style: const TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.3),
                ),
                const SizedBox(height: 10),
                _openStripeButton('stripe_connect.hosted.complete'.tr, outlined: true),
                _hostedFallbackButton(),
                _formErrorBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// État indisponible : on l'annonce et on propose de réessayer.
  Widget _loadErrorCard(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppDesign.accent.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.cloud_off_rounded, size: 40, color: AppDesign.accent),
        ),
        const SizedBox(height: 16),
        Text(
          'stripe_connect.view.status_unavailable'.tr,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            controller.loadError.value ?? '',
            style: const TextStyle(fontSize: 13.5, height: 1.4, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'stripe_connect.view.status_unavailable_hint'.tr,
            style: const TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.35),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 18),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.loadStatus,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text('stripe_connect.view.retry'.tr),
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
          ),
        ),
      ],
    );
  }

  Widget _statusBanner(BuildContext context) {
    final (Color color, IconData icon, String label, String detail) = switch (controller.status.value) {
      'approved' => (
          AppDesign.success,
          Icons.verified,
          'stripe_connect.view.banner_approved_title'.tr,
          'stripe_connect.view.banner_approved_detail'.tr
        ),
      'rejected' => (
          AppDesign.danger,
          Icons.cancel,
          'stripe_connect.view.banner_rejected_title'.tr,
          controller.rejectionReason.value ?? 'stripe_connect.view.banner_rejected_detail'.tr
        ),
      _ => (
          AppDesign.accent,
          Icons.hourglass_top,
          'stripe_connect.view.banner_pending_title'.tr,
          'stripe_connect.view.banner_pending_detail'.tr
        ),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 4),
                Text(detail, style: const TextStyle(fontSize: 13, height: 1.3)),
                if (controller.ibanLast4.value != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'stripe_connect.view.iban_masked'.trParams({'last4': '${controller.ibanLast4.value}'}) +
                        (controller.bankCountry.value != null ? '  (${controller.bankCountry.value})' : ''),
                    style: const TextStyle(fontSize: 12.5, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Page d'attente affichée quand un IBAN a été soumis et est en cours de
  /// vérification : plus de formulaire, seulement le rappel des informations
  /// (IBAN masqué + titulaire) et le statut.
  Widget _pendingCard(BuildContext context) {
    const orange = AppDesign.accent;
    final holder = controller.holderName.value;
    final last4 = controller.ibanLast4.value;
    final country = controller.bankCountry.value;

    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: orange.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.hourglass_top, size: 44, color: orange),
        ),
        const SizedBox(height: 16),
        Text(
          'stripe_connect.view.pending_title'.tr,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'stripe_connect.view.pending_message'.tr,
            style: const TextStyle(fontSize: 13.5, height: 1.4, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        _partnerStateNotice(),
        const SizedBox(height: 4),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('stripe_connect.view.saved_info'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                _readonlyRow('stripe_connect.view.holder'.tr, (holder ?? '').isNotEmpty ? holder! : '—'),
                _readonlyRow('IBAN', last4 != null ? '•••• •••• $last4' : '••••'),
                _readonlyRow('stripe_connect.view.country'.tr, country ?? '—'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(Icons.info_outline, size: 18, color: Colors.black45),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'stripe_connect.view.pending_locked'.tr,
                style: const TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.35),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _openStripeButton('stripe_connect.hosted.change_iban'.tr, outlined: true, onPressed: controller.checkIban),
        _hostedFallbackButton(),
        _formErrorBox(),
        const SizedBox(height: 4),
        _unlinkButton(),
      ],
    );
  }

  /// Compte validé : plus aucun formulaire, une page de confirmation.
  ///
  /// Le vendeur n'a plus rien à saisir — lui reproposer les champs laisse croire
  /// que sa demande n'a pas abouti.
  /// Désynchroniser l'IBAN (validé ou en attente de validation).
  Widget _unlinkButton() {
    return Obx(() => SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: controller.isUnlinking.value ? null : controller.unlink,
            icon: controller.isUnlinking.value
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.link_off_rounded, size: 18),
            label: Text('stripe_connect.unlink.button'.tr),
            style: TextButton.styleFrom(
              foregroundColor: AppDesign.danger,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ));
  }

  Widget _approvedCard(BuildContext context) {
    const green = AppDesign.success;
    final holder = controller.holderName.value;
    final last4 = controller.ibanLast4.value;
    final country = controller.bankCountry.value;

    return Column(
      children: [
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: green.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.verified_rounded, size: 44, color: green),
        ),
        const SizedBox(height: 16),
        Text(
          'stripe_connect.view.approved_title'.tr,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            'stripe_connect.view.approved_message'.tr,
            style: const TextStyle(fontSize: 13.5, height: 1.4, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('stripe_connect.view.saved_info'.tr,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 12),
                _readonlyRow('stripe_connect.view.holder'.tr, (holder ?? '').isNotEmpty ? holder! : '—'),
                _readonlyRow('IBAN', last4 != null ? '•••• •••• $last4' : '••••'),
                _readonlyRow('stripe_connect.view.country'.tr, country ?? '—'),
                _partnerStateNotice(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
            label: Text('stripe_connect.view.back_to_wallet'.tr),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _openStripeButton('stripe_connect.hosted.change_iban'.tr, outlined: true, onPressed: controller.checkIban),
        _hostedFallbackButton(),
        _formErrorBox(),
        const SizedBox(height: 4),
        _unlinkButton(),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(Icons.lock_outline, size: 18, color: Colors.black45),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'stripe_connect.view.approved_locked'.tr,
                style: const TextStyle(fontSize: 12.5, color: Colors.black54, height: 1.35),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Avertissement quand le partenaire bancaire n'a pas (encore) activé le compte.
  ///
  /// Un compte peut être validé par ASSO et pourtant refusé par le partenaire
  /// (vérification en cours, pièce manquante) : le vendeur doit le savoir avant de
  /// demander un virement qui serait rejeté.
  Widget _partnerStateNotice() {
    return Obx(() {
      if (controller.partnerReady.value) return const SizedBox.shrink();

      final message = controller.partnerVerification.value ??
          'stripe_connect.view.partner_verification_default'.tr;
      final missing = controller.partnerRequirements;

      return Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppDesign.accent.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppDesign.accent.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline, size: 18, color: AppDesign.accent),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message,
                      style: const TextStyle(fontSize: 12.5, height: 1.35)),
                  if (missing.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'stripe_connect.view.partner_blocking'.tr,
                      style: TextStyle(
                          fontSize: 12, color: AppDesign.accent, height: 1.3),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _readonlyRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(label, style: const TextStyle(color: Colors.black54))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  /// Inscription à faire (ou à reprendre / corriger) sur la page Stripe.
  Widget _setupCard(BuildContext context) {
    final unfinished = controller.registrationUnfinished;
    final rejected = controller.isRejected;

    return Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.awaitingStripe.value) ...[
              _waitingBanner(),
              const SizedBox(height: 16),
            ],
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          unfinished ? Icons.pending_actions_rounded : Icons.lock_outline_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            unfinished
                                ? 'stripe_connect.hosted.resume_title'.tr
                                : 'stripe_connect.hosted.setup_title'.tr,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      unfinished
                          ? 'stripe_connect.hosted.resume_message'.tr
                          : 'stripe_connect.hosted.setup_message'.tr,
                      style: const TextStyle(fontSize: 13.5, height: 1.4, color: Colors.black87),
                    ),
                    const SizedBox(height: 16),
                    // Pas encore de compte : l'IBAN est d'abord vérifié par ASSO (banque
                    // couverte par Stripe ?) ; le pays du compte en découle.
                    if (!controller.hasAccount.value && controller.verifiedCountry.value == null)
                      _openStripeButton(
                        'stripe_connect.hosted.add_iban'.tr,
                        onPressed: controller.checkIban,
                        icon: Icons.add_card_rounded,
                      )
                    else ...[
                      if (!controller.hasAccount.value) ...[
                        _verifiedIbanNotice(context),
                        const SizedBox(height: 12),
                      ],
                      _formErrorBox(),
                      _openStripeButton(
                        rejected
                            ? 'stripe_connect.hosted.fix'.tr
                            : unfinished
                                ? 'stripe_connect.hosted.resume'.tr
                                : 'stripe_connect.hosted.start'.tr,
                      ),
                      _hostedFallbackButton(),
                    ],
                  ],
                ),
              ),
            ),
            if (controller.hasAccount.value) ...[
              const SizedBox(height: 8),
              _unlinkButton(),
            ],
          ],
        ));
  }

  /// Page Stripe ouverte : on rappelle de la terminer, le statut suit tout seul.
  Widget _waitingBanner() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppDesign.accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppDesign.accent.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppDesign.accent),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'stripe_connect.hosted.waiting_title'.tr,
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppDesign.accent),
                ),
                const SizedBox(height: 4),
                Text(
                  'stripe_connect.hosted.waiting_message'.tr,
                  style: const TextStyle(fontSize: 13, height: 1.3),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: controller.checkStatusNow,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text('stripe_connect.hosted.check_status'.tr),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Bouton qui ouvre la page sécurisée de Stripe.
  Widget _openStripeButton(
    String label, {
    bool outlined = false,
    VoidCallback? onPressed,
    IconData icon = Icons.account_balance_rounded,
  }) {
    final action = onPressed ?? controller.openStripe;
    return Obx(() {
      final busy = controller.isOpening.value;
      final child = busy
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: outlined ? AppDesign.accent : Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text('stripe_connect.hosted.opening'.tr),
              ],
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Flexible(child: Text(label, textAlign: TextAlign.center)),
              ],
            );

      return SizedBox(
        width: double.infinity,
        child: outlined
            ? OutlinedButton(
                onPressed: busy ? null : action,
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
                child: child,
              )
            : ElevatedButton(
                onPressed: busy ? null : action,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: child,
              ),
      );
    });
  }

  /// IBAN vérifié par ASSO, en attente de l'inscription Stripe.
  Widget _verifiedIbanNotice(BuildContext context) {
    final last4 = controller.verifiedLast4.value;
    final country = controller.verifiedCountry.value ?? '';
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
      decoration: BoxDecoration(
        color: AppDesign.success.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppDesign.success.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_rounded, color: AppDesign.success, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  last4 != null
                      ? 'stripe_connect.hosted.iban_verified'.trParams({'last4': last4, 'country': country})
                      : 'stripe_connect.hosted.iban_verified_country'.trParams({'country': country}),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                ),
                const SizedBox(height: 2),
                Text(
                  'stripe_connect.hosted.iban_verified_hint'.tr,
                  style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.3),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: controller.checkIban,
            child: Text('stripe_connect.hosted.change'.tr),
          ),
        ],
      ),
    );
  }

  /// Secours : la page sécurisée hébergée par Stripe, si le formulaire intégré
  /// n'a pas pu se charger sur l'appareil.
  Widget _hostedFallbackButton() {
    return Obx(() {
      if (!controller.showHostedFallback.value) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: controller.isOpening.value ? null : controller.openHostedPage,
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: Text('stripe_connect.hosted.open_secure_page'.tr),
          ),
        ),
      );
    });
  }

  /// Erreur du dernier essai (lien Stripe indisponible, réseau…).
  Widget _formErrorBox() {
    return Obx(() {
      final error = controller.formError.value;
      if (error == null) return const SizedBox.shrink();
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 4, bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppDesign.danger.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppDesign.danger.withValues(alpha: 0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error_outline, color: AppDesign.danger, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                error,
                style: const TextStyle(color: AppDesign.danger, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
    });
  }
}
