import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/hotel_repository.dart';

final hotelRepositoryProvider = Provider<HotelRepository>((ref) {
  return HotelRepository(DioClient.instance);
});
