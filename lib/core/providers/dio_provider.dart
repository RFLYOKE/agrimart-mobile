import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';

final dioProvider = Provider<Dio>((ref) {
  // If we needed to tie the logout callback to riverpod auth provider,
  // we would set DioClient.instance.onLogoutCallback here.
  return DioClient.instance.dio;
});
