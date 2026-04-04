import 'package:asso/app/core/utils/app_theme_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/controllers/app_config_controller.dart';
import '../../../routes/app_pages.dart';
import '../controllers/wallet_controller.dart';
import 'paypal_native_webview.dart';

class RechargeWalletView extends GetView<WalletController> {
  const RechargeWalletView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appConfig = Get.find<AppConfigController>();
    final amountController = TextEditingController();
    final phoneController = TextEditingController();
    final selectedPaymentMethod = 'orange'.obs; // Default to Orange Money

    return Scaffold(
      backgroundColor: AppThemeSystem.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Recharger mon Wallet'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppThemeSystem.primaryColor,
        foregroundColor: AppThemeSystem.whiteColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Solde actuel
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppThemeSystem.primaryColor,
                    AppThemeSystem.primaryColor.withOpacity(0.85),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Solde Actuel',
                    style: TextStyle(
                      color: AppThemeSystem.whiteColor.withOpacity(0.9),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      controller.formattedBalance,
                      style: const TextStyle(
                        color: AppThemeSystem.whiteColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: 'Veillez renseigner le montant (FCFA)',
                hintText: 'Ex: 5000',
                prefixIcon: const Icon(Icons.attach_money),
                filled: true,
                fillColor: AppThemeSystem.getSurfaceColor(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppThemeSystem.getBorderColor(context),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppThemeSystem.getBorderColor(context),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppThemeSystem.primaryColor,
                    width: 2,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Méthode de paiement
            Text(
              'Choisissez votre méthode de paiement',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppThemeSystem.getPrimaryTextColor(context),
              ),
            ),
            const SizedBox(height: 16),

            // Payment method logos in grid
            Obx(
              () => Wrap(
                alignment: WrapAlignment.center,
                spacing: 16,
                runSpacing: 16,
                children: [
                  _buildPaymentMethodLogo(
                    imagePath: 'assets/images/orange-money.png',
                    label: 'Orange Money',
                    value: 'orange',
                    groupValue: selectedPaymentMethod.value,
                    onTap: () => selectedPaymentMethod.value = 'orange',
                  ),
                  _buildPaymentMethodLogo(
                    imagePath: 'assets/images/mtn-money.png',
                    label: 'MTN Mobile Money',
                    value: 'mtn',
                    groupValue: selectedPaymentMethod.value,
                    onTap: () => selectedPaymentMethod.value = 'mtn',
                  ),
                  _buildPaymentMethodLogo(
                    imagePath: 'assets/images/visa.png',
                    label: 'Visa',
                    value: 'visa',
                    groupValue: selectedPaymentMethod.value,
                    onTap: () => selectedPaymentMethod.value = 'visa',
                  ),
                  _buildPaymentMethodLogo(
                    imagePath: 'assets/images/mastercard.png',
                    label: 'Mastercard',
                    value: 'mastercard',
                    groupValue: selectedPaymentMethod.value,
                    onTap: () => selectedPaymentMethod.value = 'mastercard',
                  ),
                  _buildPaymentMethodLogo(
                    imagePath: 'assets/images/paypal.png',
                    label: 'PayPal',
                    value: 'paypal',
                    groupValue: selectedPaymentMethod.value,
                    onTap: () => selectedPaymentMethod.value = 'paypal',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Champ téléphone (visible uniquement pour Orange Money et MTN Mobile Money)
            Obx(() {
              if (selectedPaymentMethod.value == 'orange' ||
                  selectedPaymentMethod.value == 'mtn') {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Numéro de téléphone',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppThemeSystem.getPrimaryTextColor(context),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: 'Téléphone',
                        hintText: '6XXXXXXXX ou 2376XXXXXXX',
                        prefixIcon: const Icon(Icons.phone),
                        filled: true,
                        fillColor: AppThemeSystem.getSurfaceColor(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppThemeSystem.getBorderColor(context),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: AppThemeSystem.getBorderColor(context),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppThemeSystem.primaryColor,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Format: 651826475 (9 chiffres) ou 237651826475 (12 chiffres)',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppThemeSystem.getSecondaryTextColor(context),
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            const SizedBox(height: 24),

            // Bouton de confirmation
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isProcessingPayment.value
                      ? null
                      : () async {
                          // Validation
                          if (amountController.text.isEmpty) {
                            Get.snackbar(
                              'Erreur',
                              'Veuillez entrer un montant',
                              backgroundColor: AppThemeSystem.errorColor,
                              colorText: AppThemeSystem.whiteColor,
                            );
                            return;
                          }

                          final amount = double.tryParse(amountController.text);
                          print(
                            'Validating amount: $appConfig.minDepositAmount, entered: $amount',
                          );
                          if (amount == null ||
                              amount < appConfig.minDepositAmount) {
                            Get.snackbar(
                              'Erreur',
                              'Le montant minimum est de ${appConfig.minDepositAmount.toStringAsFixed(0)} FCFA',
                              backgroundColor: AppThemeSystem.errorColor,
                              colorText: AppThemeSystem.whiteColor,
                            );
                            return;
                          }

                          // Vérifier le numéro de téléphone pour Mobile Money
                          final isMobileMoney =
                              selectedPaymentMethod.value == 'orange' ||
                              selectedPaymentMethod.value == 'mtn';

                          if (isMobileMoney && phoneController.text.isEmpty) {
                            Get.snackbar(
                              'Erreur',
                              'Veuillez entrer votre numéro de téléphone',
                              backgroundColor: AppThemeSystem.errorColor,
                              colorText: AppThemeSystem.whiteColor,
                            );
                            return;
                          }

                          // Initier la recharge
                          // Pour Mobile Money (Orange/MTN), utiliser FreeMoPay
                          if (isMobileMoney) {
                            // Lancer la recharge de manière asynchrone (non-bloquant)
                            controller.isProcessingPayment.value = true;

                            final result = await controller.initiateRecharge(
                              amount: amount,
                              paymentMethod: 'freemopay', // Backend service
                              phoneNumber: phoneController.text.trim(),
                            );

                            controller.isProcessingPayment.value = false;

                            if (result['success'] == true) {
                              // Afficher le dialogue d'instructions USSD
                              if (context.mounted) {
                                await _showUssdInstructionDialog(
                                  context,
                                  amount,
                                  phoneController.text.trim(),
                                  selectedPaymentMethod.value,
                                );
                              }

                              // Retourner immédiatement à la page wallet
                              Get.back(); // Fermer la page de recharge

                              // Rafraîchir le wallet pour afficher la transaction en attente
                              await controller.refresh();
                            } else {
                              // Afficher l'erreur
                              Get.snackbar(
                                'Erreur',
                                result['message'] ??
                                    'Erreur lors de l\'initiation du paiement',
                                backgroundColor: AppThemeSystem.errorColor,
                                colorText: AppThemeSystem.whiteColor,
                              );
                            }
                            return;
                          }

                          // Pour les cartes (Visa/MasterCard) et PayPal, utiliser le paiement natif PayPal
                          if (context.mounted) {
                            _handleNativePayPalPayment(context, amount);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppThemeSystem.primaryColor,
                    foregroundColor: AppThemeSystem.whiteColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: controller.isProcessingPayment.value
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: AppThemeSystem.whiteColor,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Continuer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppThemeSystem.infoColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppThemeSystem.infoColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppThemeSystem.infoColor,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Votre wallet sera crédité immédiatement après validation du paiement.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppThemeSystem.getSecondaryTextColor(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a circular payment method logo button
  Widget _buildPaymentMethodLogo({
    required String imagePath,
    required String label,
    required String value,
    required String groupValue,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) {
        final isSelected = value == groupValue;

        return GestureDetector(
          onTap: onTap,
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppThemeSystem.whiteColor,
                  border: Border.all(
                    color: isSelected
                        ? AppThemeSystem.primaryColor
                        : AppThemeSystem.getBorderColor(context),
                    width: isSelected ? 3 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? AppThemeSystem.primaryColor.withOpacity(0.3)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: isSelected ? 12 : 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Logo image
                    Center(
                      child: ClipOval(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(
                            imagePath,
                            width: 56,
                            height: 56,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),

                    // Checkmark when selected
                    if (isSelected)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppThemeSystem.primaryColor,
                            border: Border.all(
                              color: AppThemeSystem.whiteColor,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.check,
                            size: 14,
                            color: AppThemeSystem.whiteColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 85,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected
                        ? AppThemeSystem.primaryColor
                        : AppThemeSystem.getSecondaryTextColor(context),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Gère le paiement PayPal natif avec WebView
  Future<void> _handleNativePayPalPayment(
    BuildContext context,
    double amount,
  ) async {
    try {
      // Étape 1: Créer l'ordre PayPal côté backend
      final orderResult = await controller.initiateNativePayPalPayment(
        amount: amount,
      );

      if (orderResult['success'] != true) {
        Get.snackbar(
          'Erreur',
          orderResult['message'] ?? 'Impossible de créer l\'ordre PayPal',
          backgroundColor: AppThemeSystem.errorColor,
          colorText: AppThemeSystem.whiteColor,
        );
        return;
      }

      final paymentId = orderResult['payment_id'] as int;
      final orderId = orderResult['order_id'] as String;
      final approvalUrl = orderResult['approval_url'] as String;

      print('[PayPal] Order created:');
      print('  payment_id: $paymentId');
      print('  order_id: $orderId');
      print('  approval_url: $approvalUrl');

      // Étape 2: Ouvrir la WebView PayPal
      final result = await Get.to<Map<String, dynamic>>(
        () => PayPalNativeWebView(
          approvalUrl: approvalUrl,
          orderId: orderId,
          paymentId: paymentId,
          amount: amount,
        ),
      );

      if (result == null) {
        return;
      }

      // Étape 3: Traiter le résultat
      if (result['success'] == true) {
        print('[PayPal] Payment approved, capturing...');

        // Capturer le paiement côté backend
        final captureResult = await controller.captureNativePayPalPayment(
          paymentId: paymentId,
          orderId: orderId,
        );

        if (captureResult['success'] == true) {
          Get.back(); // Retour à la page wallet
          await controller.refresh();

          Get.snackbar(
            'Succès',
            'Votre wallet a été rechargé de ${amount.toStringAsFixed(0)} FCFA !',
            backgroundColor: AppThemeSystem.successColor,
            colorText: AppThemeSystem.whiteColor,
            duration: const Duration(seconds: 4),
          );
        } else {
          Get.snackbar(
            'Erreur',
            captureResult['message'] ?? 'Impossible de capturer le paiement',
            backgroundColor: AppThemeSystem.errorColor,
            colorText: AppThemeSystem.whiteColor,
          );
        }
      } else if (result['cancelled'] == true) {
        print('[PayPal] Payment cancelled');
        Get.snackbar(
          'Annulé',
          'Vous avez annulé le paiement PayPal',
          backgroundColor: AppThemeSystem.warningColor,
          colorText: AppThemeSystem.whiteColor,
        );
      } else {
        Get.snackbar(
          'Erreur',
          result['message'] ?? 'Une erreur s\'est produite',
          backgroundColor: AppThemeSystem.errorColor,
          colorText: AppThemeSystem.whiteColor,
        );
      }
    } catch (e) {
      print("[PayPal] Error: $e");
      Get.snackbar(
        'Erreur',
        'Une erreur s\'est produite',
        backgroundColor: AppThemeSystem.errorColor,
        colorText: AppThemeSystem.whiteColor,
      );
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
    final providerName = paymentMethod == 'orange'
        ? 'Orange Money'
        : 'MTN Mobile Money';
    final providerEmoji = paymentMethod == 'orange' ? '(OM)' : '(MTN)';

    return showDialog(
      context: context,
      barrierDismissible: false, // Force l'utilisateur à cliquer sur "Compris"
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Text(providerEmoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Paiement initié',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppThemeSystem.primaryColor.withOpacity(0.1),
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
                  color: AppThemeSystem.infoColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppThemeSystem.infoColor.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.info_outline,
                          color: AppThemeSystem.infoColor,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
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
                  color: AppThemeSystem.successColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.notifications_active_outlined,
                      color: AppThemeSystem.successColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
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
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
          decoration: BoxDecoration(
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
