import '../providers/api_provider.dart';
import '../../core/values/constants.dart';

class WalletService {
  /// Get wallet balance info and stats
  static Future<ApiResponse> getWallet() async {
    return await ApiProvider.get(AppConstants.walletUrl);
  }

  /// Get wallet transactions with filters
  static Future<ApiResponse> getTransactions({
    int page = 1,
    int perPage = 20,
    String? type, // credit, debit, refund, bonus, adjustment
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (type != null) params['type'] = type;

    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return await ApiProvider.get('${AppConstants.walletTransactionsUrl}?$query');
  }

  /// Recharge wallet via KPay (Mobile Money) ou PayPal
  static Future<ApiResponse> recharge({
    required double amount,
    required String paymentMethod, // 'kpay' ou 'paypal'
    String? provider, // code opérateur KPay (ex. MTN_MOMO_CMR) — requis pour kpay
    String? phoneNumber, // format international sans '+' (ex. 237670000001) — requis pour kpay
  }) async {
    final data = <String, dynamic>{
      'amount': amount,
      'payment_method': paymentMethod,
    };
    if (provider != null) data['provider'] = provider;
    if (phoneNumber != null) data['phone_number'] = phoneNumber;

    return await ApiProvider.post(AppConstants.walletRechargeUrl, body: data);
  }

  /// Check if user can pay with wallet
  static Future<ApiResponse> canPay({required double amount}) async {
    return await ApiProvider.post(
      AppConstants.walletCanPayUrl,
      body: {'amount': amount},
    );
  }

  /// Pay with wallet
  /// paymentProvider: 'kpay' ou 'paypal' (indique d'où déduire le montant)
  static Future<ApiResponse> pay({
    required double amount,
    required String description,
    required String referenceType, // 'order', 'subscription', etc.
    required int referenceId,
    required String paymentProvider, // 'kpay' ou 'paypal'
  }) async {
    return await ApiProvider.post(AppConstants.walletPayUrl, body: {
      'amount': amount,
      'description': description,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'payment_provider': paymentProvider,
    });
  }

  /// Get withdrawal balances (separated by provider)
  static Future<ApiResponse> getWithdrawalBalances() async {
    return await ApiProvider.get(AppConstants.walletWithdrawalBalancesUrl);
  }

  /// Initiate KPay withdrawal (Mobile Money)
  static Future<ApiResponse> withdrawKpay({
    required double amount,
    required String provider, // code opérateur KPay (ex. MTN_MOMO_CMR)
    required String phoneNumber, // format international sans '+' (ex. 237670000001)
    String? notes,
  }) async {
    final data = <String, dynamic>{
      'amount': amount,
      'provider': provider,
      'phone': phoneNumber,
    };
    if (notes != null) data['notes'] = notes;

    return await ApiProvider.post(
      AppConstants.walletWithdrawKpayUrl,
      body: data,
    );
  }

  /// Initiate Stripe withdrawal (virement bancaire vers l'IBAN validé)
  static Future<ApiResponse> withdrawStripe({
    required double amount,
    String? currency,
    String? notes,
  }) async {
    final data = <String, dynamic>{
      'amount': amount,
    };
    // Devise DÉBITÉE (celle du portefeuille) ; le serveur convertit vers la
    // devise du compte bancaire.
    if (currency != null) data['currency'] = currency;
    if (notes != null) data['notes'] = notes;

    return await ApiProvider.post(
      AppConstants.walletWithdrawStripeUrl,
      body: data,
    );
  }

  /// Devis d'un virement IBAN : ce que le vendeur recevra réellement.
  static Future<ApiResponse> stripeWithdrawalQuote({
    required double amount,
    String? currency,
  }) async {
    return await ApiProvider.post(
      AppConstants.walletStripeQuoteUrl,
      body: {
        'amount': amount,
        if (currency != null) 'currency': currency,
      },
    );
  }

  /// Get withdrawal history with filters
  static Future<ApiResponse> getWithdrawalHistory({
    int page = 1,
    int perPage = 20,
    String? provider, // 'kpay' ou 'paypal'
    String? status, // 'pending', 'processing', 'completed', 'failed', 'cancelled'
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'per_page': perPage.toString(),
    };
    if (provider != null) params['provider'] = provider;
    if (status != null) params['status'] = status;

    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    return await ApiProvider.get('${AppConstants.walletWithdrawalsUrl}?$query');
  }

  /// Check withdrawal status
  static Future<ApiResponse> checkWithdrawalStatus(int withdrawalId) async {
    return await ApiProvider.get(
      '${AppConstants.walletWithdrawalStatusUrl}/$withdrawalId',
    );
  }

  /// Client confirms delivery (unlocks money to vendor + delivery person)
  /// This is kept for backward compatibility
  static Future<ApiResponse> confirmDelivery(int orderId) async {
    return await ApiProvider.post(
      '${AppConstants.confirmDeliveryUrl}/$orderId/confirm-delivery',
      body: {},
    );
  }

  /// Coordonnées de retrait Mobile Money enregistrées (`data` = null si aucune).
  static Future<ApiResponse> getPayoutAccount() async {
    return await ApiProvider.get(AppConstants.walletPayoutAccountUrl);
  }

  /// Enregistre / remplace les coordonnées de retrait Mobile Money.
  static Future<ApiResponse> savePayoutAccount({
    required String provider, // code opérateur KPay (ex. ORANGE_CMR)
    required String phoneNumber, // international sans '+'
    String? accountHolder,
  }) async {
    return await ApiProvider.put(
      AppConstants.walletPayoutAccountUrl,
      body: {
        'provider': provider,
        'phone_number': phoneNumber,
        if (accountHolder != null && accountHolder.isNotEmpty)
          'account_holder': accountHolder,
      },
    );
  }

  /// Supprime les coordonnées de retrait enregistrées.
  static Future<ApiResponse> deletePayoutAccount() async {
    return await ApiProvider.delete(AppConstants.walletPayoutAccountUrl);
  }

  // ---- IBAN et retraits par méthode -----------------------------------

  static const String _ibanCheckUrl = '/v1/wallet/iban/check';
  static const String _bankAccountUrl = '/v1/wallet/bank-account';
  static const String _withdrawPreviewUrl = '/v1/wallet/withdraw/preview';
  static const String _withdrawBankUrl = '/v1/wallet/withdraw/bank';

  /// Vérifie un IBAN : `data.valid`, `data.stripe_supported`, `data.next_step`
  /// (fix | stripe_onboarding | recommend_mobile_money).
  static Future<ApiResponse> checkIban(String iban) async {
    return await ApiProvider.post(_ibanCheckUrl, body: {'iban': iban});
  }

  /// IBAN enregistré pour un virement manuel (banque non prise en charge par Stripe).
  static Future<ApiResponse> getBankAccount() async {
    return await ApiProvider.get(_bankAccountUrl);
  }

  static Future<ApiResponse> saveBankAccount({
    required String iban,
    required String accountHolder,
    String? bic,
    String? bankName,
  }) async {
    return await ApiProvider.put(
      _bankAccountUrl,
      body: {
        'iban': iban,
        'account_holder': accountHolder,
        if (bic != null && bic.isNotEmpty) 'bic': bic,
        if (bankName != null && bankName.isNotEmpty) 'bank_name': bankName,
      },
    );
  }

  static Future<ApiResponse> deleteBankAccount() async {
    return await ApiProvider.delete(_bankAccountUrl);
  }

  /// Aperçu d'un retrait : frais, net reçu, automatique ou demande (≈ 48 h).
  static Future<ApiResponse> previewWithdrawal({
    required String method, // mobile_money | bank_transfer
    required double amount,
    String? currency,
    String? provider,
  }) async {
    return await ApiProvider.post(
      _withdrawPreviewUrl,
      body: {
        'method': method,
        'amount': amount,
        if (currency != null) 'currency': currency,
        if (provider != null) 'provider': provider,
      },
    );
  }

  /// Virement bancaire : IBAN Stripe (automatique ou demande) ou IBAN manuel.
  static Future<ApiResponse> withdrawBank({
    required double amount,
    String? currency,
    String? notes,
  }) async {
    return await ApiProvider.post(
      _withdrawBankUrl,
      body: {
        'amount': amount,
        if (currency != null) 'currency': currency,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      },
    );
  }

  /// Annule une demande de retrait pas encore prise en charge par ASSO.
  static Future<ApiResponse> cancelWithdrawal(int withdrawalId) async {
    return await ApiProvider.post('/v1/wallet/withdrawals/$withdrawalId/cancel');
  }
}
