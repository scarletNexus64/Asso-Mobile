import 'package:flutter/foundation.dart';

import '../providers/api_provider.dart';
import '../providers/storage_service.dart';

/// Envoie au serveur le pays choisi dans l'app (écran d'accueil ou réglages).
///
/// Synchro automatique (connexion, démarrage) : le serveur ne remplace que
/// le pays déduit par défaut, jamais un pays déjà confirmé. Un choix fait
/// dans les réglages ([explicit]) remplace toujours le pays du compte.
class CountrySync {
  static Future<void> push({bool explicit = false}) async {
    final country = StorageService.getCountry();
    if (country == null || country.isEmpty || !StorageService.isAuthenticated) {
      return;
    }
    try {
      await ApiProvider.post(
        '/v1/auth/country',
        body: {'country': country, if (explicit) 'explicit': true},
      );
    } catch (e) {
      // Sans réseau : nouvel essai au prochain démarrage.
      debugPrint('[CountrySync] $e');
    }
  }
}
