import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:asso/app/core/widgets/app_update_gate.dart';
import 'package:asso/app/routes/app_pages.dart';

const _fiche = 'https://play.google.com/store/apps/details?id=com.asso.asso';

/// Store qui annonce, sans réseau, une version plus récente que celle
/// installée ou la même.
class _FakeStore extends UpgraderStore {
  _FakeStore({required this.newer});

  final bool newer;

  @override
  Future<UpgraderVersionInfo> getVersionInfo({
    required state,
    required installedVersion,
    required country,
    required language,
  }) async => UpgraderVersionInfo(
    appStoreListingURL: _fiche,
    appStoreVersion: newer
        ? installedVersion.incrementMinor()
        : installedVersion,
    installedVersion: installedVersion,
  );
}

/// Liens ouverts par le bouton « Mettre à jour ».
typedef _Ouverture = (Uri, LaunchMode);

AppUpgrader _upgrader({
  required bool newer,
  UpgraderOS? os,
  List<_Ouverture>? ouverts,
  bool sansPlayStore = false,
}) {
  UpgraderStore store() => _FakeStore(newer: newer);
  return AppUpgrader(
    upgraderOS: os ?? MockUpgraderOS(android: true),
    storeController: UpgraderStoreController(onAndroid: store, oniOS: store),
    ouvrir: (url, mode) async {
      if (sansPlayStore && mode == LaunchMode.externalNonBrowserApplication) {
        throw PlatformException(code: 'ACTIVITY_NOT_FOUND');
      }
      ouverts?.add((url, mode));
      return true;
    },
  );
}

Widget _page(String texte) => Scaffold(body: Text(texte));

Widget _app(Upgrader upgrader, {Locale locale = const Locale('fr', 'FR')}) {
  return GetMaterialApp(
    initialRoute: Routes.SPLASH,
    getPages: [
      GetPage(name: Routes.SPLASH, page: () => _page('Splash')),
      GetPage(name: Routes.HOME, page: () => _page('Accueil')),
      GetPage(name: Routes.LOGIN, page: () => _page('Connexion')),
      GetPage(name: Routes.PREFERENCES, page: () => _page('Préférences')),
    ],
    locale: locale,
    supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
    localizationsDelegates: const [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    builder: (context, child) => AppUpdateGate(
      upgrader: upgrader as AppUpgrader,
      child: child ?? const SizedBox.shrink(),
    ),
  );
}

/// Laisse l'initialisation d'upgrader (préférences, version installée, store)
/// aboutir, puis les relevés d'attente de l'accueil.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
  await tester.pumpAndSettle();
}

/// Démarre l'application sur le splash, puis le quitte vers [route], comme
/// le fait le splash.
Future<void> _demarrer(
  WidgetTester tester,
  Upgrader upgrader, {
  String route = Routes.HOME,
  Locale locale = const Locale('fr', 'FR'),
}) async {
  await tester.pumpWidget(_app(upgrader, locale: locale));
  await _settle(tester);
  Get.offAllNamed(route);
  await _settle(tester);
}

