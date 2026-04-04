import '../providers/api_provider.dart';
import '../../core/values/constants.dart';

class DeliveryService {
  /// Get pending delivery requests
  static Future<ApiResponse> getPendingRequests() async {
    return await ApiProvider.get(AppConstants.deliveryPendingUrl);
  }

  /// Get active (in-progress) deliveries
  static Future<ApiResponse> getActiveDeliveries() async {
    return await ApiProvider.get(AppConstants.deliveryActiveUrl);
  }

  /// Accept a delivery request (start the delivery)
  static Future<ApiResponse> acceptDelivery(int orderId) async {
    return await ApiProvider.post('/v1/delivery/$orderId/accept', body: {});
  }

  /// Complete a delivery
  static Future<ApiResponse> completeDelivery(int orderId) async {
    return await ApiProvider.post('/v1/delivery/$orderId/complete', body: {});
  }
}
