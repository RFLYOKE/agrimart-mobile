import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final FlutterSecureStorage secureStorage;
  final Function() onLogout;

  AuthInterceptor({
    required this.dio,
    required this.secureStorage,
    required this.onLogout,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final accessToken = await secureStorage.read(key: 'access_token');
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    if (response != null && response.statusCode == 401) {
      final path = err.requestOptions.path;
      
      // Mencegah infinite loop pada endpoint auth
      if (path != ApiConstants.refreshToken && path != ApiConstants.loginEmail && path != ApiConstants.loginGoogle) {
        final refreshToken = await secureStorage.read(key: 'refresh_token');
        
        if (refreshToken != null && refreshToken.isNotEmpty) {
          try {
            // Coba untuk refresh token
            final refreshResponse = await dio.post(
              ApiConstants.refreshToken,
              options: Options(
                headers: {
                  'Authorization': 'Bearer $refreshToken',
                },
              ),
            );

            if (refreshResponse.statusCode == 200) {
              final newAccessToken = refreshResponse.data['data']['access_token'];
              await secureStorage.write(key: 'access_token', value: newAccessToken);

              if (refreshResponse.data['data']['refresh_token'] != null) {
                await secureStorage.write(key: 'refresh_token', value: refreshResponse.data['data']['refresh_token']);
              }

              // Retry original request
              final opts = Options(
                method: err.requestOptions.method,
                headers: {
                  ...err.requestOptions.headers,
                  'Authorization': 'Bearer $newAccessToken',
                },
              );
              
              final cloneReq = await dio.request(
                err.requestOptions.path,
                options: opts,
                data: err.requestOptions.data,
                queryParameters: err.requestOptions.queryParameters,
              );

              return handler.resolve(cloneReq);
            }
          } catch (e) {
            // Jika refresh gagal, keluarkan paksa
            await secureStorage.deleteAll();
            onLogout();
            return handler.next(err);
          }
        } else {
          // Tidak punya refresh token
          await secureStorage.deleteAll();
          onLogout();
        }
      }
    }
    return handler.next(err);
  }
}
