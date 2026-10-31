import 'dart:async';

import 'package:asso/app/core/utils/app_feedback.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/providers/api_provider.dart';
import '../../../data/providers/stripe_connect_service.dart';
import '../../../data/services/stripe_connect_onboarding_bridge.dart';
import '../../../core/utils/app_design.dart';
import '../../../routes/app_pages.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../../wallet/widgets/iban_setup_sheet.dart';

/// Compte de virement du vendeur (IBAN) via Stripe Connect.
///
/// L'identité et l'IBAN sont collectés par Stripe (obligation réglementaire en
/// France), dans le composant d'inscription INTÉGRÉ à l'app (SDK natif, aux
/// couleurs d'ASSO). Si l'écran natif ne peut pas s'ouvrir, la page hébergée par
/// Stripe s'ouvre en secours dans le navigateur intégré, et le statut est relu au
/// retour au premier plan et régulièrement tant que l'inscription est en cours.
///
/// Statut ASSO : null (inscription à faire) → pending (inscription terminée, en
/// revue) → approved / rejected.
class StripeConnectController extends GetxController with WidgetsBindingObserver {
  final isLoading = true.obs;
  final isOpening = false.obs;
  final isUnlinking = false.obs;

  /// Statut non chargé (réseau, session expirée, serveur). Sans cela, un échec
  /// silencieux affichait l'écran d'inscription : le vendeur croyait son IBAN perdu.
  final loadError = RxnString();

  // Statut renvoyé par le serveur.
  final status = RxnString(); // null | pending | approved | rejected
  final rejectionReason = RxnString();
  final ibanLast4 = RxnString();
  final bankCountry = RxnString();
  final holderName = RxnString();
  final hasAccount = false.obs;

  // État chez Stripe (bloc `stripe` du statut) : un compte peut être validé par
  // ASSO tout en restant bloqué côté Stripe.
  final partnerReady = true.obs;
  final detailsSubmitted = false.obs;
  final partnerVerification = RxnString();
  final partnerRequirements = <String>[].obs;

  /// La page Stripe a été ouverte : on attend que le vendeur la termine.
  final awaitingStripe = false.obs;

  /// Le formulaire intégré n'a pas pu se charger : proposer la page hébergée.
  final showHostedFallback = false.obs;

  /// Pays du compte bancaire (utile seulement à la création du compte Stripe).
  final countryController = TextEditingController(text: 'FR');
  final countryError = RxnString();

  /// Message affiché au-dessus du bouton après un échec.
  final formError = RxnString();

  /// IBAN vérifié par ASSO avant l'inscription Stripe (pays couvert par Stripe).
  /// Le pays du compte en découle ; les 4 derniers chiffres servent à vérifier
  /// que le vendeur a saisi le même IBAN dans le formulaire Stripe.
  final verifiedCountry = RxnString();
  final verifiedLast4 = RxnString();

  Timer? _pollTimer;
  DateTime? _pollUntil;

  bool get isApproved => status.value == 'approved';
  bool get isPending => status.value == 'pending';
  bool get isRejected => status.value == 'rejected';

  /// Inscription commencée chez Stripe mais pas terminée.
  bool get registrationUnfinished =>
      hasAccount.value && status.value == null && !detailsSubmitted.value;

  /// Stripe réclame des informations complémentaires : le vendeur les fournit
  /// lui-même sur la page Stripe (bouton « Compléter sur Stripe »).
  bool get needsMoreInfo =>
      (isPending || isApproved) && !partnerReady.value && partnerRequirements.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    // Arrivée depuis la vérification d'IBAN (portefeuille) : on enchaîne sur Stripe.
    final args = Get.arguments;
    final autostart = args is Map && args['autostart'] == true;
    if (args is Map) _applyVerified(args['country']?.toString(), args['last4']?.toString());

