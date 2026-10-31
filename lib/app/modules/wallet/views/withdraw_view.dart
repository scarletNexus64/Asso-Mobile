import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/controllers/app_config_controller.dart';
import '../../../core/utils/app_design.dart';
import '../../../core/utils/app_feedback.dart';
import '../../../core/utils/app_theme_system.dart';
import '../../../core/utils/semantic_tone.dart';
import '../../../core/values/kpay_catalog.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_ui.dart';
import '../../../core/widgets/segmented_tabs.dart';
import '../../../data/providers/api_provider.dart';
import '../../../data/providers/currency_service.dart';
import '../../../data/providers/payment_service.dart';
import '../../../routes/app_pages.dart';
import '../controllers/wallet_controller.dart';
import '../widgets/iban_setup_sheet.dart';
import '../widgets/payout_account_sheet.dart';
import '../widgets/withdraw_widgets.dart';

/// Destination d'un retrait.
enum WithdrawDestination { mobile, bank }

/// Page « Retirer de l'argent ».
///
/// Le vendeur choisit où recevoir l'argent (Mobile Money ou IBAN), saisit le
/// montant et voit AVANT de valider : frais, montant reçu, et si le retrait part
/// tout de suite ou devient une demande traitée par ASSO (≈ 48 h).
///
/// C'est le serveur (`/wallet/withdraw/preview`) qui tranche : retrait immédiat
/// quand l'argent part par le même canal qu'il est arrivé (Mobile Money → numéro,
/// carte → IBAN validé par Stripe), demande sinon.
class WithdrawView extends StatefulWidget {
  const WithdrawView({super.key});

  @override
  State<WithdrawView> createState() => _WithdrawViewState();
}

class _WithdrawViewState extends State<WithdrawView> {
  WalletController get _wallet => Get.find<WalletController>();
  AppConfigController get _config => Get.find<AppConfigController>();

  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  bool _loading = true;
  WithdrawDestination? _destination;
  bool _showNotes = false;

  // Mobile Money : opérateur + numéro saisis (pré-remplis par le compte enregistré).
  String? _kpayProvider;
  String? _kpayPhone;
  String _kpayCurrency = 'XAF';
  // Disponibilité de l'opérateur du numéro synchronisé (null = pas encore vérifiée).
  bool? _operatorAvailable;
  bool _checkingOperator = false;

  // Aperçu serveur.
  Timer? _debounce;
  int _previewSeq = 0;
  Map<String, dynamic>? _preview;
  bool _loadingPreview = false;

