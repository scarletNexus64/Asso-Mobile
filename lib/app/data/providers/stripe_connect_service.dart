import '../../core/values/constants.dart';
import 'api_provider.dart';

/// Appels API du compte de virement vendeur (IBAN via Stripe Connect).
///
/// L'identité et l'IBAN ne transitent jamais par l'application : la
/// réglementation impose qu'ils soient collectés par Stripe : soit dans le
/// composant d'inscription intégré (SDK natif), soit sur sa page hébergée.
class StripeConnectService {
  /// Statut du compte de virement du vendeur connecté (relu chez Stripe).
  /// GET /v1/stripe/connect/status
  static Future<ApiResponse> getStatus() async {
    return await ApiProvider.get(AppConstants.stripeConnectStatusUrl);
  }

  /// Session de l'inscription intégrée à l'app (client secret + clé publique).
  /// Le pays n'est utile qu'à la création du compte.
  /// POST /v1/stripe/connect/account-session
  static Future<ApiResponse> accountSession({String? country}) async {
    return await ApiProvider.post(AppConstants.stripeConnectAccountSessionUrl, body: {
      if (country != null && country.isNotEmpty) 'country': country,
    });
  }

  /// Lien vers la page d'inscription hébergée par Stripe (secours). Le pays n'est utile qu'à la
  /// création du compte (il est ensuite figé).
  /// POST /v1/stripe/connect/onboarding
  static Future<ApiResponse> onboardingLink({String? country}) async {
    return await ApiProvider.post(AppConstants.stripeConnectOnboardingUrl, body: {
      if (country != null && country.isNotEmpty) 'country': country,
    });
  }

  /// Désynchronise l'IBAN : le compte Stripe est fermé (refusé pendant un
  /// virement en cours ou s'il reste des fonds).
  /// DELETE /v1/stripe/connect
  static Future<ApiResponse> unlink() async {
    return await ApiProvider.delete(AppConstants.stripeConnectUrl);
  }
}
