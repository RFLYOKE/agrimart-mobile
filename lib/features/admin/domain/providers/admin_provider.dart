import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/repositories/admin_repository.dart';
import '../../data/models/admin_stats_model.dart';

// --- Repositories ---

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AdminRepository(dioClient);
});

// --- Future Providers ---

final adminStatsProvider = FutureProvider.autoDispose<AdminStatsModel>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getStats();
});

final adminUsersProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, Map<String, dynamic>>((ref, queryParams) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getUsers(
    role: queryParams['role'],
    status: queryParams['status'],
    search: queryParams['search'],
    page: queryParams['page'] ?? 1,
    limit: queryParams['limit'] ?? 20,
  );
});

final adminUserDetailProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, String>((ref, id) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getUserDetail(id);
});

final adminPendingCoopsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getPendingCooperatives();
});

final adminClaimsProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, Map<String, dynamic>>((ref, queryParams) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getClaims(
    status: queryParams['status'],
    page: queryParams['page'] ?? 1,
    limit: queryParams['limit'] ?? 20,
  );
});

final adminAnalyticsProvider = FutureProvider.family.autoDispose<Map<String, dynamic>, String>((ref, period) async {
  final repository = ref.watch(adminRepositoryProvider);
  return await repository.getAnalytics(period: period);
});

// --- Action Providers ---

final adminActionsProvider = Provider<AdminActions>((ref) {
  return AdminActions(ref.watch(adminRepositoryProvider), ref);
});

class AdminActions {
  final AdminRepository _repository;
  final Ref _ref;

  AdminActions(this._repository, this._ref);

  Future<void> updateUserStatus(String id, String status, String reason) async {
    await _repository.updateUserStatus(id, status, reason);
    _ref.invalidate(adminUserDetailProvider(id));
  }

  Future<void> verifyCooperative(String coopId, String action, {String? reason}) async {
    await _repository.verifyCooperative(coopId: coopId, action: action, reason: reason);
    _ref.invalidate(adminPendingCoopsProvider);
  }

  Future<void> approveClaim(String claimId) async {
    await _repository.approveClaim(claimId);
    // Invalidate claims list to refresh
    _ref.invalidate(adminClaimsProvider);
  }

  Future<void> rejectClaim(String claimId, String reason) async {
    await _repository.rejectClaim(claimId, reason);
    _ref.invalidate(adminClaimsProvider);
  }
}
