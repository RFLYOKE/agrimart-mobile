class AdminStatsModel {
  final UsersStats users;
  final TransactionStats transactions;
  final RevenueStats revenue;
  final CooperativeStats cooperatives;
  final int pendingClaims;
  final int activeAuctions;

  AdminStatsModel({
    required this.users,
    required this.transactions,
    required this.revenue,
    required this.cooperatives,
    required this.pendingClaims,
    required this.activeAuctions,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminStatsModel(
      users: UsersStats.fromJson(json['users'] ?? {}),
      transactions: TransactionStats.fromJson(json['transactions'] ?? {}),
      revenue: RevenueStats.fromJson(json['revenue'] ?? {}),
      cooperatives: CooperativeStats.fromJson(json['cooperatives'] ?? {}),
      pendingClaims: json['pendingClaims'] ?? 0,
      activeAuctions: json['activeAuctions'] ?? 0,
    );
  }
}

class UsersStats {
  final int total;
  final Map<String, int> breakdown;

  UsersStats({required this.total, required this.breakdown});

  factory UsersStats.fromJson(Map<String, dynamic> json) {
    return UsersStats(
      total: json['total'] ?? 0,
      breakdown: Map<String, int>.from(json['breakdown'] ?? {}),
    );
  }
}

class TransactionStats {
  final TransactionPeriod today;
  final TransactionPeriod thisWeek;
  final TransactionPeriod thisMonth;

  TransactionStats({
    required this.today,
    required this.thisWeek,
    required this.thisMonth,
  });

  factory TransactionStats.fromJson(Map<String, dynamic> json) {
    return TransactionStats(
      today: TransactionPeriod.fromJson(json['today'] ?? {}),
      thisWeek: TransactionPeriod.fromJson(json['thisWeek'] ?? {}),
      thisMonth: TransactionPeriod.fromJson(json['thisMonth'] ?? {}),
    );
  }
}

class TransactionPeriod {
  final int count;
  final double total;

  TransactionPeriod({required this.count, required this.total});

  factory TransactionPeriod.fromJson(Map<String, dynamic> json) {
    return TransactionPeriod(
      count: json['count'] ?? 0,
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}

class RevenueStats {
  final double total;

  RevenueStats({required this.total});

  factory RevenueStats.fromJson(Map<String, dynamic> json) {
    return RevenueStats(
      total: (json['total'] ?? 0).toDouble(),
    );
  }
}

class CooperativeStats {
  final int verified;
  final int pending;

  CooperativeStats({required this.verified, required this.pending});

  factory CooperativeStats.fromJson(Map<String, dynamic> json) {
    return CooperativeStats(
      verified: json['verified'] ?? 0,
      pending: json['pending'] ?? 0,
    );
  }
}
