import 'dart:developer' as developer;
import '../providers/api_provider.dart';
import '../../core/models/notification_model.dart';

class NotificationService {
  /// Récupérer toutes les notifications de l'utilisateur
  static Future<ApiResponse> getNotifications({int page = 1, int perPage = 20}) async {
    return await ApiProvider.get(
      '/v1/notifications',
      queryParams: {
        'page': page,
        'per_page': perPage,
      },
    );
  }

  /// Récupérer uniquement les notifications non lues
  static Future<ApiResponse> getUnreadNotifications() async {
    return await ApiProvider.get('/v1/notifications/unread');
  }

  /// Compter les notifications non lues
  static Future<ApiResponse> getUnreadCount() async {
    return await ApiProvider.get('/v1/notifications/unread-count');
  }

  /// Marquer une notification comme lue
  static Future<ApiResponse> markAsRead(int notificationId) async {
    return await ApiProvider.post('/v1/notifications/$notificationId/mark-as-read');
  }

  /// Marquer toutes les notifications comme lues
  static Future<ApiResponse> markAllAsRead() async {
    return await ApiProvider.post('/v1/notifications/mark-all-as-read');
  }

  /// Supprimer une notification
  static Future<ApiResponse> deleteNotification(int notificationId) async {
    return await ApiProvider.delete('/v1/notifications/$notificationId');
  }

  /// Supprimer toutes les notifications
  static Future<ApiResponse> deleteAllNotifications() async {
    return await ApiProvider.delete('/v1/notifications');
  }

  /// Envoyer une notification de test
  static Future<ApiResponse> sendTestNotification() async {
    return await ApiProvider.post('/v1/notifications/test');
  }

  /// Parser les notifications depuis la réponse API
  static List<NotificationModel> parseNotifications(dynamic data) {
    try {
      if (data == null) return [];

      if (data is List) {
        return data.map((json) => NotificationModel.fromJson(json)).toList();
      } else if (data is Map<String, dynamic> && data.containsKey('notifications')) {
        final notifications = data['notifications'];
        if (notifications is List) {
          return notifications.map((json) => NotificationModel.fromJson(json)).toList();
        }
      }

      return [];
    } catch (e, stackTrace) {
      developer.log(
        'Error parsing notifications',
        name: 'NotificationService',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }
}
