import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../routes/app_pages.dart';

/// Prévient l'utilisateur qu'une version plus récente est publiée sur les
/// stores, et l'y renvoie pour l'installer.
///
/// Le correctif Dart passe par Shorebird et n'a pas besoin de ce passage : ce
/// garde-fou ne sert qu'aux vraies releases (dépendance ajoutée, code natif,
/// montée de version), les seules que Shorebird ne peut pas pousser.
///
/// La version publiée est lue directement sur l'App Store et le Play Store à
/// partir de l'identifiant de l'application, sans réglage côté serveur.
class AppUpdateGate extends StatelessWidget {
  const AppUpdateGate({super.key, required this.child, this.upgrader});

  final Widget child;

  /// Remplace le vérificateur partagé, pour les tests.
  @visibleForTesting
  final AppUpgrader? upgrader;

  /// Délai avant de reproposer la mise à jour à qui a répondu.
  static const _rappel = Duration(days: 3);

  /// Une seule instance pour toute la vie de l'application.
  ///
  /// Ce widget est reconstruit avec l'application (thème, langue, retour au
  /// premier plan…) : en recréer une à chaque fois laissait derrière chaque
  /// reconstruction un vérificateur et son flux jamais fermés.
  ///
  /// Aucun texte n'est fixé ici : la fenêtre prend la langue de l'application
  /// au moment où elle s'ouvre, et suit donc un changement de langue.
  static final AppUpgrader _upgrader = AppUpgrader(
    durationUntilAlertAgain: _rappel,
    // En débogage la version installée ne correspond pas à celle publiée :
    // sans cela, la fenêtre s'ouvrirait à chaque démarrage.
    debugDisplayAlways: false,
  );

  @override
  Widget build(BuildContext context) {
    return _AppUpgradeAlert(
      upgrader: upgrader ?? _upgrader,
      // Ce widget enveloppe le navigateur, il n'est pas dessous : sans sa
      // clé, la fenêtre cherchait un Navigator au-dessus d'elle et échouait.
      navigatorKey: Get.key,
      // « Ignorer » masquerait la version à vie, y compris une mise à jour
      // importante : seul « plus tard » est proposé.
      showIgnore: false,
      showLater: true,
      showReleaseNotes: true,
      child: child,
    );
  }
}

/// Vérificateur qui ne se montre que sur l'accueil.
///
/// Après le splash, l'accueil est l'écran où tout utilisateur d'une ancienne
/// version arrive (directement, ou après connexion ou préférences). Ailleurs
/// la fenêtre gênait, ou disparaissait : ouverte sur le splash, la
/// connexion ou les préférences, elle était emportée par le `offAllNamed` qui
/// termine chacun de ces écrans ; ouverte au retour au premier plan, elle
/// tombait au milieu d'un paiement. Elle attend donc que l'utilisateur soit
/// sur l'accueil depuis un instant.
class AppUpgrader extends Upgrader {
  AppUpgrader({
    super.client,
    super.durationUntilAlertAgain,
    super.messages,
    super.debugDisplayAlways,
    super.storeController,
    super.upgraderOS,
    @visibleForTesting this.ouvrir = _ouvrir,
  });

  /// Ouvre un lien hors de l'application ; remplacé dans les tests.
  final Future<bool> Function(Uri url, LaunchMode mode) ouvrir;

  static Future<bool> _ouvrir(Uri url, LaunchMode mode) =>
      launchUrl(url, mode: mode);

  /// Intervalle auquel on regarde si l'utilisateur est sur l'accueil.
  static const _intervalle = Duration(milliseconds: 500);

  /// Nombre de relevés consécutifs sur l'accueil avant d'ouvrir : laisse
  /// l'écran finir d'apparaître.
  static const _releves = 2;

  Timer? _attente;

  static bool get _surAccueil => Get.currentRoute == Routes.HOME;

  @override
  bool shouldDisplayUpgrade() {
    if (!super.shouldDisplayUpgrade()) return false;
    if (_surAccueil) return true;
    reproposer();
    return false;
  }

  /// Relance l'évaluation dès que l'utilisateur est sur l'accueil.
  ///
  /// `UpgradeAlert` ne réévalue qu'à chaque nouvel état, qui sans cela
  /// n'arriverait qu'au prochain retour au premier plan.
  void reproposer() {
    if (_attente?.isActive ?? false) return;
    var releves = 0;
    _attente = Timer.periodic(_intervalle, (timer) {
      releves = _surAccueil ? releves + 1 : 0;
      if (releves < _releves) return;
      timer.cancel();
      updateStream();
    });
  }

