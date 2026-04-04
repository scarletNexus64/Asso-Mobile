import 'dart:developer' as developer;
import 'package:get_storage/get_storage.dart';
import '../../core/values/constants.dart';
import '../models/user_model.dart';

/// Service for managing local storage (tokens, user data, preferences)
class StorageService {
  static final GetStorage _storage = GetStorage();

  /// Check if storage is initialized
  static bool get isInitialized {
    try {
      _storage.read('test');
      return true;
    } catch (e) {
      print('❌ StorageService NOT initialized: $e');
      return false;
    }
  }

  // ==================== Token Management ====================

  /// Save authentication token
  static void saveToken(String token) {
    developer.log(
      'Saving auth token',
      name: 'StorageService',
      error: 'Token length: ${token.length}',
    );
    _storage.write(AppConstants.keyToken, token);
  }

  /// Get stored token
  static String? getToken() {
    final token = _storage.read<String>(AppConstants.keyToken);
    developer.log(
      'Retrieved token',
      name: 'StorageService',
      error: token != null ? 'Token exists (${token.length} chars)' : 'No token found',
    );
    return token;
  }

  /// Check if user has valid token
  static bool get hasToken {
    final token = getToken();
    final hasValidToken = token != null && token.isNotEmpty;
    developer.log(
      'Token check: $hasValidToken',
      name: 'StorageService',
    );
    return hasValidToken;
  }

  /// Remove token
  static void clearToken() {
    developer.log('Clearing auth token', name: 'StorageService');
    _storage.remove(AppConstants.keyToken);
  }

  // ==================== User Data Management ====================

  /// Save user data to storage
  static void saveUser(UserModel user) {
    developer.log(
      'Saving user data',
      name: 'StorageService',
      error: 'User: ${user.toString()}',
    );
    _storage.write(AppConstants.keyUser, user.toJson());
  }

  /// Get cached user data
  static UserModel? getUser() {
    try {
      final data = _storage.read(AppConstants.keyUser);
      if (data == null) {
        developer.log('No cached user found', name: 'StorageService');
        return null;
      }

      Map<String, dynamic> userData;
      if (data is Map<String, dynamic>) {
        userData = data;
      } else {
        userData = Map<String, dynamic>.from(data);
      }

      final user = UserModel.fromJson(userData);
      developer.log(
        'Retrieved cached user',
        name: 'StorageService',
        error: 'User: ${user.toString()}',
      );
      return user;
    } catch (e, stackTrace) {
      developer.log(
        'Error getting cached user',
        name: 'StorageService',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  /// Update user data
  static void updateUser(UserModel user) {
    saveUser(user);
  }

  /// Remove user data
  static void clearUser() {
    developer.log('Clearing user data', name: 'StorageService');
    _storage.remove(AppConstants.keyUser);
  }

  // ==================== Preferences Management ====================

  /// Save user preferences
  static void savePreferences(Map<String, dynamic> preferences) {
    developer.log(
      'Saving preferences',
      name: 'StorageService',
      error: 'Preferences: $preferences',
    );
    _storage.write(AppConstants.keyPreferences, preferences);
  }

  /// Get user preferences
  static Map<String, dynamic>? getPreferences() {
    try {
      final data = _storage.read(AppConstants.keyPreferences);
      if (data == null) return null;

      if (data is Map<String, dynamic>) {
        return data;
      }
      return Map<String, dynamic>.from(data);
    } catch (e) {
      developer.log(
        'Error getting preferences',
        name: 'StorageService',
        error: e,
      );
      return null;
    }
  }

  /// Clear preferences
  static void clearPreferences() {
    developer.log('Clearing preferences', name: 'StorageService');
    _storage.remove(AppConstants.keyPreferences);
  }

  // ==================== Onboarding Management ====================

  /// Mark onboarding as completed
  static void setOnboardingDone() {
    developer.log('Marking onboarding as done', name: 'StorageService');
    _storage.write(AppConstants.keyOnboardingDone, true);
  }

  /// Check if onboarding was completed
  static bool get isOnboardingDone {
    final done = _storage.read(AppConstants.keyOnboardingDone) ?? false;
    developer.log('Onboarding done: $done', name: 'StorageService');
    return done;
  }

  /// Clear onboarding flag
  static void clearOnboardingFlag() {
    _storage.remove(AppConstants.keyOnboardingDone);
  }

  // ==================== Theme Management ====================

  /// Save theme mode
  static void saveThemeMode(String mode) {
    developer.log('Saving theme mode: $mode', name: 'StorageService');
    _storage.write(AppConstants.keyThemeMode, mode);
  }

  /// Get theme mode
  static String? getThemeMode() {
    return _storage.read<String>(AppConstants.keyThemeMode);
  }

  // ==================== Session Management ====================

  /// Check if user is authenticated
  static bool get isAuthenticated {
    final authenticated = hasToken && getUser() != null;
    developer.log(
      'Authentication check: $authenticated',
      name: 'StorageService',
    );
    return authenticated;
  }

  /// Clear all authentication data (logout)
  static void clearAuth() {
    developer.log(
      '========== LOGOUT: Clearing all auth data ==========',
      name: 'StorageService',
    );
    clearToken();
    clearUser();
    clearPreferences();
  }

  /// Clear all storage data
  static void clearAll() {
    developer.log(
      '========== CLEARING ALL STORAGE ==========',
      name: 'StorageService',
    );
    _storage.erase();
  }

  /// Save complete auth session (token + user)
  static void saveAuthSession(String token, UserModel user) {
    developer.log(
      '========== SAVING AUTH SESSION ==========',
      name: 'StorageService',
      error: 'Token length: ${token.length}, User: ${user.toString()}',
    );
    saveToken(token);
    saveUser(user);
  }

  /// Clear auth session (token + user)
  static void clearAuthSession() {
    developer.log(
      '========== CLEARING AUTH SESSION ==========',
      name: 'StorageService',
    );
    _storage.remove(AppConstants.keyToken);
    _storage.remove(AppConstants.keyUser);
  }
}