  bool _submitting = false;
  Map<String, dynamic>? _result; // réponse du retrait envoyé

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    await Future.wait([
      _wallet.loadWithdrawalBalances(),
      _wallet.loadPayoutAccount(),
    ]);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _destination ??= _defaultDestination();
    });
    _syncMobile();
  }

  /// Reprend le numéro synchronisé dans le portefeuille et vérifie que le
  /// service de son opérateur répond.
  void _syncMobile() {
    final saved = _savedMobile;
    _kpayProvider = saved?['provider']?.toString();
    _kpayPhone = saved?['phone_number']?.toString();
    final oldCurrency = _kpayCurrency;
    _kpayCurrency =
        KPayCatalog.byProviderCode(_kpayProvider)?.$1.currency ??
        saved?['currency']?.toString() ??
        'XAF';
    _operatorAvailable = null;
    if (_isMobile && oldCurrency != _kpayCurrency) {
      _convertAmount(oldCurrency, _kpayCurrency);
    }
    _checkOperator();
  }

  Future<void> _checkOperator() async {
    final code = _kpayProvider;
    if (code == null) return;
    setState(() => _checkingOperator = true);
    final res = await PaymentService.checkOperatorAvailability(code);
    if (!mounted || code != _kpayProvider) return;
    setState(() {
      _checkingOperator = false;
      _operatorAvailable = res.available;
    });
  }

  /// Destination proposée d'emblée : celle qui part immédiatement pour la plus
  /// grosse part du solde.
  WithdrawDestination? _defaultDestination() {
    final stripe = _bankType == 'stripe';
    if (stripe && _wallet.cardFunds.value > _wallet.mobileFunds.value) {
      return WithdrawDestination.bank;
    }
    return WithdrawDestination.mobile;
  }

  // ------------------------------------------------------------------
  // État dérivé
  // ------------------------------------------------------------------

  String? get _bankType => _wallet.bankAccountType.value;
  bool get _stripePending =>
      _bankType != 'stripe' && _wallet.stripeWithdrawStatus.value == 'pending';
  bool get _hasBank => _bankType != null;
  int get _hours => _wallet.manualDelayHours.value;

  bool get _isMobile => _destination == WithdrawDestination.mobile;
  bool get _isBank => _destination == WithdrawDestination.bank;

  String get _currency {
    if (_isMobile) return _kpayCurrency;
    if (_bankType == 'stripe') {
      return _wallet.stripeSourceCurrency.value ?? 'XAF';
    }
    return 'XAF';
  }

  double get _available => _wallet.kpayAvailableFor(_currency);
  double get _amount =>
      double.tryParse(_amountController.text.replaceAll(' ', '')) ?? 0;

  /// Part du solde (FCFA) qui part immédiatement vers la destination choisie.
  double? get _instantLimit {
    if (_currency != 'XAF') return null;
    if (_isMobile) {
      return _wallet.kpayConfigured.value ? _wallet.mobileFunds.value : 0;
    }
    if (_isBank) return _bankType == 'stripe' ? _wallet.cardFunds.value : 0;
    return null;
  }

  bool get _isRequest => _preview?['processing_mode'] == 'manual';

  String _money(double v, [String? currency]) =>
      CurrencyService.formatAmountInCurrency(v, currency ?? _currency);

  String _fcfa(double v) => CurrencyService.formatAmountInCurrency(v, 'XAF');

  /// Raison qui empêche d'envoyer (null = prêt).
  String? get _blocker {
    if (_destination == null) {
      return 'wallet.withdraw_page.cta_choose_destination'.tr;
    }
    if (_isMobile && !_hasMobile) {
      return 'wallet.withdraw_page.mobile_empty_title'.tr;
    }
    if (_isMobile && _checkingOperator) {
      return 'wallet.withdraw_page.checking_operator'.tr;
    }
    if (_isMobile && _operatorAvailable == false) {
      return 'wallet.withdraw_page.operator_down'.trParams({
        'operator': KPayCatalog.labelFor(_kpayProvider),
      });
    }
    if (_isBank && !_hasBank) {
      return _stripePending
          ? 'wallet.withdraw_page.stripe_pending_message'.tr
          : 'wallet.withdraw_page.dest_not_set'.tr;
    }
    if (_amount <= 0) return 'wallet.withdraw_page.cta_enter_amount'.tr;
    if (_amount > _available + 0.009) {
      return 'wallet.withdraw_page.exceeds_available'.trParams({
        'amount': _money(_available),
      });
    }
    if (_loadingPreview || _preview == null) return null;
    if (_preview!['can_withdraw'] == false) {
      return _preview!['message']?.toString() ?? 'wallet.withdrawal.failed'.tr;
    }
    return null;
  }

  bool get _canSubmit =>
      _blocker == null && !_loadingPreview && _preview != null && !_submitting;

  // ------------------------------------------------------------------
  // Actions
  // ------------------------------------------------------------------

  void _select(WithdrawDestination d) {
    if (_destination == d) return;
    final oldCurrency = _destination == null ? null : _currency;
    setState(() {
      _destination = d;
      _preview = null;
    });
    // Le montant saisi suit la devise de la nouvelle destination.
    if (oldCurrency != null && oldCurrency != _currency) {
      _convertAmount(oldCurrency, _currency);
    } else {
      _schedulePreview(immediate: true);
    }
  }

  Future<void> _setupBank() async {
    if (_stripePending || _bankType == 'stripe') {
      await Get.toNamed('/stripe-connect');
    } else {
      await IbanSetupSheet.show();
    }
    if (!mounted) return;
    await _wallet.loadWithdrawalBalances();
    if (!mounted) return;
    setState(() {
      _destination = WithdrawDestination.bank;
      _preview = null;
    });
    _schedulePreview(immediate: true);
  }

  void _setAmount(double value) {
    final decimals = CurrencyService.decimalsFor(_currency);
    // Arrondi vers le bas : jamais plus que le disponible.
    final factor = decimals == 0 ? 1 : 100;
    final v = (value * factor).floor() / factor;
    _amountController.text = decimals == 0
        ? v.toStringAsFixed(0)
        : v.toStringAsFixed(2);
    _amountController.selection = TextSelection.collapsed(
      offset: _amountController.text.length,
    );
    _schedulePreview(immediate: true);
  }

  void _schedulePreview({bool immediate = false}) {
    _debounce?.cancel();
    setState(() {});
    final amount = _amount;
    if (_destination == null || amount <= 0) {
      if (_preview != null || _loadingPreview) {
        setState(() {
          _preview = null;
          _loadingPreview = false;
        });
      }
      return;
    }
    setState(() => _loadingPreview = true);
    _debounce = Timer(
      Duration(milliseconds: immediate ? 0 : 450),
      () => _fetchPreview(amount),
    );
  }

  Future<void> _fetchPreview(double amount) async {
    final seq = ++_previewSeq;
    final destination = _destination;
    final futures = <Future<dynamic>>[
      _wallet.previewWithdrawal(
        method: _isMobile ? 'mobile_money' : 'bank_transfer',
        amount: amount,
        currency: _currency,
        provider: _isMobile ? _kpayProvider : null,
      ),
      // Virement Stripe : montant converti dans la devise du compte bancaire.
      if (_isBank && _bankType == 'stripe')
        _wallet.quoteStripeWithdrawal(amount),
    ];
    final results = await Future.wait(futures);
    if (!mounted || seq != _previewSeq || destination != _destination) return;
    setState(() {
      _loadingPreview = false;
      _preview = results.first as Map<String, dynamic>?;
    });
  }

  /// Convertit le montant saisi quand l'opérateur choisi change de devise.
  Future<void> _convertAmount(String from, String to) async {
    final amount = _amount;
    if (from == to || amount <= 0) {
      _schedulePreview(immediate: true);
      return;
    }
    final res = await ApiProvider.get(
      '/v1/currencies/convert',
      queryParams: {'from': from, 'to': to, 'amount': amount},
    );
    if (!mounted) return;
    final converted = res.success ? res.data?['data']?['converted'] : null;
    if (converted != null) {
      _setAmount(double.tryParse('$converted') ?? 0);
    } else {
      _schedulePreview(immediate: true);
    }
  }

  Map<String, dynamic>? get _savedMobile => _wallet.payoutAccount.value;

  String get _destinationLabel {
    if (_isMobile) {
      return _savedMobile?['masked_phone']?.toString() ??
          '+${_kpayPhone ?? ''}';
    }
    if (_bankType == 'stripe') {
      return 'IBAN •••• ${_wallet.stripeIbanLast4.value ?? ''}';
    }
    return _wallet.manualBankAccount.value?['masked_iban']?.toString() ??
        'IBAN';
  }

  Future<void> _submit() async {
    if (!_canSubmit) {
      final reason = _blocker;
      if (reason != null) {
        AppFeedback.show('wallet.withdraw_page.failed_title'.tr, reason);
      }
      return;
    }
    final confirmed = await _confirm();
    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);
    final notes = _notesController.text.trim().isEmpty
        ? null
        : _notesController.text.trim();
    final Map<String, dynamic> result;
    if (_isMobile) {
      result = await _wallet.initiateKpayWithdrawal(
        amount: _amount,
        provider: _kpayProvider!,
        phoneNumber: _kpayPhone!,
        notes: notes,
      );
    } else {
      result = await _wallet.withdrawToBank(
        amount: _amount,
        currency: _currency,
        notes: notes,
      );
    }
    if (!mounted) return;
    setState(() => _submitting = false);

    if (result['success'] != true) {
      AppFeedback.show(
        'wallet.withdraw_page.failed_title'.tr,
        result['message']?.toString() ?? 'wallet.withdrawal.failed'.tr,
        backgroundColor: AppThemeSystem.errorColor,
        colorText: Colors.white,
      );
      return;
    }

    final data = result['data'] is Map
        ? Map<String, dynamic>.from(result['data'] as Map)
        : <String, dynamic>{};

    final id = data['withdrawal_id'];
    if (id is int && data['processing_mode'] != 'manual') {
      _wallet.trackWithdrawalInBackground(id);
    }
    _wallet.refresh();

    setState(() {
      _result = {
        ...data,
        'message': result['message'],
        'destination_label': _destinationLabel,
        'amount_entered': _amount,
        'currency_entered': _currency,
      };
    });
  }

  Future<bool?> _confirm() {
    final p = _preview!;
    final fee = _num(p['fee']);
    final net = _num(p['net_amount']);
    final request = _isRequest;

    return AppSheet.show<bool>(
      AppSheet(
        title: request
            ? 'wallet.withdraw_page.confirm_request_title'.tr
            : 'wallet.withdraw_page.confirm_title'.tr,
        footer: Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'wallet.withdraw_page.confirm_cancel'.tr,
                variant: AppButtonVariant.secondary,
                onPressed: () => Get.back(result: false),
              ),
            ),
            const SizedBox(width: AppDesign.space3),
            Expanded(
              child: AppButton(
                label: 'wallet.withdraw_page.confirm_ok'.tr,
                onPressed: () => Get.back(result: true),
              ),
            ),
          ],
        ),
        child: Builder(
          builder: (context) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              WithdrawSummaryRow(
                label: 'wallet.withdraw_page.confirm_to'.tr,
                value: _destinationLabel,
              ),
              WithdrawSummaryRow(
                label: 'wallet.withdraw_page.confirm_amount'.tr,
                value: _money(_amount),
              ),
              WithdrawSummaryRow(
                label: 'wallet.payout_methods.fee_label'.tr,
                value: fee > 0
                    ? '− ${_money(fee)}'
                    : 'wallet.payout_methods.no_fee'.tr,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppDesign.space2),
                child: AppDivider(),
              ),
              WithdrawSummaryRow(
                label: 'wallet.payout_methods.you_receive'.tr,
                value: _money(net),
                emphasize: true,
              ),
              WithdrawSummaryRow(
                label: 'wallet.payout_methods.delay_label'.tr,
                value: request
                    ? 'wallet.payout_methods.delay_manual'.trParams({
                        'hours': '$_hours',
                      })
                    : 'wallet.payout_methods.delay_instant'.tr,
                valueColor: request ? AppDesign.warning : AppDesign.success,
              ),
              if (request) ...[
                const SizedBox(height: AppDesign.space3),
                WithdrawNotice(
                  warning: true,
                  icon: Icons.schedule_rounded,
                  text: 'wallet.withdraw_page.confirm_request_note'.trParams({
                    'hours': '$_hours',
                  }),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _cancelling = false;

  Future<void> _cancelRequest(int id) async {
    final ok = await AppSheet.show<bool>(
      AppSheet(
        title: 'wallet.withdraw_page.cancel_confirm_title'.tr,
        footer: Row(
          children: [
            Expanded(
              child: AppButton(
                label: 'wallet.withdraw_page.cancel_keep'.tr,
                variant: AppButtonVariant.secondary,
                onPressed: () => Get.back(result: false),
              ),
            ),
            const SizedBox(width: AppDesign.space3),
            Expanded(
              child: AppButton(
                label: 'wallet.withdraw_page.cancel_request'.tr,
                variant: AppButtonVariant.danger,
                onPressed: () => Get.back(result: true),
              ),
            ),
          ],
        ),
        child: Builder(
          builder: (context) => Text(
            'wallet.withdraw_page.cancel_confirm_message'.tr,
            style: context.textStyle(
              FontSizeType.body2,
              color: context.ds.textSecondary,
            ),
          ),
        ),
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _cancelling = true);
    final res = await _wallet.cancelWithdrawal(id);
    if (!mounted) return;
    setState(() => _cancelling = false);

    if (res['success'] == true) {
      AppFeedback.show(
        'wallet.withdraw_page.cancelled_title'.tr,
        res['message']?.toString() ?? '',
        backgroundColor: AppThemeSystem.successColor,
        colorText: Colors.white,
      );
      Get.back();
    } else {
      AppFeedback.show(
        'wallet.withdraw_page.failed_title'.tr,
        res['message']?.toString() ?? 'wallet.errors.generic'.tr,
        backgroundColor: AppThemeSystem.errorColor,
        colorText: Colors.white,
      );
    }
  }

  static double _num(dynamic v) =>
      v is num ? v.toDouble() : double.tryParse('${v ?? ''}') ?? 0;

  // ------------------------------------------------------------------
  // Construction
  // ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.ds.canvas,
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text('wallet.withdraw_page.title'.tr),
      ),
      body: SafeArea(
        top: false,
        child: _loading
            ? _buildLoading(context)
            : _result != null
            ? _buildSuccess(context)
            : _buildForm(context),
      ),
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppDesign.space3),
          Text(
            'wallet.withdraw_page.loading'.tr,
            style: context.textStyle(
              FontSizeType.body2,
              color: context.ds.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final gutter = context.ds.gutter;

        final steps = Obx(() {
          // Relit les soldes réactifs (rafraîchis en arrière-plan).
          _wallet.cardFunds.value;
          _wallet.mobileFunds.value;
          _wallet.bankAccountType.value;
          _wallet.payoutAccount.value;
          _wallet.manualBankAccount.value;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedTabs(
                tabs: [
                  SegmentedTab(
                    label: 'wallet.withdraw_page.tab_mobile'.tr,
                    icon: Icons.phone_android_rounded,
                  ),
                  SegmentedTab(
                    label: 'wallet.withdraw_page.tab_bank'.tr,
                    icon: Icons.account_balance_rounded,
                  ),
                ],
                selectedIndex: _isBank ? 1 : 0,
                onChanged: (i) => _select(
                  i == 1
                      ? WithdrawDestination.bank
                      : WithdrawDestination.mobile,
                ),
              ),
              const SizedBox(height: AppDesign.space4),
              // Rien de synchronisé sur cet onglet : on propose de le faire.
              if (!_tabConfigured)
                _isBank ? _buildBankEmpty(context) : _buildMobileEmpty(context)
              else ...[
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: KeyedSubtree(
                    key: ValueKey(_destination),
                    child: _isBank
                        ? _buildBankFunds(context)
                        : _buildMobileFunds(context),
                  ),
                ),
                // Retrait croisé : l'autre part du solde par l'autre méthode,
                // sous forme de demande traitée par ASSO.
                if (_crossOffer(context) case final offer?) ...[
                  const SizedBox(height: AppDesign.space3),
                  offer,
                ],
                if (_isMobile && _operatorAvailable == false) ...[
                  const SizedBox(height: AppDesign.space3),
                  _buildOperatorDown(context),
                ],
                const SizedBox(height: AppDesign.space6),
                WithdrawStepTitle(
                  step: 1,
                  title: 'wallet.withdraw_page.step_amount'.tr,
                ),
                _buildAmount(context),
                if (!wide) ...[
                  const SizedBox(height: AppDesign.space6),
                  WithdrawStepTitle(
                    step: 2,
                    title: 'wallet.withdraw_page.step_summary'.tr,
                  ),
                  _buildSummary(context),
                ],
              ],
              const SizedBox(height: AppDesign.space6),
            ],
          );
        });

        if (wide) {
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              gutter,
              AppDesign.space5,
              gutter,
              AppDesign.space8,
            ),
            child: AppContentWidth(
              maxWidth: 1100,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: steps),
                  const SizedBox(width: AppDesign.space6),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        WithdrawStepTitle(
                          step: 2,
                          title: 'wallet.withdraw_page.step_summary'.tr,
                        ),
                        _buildSummary(context),
                        const SizedBox(height: AppDesign.space4),
                        _buildSubmitButton(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _load,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    gutter,
                    AppDesign.space4,
                    gutter,
                    AppDesign.space4,
                  ),
                  child: AppContentWidth(maxWidth: 640, child: steps),
                ),
              ),
            ),
            _buildBottomBar(context),
          ],
        );
      },
    );
  }

  double get _locked => _wallet.wallet.value?.totalLockedBalance ?? 0;

  /// Onglet Mobile Money : l'argent encaissé en Mobile Money part tout de
  /// suite ; celui encaissé par carte passe par une demande.
  Widget _buildMobileFunds(BuildContext context) {
    final gatewayReady = _wallet.kpayConfigured.value;
    final mobile = _wallet.mobileFunds.value;
    final card = _wallet.cardFunds.value;
    final instant = gatewayReady ? mobile : 0.0;
    final viaRequest = gatewayReady ? card : mobile + card;

    return WithdrawFundsCard(
      icon: Icons.phone_android_rounded,
      color: AppDesign.accent,
      title: 'wallet.withdraw_page.funds_mobile_title'.tr,
      instantAmount: _fcfa(instant),
      instantCaption: 'wallet.withdraw_page.funds_instant_caption'.tr,
      requestAmount: viaRequest > 0 ? _fcfa(viaRequest) : null,
      requestCaption: gatewayReady
          ? 'wallet.withdraw_page.funds_mobile_request'.trParams({
              'hours': '$_hours',
            })
          : 'wallet.withdraw_page.funds_gateway_down'.trParams({
              'hours': '$_hours',
            }),
      lockedNote: _locked > 0
          ? 'wallet.withdraw_page.locked_note'.trParams({
              'amount': _fcfa(_locked),
            })
          : null,
    );
  }

  /// Onglet Banque : l'argent encaissé par carte part tout de suite vers un
  /// IBAN validé par Stripe ; le reste (ou tout, pour un IBAN manuel) passe
  /// par une demande.
  Widget _buildBankFunds(BuildContext context) {
    final stripe = _bankType == 'stripe';
    final mobile = _wallet.mobileFunds.value;
    final card = _wallet.cardFunds.value;
    final instant = stripe ? card : 0.0;
    final viaRequest = stripe ? mobile : mobile + card;

    return WithdrawFundsCard(
      icon: Icons.account_balance_rounded,
      color: AppThemeSystem.bankColor,
      title: 'wallet.withdraw_page.funds_bank_title'.tr,
      instantAmount: _fcfa(instant),
      instantCaption: 'wallet.withdraw_page.funds_instant_caption'.tr,
      requestAmount: viaRequest > 0 ? _fcfa(viaRequest) : null,
      requestCaption: stripe
          ? 'wallet.withdraw_page.funds_bank_request'.trParams({
              'hours': '$_hours',
            })
          : 'wallet.withdraw_page.funds_bank_manual'.trParams({
              'hours': '$_hours',
            }),
      lockedNote: _locked > 0
          ? 'wallet.withdraw_page.locked_note'.trParams({
              'amount': _fcfa(_locked),
            })
          : null,
    );
  }

  bool get _hasMobile => _savedMobile != null;

  /// Aucun numéro enregistré : on propose de l'ajouter avant tout montant.
  Widget _buildMobileEmpty(BuildContext context) {
    return WithdrawEmptyState(
      icon: Icons.phone_android_outlined,
      title: 'wallet.withdraw_page.mobile_empty_title'.tr,
      message: 'wallet.withdraw_page.mobile_empty_message'.tr,
      actionLabel: 'wallet.withdraw_page.mobile_add_button'.tr,
      onAction: _setupMobile,
      secondaryLabel: _hasBank
          ? 'wallet.withdraw_page.use_bank_instead'.tr
          : null,
      onSecondary: _hasBank ? () => _select(WithdrawDestination.bank) : null,
    );
  }

  Future<void> _setupMobile() async {
    final saved = await PayoutAccountSheet.show();
    if (saved != true || !mounted) return;
    await _wallet.loadPayoutAccount();
    if (!mounted) return;
    setState(() {
      _destination = WithdrawDestination.mobile;
      _preview = null;
    });
    _syncMobile();
    _schedulePreview(immediate: true);
  }

  /// Propose de retirer par l'autre méthode : depuis Mobile Money, les fonds
  /// encaissés en Mobile Money vers la banque ; depuis Banque, les fonds
  /// encaissés par carte vers Mobile Money. C'est une demande (≈ 48 h).
  Widget? _crossOffer(BuildContext context) {
    final amount = _isMobile
        ? _wallet.mobileFunds.value
        : _wallet.cardFunds.value;
    if (amount <= 0) return null;
    return WithdrawCrossOffer(
      icon: _isMobile
          ? Icons.account_balance_rounded
          : Icons.phone_android_rounded,
      title: _isMobile
          ? 'wallet.withdraw_page.suggest_bank'.tr
          : 'wallet.withdraw_page.suggest_mobile'.tr,
      subtitle: 'wallet.withdraw_page.cross_offer_hint'.trParams({
        'amount': _fcfa(amount),
        'hours': '$_hours',
      }),
      onTap: () => _select(
        _isMobile ? WithdrawDestination.bank : WithdrawDestination.mobile,
      ),
    );
  }

  bool get _tabConfigured => _isBank ? _hasBank : _hasMobile;

  /// L'opérateur du numéro synchronisé ne répond pas : on le dit et on
  /// propose de changer de numéro (ou de passer par la banque).
  Widget _buildOperatorDown(BuildContext context) {
    final operator = KPayCatalog.labelFor(_kpayProvider);
    return AppCard(
      elevated: false,
      color: ToneColors.warning(context).background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WithdrawNotice(
            warning: true,
            icon: Icons.signal_cellular_connected_no_internet_4_bar_rounded,
            text: 'wallet.withdraw_page.operator_down'.trParams({
              'operator': operator,
            }),
          ),
          const SizedBox(height: AppDesign.space3),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'wallet.withdraw_page.change_number'.tr,
                  variant: AppButtonVariant.secondary,
                  size: AppButtonSize.small,
                  onPressed: _setupMobile,
                ),
              ),
              const SizedBox(width: AppDesign.space2),
              Expanded(
                child: AppButton(
                  label: 'wallet.withdraw_page.retry'.tr,
                  variant: AppButtonVariant.ghost,
                  size: AppButtonSize.small,
                  isLoading: _checkingOperator,
                  onPressed: _checkOperator,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankEmpty(BuildContext context) {
    if (_stripePending) {
      return WithdrawEmptyState(
        icon: Icons.hourglass_top_rounded,
        title: 'wallet.withdraw_page.dest_pending'.tr,
        message: 'wallet.withdraw_page.stripe_pending_message'.tr,
        actionLabel: 'wallet.withdraw_page.see_status'.tr,
        actionIcon: Icons.visibility_outlined,
        onAction: _setupBank,
        secondaryLabel: _hasMobile
            ? 'wallet.withdraw_page.use_mobile_instead'.tr
            : null,
        onSecondary: _hasMobile
            ? () => _select(WithdrawDestination.mobile)
            : null,
      );
    }
    return WithdrawEmptyState(
      icon: Icons.account_balance_outlined,
      title: 'wallet.withdraw_page.bank_empty_title'.tr,
      message: 'wallet.withdraw_page.bank_empty_message'.trParams({
        'hours': '$_hours',
      }),
      actionLabel: 'wallet.withdraw_page.bank_add_button'.tr,
      onAction: _setupBank,
      secondaryLabel: _hasMobile
          ? 'wallet.withdraw_page.use_mobile_instead'.tr
          : null,
      onSecondary: _hasMobile
          ? () => _select(WithdrawDestination.mobile)
          : null,
    );
  }

  Widget _buildAmount(BuildContext context) {
    final enabled = _destination != null;
    final available = _available;
    final instant = _instantLimit;
    final currencyLabel = CurrencyService.getSymbolForCode(_currency);
    final over = _amount > available + 0.009;

    return AppCard(
      elevated: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'wallet.payout_methods.available'.trParams({
              'amount': _money(available),
            }),
            style: context.textStyle(
              FontSizeType.caption,
              color: context.ds.textSecondary,
            ),
          ),
          const SizedBox(height: AppDesign.space2),
          TextField(
            controller: _amountController,
            enabled: enabled,
            keyboardType: TextInputType.numberWithOptions(
              decimal: CurrencyService.decimalsFor(_currency) > 0,
            ),
            inputFormatters: [
              CurrencyService.decimalsFor(_currency) > 0
                  ? FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))
                  : FilteringTextInputFormatter.digitsOnly,
            ],
            onChanged: (_) => _schedulePreview(),
            style: context.textStyle(
              FontSizeType.h3,
              fontWeight: FontWeight.w800,
              color: context.ds.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: '0',
              suffixText: currencyLabel,
              suffixStyle: context.textStyle(
                FontSizeType.subtitle1,
                fontWeight: FontWeight.w600,
                color: context.ds.textSecondary,
              ),
              filled: true,
              fillColor: context.ds.surfaceMuted,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppDesign.space4,
                vertical: AppDesign.space4,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesign.radiusSm),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDesign.radiusSm),
                borderSide: BorderSide(
                  color: over ? AppDesign.danger : AppDesign.accent,
                  width: 1.5,
                ),
              ),
              errorText: over
                  ? 'wallet.withdraw_page.exceeds_available'.trParams({
                      'amount': _money(available),
                    })
                  : null,
              helperText: enabled
                  ? 'wallet.withdraw_page.min_hint'.trParams({
                      'amount': _money(
                        _isBank && _bankType != 'stripe'
                            ? _wallet.minManualBankAmount.value
                            : _config.minWithdrawalAmount,
                      ),
                    })
                  : 'wallet.withdraw_page.cta_choose_destination'.tr,
            ),
          ),
          if (enabled && available > 0) ...[
            const SizedBox(height: AppDesign.space3),
            Wrap(
              spacing: AppDesign.space2,
              runSpacing: AppDesign.space2,
              children: [
                if (instant != null && instant > 0 && instant < available)
                  ActionChip(
                    avatar: const Icon(
                      Icons.bolt_rounded,
                      size: 16,
                      color: AppDesign.success,
                    ),
                    label: Text(
                      'wallet.withdraw_page.chip_instant'.trParams({
                        'amount': _money(instant),
                      }),
                    ),
                    onPressed: () => _setAmount(instant),
                  ),
                ActionChip(
                  label: Text(
                    'wallet.withdraw_page.chip_all'.trParams({
                      'amount': _money(available),
                    }),
                  ),
                  onPressed: () => _setAmount(available),
                ),
              ],
            ),
          ],
          if (enabled &&
              instant != null &&
              instant > 0 &&
              instant < available) ...[
            const SizedBox(height: AppDesign.space3),
            WithdrawNotice(
              icon: Icons.bolt_rounded,
              text: 'wallet.withdraw_page.instant_tip'.trParams({
                'amount': _money(instant),
                'hours': '$_hours',
              }),
            ),
          ],
          const SizedBox(height: AppDesign.space2),
          if (!_showNotes)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: enabled
                    ? () => setState(() => _showNotes = true)
                    : null,
                icon: const Icon(Icons.edit_note_rounded, size: 18),
                label: Text('wallet.withdraw_page.add_note'.tr),
              ),
            )
          else ...[
            const SizedBox(height: AppDesign.space2),
            AppTextField(
              controller: _notesController,
              label: 'wallet.withdrawal.notes_label'.tr,
              hint: 'wallet.withdrawal.notes_hint'.tr,
              maxLines: 2,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummary(BuildContext context) {
    final p = _preview;
    final blocker = _blocker;

    if (_loadingPreview) {
      return AppCard(
        elevated: false,
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: AppDesign.space3),
            Text(
              'wallet.payout_methods.computing'.tr,
              style: context.textStyle(
                FontSizeType.body2,
                color: context.ds.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (p == null) {
      return AppCard(
        elevated: false,
        child: Row(
          children: [
            Icon(Icons.receipt_long_outlined, color: context.ds.icon),
            const SizedBox(width: AppDesign.space3),
            Expanded(
              child: Text(
                blocker ?? 'wallet.withdraw_page.cta_enter_amount'.tr,
                style: context.textStyle(
                  FontSizeType.body2,
                  color: context.ds.textSecondary,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final fee = _num(p['fee']);
    final net = _num(p['net_amount']);
    final request = _isRequest;
    final reason = p['reason_message']?.toString();
    final payoutCurrency = _wallet.stripeWithdrawCurrency.value;
    final showConversion =
        _isBank &&
        _bankType == 'stripe' &&
        !request &&
        payoutCurrency != _currency &&
        _wallet.stripeQuoteAmount.value > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCard(
          elevated: false,
          child: Column(
            children: [
              WithdrawSummaryRow(
                label: 'wallet.withdraw_page.confirm_amount'.tr,
                value: _money(_amount),
              ),
              WithdrawSummaryRow(
                label: 'wallet.payout_methods.fee_label'.tr,
                value: fee > 0
                    ? '− ${_money(fee)}'
                    : 'wallet.payout_methods.no_fee'.tr,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: AppDesign.space2),
                child: AppDivider(),
              ),
              WithdrawSummaryRow(
                label: 'wallet.payout_methods.you_receive'.tr,
                value: _money(net),
                emphasize: true,
              ),
              if (showConversion)
                WithdrawSummaryRow(
                  label: 'wallet.withdraw_page.arrives_on_account'.tr,
                  value:
                      '≈ ${_money(_wallet.stripeQuoteAmount.value, payoutCurrency)}',
                ),
              WithdrawSummaryRow(
                label: 'wallet.payout_methods.delay_label'.tr,
                value: request
                    ? 'wallet.payout_methods.delay_manual'.trParams({
                        'hours': '$_hours',
                      })
                    : 'wallet.payout_methods.delay_instant'.tr,
                valueColor: request ? AppDesign.warning : AppDesign.success,
              ),
            ],
          ),
        ),
        if (request && reason != null && reason.isNotEmpty) ...[
          const SizedBox(height: AppDesign.space3),
          WithdrawNotice(
            warning: true,
            icon: Icons.schedule_rounded,
            text: reason,
          ),
        ],
        if (blocker != null) ...[
          const SizedBox(height: AppDesign.space3),
          WithdrawNotice(
            warning: true,
            icon: Icons.error_outline_rounded,
            text: blocker,
          ),
        ],
      ],
    );
  }

  String get _ctaLabel {
    if (_preview != null && !_loadingPreview && _isRequest) {
      return 'wallet.payout_methods.send_request'.trParams({
        'hours': '$_hours',
      });
    }
    if (_amount > 0) {
      return 'wallet.withdraw_page.cta_withdraw'.trParams({
        'amount': _money(_amount),
      });
    }
    return 'wallet.actions.withdraw'.tr;
  }

  Widget _buildSubmitButton(BuildContext context) {
    return AppButton(
      label: _ctaLabel,
      size: AppButtonSize.large,
      icon: _isRequest
          ? Icons.schedule_send_rounded
          : Icons.arrow_upward_rounded,
      isLoading: _submitting,
      onPressed: _canSubmit ? _submit : null,
    );
  }

  Widget _buildBottomBar(BuildContext context) {
    final p = _preview;
    final net = p == null ? null : _num(p['net_amount']);
    final blocker = _blocker;
    return Container(
      decoration: BoxDecoration(
        color: context.ds.surface,
        border: Border(top: BorderSide(color: context.ds.border)),
      ),
      padding: EdgeInsets.fromLTRB(
        context.ds.gutter,
        AppDesign.space3,
        context.ds.gutter,
        AppDesign.space3,
      ),
      child: AppContentWidth(
        maxWidth: 640,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (net != null && !_loadingPreview && blocker == null)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDesign.space2),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'wallet.payout_methods.you_receive'.tr,
                        style: context.textStyle(
                          FontSizeType.caption,
                          color: context.ds.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      _money(net),
                      style: context.textStyle(
                        FontSizeType.body1,
                        fontWeight: FontWeight.w800,
                        color: context.ds.textPrimary,
                      ),
                    ),
                    const SizedBox(width: AppDesign.space2),
                    AppBadge(
                      tone: _isRequest
                          ? AppBadgeTone.warning
                          : AppBadgeTone.success,
                      label: _isRequest
                          ? '≈ $_hours h'
                          : 'wallet.payout_methods.delay_instant'.tr,
                    ),
                  ],
                ),
              ),
            // Ce qui manque, juste au-dessus du bouton grisé.
            if (blocker != null && !_loadingPreview)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDesign.space2),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: context.ds.textTertiary,
                    ),
                    const SizedBox(width: AppDesign.space2),
                    Expanded(
                      child: Text(
                        blocker,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyle(
                          FontSizeType.caption,
                          color: context.ds.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            _buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final r = _result!;
    final request = r['processing_mode'] == 'manual';
    final currency =
        r['currency']?.toString() ?? r['currency_entered'].toString();
    final net = _num(r['net_amount'] ?? r['amount_entered']);
    final fee = _num(r['fee']);
    final expected = DateTime.tryParse(
      r['expected_by']?.toString() ?? '',
    )?.toLocal();
    final reference = r['transaction_reference']?.toString();

    final rows = <Widget>[
      WithdrawSummaryRow(
        label: 'wallet.withdraw_page.confirm_to'.tr,
        value: r['destination_label'].toString(),
      ),
      WithdrawSummaryRow(
        label: 'wallet.withdraw_page.confirm_amount'.tr,
        value: _money(_num(r['amount'] ?? r['amount_entered']), currency),
      ),
      if (fee > 0)
        WithdrawSummaryRow(
          label: 'wallet.payout_methods.fee_label'.tr,
          value: '− ${_money(fee, currency)}',
        ),
      WithdrawSummaryRow(
        label: 'wallet.payout_methods.you_receive'.tr,
        value: _money(net, currency),
        emphasize: true,
      ),
      if (expected != null)
        WithdrawSummaryRow(
          label: 'wallet.withdraw_page.expected_label'.tr,
          value: DateFormat.yMMMd(
            Get.locale?.toLanguageTag(),
          ).add_Hm().format(expected),
          valueColor: AppDesign.warning,
        ),
      if (reference != null && reference.isNotEmpty)
        WithdrawSummaryRow(
          label: 'wallet.withdraw_page.reference'.tr,
          value: reference,
        ),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: context.ds.gutter,
        vertical: AppDesign.space4,
      ),
      child: AppContentWidth(
        maxWidth: 520,
        child: WithdrawSuccessPanel(
          isRequest: request,
          title: request
              ? 'wallet.withdraw_page.success_request_title'.tr
              : 'wallet.withdraw_page.success_instant_title'.tr,
          message: request
              ? 'wallet.withdraw_page.success_request_message'.trParams({
                  'hours': '$_hours',
                })
              : 'wallet.withdraw_page.success_instant_message'.tr,
          rows: rows,
          onHistory: () => Get.offNamed(Routes.WALLET_HISTORY),
          onDone: () => Get.back(),
          cancelling: _cancelling,
          onCancel:
              request && r['withdrawal_id'] is int && r['cancelled'] != true
              ? () => _cancelRequest(r['withdrawal_id'] as int)
              : null,
        ),
      ),
    );
  }
}
