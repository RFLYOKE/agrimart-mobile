import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Admin Dashboard — Home Screen
/// Menampilkan MetricCards overview dan navigasi ke sub-fitur admin.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;

  // Placeholder stats data — replace with actual API call via provider
  Map<String, dynamic> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _isLoading = true);

    // TODO: Replace with actual API call
    // final response = await ref.read(adminServiceProvider).getStats();
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _stats = {
        'totalUsers': 1250,
        'usersBreakdown': {
          'konsumen': 800,
          'koperasi': 250,
          'hotel_restoran': 120,
          'eksportir': 75,
          'admin': 5,
        },
        'revenueToday': 45670000,
        'pendingClaims': 3,
        'pendingCoops': 7,
        'activeAuctions': 12,
        'transactionsMonth': 3420,
      };
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      appBar: AppBar(
        title: const Text('Admin Dashboard — AgriMart'),
        backgroundColor: const Color(0xFF1E293B), // Slate 800
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: Navigate to admin notifications
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        color: const Color(0xFF22C55E),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF22C55E)),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Header ──────────────────────
                    const Text(
                      'Platform Overview',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(DateTime.now()),
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 20),

                    // ─── Metric Cards Grid ──────────────────────
                    GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.4,
                      children: [
                        _MetricCard(
                          icon: Icons.people_alt_rounded,
                          iconColor: const Color(0xFF60A5FA),
                          title: 'Total Pengguna',
                          value: NumberFormat('#,###').format(_stats['totalUsers']),
                          subtitle: _buildUserBreakdown(),
                        ),
                        _MetricCard(
                          icon: Icons.monetization_on_rounded,
                          iconColor: const Color(0xFF34D399),
                          title: 'Revenue Hari Ini',
                          value: currencyFormat.format(_stats['revenueToday']),
                          subtitle: null,
                        ),
                        _MetricCard(
                          icon: Icons.report_problem_rounded,
                          iconColor: const Color(0xFFF87171),
                          title: 'Klaim Pending',
                          value: '${_stats['pendingClaims']}',
                          badgeCount: _stats['pendingClaims'],
                          badgeColor: Colors.red,
                          subtitle: null,
                        ),
                        _MetricCard(
                          icon: Icons.verified_rounded,
                          iconColor: const Color(0xFFFBBF24),
                          title: 'Koperasi Pending',
                          value: '${_stats['pendingCoops']}',
                          badgeCount: _stats['pendingCoops'],
                          badgeColor: Colors.orange,
                          subtitle: null,
                        ),
                        _MetricCard(
                          icon: Icons.gavel_rounded,
                          iconColor: const Color(0xFFC084FC),
                          title: 'Auction Aktif',
                          value: '${_stats['activeAuctions']}',
                          subtitle: null,
                        ),
                        _MetricCard(
                          icon: Icons.receipt_long_rounded,
                          iconColor: const Color(0xFF38BDF8),
                          title: 'Transaksi Bulan Ini',
                          value: NumberFormat('#,###').format(_stats['transactionsMonth']),
                          subtitle: null,
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // ─── Quick Navigation ──────────────────────
                    const Text(
                      'Kelola Platform',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _NavButton(
                      icon: Icons.people_outline,
                      label: 'Kelola Pengguna',
                      color: const Color(0xFF3B82F6),
                      onTap: () {
                        Navigator.pushNamed(context, '/admin/users');
                      },
                    ),
                    const SizedBox(height: 10),
                    _NavButton(
                      icon: Icons.business_center_outlined,
                      label: 'Verifikasi Koperasi',
                      color: const Color(0xFFF59E0B),
                      badgeCount: _stats['pendingCoops'],
                      onTap: () {
                        Navigator.pushNamed(context, '/admin/cooperatives');
                      },
                    ),
                    const SizedBox(height: 10),
                    _NavButton(
                      icon: Icons.shield_outlined,
                      label: 'Kelola Klaim',
                      color: const Color(0xFFEF4444),
                      badgeCount: _stats['pendingClaims'],
                      onTap: () {
                        Navigator.pushNamed(context, '/admin/claims');
                      },
                    ),
                    const SizedBox(height: 10),
                    _NavButton(
                      icon: Icons.analytics_outlined,
                      label: 'Analytics',
                      color: const Color(0xFF8B5CF6),
                      onTap: () {
                        Navigator.pushNamed(context, '/admin/analytics');
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
      ),
    );
  }

  String _buildUserBreakdown() {
    final b = _stats['usersBreakdown'] as Map<String, dynamic>?;
    if (b == null) return '';
    return 'K:${b['konsumen']} | Kop:${b['koperasi']} | H:${b['hotel_restoran']} | E:${b['eksportir']}';
  }
}

// ─── Metric Card Widget ────────────────────────────────────

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String? subtitle;
  final int? badgeCount;
  final Color? badgeColor;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    this.subtitle,
    this.badgeCount,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Slate 800
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const Spacer(),
              if (badgeCount != null && badgeCount! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: (badgeColor ?? Colors.red).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$badgeCount',
                    style: TextStyle(
                      color: badgeColor ?? Colors.red,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(color: Colors.grey[400], fontSize: 12),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: TextStyle(color: Colors.grey[500], fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Navigation Button Widget ──────────────────────────────

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int? badgeCount;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (badgeCount != null && badgeCount! > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$badgeCount',
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
          ],
        ),
      ),
    );
  }
}
