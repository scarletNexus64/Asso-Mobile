import 'package:asso/app/core/utils/app_theme_system.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// WebView pour le paiement PayPal natif
/// Ouvre l'URL d'approbation PayPal et détecte le succès/annulation
class PayPalNativeWebView extends StatefulWidget {
  final String approvalUrl;
  final String orderId;
  final int paymentId;
  final double amount;

  const PayPalNativeWebView({
    Key? key,
    required this.approvalUrl,
    required this.orderId,
    required this.paymentId,
    required this.amount,
  }) : super(key: key);

  @override
  State<PayPalNativeWebView> createState() => _PayPalNativeWebViewState();
}

class _PayPalNativeWebViewState extends State<PayPalNativeWebView> {
  late final WebViewController _controller;
  final isLoading = true.obs;
  final loadingProgress = 0.0.obs;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('[PayPalNativeWebView] Page started: $url');
            isLoading.value = true;
            _checkPaymentCompletion(url);
          },
          onPageFinished: (String url) {
            print('[PayPalNativeWebView] Page finished: $url');
            isLoading.value = false;
          },
          onProgress: (int progress) {
            loadingProgress.value = progress / 100;
          },
          onWebResourceError: (WebResourceError error) {
            print('[PayPalNativeWebView] Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.approvalUrl));
  }

  void _checkPaymentCompletion(String url) {
    print('[PayPalNativeWebView] Checking URL: $url');

    // Vérifier si l'utilisateur a approuvé le paiement
    // Il doit avoir un PayerID dans l'URL pour confirmer l'approbation
    if (url.contains('PayerID=') || url.contains('ba_token=')) {
      // L'utilisateur a approuvé, extraire les paramètres
      final uri = Uri.parse(url);
      final token = uri.queryParameters['token'] ?? uri.queryParameters['ba_token'];
      final payerId = uri.queryParameters['PayerID'];

      print('[PayPalNativeWebView] Payment approved!');
      print('  Token: $token');
      print('  PayerID: $payerId');

      // Retourner le succès avec l'order_id
      Get.back(result: {
        'success': true,
        'order_id': widget.orderId,
        'payment_id': widget.paymentId,
        'token': token,
        'payer_id': payerId,
      });
      return;
    }

    // Vérifier si l'utilisateur a annulé
    if (url.contains('cancel') || url.contains('cancelled')) {
      print('[PayPalNativeWebView] Payment cancelled');
      Get.back(result: {
        'success': false,
        'cancelled': true,
        'message': 'Paiement annulé',
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppThemeSystem.getBackgroundColor(context),
      appBar: AppBar(
        title: const Text('Paiement PayPal'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppThemeSystem.primaryColor,
        foregroundColor: AppThemeSystem.whiteColor,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _showCancelDialog();
          },
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),

          // Loading indicator
          Obx(() {
            if (isLoading.value) {
              return Container(
                color: AppThemeSystem.whiteColor,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        color: AppThemeSystem.primaryColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Chargement de PayPal...',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppThemeSystem.getSecondaryTextColor(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Obx(() => LinearProgressIndicator(
                            value: loadingProgress.value,
                            backgroundColor: Colors.grey[200],
                            color: AppThemeSystem.primaryColor,
                          )),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  void _showCancelDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Annuler le paiement ?'),
        content: const Text('Êtes-vous sûr de vouloir annuler ce paiement PayPal ?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Non'),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Close dialog
              Get.back(result: {
                'success': false,
                'cancelled': true,
                'message': 'Paiement annulé par l\'utilisateur'
              });
            },
            child: const Text(
              'Oui, annuler',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