  /// Upgrader retient l'alerte dès son affichage, et ne la repropose plus
  /// avant [durationUntilAlertAgain] : une fenêtre emportée par une
  /// redirection, que personne n'a vue, comptait comme vue. Seule une
  /// réponse de l'utilisateur est retenue, par [retenirReponse].
  @override
  Future<bool> saveLastAlerted() async => true;

  /// L'utilisateur a répondu : pas de nouvelle proposition avant le délai.
  Future<bool> retenirReponse() => super.saveLastAlerted();

  /// Ouvre la fiche de l'application dans le store.
  ///
  /// Upgrader vérifiait d'abord `canLaunchUrl`, et abandonnait sans rien dire
  /// au moindre refus ; il ouvrait aussi la fiche App Store dans un
  /// navigateur intégré plutôt que dans l'App Store. Ici l'app du store est
  /// ouverte directement, et à défaut (téléphone sans Play Store, comme les
  /// Huawei récents) la fiche s'ouvre dans le navigateur.
  @override
  Future<void> sendUserToAppStore() async {
    final lien = versionInfo?.appStoreListingURL;
    if (lien == null || lien.isEmpty) return;
    final url = Uri.parse(lien);
    if (state.upgraderOS.isAndroid &&
        await _essayer(url, LaunchMode.externalNonBrowserApplication)) {
      return;
    }
    await _essayer(url, LaunchMode.externalApplication);
  }

  Future<bool> _essayer(Uri url, LaunchMode mode) async {
    try {
      return await ouvrir(url, mode);
    } catch (_) {
      // Aucune application pour ce lien : Android lève une erreur.
      return false;
    }
  }

  @override
  void dispose() {
    _attente?.cancel();
    super.dispose();
  }
}

class _AppUpgradeAlert extends UpgradeAlert {
  _AppUpgradeAlert({
    required AppUpgrader super.upgrader,
    super.navigatorKey,
    super.showIgnore,
    super.showLater,
    super.showReleaseNotes,
    super.child,
  });

  @override
  UpgradeAlertState createState() => _AppUpgradeAlertState();
}

/// Fenêtre reproposée quand elle disparaît sans réponse.
///
/// Une redirection — vers la connexion quand la session a expiré, par
/// exemple — la retire sans que l'utilisateur ait rien choisi. Upgrader la
/// croyait encore ouverte et n'en montrait plus aucune de la session : elle
/// revient ici au prochain passage sur l'accueil.
class _AppUpgradeAlertState extends UpgradeAlertState {
  AppUpgrader get _upgrader => widget.upgrader as AppUpgrader;

  /// Vrai dès que l'utilisateur a touché un bouton de la fenêtre ouverte.
  bool _repondu = false;

  @override
  void showTheDialog({
    Key? key,
    required BuildContext context,
    required String? title,
    required String message,
    required String? releaseNotes,
    required bool barrierDismissible,
    required UpgraderMessages messages,
  }) {
    _repondu = false;
    // Une clé neuve par ouverture : elle retrouve la route de la fenêtre.
    final cle = GlobalKey();
    super.showTheDialog(
      key: cle,
      context: context,
      title: title,
      message: message,
      releaseNotes: releaseNotes,
      barrierDismissible: barrierDismissible,
      messages: messages,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _suivre(cle));
  }

  void _suivre(GlobalKey cle) {
    final fenetre = cle.currentContext;
    final route = fenetre == null ? null : ModalRoute.of(fenetre);
    if (route == null) {
      // Jamais affichée (navigateur indisponible, ou déjà emportée).
      _reproposer();
      return;
    }
    // Se termine aussi quand la route est retirée par une redirection.
    route.popped.whenComplete(() {
      if (!_repondu) _reproposer();
    });
  }

  void _reproposer() {
    if (!mounted) return;
    displayed = false;
    _upgrader.reproposer();
  }

  @override
  void onUserLater(BuildContext context, bool shouldPop) {
    _repondu = true;
    unawaited(_upgrader.retenirReponse());
    super.onUserLater(context, shouldPop);
  }

  @override
  void onUserUpdated(BuildContext context, bool shouldPop) {
    _repondu = true;
    unawaited(_upgrader.retenirReponse());
    super.onUserUpdated(context, shouldPop);
  }
}
