import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../../../core/utils/app_theme_system.dart';
import '../../../data/providers/api_provider.dart';

class InvoiceWebView extends StatefulWidget {
  final String invoiceUrl;

  const InvoiceWebView({
    super.key,
    required this.invoiceUrl,
  });

  @override
  State<InvoiceWebView> createState() => _InvoiceWebViewState();
}

class _InvoiceWebViewState extends State<InvoiceWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    try {
      final token = ApiProvider.token;

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..addJavaScriptChannel(
          'FlutterChannel',
          onMessageReceived: (JavaScriptMessage message) {
            _handleJavaScriptMessage(message.message);
          },
        )
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (url) {
              if (mounted) {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
              }
            },
            onPageFinished: (url) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                });
              }
            },
            onWebResourceError: (error) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _error = 'Erreur de chargement: ${error.description}';
                });
              }
            },
          ),
        )
        ..loadRequest(
          Uri.parse(widget.invoiceUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Accept': 'text/html',
          },
        );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = 'Erreur d\'initialisation: $e';
        });
      }
    }
  }

  void _handleJavaScriptMessage(String message) {
    try {
      final data = json.decode(message);
      if (data['action'] == 'downloadInvoice') {
        _downloadAndShareInvoice(data['url']);
      }
    } catch (e) {
      debugPrint('Error handling JavaScript message: $e');
    }
  }

  Future<void> _downloadAndShareInvoice(String url) async {
    try {
      // Show loading
      Get.dialog(
        Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppThemeSystem.primaryColor,
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Préparation de la facture...'),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Download the invoice HTML
      final token = ApiProvider.token;
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'text/html',
        },
      );

      Get.back(); // Close loading dialog

      if (response.statusCode == 200) {
        // Save to temporary file
        final dir = await getTemporaryDirectory();
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final file = File('${dir.path}/facture_$timestamp.html');
        await file.writeAsBytes(response.bodyBytes);

        // Share the file
        await Share.shareXFiles(
          [XFile(file.path)],
          subject: 'Facture ASSO',
          text: 'Voici votre facture ASSO',
        );
      } else {
        Get.snackbar(
          'Erreur',
          'Impossible de télécharger la facture',
          backgroundColor: AppThemeSystem.errorColor,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back(); // Close loading dialog if open
      Get.snackbar(
        'Erreur',
        'Erreur lors du téléchargement: $e',
        backgroundColor: AppThemeSystem.errorColor,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: context.primaryTextColor,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Facture',
          style: context.h4.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          if (_error != null)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppThemeSystem.errorColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: context.body1.copyWith(
                        color: context.secondaryTextColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _error = null;
                        });
                        _initializeWebView();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemeSystem.primaryColor,
                      ),
                      child: const Text(
                        'Réessayer',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            WebViewWidget(controller: _controller),
          if (_isLoading)
            Container(
              color: context.backgroundColor.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppThemeSystem.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Chargement de la facture...',
                      style: context.body2.copyWith(
                        color: context.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
