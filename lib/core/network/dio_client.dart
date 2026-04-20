import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../constants/api_constants.dart';
import 'auth_interceptor.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  static DioClient get instance => _instance;

  late Dio dio;
  final secureStorage = const FlutterSecureStorage();
  
  // Callback untuk handle logout dari interceptor
  // Di-set dari luar saat inisialisasi / provider
  Function()? onLogoutCallback;

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    dio.interceptors.add(AuthInterceptor(
      dio: Dio(BaseOptions(baseUrl: ApiConstants.baseUrl)), // Dedicated dio instance for refresh
      secureStorage: secureStorage,
      onLogout: () {
        if (onLogoutCallback != null) {
          onLogoutCallback!();
        }
      },
    ));

    if (kDebugMode) {
      dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
      ));
    }
  }
}
