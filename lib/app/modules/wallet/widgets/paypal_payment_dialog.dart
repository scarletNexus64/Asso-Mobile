import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/wallet_controller.dart';

class PayPalPaymentDialog extends StatefulWidget {
  final String paymentUrl;
  final int paymentId;
  final double amount;
  final String? amountUSD;

  const PayPalPaymentDialog({
    super.key,
    required this.paymentUrl,
    required this.paymentId,
    required this.amount,
    this.amountUSD,
  });

  @override
  State<PayPalPaymentDialog> createState() => _PayPalPaymentDialogState();
}

class _PayPalPaymentDialogState extends State<PayPalPaymentDialog> {
  final WalletController _walletController = Get.find<WalletController>();

  bool _isCheckingStatus = false;
  String _currentStatus = 'pending';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0070BA), Color(0xFF1546A0)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.payment, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Paiement PayPal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (!_isCheckingStatus)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Instructions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Instructions',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildInstruction('1. Cliquez sur "Ouvrir PayPal"'),
                        _buildInstruction('2. Connectez-vous à votre compte PayPal'),
                        _buildInstruction(
                          '3. Confirmez le paiement de ${widget.amountUSD ?? '\$${(widget.amount / 655).toStringAsFixed(2)}'} USD',
                        ),
                        _buildInstruction('4. Revenez sur cette page'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Status
                  if (_isCheckingStatus)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'En attente de confirmation du paiement...',
                              style: TextStyle(
                                color: Colors.orange.shade800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  // Amount info
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Montant PayPal',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              widget.amountUSD ?? '\$${(widget.amount / 655).toStringAsFixed(2)} USD',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0070BA),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Équivalent en FCFA',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${widget.amount.toStringAsFixed(0)} FCFA',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Open PayPal Button
                  ElevatedButton.icon(
                    onPressed: _isCheckingStatus ? null : _handleOpenPayPal,
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Ouvrir PayPal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0070BA),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Cancel Button
                  TextButton(
                    onPressed: _isCheckingStatus ? null : () => Navigator.of(context).pop(),
                    child: const Text('Annuler'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: TextStyle(
              color: Colors.blue.shade800,
              fontSize: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleOpenPayPal() async {
    // Ouvrir PayPal
    final uri = Uri.parse(widget.paymentUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      // Démarrer le polling après avoir ouvert PayPal
      _startPolling();
    } else {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ouvrir PayPal',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _startPolling() async {
    if (mounted) {
      setState(() {
        _isCheckingStatus = true;
      });
    }

    // Lancer le polling
    final result = await _walletController.pollPaymentStatus(
      paymentId: widget.paymentId,
      onStatusUpdate: (status) {
        if (mounted) {
          setState(() {
            _currentStatus = status;
          });
        }
      },
    );

    if (!mounted) return;

    setState(() {
      _isCheckingStatus = false;
    });

    // Fermer le dialog
    Navigator.of(context).pop();

    // Afficher le résultat
    if (result['status'] == 'completed') {
      Get.snackbar(
        'Succès',
        'Votre wallet a été rechargé de ${widget.amount.toStringAsFixed(0)} FCFA',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } else if (result['status'] == 'failed') {
      Get.snackbar(
        'Paiement échoué',
        result['message'] ?? 'Le paiement a échoué',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } else if (result['status'] == 'cancelled') {
      Get.snackbar(
        'Paiement annulé',
        'Vous avez annulé le paiement',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } else if (result['status'] == 'timeout') {
      Get.snackbar(
        'Délai dépassé',
        result['message'] ?? 'Le paiement prend trop de temps. Vérifiez votre wallet.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }
}
