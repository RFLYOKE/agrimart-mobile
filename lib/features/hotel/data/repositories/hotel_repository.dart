import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class HotelRepository {
  final DioClient _dioClient;

  HotelRepository(this._dioClient);

  Future<void> createBulkOrder({
    required List<Map<String, dynamic>> items,
    required DateTime deliveryDate,
    required Map<String, dynamic> deliveryAddress,
    String? note,
  }) async {
    try {
      await _dioClient.dio.post(
        '/hotel/bulk-orders',
        data: {
          'items': items,
          'delivery_date': deliveryDate.toIso8601String(),
          'delivery_address': deliveryAddress,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> createSubscription({
    required String coopId,
    required String productId,
    required int qtyPerDelivery,
    required String frequency,
    required int deliveryDay,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      await _dioClient.dio.post(
        '/hotel/subscriptions',
        data: {
          'coop_id': coopId,
          'product_id': productId,
          'qty_per_delivery': qtyPerDelivery,
          'frequency': frequency,
          'delivery_day': deliveryDay,
          'start_date': startDate.toIso8601String(),
          'end_date': endDate.toIso8601String(),
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    if (e.response != null && e.response?.data is Map<String, dynamic>) {
      final message = e.response?.data['message'] ?? 'Terjadi kesalahan sistem';
      return Exception(message);
    }
    return Exception(e.message ?? 'Gagal terhubung ke server');
  }
}