    loadStatus().then((_) {
      if (autostart && !isApproved && !isPending) openStripe();
    });
  }

  /// Ouvre l'inscription Stripe après vérification de l'IBAN, depuis n'importe quel
  /// écran : sur place si l'écran IBAN (ou Moyens de paiement) est ouvert, sinon en
  /// ouvrant l'écran IBAN.
  static void startVerified({String? country, String? last4}) {
    if (Get.isRegistered<StripeConnectController>()) {
      Get.find<StripeConnectController>()
        .._applyVerified(country, last4)
        ..openStripe();
      return;
    }
    Get.toNamed(Routes.STRIPE_CONNECT, arguments: {
      'country': country,
      'last4': last4,
      'autostart': true,
    });
  }

  void _applyVerified(String? country, String? last4) {
    if (country != null && RegExp(r'^[A-Z]{2}$').hasMatch(country)) {
      verifiedCountry.value = country;
      countryController.text = country;
    }
    if (last4 != null && last4.isNotEmpty) verifiedLast4.value = last4;
  }

  /// Ajouter / changer d'IBAN : vérification par ASSO d'abord (format, banque
  /// couverte par Stripe), puis Stripe ou IBAN manuel selon le résultat.
  Future<void> checkIban() async {
    if (!Get.isRegistered<WalletController>()) {
      Get.lazyPut<WalletController>(() => WalletController());
    }
    await IbanSetupSheet.show();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopPolling();
    countryController.dispose();
    super.onClose();
  }

  /// Retour dans l'app (Safari fermé, app rouverte) : on relit le statut.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && awaitingStripe.value) {
      loadStatus(silent: true);
    }
  }

  Future<void> loadStatus({bool silent = false}) async {
    try {
      if (!silent) isLoading.value = true;
      final res = await StripeConnectService.getStatus();
      if (res.success && res.data != null) {
        loadError.value = null;
        _applyStatus(res.data!);
      } else if (!silent) {
        loadError.value = res.message.isNotEmpty
            ? res.message
            : 'stripe_connect.errors.status_load_failed'.tr;
      }
    } catch (_) {
      if (!silent) loadError.value = 'stripe_connect.errors.server_unreachable'.tr;
    } finally {
      if (!silent) isLoading.value = false;
    }
  }

  /// Applique le statut renvoyé par le serveur.
  ///
  /// ⚠️ `ApiResponse.data` porte le corps COMPLET (`{success, message, data}`) et
  /// non le sous-objet `data` : on le déballe.
  void _applyStatus(Map<String, dynamic> body) {
    final raw = body['data'];
    final data = raw is Map<String, dynamic> ? raw : body;
    final wasWaiting = awaitingStripe.value;

    status.value = data['status'] as String?;
    rejectionReason.value = data['rejection_reason'] as String?;
    ibanLast4.value = data['iban_last4'] as String?;
    bankCountry.value = data['bank_country'] as String?;
    holderName.value = data['account_holder_name'] as String?;
    hasAccount.value = data['has_account'] == true;

    if ((bankCountry.value ?? '').isNotEmpty) {
      countryController.text = bankCountry.value!;
    }

    // Bloc absent si Stripe n'est pas configuré ou sans compte.
    final partner = data['stripe'];
    if (partner is Map) {
      partnerReady.value = partner['ready'] == true;
      detailsSubmitted.value = partner['details_submitted'] == true;
      partnerVerification.value = partner['verification']?.toString();
      partnerRequirements.value = (partner['requirements_due'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          <String>[];
    } else {
      partnerReady.value = true;
      detailsSubmitted.value = false;
      partnerVerification.value = null;
      partnerRequirements.clear();
    }

    // Inscription terminée pendant que la page Stripe était ouverte.
    final finished = isPending || isApproved || detailsSubmitted.value;
    if (wasWaiting && finished) {
      _finishWaiting();
    }
  }

  /// Pays saisi, validé (seulement avant la création du compte Stripe).
  /// Renvoie false si la saisie est invalide (erreur affichée sous le champ).
  bool _readCountry(void Function(String?) use) {
    if (hasAccount.value) {
      use(null);
      return true;
    }
    final country = countryController.text.trim().toUpperCase();
    final error = validateCountry(country);
    if (error != null) {
      countryError.value = error;
      return false;
    }
    use(country);
    return true;
  }

  /// Configure le compte de virement : inscription intégrée à l'app, avec la
  /// page hébergée par Stripe en secours.
  Future<void> openStripe() async {
    if (isOpening.value) return;
    formError.value = null;
    countryError.value = null;
    showHostedFallback.value = false;

    String? country;
    if (!_readCountry((c) => country = c)) return;

    isOpening.value = true;
    try {
      final res = await StripeConnectService.accountSession(country: country);
      final payload = res.data?['data'];
      final secret = payload is Map ? payload['client_secret']?.toString() : null;
      final key = payload is Map ? payload['publishable_key']?.toString() : null;

      if (!res.success || secret == null || secret.isEmpty || key == null || key.isEmpty) {
        // Serveur pas encore à jour (route absente) : la page hébergée prend le relais.
        if (res.statusCode == 404) {
          await _openHosted(country);
          return;
        }
        _showApiError(res, fallbackMessage: 'stripe_connect.hosted.link_missing'.tr);
        return;
      }

      final status = payload is Map ? payload['status'] : null;
      if (status is Map<String, dynamic>) _applyStatus(status);

      final result = await StripeConnectOnboardingBridge.present(
        publishableKey: key,
        clientSecret: secret,
        title: 'stripe_connect.view.title'.tr,
        primaryColor: AppDesign.accent,
        refreshSecret: _refreshSessionSecret,
      );

      if (!result.opened) {
        // SDK natif absent ou écran impossible à présenter : page hébergée.
        await _openHosted(null);
        return;
      }

      await loadStatus(silent: true);
      final finished = isPending || isApproved || detailsSubmitted.value;
      if (finished) {
        _announceReceived();
        _warnIfOtherIban();
      } else if (result.loadError != null) {
        // Le formulaire intégré n'a pas pu se charger : on propose la page sécurisée.
        formError.value = 'stripe_connect.hosted.embedded_load_failed'.tr;
        showHostedFallback.value = true;
      }
    } catch (_) {
      formError.value = 'stripe_connect.errors.generic_retry'.tr;
    } finally {
      isOpening.value = false;
    }
  }

  /// Session expirée pendant l'inscription : nouveau client secret.
  Future<String?> _refreshSessionSecret() async {
    final res = await StripeConnectService.accountSession();
    final payload = res.data?['data'];
    return res.success && payload is Map ? payload['client_secret']?.toString() : null;
  }

  /// Ouvre la page d'inscription hébergée par Stripe (bouton de secours).
  Future<void> openHostedPage() async {
    if (isOpening.value) return;
    formError.value = null;
    countryError.value = null;
    showHostedFallback.value = false;

    String? country;
    if (!_readCountry((c) => country = c)) return;

    isOpening.value = true;
    try {
      await _openHosted(country);
    } catch (_) {
      formError.value = 'stripe_connect.errors.generic_retry'.tr;
    } finally {
      isOpening.value = false;
    }
  }

  Future<void> _openHosted(String? country) async {
    final res = await StripeConnectService.onboardingLink(country: country ?? _pendingCountry());
    final payload = res.data?['data'];
    final url = payload is Map ? payload['url']?.toString() : null;

    if (!res.success || url == null || url.isEmpty) {
      _showApiError(res, fallbackMessage: 'stripe_connect.hosted.link_missing'.tr);
      return;
    }

    final status = payload is Map ? payload['status'] : null;
    if (status is Map<String, dynamic>) _applyStatus(status);

    final opened = await _launch(Uri.parse(url));
    if (!opened) {
      formError.value = 'stripe_connect.hosted.open_failed'.tr;
      return;
    }
    _startWaiting();
  }

  /// Pays à transmettre si le compte n'existe pas encore.
  String? _pendingCountry() =>
      hasAccount.value ? null : countryController.text.trim().toUpperCase();

  /// Erreur d'API affichée au vendeur (sous le champ pays si elle le concerne).
  void _showApiError(ApiResponse res, {required String fallbackMessage}) {
    final errors = res.data?['errors'];
    if (errors is Map && errors['country'] is List && (errors['country'] as List).isNotEmpty) {
      countryError.value = '${(errors['country'] as List).first}';
    }
    formError.value =
        res.success ? fallbackMessage : _friendlyError(res.message, statusCode: res.statusCode);
    // Le compte a pu être créé avant l'échec : on relit le statut.
    loadStatus(silent: true);
  }

  /// Navigateur intégré (Safari / Chrome Custom Tabs, recommandé par Stripe :
  /// une WebView bloque la vérification d'identité), sinon le navigateur.
  Future<bool> _launch(Uri uri) async {
    for (final mode in [LaunchMode.inAppBrowserView, LaunchMode.externalApplication]) {
      try {
        if (await launchUrl(uri, mode: mode)) return true;
      } catch (_) {
        // Mode non pris en charge sur cet appareil : on essaie le suivant.
      }
    }
    return false;
  }

  void _startWaiting() {
    awaitingStripe.value = true;
    _pollUntil = DateTime.now().add(const Duration(minutes: 15));
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (_pollUntil != null && DateTime.now().isAfter(_pollUntil!)) {
        _stopPolling();
        return;
      }
      loadStatus(silent: true);
    });
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _finishWaiting() {
    _stopPolling();
    awaitingStripe.value = false;
    // Referme la page Stripe si elle est encore ouverte dans l'app.
    closeInAppWebView().catchError((_) {});
    _announceReceived();
  }

  void _announceReceived() {
    showHostedFallback.value = false;
    formError.value = null;
    AppFeedback.show(
      'stripe_connect.hosted.done_title'.tr,
      'stripe_connect.hosted.done_message'.tr,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppDesign.success,
      colorText: Colors.white,
    );
  }

  /// L'IBAN saisi chez Stripe n'est pas celui vérifié par ASSO : on le signale
  /// (sans bloquer : c'est celui enregistré chez Stripe qui sera utilisé).
  void _warnIfOtherIban() {
    final checked = verifiedLast4.value;
    final saved = ibanLast4.value;
    if (checked == null || saved == null || checked == saved) return;
    AppFeedback.show(
      'stripe_connect.hosted.iban_mismatch_title'.tr,
      'stripe_connect.hosted.iban_mismatch_message'.trParams({'saved': saved, 'checked': checked}),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppDesign.accent,
      colorText: Colors.white,
      duration: const Duration(seconds: 6),
    );
  }

  /// Le vendeur revient sans avoir terminé : relecture manuelle du statut.
  Future<void> checkStatusNow() => loadStatus(silent: true);

  /// Désynchronise l'IBAN après confirmation : le compte Stripe est fermé et
  /// l'écran d'inscription est rouvert pour en configurer un autre.
  Future<void> unlink() async {
    if (isUnlinking.value) return;
    final ok = await Get.dialog<bool>(AlertDialog(
      title: Text('stripe_connect.unlink.title'.tr),
      content: Text('stripe_connect.unlink.confirm'.tr),
      actions: [
        TextButton(onPressed: () => Get.back(result: false), child: Text('common.cancel'.tr)),
        TextButton(
          onPressed: () => Get.back(result: true),
          style: TextButton.styleFrom(foregroundColor: AppDesign.danger),
          child: Text('stripe_connect.unlink.action'.tr),
        ),
      ],
    ));
    if (ok != true) return;

    isUnlinking.value = true;
    try {
      final res = await StripeConnectService.unlink();
      if (res.success && res.data != null) _applyStatus(res.data!);
      AppFeedback.show(
        res.success ? 'stripe_connect.unlink.done_title'.tr : 'stripe_connect.error'.tr,
        res.success
            ? (res.message.isNotEmpty ? res.message : 'stripe_connect.unlink.done_title'.tr)
            : _friendlyError(res.message, statusCode: res.statusCode),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: res.success ? AppDesign.success : AppDesign.danger,
        colorText: Colors.white,
      );
    } catch (_) {
      AppFeedback.show(
        'stripe_connect.error'.tr,
        'stripe_connect.errors.generic_retry'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppDesign.danger,
        colorText: Colors.white,
      );
    } finally {
      isUnlinking.value = false;
    }
  }

  /// Message d'erreur présentable : les messages du serveur sont traduits et
  /// choisis ; un texte technique brut (Stripe, réseau…) est remplacé.
  String _friendlyError(String message, {int? statusCode}) {
    final raw = message.trim();
    // Échec réseau côté app (hors ligne, pas d'internet) : ApiProvider fournit
    // déjà un message traduit.
    if (statusCode == 0) {
      return raw.isNotEmpty ? raw : 'stripe_connect.errors.service_unavailable'.tr;
    }
    if (raw.isEmpty) {
      return statusCode == 503
          ? 'stripe_connect.errors.service_unavailable'.tr
          : 'stripe_connect.errors.generic_retry'.tr;
    }

    final low = raw.toLowerCase();
    const technicalMarkers = [
      'stripe.com',
      'could not connect',
      'could not resolve host',
      'network error',
      'errno',
      'http',
      'connection',
      'timeout',
      'ssl',
      'curl',
      'exception',
      'acct_',
    ];
    if (technicalMarkers.any(low.contains)) {
      return 'stripe_connect.errors.service_unavailable'.tr;
    }

    // 4xx/5xx avec message du serveur : il explique la cause au vendeur.
    if (statusCode == 422 || statusCode == 503 || statusCode == 502 || statusCode == 409) {
      return raw;
    }
    return 'stripe_connect.errors.generic_retry'.tr;
  }

  String? validateCountry(String? v) {
    final country = (v ?? '').trim().toUpperCase();
    if (country.isEmpty) return 'stripe_connect.validation.country_required'.tr;
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(country)) return 'stripe_connect.validation.country_code'.tr;
    return null;
  }
}
