import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/fresh_guarantee_repository.dart';

final freshGuaranteeRepositoryProvider = Provider<FreshGuaranteeRepository>((ref) {
  return FreshGuaranteeRepository(DioClient.instance);
});
