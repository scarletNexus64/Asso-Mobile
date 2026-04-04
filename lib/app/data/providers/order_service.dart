import '../../core/values/constants.dart';
import 'api_provider.dart';

class OrderService {
  /// Get user orders
  static Future<ApiResponse> getOrders({
    int page = 1,
    int perPage = 20,
    String? status,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };
    if (status != null) params['status'] = status;

    return await ApiProvider.get(AppConstants.ordersUrl, queryParams: params);
  }

  /// Get single order
  static Future<ApiResponse> getOrder(int id) async {
    return await ApiProvider.get('${AppConstants.ordersUrl}/$id');
  }

  /// Create order
  static Future<ApiResponse> createOrder({
    required List<Map<String, dynamic>> items,
    String? deliveryAddress,
    double? deliveryLatitude,
    double? deliveryLongitude,
    String? paymentMethod,
    String? notes,
    double? deliveryFee,
  }) async {
    return await ApiProvider.post(AppConstants.ordersUrl, body: {
      'items': items,
      'delivery_address': deliveryAddress,
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
      'payment_method': paymentMethod ?? 'mobile',
      'notes': notes,
      'delivery_fee': deliveryFee ?? 2000,
    });
  }

  /// Cancel order
  static Future<ApiResponse> cancelOrder(int id, {String? reason}) async {
    return await ApiProvider.post('${AppConstants.ordersUrl}/$id/cancel', body: {
      'reason': reason,
    });
  }

  /// Initiate payment
  static Future<ApiResponse> initiatePayment({
    required int orderId,
    required String paymentMethod,
    String? phoneNumber,
  }) async {
    return await ApiProvider.post(AppConstants.paymentInitiateUrl, body: {
      'order_id': orderId,
      'payment_method': paymentMethod,
      'phone_number': phoneNumber,
    });
  }

  /// Check payment status
  static Future<ApiResponse> checkPaymentStatus(String reference) async {
    return await ApiProvider.get('${AppConstants.paymentStatusUrl}/$reference');
  }
}
