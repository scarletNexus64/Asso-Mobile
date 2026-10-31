import 'package:get/get.dart';

import '../../stripeConnect/controllers/stripe_connect_controller.dart';
import '../../wallet/controllers/wallet_controller.dart';

/// « Moyens de paiement » réutilise les contrôleurs existants : IBAN (Stripe
/// Connect) et Mobile Money (portefeuille), sans dupliquer leur logique.
class PaymentMethodsBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<WalletController>()) {
      Get.lazyPut<WalletController>(() => WalletController());
    }
    if (!Get.isRegistered<StripeConnectController>()) {
      Get.lazyPut<StripeConnectController>(() => StripeConnectController());
    }
  }
}
