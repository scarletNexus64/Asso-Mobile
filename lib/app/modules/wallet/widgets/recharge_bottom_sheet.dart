import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/utils/app_theme_system.dart';
import '../../../routes/app_pages.dart';
import '../controllers/wallet_controller.dart';

/// Bottom sheet pour recharger le wallet en 2 étapes
/// Step 1: Choix de la méthode de paiement
/// Step 2: Formulaire de paiement correspondant
class RechargeBottomSheet extends StatefulWidget {
  const RechargeBottomSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => const RechargeBottomSheet(),
    );
  }

  @override
  State<RechargeBottomSheet> createState() => _RechargeBottomSheetState();
}

class _RechargeBottomSheetState extends State<RechargeBottomSheet> {
  int _currentStep = 1; // 1 = choix méthode, 2 = formulaire
  String? _selectedMethod; // 'om', 'momo', 'visa', 'mastercard', 'paypal', 'crypto'

  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cardExpiryController = TextEditingController();
  final _cardCvvController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isProcessing = false;
  final walletController = Get.find<WalletController>();

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    _cardNumberController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    _cardHolderController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppThemeSystem.getBackgroundColor(context),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppThemeSystem.getHorizontalPadding(context)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppThemeSystem.grey300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header avec bouton retour et fermer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (_currentStep == 2)
                        IconButton(
                          onPressed: () => setState(() {
                            _currentStep = 1;
                            _selectedMethod = null;
                          }),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: AppThemeSystem.getPrimaryTextColor(context),
                        ),
                      if (_currentStep == 2) const SizedBox(width: 12),
                      Text(
                        _currentStep == 1
                            ? 'Recharger mon wallet'
                            : 'Montant à recharger',
                        style: TextStyle(
                          fontSize: AppThemeSystem.getFontSize(context, FontSizeType.h4),
                          fontWeight: FontWeight.bold,
                          color: AppThemeSystem.getPrimaryTextColor(context),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    color: AppThemeSystem.getSecondaryTextColor(context),
                  ),
                ],
              ),

              SizedBox(height: AppThemeSystem.getElementSpacing(context)),

              // Barre de progression par étapes
              _buildStepProgressBar(context),

              SizedBox(height: AppThemeSystem.getSectionSpacing(context)),

              // Contenu selon l'étape
              if (_currentStep == 1) _buildStep1MethodSelection(context),
              if (_currentStep == 2) _buildStep2PaymentForm(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Barre de progression par étapes
  Widget _buildStepProgressBar(BuildContext context) {
    return Row(
      children: [
        // Étape 1
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  // Cercle étape 1
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentStep >= 1
                          ? AppThemeSystem.primaryColor
                          : AppThemeSystem.grey300,
                    ),
                    child: Center(
                      child: _currentStep > 1
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppThemeSystem.whiteColor,
                              size: 18,
                            )
                          : Text(
                              '1',
                              style: TextStyle(
                                color: _currentStep >= 1
                                    ? AppThemeSystem.whiteColor
                                    : AppThemeSystem.grey600,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                  // Ligne de connexion
                  Expanded(
                    child: Container(
                      height: 2,
                      color: _currentStep >= 2
                          ? AppThemeSystem.primaryColor
                          : AppThemeSystem.grey300,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Méthode',
                style: TextStyle(
                  fontSize: 12,
                  color: _currentStep >= 1
                      ? AppThemeSystem.getPrimaryTextColor(context)
                      : AppThemeSystem.getSecondaryTextColor(context),
                  fontWeight: _currentStep == 1 ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),

        // Étape 2
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentStep >= 2
                    ? AppThemeSystem.primaryColor
                    : AppThemeSystem.grey300,
              ),
              child: Center(
                child: Text(
                  '2',
                  style: TextStyle(
                    color: _currentStep >= 2
                        ? AppThemeSystem.whiteColor
                        : AppThemeSystem.grey600,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Montant',
              style: TextStyle(
                fontSize: 12,
                color: _currentStep >= 2
                    ? AppThemeSystem.getPrimaryTextColor(context)
                    : AppThemeSystem.getSecondaryTextColor(context),
                fontWeight: _currentStep == 2 ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Step 1: Sélection de la méthode de paiement
  Widget _buildStep1MethodSelection(BuildContext context) {
    return Column(
      children: [
        // Mobile Money
        _buildMethodOption(
          context: context,
          logoPath: 'assets/images/orange-money.png',
          title: 'Orange Money',
          subtitle: 'Paiement via Orange Money',
          color: const Color(0xFFFF7900),
          onTap: () => _selectMethod('om'),
        ),

        const SizedBox(height: 12),

        _buildMethodOption(
          context: context,
          logoPath: 'assets/images/mtn-money.png',
          title: 'MTN MoMo',
          subtitle: 'Paiement via MTN Mobile Money',
          color: const Color(0xFFFFCC00),
          onTap: () => _selectMethod('momo'),
        ),

        const SizedBox(height: 12),

        // Cartes bancaires
        _buildMethodOption(
          context: context,
          logoPath: 'assets/images/visa.png',
          title: 'VISA',
          subtitle: 'Paiement par carte VISA',
          color: const Color(0xFF1A1F71),
          onTap: () => _selectMethod('visa'),
        ),

        const SizedBox(height: 12),

        _buildMethodOption(
          context: context,
          logoPath: 'assets/images/mastercard.png',
          title: 'MasterCard',
          subtitle: 'Paiement par carte MasterCard',
          color: const Color(0xFFEB001B),
          onTap: () => _selectMethod('mastercard'),
        ),

        const SizedBox(height: 12),

        _buildMethodOption(
          context: context,
          logoPath: 'assets/images/paypal.png',
          title: 'PayPal',
          subtitle: 'Paiement via PayPal',
          color: const Color(0xFF0070BA),
          onTap: () => _selectMethod('paypal'),
        ),

        const SizedBox(height: 12),

        // Crypto (Coming Soon)
        _buildMethodOption(
          context: context,
          logoPath: 'assets/images/bitcoin.png',
          title: 'Crypto',
          subtitle: 'Paiement par cryptomonnaie',
          color: AppThemeSystem.infoColor,
          isComingSoon: true,
          onTap: () {
            Get.snackbar(
              'Bientôt disponible',
              'Le paiement par cryptomonnaie sera bientôt disponible',
              backgroundColor: AppThemeSystem.infoColor,
              colorText: AppThemeSystem.whiteColor,
            );
          },
        ),
      ],
    );
  }

  Widget _buildMethodOption({
    required BuildContext context,
    required String logoPath,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    bool isComingSoon = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isComingSoon
              ? AppThemeSystem.getSurfaceColor(context).withValues(alpha: 0.5)
              : AppThemeSystem.getSurfaceColor(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isComingSoon
                ? AppThemeSystem.getBorderColor(context).withValues(alpha: 0.3)
                : AppThemeSystem.getBorderColor(context),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Logo circulaire
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(6),
              child: ClipOval(
                child: Image.asset(
                  logoPath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback si l'image n'existe pas
                    return Container(
                      color: color.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.payment,
                        color: color,
                        size: 24,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isComingSoon
                          ? AppThemeSystem.getSecondaryTextColor(context)
                          : AppThemeSystem.getPrimaryTextColor(context),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppThemeSystem.getSecondaryTextColor(context),
                    ),
                  ),
                ],
              ),
            ),
            if (isComingSoon)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppThemeSystem.infoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Bientôt',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppThemeSystem.infoColor,
                  ),
                ),
              )
            else
              Icon(
                Icons.chevron_right,
                color: AppThemeSystem.getSecondaryTextColor(context),
              ),
          ],
        ),
      ),
    );
  }

  void _selectMethod(String method) {
    setState(() {
      _selectedMethod = method;
      _currentStep = 2;
    });
  }

  /// Step 2: Formulaire de paiement
  Widget _buildStep2PaymentForm(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Montant
          TextFormField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              labelText: 'Montant (FCFA)',
              hintText: '10000',
              prefixIcon: const Icon(Icons.attach_money),
              filled: true,
              fillColor: AppThemeSystem.getSurfaceColor(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppThemeSystem.getBorderColor(context),
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez entrer un montant';
              }
              final amount = double.tryParse(value);
              if (amount == null || amount < 100) {
                return 'Le montant minimum est de 100 FCFA';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          // Champs spécifiques selon la méthode
          if (_selectedMethod == 'om' || _selectedMethod == 'momo')
            ..._buildMobileMoneyFields(context),
          if (_selectedMethod == 'visa' || _selectedMethod == 'mastercard')
            ..._buildCardFields(context),
          if (_selectedMethod == 'paypal') ..._buildPayPalFields(context),

          const SizedBox(height: 24),

          // Bouton de confirmation
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _handleRecharge,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeSystem.primaryColor,
                foregroundColor: AppThemeSystem.whiteColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isProcessing
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: AppThemeSystem.whiteColor,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Confirmer la recharge',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMobileMoneyFields(BuildContext context) {
    return [
      TextFormField(
        controller: _phoneController,
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: 'Numéro de téléphone',
          hintText: '651826475',
          prefixIcon: const Icon(Icons.phone),
          filled: true,
          fillColor: AppThemeSystem.getSurfaceColor(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez entrer votre numéro';
          }
          final cleaned = value.replaceAll(RegExp(r'[^\d]'), '');
          if (cleaned.length != 9 && cleaned.length != 12) {
            return 'Format invalide (9 ou 12 chiffres)';
          }
          return null;
        },
      ),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppThemeSystem.infoColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppThemeSystem.infoColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Vous recevrez un code USSD pour valider le paiement',
                style: TextStyle(
                  fontSize: 12,
                  color: AppThemeSystem.getSecondaryTextColor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildCardFields(BuildContext context) {
    return [
      TextFormField(
        controller: _cardHolderController,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(
          labelText: 'Nom sur la carte',
          hintText: 'JOHN DOE',
          prefixIcon: const Icon(Icons.person),
          filled: true,
          fillColor: AppThemeSystem.getSurfaceColor(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez entrer le nom';
          }
          return null;
        },
      ),
      const SizedBox(height: 12),
      TextFormField(
        controller: _cardNumberController,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(16),
        ],
        decoration: InputDecoration(
          labelText: 'Numéro de carte',
          hintText: '4111 1111 1111 1111',
          prefixIcon: const Icon(Icons.credit_card),
          filled: true,
          fillColor: AppThemeSystem.getSurfaceColor(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez entrer le numéro de carte';
          }
          if (value.length < 15) {
            return 'Numéro de carte invalide';
          }
          return null;
        },
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _cardExpiryController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              decoration: InputDecoration(
                labelText: 'Expiration',
                hintText: 'MM/AA',
                prefixIcon: const Icon(Icons.calendar_today),
                filled: true,
                fillColor: AppThemeSystem.getSurfaceColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Requis';
                }
                if (value.length != 4) {
                  return 'Format: MMAA';
                }
                return null;
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _cardCvvController,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(3),
              ],
              decoration: InputDecoration(
                labelText: 'CVV',
                hintText: '123',
                prefixIcon: const Icon(Icons.lock),
                filled: true,
                fillColor: AppThemeSystem.getSurfaceColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Requis';
                }
                if (value.length != 3) {
                  return '3 chiffres';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildPayPalFields(BuildContext context) {
    return [
      TextFormField(
        controller: _emailController,
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: 'Email PayPal',
          hintText: 'votre.email@exemple.com',
          prefixIcon: const Icon(Icons.email),
          filled: true,
          fillColor: AppThemeSystem.getSurfaceColor(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Veuillez entrer votre email PayPal';
          }
          if (!value.contains('@') || !value.contains('.')) {
            return 'Email invalide';
          }
          return null;
        },
      ),
    ];
  }

  Future<void> _handleRecharge() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final amount = double.parse(_amountController.text);

      // Déterminer le payment method et provider
      String paymentMethod;
      String? phoneNumber;

      if (_selectedMethod == 'om' || _selectedMethod == 'momo') {
        // Mobile Money via FreeMoPay
        paymentMethod = 'freemopay';
        phoneNumber = _phoneController.text.trim();

        // Initier la recharge
        final result = await walletController.initiateRecharge(
          amount: amount,
          paymentMethod: paymentMethod,
          phoneNumber: phoneNumber,
        );

        if (!mounted) return;

        if (result['success'] == true) {
          // Fermer le bottom sheet
          Navigator.of(context).pop();

          // Afficher les instructions USSD (non-bloquant)
          await _showUssdInstructionDialog(
            context,
            amount,
            phoneNumber,
            _selectedMethod == 'om' ? 'orange' : 'mtn',
          );

          // Rafraîchir le wallet et naviguer vers l'historique
          await walletController.refresh();

          // Naviguer vers l'historique pour voir la transaction en pending
          Get.toNamed(Routes.WALLET_HISTORY);
        } else {
          Get.snackbar(
            'Erreur',
            result['message'] ?? 'Échec de la recharge',
            backgroundColor: AppThemeSystem.errorColor,
            colorText: AppThemeSystem.whiteColor,
          );
        }
      } else {
        // PayPal (VISA, MasterCard, PayPal)
        paymentMethod = 'paypal';

        final result = await walletController.initiateRecharge(
          amount: amount,
          paymentMethod: paymentMethod,
        );

        if (!mounted) return;

        if (result['success'] == true) {
          Navigator.of(context).pop();

          Get.snackbar(
            'Succès',
            result['message'] ?? 'Recharge initiée avec succès',
            backgroundColor: AppThemeSystem.successColor,
            colorText: AppThemeSystem.whiteColor,
          );

          // TODO: Ouvrir PayPal pour finaliser le paiement
          // final paymentUrl = result['payment_url'];
        } else {
          Get.snackbar(
            'Erreur',
            result['message'] ?? 'Échec de la recharge',
            backgroundColor: AppThemeSystem.errorColor,
            colorText: AppThemeSystem.whiteColor,
          );
        }
      }
    } catch (e) {
      print('[RechargeBottomSheet] Error: $e');
      Get.snackbar(
        'Erreur',
        'Une erreur est survenue',
        backgroundColor: AppThemeSystem.errorColor,
        colorText: AppThemeSystem.whiteColor,
      );
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  /// Afficher le dialogue d'instructions USSD (non-bloquant)
  /// L'utilisateur peut fermer le dialogue et retourner au wallet
  /// Il recevra une notification FCM quand le paiement sera confirmé
  Future<void> _showUssdInstructionDialog(
    BuildContext context,
    double amount,
    String phoneNumber,
    String paymentMethod,
  ) async {
    final providerName = paymentMethod == 'orange' ? 'Orange Money' : 'MTN Mobile Money';
    final providerEmoji = paymentMethod == 'orange' ? '(OM)' : '(MTN)';

    return showDialog(
      context: context,
      barrierDismissible: false, // Force l'utilisateur à cliquer sur "Compris"
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Text(
              providerEmoji,
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Paiement initié',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Un code USSD a été envoyé sur le numéro :',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppThemeSystem.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  phoneNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppThemeSystem.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppThemeSystem.infoColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppThemeSystem.infoColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppThemeSystem.infoColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Instructions',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppThemeSystem.infoColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionStep(
                      '1',
                      'Composez le code USSD reçu sur votre téléphone',
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionStep(
                      '2',
                      'Entrez votre code PIN $providerName',
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionStep(
                      '3',
                      'Confirmez le paiement de ${amount.toStringAsFixed(0)} FCFA',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppThemeSystem.successColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      color: AppThemeSystem.successColor,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Vous recevrez une notification dès que le paiement sera confirmé.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppThemeSystem.successColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppThemeSystem.primaryColor,
                foregroundColor: AppThemeSystem.whiteColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Compris',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget helper pour afficher une étape d'instruction
  Widget _buildInstructionStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: AppThemeSystem.infoColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: AppThemeSystem.whiteColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
