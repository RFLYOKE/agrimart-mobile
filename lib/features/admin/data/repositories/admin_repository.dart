import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/admin_stats_model.dart';

class AdminRepository {
  final DioClient _dioClient;

  AdminRepository(this._dioClient);

  Future<AdminStatsModel> getStats() async {
    try {
      final response = await _dioClient.dio.get('/admin/stats');
      return AdminStatsModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getUsers({
    String? role,
    String? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/admin/users',
        queryParameters: {
          if (role != null && role != 'all') 'role': role,
          if (status != null && status != 'all') 'status': status,
          if (search != null && search.isNotEmpty) 'search': search,
          'page': page,
          'limit': limit,
        },
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getUserDetail(String id) async {
    try {
      final response = await _dioClient.dio.get('/admin/users/$id');
      return response.data['data'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateUserStatus(String id, String status, String reason) async {
    try {
      await _dioClient.dio.put(
        '/admin/users/$id/status',
        data: {
          'status': status,
          'reason': reason,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Map<String, dynamic>>> getPendingCooperatives() async {
    try {
      final response = await _dioClient.dio.get('/admin/cooperatives/pending');
      return List<Map<String, dynamic>>.from(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> verifyCooperative({
    required String coopId,
    required String action,
    String? reason,
  }) async {
    try {
      await _dioClient.dio.put(
        '/admin/cooperatives/verify',
        data: {
          'coop_id': coopId,
          'action': action,
          if (reason != null) 'reason': reason,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getClaims({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dioClient.dio.get(
        '/admin/claims',
        queryParameters: {
          if (status != null && status != 'all') 'status': status,
          'page': page,
          'limit': limit,
        },
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> getAnalytics({String period = 'daily'}) async {
    try {
      final response = await _dioClient.dio.get(
        '/admin/analytics',
        queryParameters: {'period': period},
      );
      return response.data['data'];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> approveClaim(String claimId) async {
    try {
      await _dioClient.dio.put('/fresh-guarantee/claims/$claimId/approve');
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> rejectClaim(String claimId, String reason) async {
    try {
      await _dioClient.dio.put(
        '/fresh-guarantee/claims/$claimId/reject',
        data: {'reason': reason},
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