void main() {
  final fr = UpgraderMessages(code: 'fr');
  final en = UpgraderMessages(code: 'en');

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PackageInfo.setMockInitialValues(
      appName: 'Asso',
      packageName: 'com.asso.asso',
      version: '1.1.3',
      buildNumber: '15',
      buildSignature: '',
    );
  });

  tearDown(Get.reset);

  group('Moment d’affichage', () {
    testWidgets('se tait sur le splash, puis s’ouvre sur l’accueil', (
      tester,
    ) async {
      final upgrader = _upgrader(newer: true);
      await tester.pumpWidget(_app(upgrader));
      await _settle(tester);

      expect(find.text('Splash'), findsOneWidget);
      expect(find.text(fr.title), findsNothing);

      Get.offAllNamed(Routes.HOME);
      await _settle(tester);

      expect(find.text('Accueil'), findsOneWidget);
      expect(find.text(fr.title), findsOneWidget);
      expect(find.text(fr.buttonTitleUpdate), findsOneWidget);
      expect(find.text(fr.buttonTitleLater), findsOneWidget);
      // « Ignorer » masquerait la version à vie : jamais proposé.
      expect(find.text(fr.buttonTitleIgnore), findsNothing);

      upgrader.dispose();
    });

    testWidgets('attend l’accueil quand le splash mène ailleurs', (
      tester,
    ) async {
      final upgrader = _upgrader(newer: true);
      await _demarrer(tester, upgrader, route: Routes.PREFERENCES);

      // Les préférences se terminent par un `offAllNamed` qui l'emporterait.
      expect(find.text('Préférences'), findsOneWidget);
      expect(find.text(fr.title), findsNothing);

      Get.offAllNamed(Routes.HOME);
      await _settle(tester);

      expect(find.text(fr.title), findsOneWidget);

      upgrader.dispose();
    });

    testWidgets('emportée par une redirection, elle revient sur l’accueil', (
      tester,
    ) async {
      final upgrader = _upgrader(newer: true);
      await _demarrer(tester, upgrader);
      expect(find.text(fr.title), findsOneWidget);

      // Session expirée : renvoi vers la connexion, fenêtre comprise.
      Get.offAllNamed(Routes.LOGIN);
      await _settle(tester);

      expect(find.text('Connexion'), findsOneWidget);
      expect(find.text(fr.title), findsNothing);
      // Personne n'a répondu : elle ne compte pas comme vue.
      expect(upgrader.isTooSoon(), isFalse);

      Get.offAllNamed(Routes.HOME);
      await _settle(tester);

      expect(find.text(fr.title), findsOneWidget);

      upgrader.dispose();
    });

    testWidgets('rien n’est proposé quand la version installée est à jour', (
      tester,
    ) async {
      final upgrader = _upgrader(newer: false);
      await _demarrer(tester, upgrader);

      expect(find.text(fr.title), findsNothing);
      expect(find.text('Accueil'), findsOneWidget);

      upgrader.dispose();
    });

    testWidgets('la fenêtre parle la langue de l’application', (tester) async {
      final upgrader = _upgrader(newer: true);
      await _demarrer(tester, upgrader, locale: const Locale('en', 'US'));

      expect(find.text(en.title), findsOneWidget);
      expect(find.text(fr.title), findsNothing);

      upgrader.dispose();
    });
  });

  group('Réponses', () {
    testWidgets('« plus tard » referme la fenêtre et laisse l’écran en place', (
      tester,
    ) async {
      final upgrader = _upgrader(newer: true);
      await _demarrer(tester, upgrader);

      await tester.tap(find.text(fr.buttonTitleLater));
      await _settle(tester);

      expect(find.text(fr.title), findsNothing);
      expect(find.text('Accueil'), findsOneWidget);
      // Le refus est retenu : pas de nouvelle proposition avant le délai.
      expect(upgrader.isTooSoon(), isTrue);

      upgrader.dispose();
    });

    testWidgets('Android : « mettre à jour » ouvre le Play Store', (
      tester,
    ) async {
      final ouverts = <_Ouverture>[];
      final upgrader = _upgrader(newer: true, ouverts: ouverts);
      await _demarrer(tester, upgrader);

      await tester.tap(find.text(fr.buttonTitleUpdate));
      await _settle(tester);

      expect(ouverts, [
        (Uri.parse(_fiche), LaunchMode.externalNonBrowserApplication),
      ]);
      expect(find.text(fr.title), findsNothing);
      expect(upgrader.isTooSoon(), isTrue);

      upgrader.dispose();
    });

    testWidgets('Android sans Play Store : la fiche s’ouvre au navigateur', (
      tester,
    ) async {
      final ouverts = <_Ouverture>[];
      final upgrader = _upgrader(
        newer: true,
        ouverts: ouverts,
        sansPlayStore: true,
      );
      await _demarrer(tester, upgrader);

      await tester.tap(find.text(fr.buttonTitleUpdate));
      await _settle(tester);

      expect(ouverts, [(Uri.parse(_fiche), LaunchMode.externalApplication)]);

      upgrader.dispose();
    });

    testWidgets('iOS : la fiche s’ouvre dans l’App Store, pas dans l’app', (
      tester,
    ) async {
      final ouverts = <_Ouverture>[];
      final upgrader = _upgrader(
        newer: true,
        os: MockUpgraderOS(ios: true),
        ouverts: ouverts,
      );
      await _demarrer(tester, upgrader);

      await tester.tap(find.text(fr.buttonTitleUpdate));
      await _settle(tester);

      expect(ouverts, [(Uri.parse(_fiche), LaunchMode.externalApplication)]);

      upgrader.dispose();
    });
  });
}
