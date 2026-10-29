import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/utils/app_design.dart';
import '../../core/utils/app_feedback.dart';
import '../../core/utils/app_theme_system.dart';
import '../../core/widgets/app_sheet.dart';
import '../../core/widgets/app_ui.dart';
import '../../data/providers/api_provider.dart';
import '../../data/providers/storage_service.dart';
import 'controllers/legal_controller.dart';
import 'views/legal_document_view.dart';
import 'views/legal_view.dart';

/// Étape de l'application qui exige l'acceptation de documents légaux.
///
/// [apiValue] est le filtre `context` de GET /v1/legal-pages ; [slugs] sont
/// les documents attendus (slugs bloqués dans le back-office).
enum LegalStep {
  registration('registration', [
    LegalSlugs.cgu,
    LegalSlugs.trustCharter,
  ]),
  purchase('purchase', [LegalSlugs.cga]),
  vendor('vendor', [LegalSlugs.vendorCharter]),
  deliveryPartner('delivery_partner', [LegalSlugs.deliveryCharter]);

  const LegalStep(this.apiValue, this.slugs);

  final String apiValue;
  final List<String> slugs;

  String get _key => switch (this) {
    LegalStep.registration => 'registration',
    LegalStep.purchase => 'purchase',
    LegalStep.vendor => 'vendor',
    LegalStep.deliveryPartner => 'delivery_partner',
  };

  String get title => 'legal.consent.$_key.title'.tr;
  String get message => 'legal.consent.$_key.message'.tr;
}

/// Slugs des documents obligatoires, fixés côté back-office.
abstract final class LegalSlugs {
  static const cgu = 'conditions-generales-utilisation';
  static const trustCharter = 'charte-confiance-securite';
  static const cga = 'conditions-generales-achat';
  static const vendorCharter = 'charte-vendeurs';
  static const deliveryCharter = 'charte-livreurs-partenaires';
}

/// Acceptation obligatoire des documents légaux avant une étape (achat,
/// compte vendeur, partenaire livreur).
///
/// L'acceptation est retenue par compte et par version du document : elle
/// est redemandée dès que le back-office publie une nouvelle version.
abstract final class LegalConsent {
  /// Documents à accepter pour [step], dans l'ordre du back-office.
  /// null si le serveur n'a pas pu être joint.
  static Future<List<LegalDocument>?> documentsFor(LegalStep step) async {
    try {
      final response = await ApiProvider.get(
        '/v1/legal-pages',
        queryParams: {'context': step.apiValue, 'with_content': '0'},
      );
      if (!response.success) return null;
      final documents = LegalDocument.listFrom(response.data?['data']);
      // Un serveur qui ignore `context` renvoie tous les documents : on ne
      // garde que ceux de l'étape (slugs bloqués dans le back-office).
      return documents.where((d) => step.slugs.contains(d.slug)).toList();
    } catch (e) {
      developer.log('Legal consent fetch failed', name: 'LegalConsent', error: e);
      return null;
    }
  }

  static String _version(LegalDocument d) =>
      d.updatedAt?.toUtc().toIso8601String() ?? '-';

  static bool _isAccepted(List<LegalDocument> documents) {
    final accepted = StorageService.legalAcceptances;
    return documents.every((d) => accepted[d.slug] == _version(d));
  }

  static void _remember(List<LegalDocument> documents) {
    final accepted = StorageService.legalAcceptances;
    for (final d in documents) {
      accepted[d.slug] = _version(d);
    }
    StorageService.saveLegalAcceptances(accepted);
  }

  /// true si l'utilisateur a accepté (maintenant ou déjà) les documents de
  /// [step] ; false s'il refuse ou si les documents n'ont pas pu être
  /// chargés. L'étape doit alors être interrompue.
  static Future<bool> ensure(LegalStep step) async {
    final documents = await documentsFor(step);
    if (documents == null) {
      AppFeedback.show(
        'legal.consent.load_failed_title'.tr,
        'legal.check_connection'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    // Rien de publié pour cette étape : rien à faire accepter.
    if (documents.isEmpty) return true;
    if (_isAccepted(documents)) return true;

    final ok = await AppSheet.show<bool>(
      _LegalConsentSheet(step: step, documents: documents),
    );
    if (ok != true) return false;
    _remember(documents);
    return true;
  }

  /// Ouvre un document dans l'app à partir de son slug.
  static void open(String slug, String title) =>
      LegalDocumentView.open(LegalDocument(slug: slug, title: title));
}

class _LegalConsentSheet extends StatefulWidget {
  const _LegalConsentSheet({required this.step, required this.documents});

  final LegalStep step;
  final List<LegalDocument> documents;

  @override
  State<_LegalConsentSheet> createState() => _LegalConsentSheetState();
}

class _LegalConsentSheetState extends State<_LegalConsentSheet> {
  bool _checked = false;

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      title: widget.step.title,
      footer: AppButton(
        label: 'legal.consent.accept'.tr,
        // Navigator plutôt que Get.back : avec un snackbar affiché, Get.back
        // fermerait le snackbar et laisserait la feuille ouverte.
        onPressed: _checked ? () => Navigator.of(context).pop(true) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.step.message,
            style: context.textStyle(
              FontSizeType.body2,
              color: context.ds.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: AppDesign.space4),
          LegalDocumentsCard(documents: widget.documents),
          const SizedBox(height: AppDesign.space4),
          InkWell(
            borderRadius: BorderRadius.circular(AppDesign.radiusSm),
            onTap: () => setState(() => _checked = !_checked),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDesign.space2),
              child: Row(
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _checked,
                      onChanged: (v) => setState(() => _checked = v ?? false),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  const SizedBox(width: AppDesign.space3),
                  Expanded(
                    child: Text(
                      'legal.consent.checkbox'.tr,
                      style: context.textStyle(
                        FontSizeType.body2,
                        color: context.ds.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
