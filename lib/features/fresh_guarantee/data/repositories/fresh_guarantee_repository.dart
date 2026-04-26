import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';

class FreshGuaranteeRepository {
  final DioClient _dioClient;

  FreshGuaranteeRepository(this._dioClient);

  Future<void> confirmReceipt({
    required String orderId,
    required String condition,
    List<String>? photoUrls,
  }) async {
    try {
      await _dioClient.dio.post(
        '/fresh-guarantee/orders/$orderId/confirm',
        data: {
          'order_id': orderId,
          'condition': condition,
          if (photoUrls != null && photoUrls.isNotEmpty) 'photo_urls': photoUrls,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> createClaim({
    required String orderId,
    required String issueType,
    String? description,
    required List<String> photoUrls,
    required String refundType,
  }) async {
    try {
      await _dioClient.dio.post(
        '/fresh-guarantee/claims',
        data: {
          'order_id': orderId,
          'issue_type': issueType,
          if (description != null) 'description': description,
          'photo_urls': photoUrls,
          'refund_type': refundType,
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
