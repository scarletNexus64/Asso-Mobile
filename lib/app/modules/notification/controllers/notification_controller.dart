import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/app_theme_system.dart';
import '../../../core/models/notification_model.dart';
import '../../../data/services/notification_service.dart';
import '../../wallet/controllers/wallet_controller.dart';

class NotificationController extends GetxController {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  // Liste des notifications (synchronisées avec le backend)
  final notifications = <NotificationModel>[].obs;
  final unreadCount = 0.obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;
  int _currentPage = 1;
  bool _hasMorePages = true;

  @override
  void onInit() {
    super.onInit();
    _setupFCMListeners();
    fetchNotifications(); // Charger l'historique depuis le backend
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

    // Ajouter localement (elle sera aussi dans le backend)
    _addLocalNotification(NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch, // ID temporaire
      userId: 0, // Sera remplacé par le backend
      title: notification?.title ?? 'Notification',
      body: notification?.body ?? '',
      type: data['type'] as String?,
      data: data,
      isRead: false,
      sentAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ));

    // Afficher un snackbar
    _showNotificationSnackbar(
      title: notification?.title ?? 'Notification',
      message: notification?.body ?? '',
      data: data,
    );

    // Gérer les actions selon le type
    _handleNotificationAction(data);

    // Rafraîchir depuis le backend pour avoir l'ID réel
    updateUnreadCount();
  }

  /// Gère le clic sur une notification en arrière-plan
  void _handleBackgroundMessageClick(RemoteMessage message) {
    print('🖱️  [FCM] Notification cliquée: ${message.data}');

    final data = message.data;

    // Rafraîchir les notifications depuis le backend
    fetchNotifications(refresh: true);

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

  /// Récupère les notifications depuis le backend
  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMorePages = true;
      notifications.clear();
    }

    if (!_hasMorePages) return;

    isLoading.value = true;

    try {
      final response = await NotificationService.getNotifications(
        page: _currentPage,
        perPage: 20,
      );

      if (response.success && response.data != null) {
        final newNotifications = NotificationService.parseNotifications(response.data!['notifications']);

        if (refresh) {
          notifications.value = newNotifications;
        } else {
          notifications.addAll(newNotifications);
        }

        // Mettre à jour le compteur non lus
        unreadCount.value = response.data!['unread_count'] ?? 0;

        // Vérifier s'il y a plus de pages
        final pagination = response.data!['pagination'];
        if (pagination != null) {
          _currentPage = pagination['current_page'];
          final lastPage = pagination['last_page'];
          _hasMorePages = _currentPage < lastPage;
        }
      }
    } catch (e) {
      print('❌ Erreur lors du chargement des notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Charge plus de notifications (pagination)
  Future<void> loadMoreNotifications() async {
    if (isLoadingMore.value || !_hasMorePages) return;

    isLoadingMore.value = true;
    _currentPage++;

    try {
      await fetchNotifications();
    } finally {
      isLoadingMore.value = false;
    }
  }

  /// Met à jour le compteur de notifications non lues
  Future<void> updateUnreadCount() async {
    try {
      final response = await NotificationService.getUnreadCount();
      if (response.success && response.data != null) {
        unreadCount.value = response.data!['unread_count'] ?? 0;
      }
    } catch (e) {
      print('❌ Erreur lors de la mise à jour du compteur: $e');
    }
  }

  /// Ajoute une notification locale (depuis FCM)
  void _addLocalNotification(NotificationModel notification) {
    notifications.insert(0, notification);
    if (!notification.isRead) {
      unreadCount.value++;
    }
  }

  /// Marque une notification comme lue
  Future<void> markAsRead(int notificationId) async {
    try {
      final response = await NotificationService.markAsRead(notificationId);

      if (response.success) {
        // Mettre à jour localement
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = notifications[index].copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
          notifications.refresh();
          unreadCount.value = (unreadCount.value - 1).clamp(0, 999);
        }
      }
    } catch (e) {
      print('❌ Erreur lors du marquage comme lu: $e');
    }
  }

  /// Marque toutes les notifications comme lues
  Future<void> markAllAsRead() async {
    try {
      final response = await NotificationService.markAllAsRead();

      if (response.success) {
        // Mettre à jour localement
        notifications.value = notifications.map((n) => n.copyWith(isRead: true, readAt: DateTime.now())).toList();
        unreadCount.value = 0;
        notifications.refresh();
      }
    } catch (e) {
      print('❌ Erreur lors du marquage de toutes comme lues: $e');
    }
  }

  /// Supprime une notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      final response = await NotificationService.deleteNotification(notificationId);

      if (response.success) {
        // Mettre à jour localement
        final notification = notifications.firstWhere((n) => n.id == notificationId);
        if (!notification.isRead) {
          unreadCount.value = (unreadCount.value - 1).clamp(0, 999);
        }
        notifications.removeWhere((n) => n.id == notificationId);
      }
    } catch (e) {
      print('❌ Erreur lors de la suppression: $e');
    }
  }

  /// Supprime toutes les notifications
  Future<void> clearAll() async {
    try {
      final response = await NotificationService.deleteAllNotifications();

      if (response.success) {
        notifications.clear();
        unreadCount.value = 0;
      }
    } catch (e) {
      print('❌ Erreur lors de la suppression de toutes: $e');
    }
  }

}
