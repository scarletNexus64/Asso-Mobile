import 'api_provider.dart';
import '../../core/values/constants.dart';
import 'dart:io' show Platform;

/// Provider pour gérer les tokens FCM (device tokens)
class DeviceTokenProvider {
  /// Enregistrer ou mettre à jour un device token FCM
  static Future<ApiResponse> registerToken(String token) async {
    try {
      final platform = Platform.isIOS ? 'ios' : 'android';

      return await ApiProvider.post(
        AppConstants.deviceTokensUrl,
        body: {
          'token': token,
          'platform': platform,
        },
      );
    } catch (e) {
      print('[DeviceTokenProvider] Error registering token: $e');
      return ApiResponse(
        success: false,
        message: 'Failed to register device token',
        statusCode: 0,
        data: null,
      );
    }
  }

  /// Supprimer un device token par sa valeur
  static Future<ApiResponse> deleteToken(String token) async {
    try {
      // Utiliser POST au lieu de DELETE car DELETE ne supporte pas de body
      return await ApiProvider.post(
        '${AppConstants.deviceTokensUrl}/by-token/delete',
        body: {'token': token},
      );
    } catch (e) {
      print('[DeviceTokenProvider] Error deleting token: $e');
      return ApiResponse(
        success: false,
        message: 'Failed to delete device token',
        statusCode: 0,
        data: null,
      );
    }
  }
}
