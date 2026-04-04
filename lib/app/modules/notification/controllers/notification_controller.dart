import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/app_theme_system.dart';
import '../../wallet/controllers/wallet_controller.dart';

class NotificationController extends GetxController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final GetStorage _storage = GetStorage();

  // Liste des notifications (pour affichage dans une page dédiée si besoin)
  final notifications = <Map<String, dynamic>>[].obs;
  final unreadCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _setupFCMListeners();
  }

  /// Configure les listeners FCM
  void _setupFCMListeners() {
    // 1. Notification reçue quand l'app est au premier plan (foreground)
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 2. Notification cliquée quand l'app est en arrière-plan
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessageClick);

    // 3. Vérifier si l'app a été ouverte via une notification
    _checkInitialMessage();
  }

  /// Gère les notifications reçues quand l'app est active
  void _handleForegroundMessage(RemoteMessage message) {
    print('📬 [FCM] Message reçu (foreground): ${message.data}');

    final data = message.data;
    final notification = message.notification;

    // Ajouter à la liste des notifications
    _addNotification({
      'title': notification?.title ?? 'Notification',
      'body': notification?.body ?? '',
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'read': false,
    });

    // Afficher un snackbar
    _showNotificationSnackbar(
      title: notification?.title ?? 'Notification',
      message: notification?.body ?? '',
      data: data,
    );

    // Gérer les actions selon le type
    _handleNotificationAction(data);
  }

  /// Gère le clic sur une notification en arrière-plan
  void _handleBackgroundMessageClick(RemoteMessage message) {
    print('🖱️  [FCM] Notification cliquée: ${message.data}');

    final data = message.data;

    // Marquer comme lue
    _addNotification({
      'title': message.notification?.title ?? 'Notification',
      'body': message.notification?.body ?? '',
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'read': true,
    });

    // Gérer les actions selon le type
    _handleNotificationAction(data, fromClick: true);
  }

  /// Vérifie si l'app a été ouverte via une notification
  Future<void> _checkInitialMessage() async {
    final message = await _firebaseMessaging.getInitialMessage();
    if (message != null) {
      print('🚀 [FCM] App ouverte via notification: ${message.data}');
      _handleBackgroundMessageClick(message);
    }
  }

  /// Affiche un snackbar pour la notification
  void _showNotificationSnackbar({
    required String title,
    required String message,
    required Map<String, dynamic> data,
  }) {
    Color backgroundColor;
    IconData icon;

    // Déterminer la couleur et l'icône selon le type
    final type = data['type'] as String?;
    switch (type) {
      case 'wallet_credit':
      case 'wallet_deposit_success':
        backgroundColor = AppThemeSystem.successColor;
        icon = Icons.check_circle_rounded;
        break;
      case 'wallet_credit_failed':
      case 'wallet_deposit_failed':
        backgroundColor = AppThemeSystem.errorColor;
        icon = Icons.error_rounded;
        break;
      case 'wallet_withdrawal_success':
        backgroundColor = AppThemeSystem.infoColor;
        icon = Icons.arrow_circle_up_rounded;
        break;
      default:
        backgroundColor = AppThemeSystem.primaryColor;
        icon = Icons.notifications_rounded;
    }

    Get.snackbar(
      title,
      message,
      backgroundColor: backgroundColor,
      colorText: AppThemeSystem.whiteColor,
      icon: Icon(icon, color: AppThemeSystem.whiteColor),
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      onTap: (_) {
        // Cliquer sur la snackbar exécute l'action
        _handleNotificationAction(data, fromClick: true);
      },
    );
  }

  /// Gère les actions selon le type de notification
  void _handleNotificationAction(Map<String, dynamic> data, {bool fromClick = false}) {
    final type = data['type'] as String?;
    print('🎬 [FCM] Action pour type: $type (fromClick: $fromClick)');

    switch (type) {
      case 'wallet_credit':
      case 'wallet_deposit_success':
      case 'wallet_deposit_failed':
        // Rafraîchir le wallet
        _refreshWallet();

        // Si cliqué, naviguer vers l'historique
        if (fromClick) {
          Get.toNamed('/wallet/history');
        }
        break;

      case 'wallet_withdrawal_success':
      case 'wallet_withdrawal_failed':
        // Rafraîchir le wallet
        _refreshWallet();

        // Si cliqué, naviguer vers l'historique
        if (fromClick) {
          Get.toNamed('/wallet/history');
        }
        break;

      case 'order_update':
        // Naviguer vers les commandes
        if (fromClick) {
          final orderId = data['order_id'];
          if (orderId != null) {
            Get.toNamed('/orders/$orderId');
          } else {
            Get.toNamed('/orders');
          }
        }
        break;

      case 'new_message':
        // Naviguer vers le chat
        if (fromClick) {
          final conversationId = data['conversation_id'];
          if (conversationId != null) {
            Get.toNamed('/chat/$conversationId');
          } else {
            Get.toNamed('/chat');
          }
        }
        break;

      default:
        print('⚠️  [FCM] Type de notification non géré: $type');
    }
  }

  /// Rafraîchit le wallet
  void _refreshWallet() {
    try {
      if (Get.isRegistered<WalletController>()) {
        final walletController = Get.find<WalletController>();
        walletController.refresh();
        print('✅ [FCM] Wallet rafraîchi');
      } else {
        print('⚠️  [FCM] WalletController non enregistré');
      }
    } catch (e) {
      print('❌ [FCM] Erreur lors du rafraîchissement du wallet: $e');
    }
  }

  /// Ajoute une notification à la liste
  void _addNotification(Map<String, dynamic> notification) {
    notifications.insert(0, notification);
    if (notification['read'] == false) {
      unreadCount.value++;
    }

    // Sauvegarder dans le storage
    _saveNotifications();
  }

  /// Marque une notification comme lue
  void markAsRead(int index) {
    if (index >= 0 && index < notifications.length) {
      if (notifications[index]['read'] == false) {
        notifications[index]['read'] = true;
        unreadCount.value = (unreadCount.value - 1).clamp(0, 999);
        notifications.refresh();
        _saveNotifications();
      }
    }
  }

  /// Marque toutes les notifications comme lues
  void markAllAsRead() {
    for (var notification in notifications) {
      notification['read'] = true;
    }
    unreadCount.value = 0;
    notifications.refresh();
    _saveNotifications();
  }

  /// Supprime une notification
  void deleteNotification(int index) {
    if (index >= 0 && index < notifications.length) {
      if (notifications[index]['read'] == false) {
        unreadCount.value = (unreadCount.value - 1).clamp(0, 999);
      }
      notifications.removeAt(index);
      _saveNotifications();
    }
  }

  /// Supprime toutes les notifications
  void clearAll() {
    notifications.clear();
    unreadCount.value = 0;
    _saveNotifications();
  }

  /// Sauvegarde les notifications dans le storage
  void _saveNotifications() {
    try {
      // Limiter à 50 notifications max
      final toSave = notifications.take(50).toList();
      _storage.write('notifications', toSave);
    } catch (e) {
      print('❌ [FCM] Erreur lors de la sauvegarde des notifications: $e');
    }
  }

  /// Charge les notifications depuis le storage
  void loadNotifications() {
    try {
      final saved = _storage.read('notifications');
      if (saved != null && saved is List) {
        notifications.value = List<Map<String, dynamic>>.from(
          saved.map((item) => Map<String, dynamic>.from(item)),
        );
        unreadCount.value = notifications.where((n) => n['read'] == false).length;
      }
    } catch (e) {
      print('❌ [FCM] Erreur lors du chargement des notifications: $e');
    }
  }

  @override
  void onClose() {
    // Sauvegarder avant de fermer
    _saveNotifications();
    super.onClose();
  }
}
