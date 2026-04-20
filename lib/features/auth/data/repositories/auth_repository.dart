import 'package:dio/dio.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/user_model.dart';
import '../../../../core/network/dio_client.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<Map<String, dynamic>> loginWithEmail(String email, String password) async {
    try {
      final response = await _dio.post(ApiConstants.loginEmail, data: {
        'email': email,
        'password': password,
      });
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> registerWithEmail(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(ApiConstants.registerEmail, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> sendOtp(String phone) async {
    try {
      await _dio.post(ApiConstants.sendOtp, data: {'phone': phone});
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp, {String? name, String? role}) async {
    try {
      final data = {'phone': phone, 'otp': otp};
      if (name != null) data['name'] = name;
      if (role != null) data['role'] = role;

      final response = await _dio.post(ApiConstants.verifyOtp, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> loginWithGoogle(String idToken, {String? role}) async {
    try {
      final data = {'id_token': idToken};
      if (role != null) data['role'] = role;

      final response = await _dio.post(ApiConstants.loginGoogle, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> refreshToken(String refreshTokenStr) async {
    try {
      final response = await _dio.post(
        ApiConstants.refreshToken,
        options: Options(headers: {'Authorization': 'Bearer $refreshTokenStr'}),
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserModel> getMe() async {
    try {
      final response = await _dio.get(ApiConstants.me);
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  ApiException _handleError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      return ApiException(
        statusCode: e.response?.statusCode,
        message: data is Map && data['message'] != null ? data['message'] : e.message ?? 'Unknown error',
        data: data,
      );
    } else {
      return ApiException(message: 'Connection error: ${e.message}');
    }
  }
}
