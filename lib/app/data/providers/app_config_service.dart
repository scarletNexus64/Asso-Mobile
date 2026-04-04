import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import '../../core/values/constants.dart';

class AppConfigService {
  static final http.Client _client = http.Client();

  /// Récupérer tous les settings publics (general + system)
  static Future<Map<String, dynamic>> getAllSettings() async {
    try {
      final url = '${AppConstants.baseUrl}/settings';
      developer.log('GET $url', name: 'AppConfigService');

      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      developer.log(
        'Response status: ${response.statusCode}',
        name: 'AppConfigService',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
      }

      throw Exception('Failed to load settings');
    } catch (e) {
      developer.log('Error loading settings: $e', name: 'AppConfigService', error: e);
      rethrow;
    }
  }

  /// Récupérer les settings d'un groupe spécifique (general ou system)
  static Future<Map<String, dynamic>> getSettingsByGroup(String group) async {
    try {
      final url = '${AppConstants.baseUrl}/settings/group/$group';
      developer.log('GET $url', name: 'AppConfigService');

      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        }
      }

      throw Exception('Failed to load settings for group: $group');
    } catch (e) {
      developer.log('Error loading settings for group $group: $e', name: 'AppConfigService', error: e);
      rethrow;
    }
  }

  /// Récupérer un setting spécifique par sa clé
  static Future<dynamic> getSetting(String key) async {
    try {
      final url = '${AppConstants.baseUrl}/settings/$key';
      developer.log('GET $url', name: 'AppConfigService');

      final response = await _client.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['data']['value'];
        }
      }

      throw Exception('Failed to load setting: $key');
    } catch (e) {
      developer.log('Error loading setting $key: $e', name: 'AppConfigService', error: e);
      rethrow;
    }
  }
}
