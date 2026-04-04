import 'package:get/get.dart';
import '../../data/providers/app_config_service.dart';

/// Contrôleur global pour gérer les paramètres de l'application
class AppConfigController extends GetxController {
  // Observable settings
  final _minDepositAmount = RxDouble(100.0); // Valeur par défaut
  final _minWithdrawalAmount = RxDouble(100.0); // Valeur par défaut
  final _currency = Rx<String>('XOF');
  final _currencySymbol = Rx<String>('FCFA');
  final _timezone = Rx<String>('Africa/Porto-Novo');
  final _defaultLanguage = Rx<String>('fr');
  final _appName = Rx<String>('ASSO');

  // Getters
  double get minDepositAmount => _minDepositAmount.value;
  double get minWithdrawalAmount => _minWithdrawalAmount.value;
  String get currency => _currency.value;
  String get currencySymbol => _currencySymbol.value;
  String get timezone => _timezone.value;
  String get defaultLanguage => _defaultLanguage.value;
  String get appName => _appName.value;

  // Loading state
  final isLoading = RxBool(false);
  final isLoaded = RxBool(false);

  /// Charger les paramètres depuis l'API
  Future<void> loadSettings() async {
    try {
      isLoading.value = true;

      final settings = await AppConfigService.getAllSettings();

      // System settings
      if (settings.containsKey('system')) {
        final systemSettings = settings['system'] as Map<String, dynamic>;

        if (systemSettings.containsKey('min_deposit_amount')) {
          _minDepositAmount.value = _parseDouble(systemSettings['min_deposit_amount']);
        }

        if (systemSettings.containsKey('min_withdrawal_amount')) {
          _minWithdrawalAmount.value = _parseDouble(systemSettings['min_withdrawal_amount']);
        }

        if (systemSettings.containsKey('currency')) {
          _currency.value = systemSettings['currency'].toString();
        }

        if (systemSettings.containsKey('currency_symbol')) {
          _currencySymbol.value = systemSettings['currency_symbol'].toString();
        }

        if (systemSettings.containsKey('timezone')) {
          _timezone.value = systemSettings['timezone'].toString();
        }

        if (systemSettings.containsKey('default_language')) {
          _defaultLanguage.value = systemSettings['default_language'].toString();
        }
      }

      // General settings
      if (settings.containsKey('general')) {
        final generalSettings = settings['general'] as Map<String, dynamic>;

        if (generalSettings.containsKey('app_name')) {
          _appName.value = generalSettings['app_name'].toString();
        }
      }

      isLoaded.value = true;
      print('[AppConfigController] Settings loaded successfully');
      print('Min Deposit: ${_minDepositAmount.value} FCFA');
      print('Min Withdrawal: ${_minWithdrawalAmount.value} FCFA');
    } catch (e) {
      print('[AppConfigController] Error loading settings: $e');
      // Garder les valeurs par défaut en cas d'erreur
    } finally {
      isLoading.value = false;
    }
  }

  /// Convertir une valeur en double (gère String, int, double)
  double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 100.0;
    }
    return 100.0;
  }

  /// Recharger les settings (utile après modification dans le panel admin)
  Future<void> refreshSettings() async {
    await loadSettings();
  }
}
