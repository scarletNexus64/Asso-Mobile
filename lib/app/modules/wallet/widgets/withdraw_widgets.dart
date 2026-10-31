import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_design.dart';
import '../../../core/utils/app_theme_system.dart';
import '../../../core/utils/semantic_tone.dart';
import '../../../core/widgets/app_ui.dart';

/// Blocs visuels de la page « Retirer de l'argent » (WithdrawView).

/// Titre numéroté d'une étape de la page.
class WithdrawStepTitle extends StatelessWidget {
  const WithdrawStepTitle({super.key, required this.step, required this.title});

  final int step;
  final String title;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.accent(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppDesign.space3),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: tone.background,
              shape: BoxShape.circle,
            ),
            child: Text(
              '$step',
              style: context.textStyle(
                FontSizeType.caption,
                fontWeight: FontWeight.w700,
                color: tone.foreground,
              ),
            ),
          ),
          const SizedBox(width: AppDesign.space2),
          Expanded(
            child: Text(
              title,
              style: context.textStyle(
                FontSizeType.subtitle1,
                fontWeight: FontWeight.w700,
                color: context.ds.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Solde d'un onglet (Mobile Money ou Banque) : ce qui part tout de suite vers
/// cette méthode, et ce qui passera par une demande traitée par ASSO.
class WithdrawFundsCard extends StatelessWidget {
  const WithdrawFundsCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.instantAmount,
    required this.instantCaption,
    this.requestAmount,
    this.requestCaption,
    this.lockedNote,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String instantAmount;
  final String instantCaption;
  final String? requestAmount;
  final String? requestCaption;
  final String? lockedNote;

  @override
  Widget build(BuildContext context) {
    final warning = ToneColors.warning(context);
    return AppCard(
      padding: const EdgeInsets.all(AppDesign.space5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDesign.radiusSm),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const SizedBox(width: AppDesign.space3),
              Expanded(
                child: Text(
                  title,
                  style: context.textStyle(
                    FontSizeType.body2,
                    fontWeight: FontWeight.w600,
                    color: context.ds.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDesign.space4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              instantAmount,
              style: context.textStyle(
                FontSizeType.h2,
                fontWeight: FontWeight.w800,
                color: context.ds.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: AppDesign.space1),
          Row(
            children: [
              const Icon(
                Icons.bolt_rounded,
                size: 16,
                color: AppDesign.success,
              ),
              const SizedBox(width: AppDesign.space1),
              Expanded(
                child: Text(
                  instantCaption,
                  style: context.textStyle(
                    FontSizeType.caption,
                    fontWeight: FontWeight.w600,
                    color: AppDesign.success,
                  ),
                ),
              ),
            ],
          ),
          if (requestAmount != null && requestCaption != null) ...[
            const SizedBox(height: AppDesign.space4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppDesign.space3),
              decoration: BoxDecoration(
                color: warning.background,
                borderRadius: BorderRadius.circular(AppDesign.radiusSm),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 18,
                    color: warning.foreground,
                  ),
                  const SizedBox(width: AppDesign.space2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          requestAmount!,
                          style: context.textStyle(
                            FontSizeType.body1,
                            fontWeight: FontWeight.w700,
                            color: warning.foreground,
                          ),
                        ),
                        Text(
                          requestCaption!,
                          style: context.textStyle(
                            FontSizeType.caption,
                            color: warning.foreground,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (lockedNote != null) ...[
            const SizedBox(height: AppDesign.space3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.lock_clock_outlined,
                  size: 16,
                  color: context.ds.textTertiary,
                ),
                const SizedBox(width: AppDesign.space2),
                Expanded(
                  child: Text(
                    lockedNote!,
                    style: context.textStyle(
                      FontSizeType.caption,
                      color: context.ds.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Compte qui reçoit l'argent (IBAN enregistré, validation en cours…).
class WithdrawAccountCard extends StatelessWidget {
  const WithdrawAccountCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.badge,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final Widget? badge;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      elevated: false,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDesign.radiusSm),
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: AppDesign.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyle(
                    FontSizeType.body1,
                    fontWeight: FontWeight.w700,
                    color: context.ds.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.textStyle(
                    FontSizeType.caption,
                    color: context.ds.textSecondary,
                  ),
                ),
                if (badge != null) ...[
                  const SizedBox(height: AppDesign.space2),
                  badge!,
                ],
              ],
            ),
          ),
          if (actionLabel != null) ...[
            const SizedBox(width: AppDesign.space2),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

/// Onglet pas encore configuré : explication + ajout du compte.
class WithdrawEmptyState extends StatelessWidget {
  const WithdrawEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    required this.actionLabel,
    required this.onAction,
    this.actionIcon = Icons.add_rounded,
    this.secondaryLabel,
    this.onSecondary,
  });

  final IconData icon;
  final String title;
  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData actionIcon;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.accent(context);
    return AppCard(
      elevated: false,
      padding: const EdgeInsets.all(AppDesign.space5),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: tone.background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: tone.foreground),
          ),
          const SizedBox(height: AppDesign.space4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: context.textStyle(
              FontSizeType.subtitle1,
              fontWeight: FontWeight.w700,
              color: context.ds.textPrimary,
            ),
          ),
          const SizedBox(height: AppDesign.space2),
          Text(
            message,
            textAlign: TextAlign.center,
            style: context.textStyle(
              FontSizeType.body2,
              color: context.ds.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppDesign.space5),
          AppButton(label: actionLabel, icon: actionIcon, onPressed: onAction),
          if (secondaryLabel != null && onSecondary != null) ...[
            const SizedBox(height: AppDesign.space2),
            AppButton(
              label: secondaryLabel!,
              variant: AppButtonVariant.ghost,
              onPressed: onSecondary,
            ),
          ],
        ],
      ),
    );
  }
}

/// Carte « retirer plutôt par l'autre méthode ? » (retrait croisé, sur demande).
class WithdrawCrossOffer extends StatelessWidget {
  const WithdrawCrossOffer({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tone = ToneColors.accent(context);
    return AppCard(
      elevated: false,
      color: tone.background,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.ds.surface,
              borderRadius: BorderRadius.circular(AppDesign.radiusSm),
            ),
            child: Icon(icon, size: 20, color: AppDesign.accent),
          ),
          const SizedBox(width: AppDesign.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textStyle(
                    FontSizeType.body2,
                    fontWeight: FontWeight.w700,
                    color: tone.foreground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.textStyle(
                    FontSizeType.caption,
                    color: tone.foreground,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: tone.foreground),
        ],
      ),
    );
  }
}

/// Encadré coloré (info, avertissement) avec icône.
class WithdrawNotice extends StatelessWidget {
  const WithdrawNotice({
    super.key,
    required this.text,
    this.icon = Icons.info_outline_rounded,
    this.warning = false,
  });

  final String text;
  final IconData icon;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    final tone = warning
        ? ToneColors.warning(context)
        : ToneColors.info(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDesign.space3),
      decoration: BoxDecoration(
        color: tone.background,
        borderRadius: BorderRadius.circular(AppDesign.radiusSm),
        border: Border.all(color: tone.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: tone.foreground),
          const SizedBox(width: AppDesign.space2),
          Expanded(
            child: Text(
              text,
              style: context.textStyle(
                FontSizeType.caption,
                color: tone.foreground,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ligne libellé / valeur d'un récapitulatif.
class WithdrawSummaryRow extends StatelessWidget {
  const WithdrawSummaryRow({
    super.key,
    required this.label,
    required this.value,
    this.emphasize = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool emphasize;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppDesign.space1 + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: context.textStyle(
                FontSizeType.body2,
                color: context.ds.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: AppDesign.space3),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: context.textStyle(
                emphasize ? FontSizeType.subtitle1 : FontSizeType.body2,
                fontWeight: emphasize ? FontWeight.w800 : FontWeight.w600,
                color:
                    valueColor ??
                    (emphasize ? AppDesign.accent : context.ds.textPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Écran affiché une fois le retrait envoyé (immédiat ou demande ≈ 48 h).
class WithdrawSuccessPanel extends StatelessWidget {
  const WithdrawSuccessPanel({
    super.key,
    required this.isRequest,
    required this.title,
    required this.message,
    required this.rows,
    required this.onHistory,
    required this.onDone,
    this.onCancel,
    this.cancelling = false,
  });

  final bool isRequest;
  final String title;
  final String message;
  final List<Widget> rows;
  final VoidCallback onHistory;
  final VoidCallback onDone;

  /// Annulation d'une demande encore en attente (null = pas proposée).
  final VoidCallback? onCancel;
  final bool cancelling;

  @override
  Widget build(BuildContext context) {
    final tone = isRequest
        ? ToneColors.warning(context)
        : ToneColors.success(context);
    return Column(
      children: [
        const SizedBox(height: AppDesign.space6),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: tone.background,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isRequest ? Icons.schedule_send_rounded : Icons.check_rounded,
            size: 40,
            color: tone.foreground,
          ),
        ),
        const SizedBox(height: AppDesign.space5),
        Text(
          title,
          textAlign: TextAlign.center,
          style: context.textStyle(
            FontSizeType.h4,
            fontWeight: FontWeight.w800,
            color: context.ds.textPrimary,
          ),
        ),
        const SizedBox(height: AppDesign.space2),
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.textStyle(
            FontSizeType.body2,
            color: context.ds.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: AppDesign.space6),
        AppCard(elevated: false, child: Column(children: rows)),
        const SizedBox(height: AppDesign.space6),
        AppButton(
          label: 'wallet.withdraw_page.see_history'.tr,
          icon: Icons.history_rounded,
          onPressed: onHistory,
        ),
        const SizedBox(height: AppDesign.space3),
        AppButton(
          label: 'wallet.withdraw_page.back_to_wallet'.tr,
          variant: AppButtonVariant.secondary,
          onPressed: onDone,
        ),
        if (onCancel != null) ...[
          const SizedBox(height: AppDesign.space2),
          TextButton.icon(
            onPressed: cancelling ? null : onCancel,
            style: TextButton.styleFrom(foregroundColor: AppDesign.danger),
            icon: cancelling
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.close_rounded, size: 18),
            label: Text('wallet.withdraw_page.cancel_request'.tr),
          ),
        ],
      ],
    );
  }
}
