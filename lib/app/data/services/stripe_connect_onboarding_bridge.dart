import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Résultat de l'inscription intégrée, à sa fermeture.
class EmbeddedOnboardingResult {
  /// L'écran s'est ouvert puis a été fermé par le vendeur.
  final bool opened;

  /// Erreur de chargement remontée par le SDK Stripe (null si aucune).
  final String? loadError;

  /// Code d'erreur natif quand l'écran n'a pas pu s'ouvrir.
  final String? errorCode;

  const EmbeddedOnboardingResult({required this.opened, this.loadError, this.errorCode});
}

/// Pont vers le composant d'inscription Stripe Connect natif (iOS : AppDelegate,
/// Android : MainActivity). Le formulaire d'identité / IBAN s'affiche dans l'app,
/// aux couleurs d'ASSO.
class StripeConnectOnboardingBridge {
  static const _channel = MethodChannel('asso/stripe_connect_onboarding');

  /// Fournit un nouveau client secret quand la session Stripe expire.
  static Future<String?> Function()? _refreshSecret;

  static bool _handlerInstalled = false;

  static void _installHandler() {
    if (_handlerInstalled) return;
    _handlerInstalled = true;
    _channel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'fetchClientSecret':
          try {
            return await _refreshSecret?.call();
          } catch (e) {
            debugPrint('[StripeConnectOnboarding] Renouvellement de session impossible : $e');
            return null;
          }
        case 'loadError':
          debugPrint('[StripeConnectOnboarding] Erreur de chargement : ${call.arguments}');
          return null;
      }
      return null;
    });
  }

  /// Le SDK natif est-il présent sur cet appareil ?
  static Future<bool> isSupported() async {
    if (kIsWeb) return false;
    try {
      return await _channel.invokeMethod<bool>('isSupported') ?? false;
    } catch (_) {
      return false;
    }
  }

  /// Ouvre l'inscription intégrée et attend sa fermeture.
  static Future<EmbeddedOnboardingResult> present({
    required String publishableKey,
    required String clientSecret,
    required String title,
    required Color primaryColor,
    required Future<String?> Function() refreshSecret,
  }) async {
    _installHandler();
    _refreshSecret = refreshSecret;
    try {
      final raw = await _channel.invokeMethod<Map<dynamic, dynamic>>('present', {
        'publishableKey': publishableKey,
        'clientSecret': clientSecret,
        'title': title,
        'primaryColor': primaryColor.toARGB32(),
      });
      final error = raw?['error']?.toString();
      return EmbeddedOnboardingResult(
        opened: true,
        loadError: (error == null || error.isEmpty) ? null : error,
      );
    } on PlatformException catch (e) {
      debugPrint('[StripeConnectOnboarding] Ouverture impossible : ${e.code} ${e.message}');
      return EmbeddedOnboardingResult(opened: false, errorCode: e.code);
    } on MissingPluginException {
      return const EmbeddedOnboardingResult(opened: false, errorCode: 'unsupported');
    } finally {
      _refreshSecret = null;
    }
  }
}
