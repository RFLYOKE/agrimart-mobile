import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/admin_provider.dart';

/// Admin Analytics Screen — Revenue charts, top products, user distribution
class AdminAnalyticsScreen extends ConsumerStatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  ConsumerState<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends ConsumerState<AdminAnalyticsScreen> {
  String _selectedPeriod = 'daily';

  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final compactFormat = NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final analyticsAsync = ref.watch(adminAnalyticsProvider(_selectedPeriod));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: analyticsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF22C55E))),
        error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
        data: (data) {
          final revenueData = (data['revenue'] as List).cast<Map<String, dynamic>>();
          final topProducts = (data['topProducts'] as List).cast<Map<String, dynamic>>();
          final topCoops = (data['topCooperatives'] as List).cast<Map<String, dynamic>>();
          final userRolesRaw = (data['userRoles'] as List).cast<Map<String, dynamic>>();

          final colors = [
            const Color(0xFF3B82F6),
            const Color(0xFF22C55E),
            const Color(0xFFF59E0B),
            const Color(0xFF8B5CF6),
            const Color(0xFFEF4444),
          ];

          final userRoles = userRolesRaw.asMap().entries.map((e) {
            final idx = e.key;
            final map = Map<String, dynamic>.from(e.value);
            map['color'] = colors[idx % colors.length];
            return map;
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Period Selector ──────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: ['daily', 'weekly', 'monthly'].map((period) {
                      final isActive = _selectedPeriod == period;
                      final label = period == 'daily' ? 'Harian' : period == 'weekly' ? 'Mingguan' : 'Bulanan';
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedPeriod = period);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isActive ? const Color(0xFF22C55E) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isActive ? Colors.white : Colors.grey[400],
                                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Revenue Line Chart ──────────────────────
                _sectionTitle('Revenue'),
                const SizedBox(height: 12),
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 10000000,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: const Color(0xFF334155),
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 50,
                            getTitlesWidget: (value, meta) => Text(
                              compactFormat.format(value),
                              style: TextStyle(color: Colors.grey[500], fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'D${value.toInt()}',
                                style: TextStyle(color: Colors.grey[500], fontSize: 11),
                              ),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: revenueData.asMap().entries.map((e) => FlSpot(
                            e.key.toDouble(),
                            (e.value['revenue'] as num).toDouble(),
                          )).toList(),
                          isCurved: true,
                          color: const Color(0xFF22C55E),
                          barWidth: 3,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                              radius: 4,
                              color: const Color(0xFF22C55E),
                              strokeColor: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Top 5 Products Bar Chart ──────────────────────
                _sectionTitle('Top Produk Terlaris'),
                const SizedBox(height: 12),
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (topProducts.isNotEmpty ? (topProducts[0]['totalSold'] as num).toDouble() * 1.2 : 100),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 100,
                        getDrawingHorizontalLine: (value) => FlLine(color: const Color(0xFF334155), strokeWidth: 1),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}',
                              style: TextStyle(color: Colors.grey[500], fontSize: 10),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final idx = value.toInt();
                              if (idx >= 0 && idx < topProducts.length) {
                                final name = topProducts[idx]['productName'] as String;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    name.length > 8 ? '${name.substring(0, 8)}...' : name,
                                    style: TextStyle(color: Colors.grey[400], fontSize: 9),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: topProducts.asMap().entries.map((e) {
                        final colors = [
                          const Color(0xFF22C55E),
                          const Color(0xFF3B82F6),
                          const Color(0xFFF59E0B),
                          const Color(0xFF8B5CF6),
                          const Color(0xFFEC4899),
                        ];
                        return BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: (e.value['totalSold'] as num).toDouble(),
                              color: colors[e.key % colors.length],
                              width: 20,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ─── User Distribution Pie Chart ──────────────────────
                _sectionTitle('Distribusi User per Role'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Row(
                    children: [
                      // Pie Chart
                      SizedBox(
                        height: 160,
                        width: 160,
                        child: PieChart(
                          PieChartData(
                            sections: userRoles.map((r) {
                              return PieChartSectionData(
                                value: (r['count'] as num).toDouble(),
                                color: r['color'] as Color,
                                title: '${r['count']}',
                                titleStyle: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                radius: 50,
                              );
                            }).toList(),
                            sectionsSpace: 2,
                            centerSpaceRadius: 30,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Legend
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: userRoles.map((r) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 12, height: 12,
                                  decoration: BoxDecoration(
                                    color: r['color'] as Color,
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${r['role']} (${r['count']})',
                                  style: TextStyle(color: Colors.grey[300], fontSize: 12),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Top 10 Koperasi by Revenue ──────────────────────
                _sectionTitle('Top Koperasi by Revenue'),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: topCoops.length,
                    separatorBuilder: (_, __) => const Divider(color: Color(0xFF334155), height: 1),
                    itemBuilder: (_, i) {
                      final coop = topCoops[i];
                      return ListTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: const Color(0xFF22C55E).withValues(alpha: 0.15),
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                        title: Text(coop['coopName'] ?? 'Unknown', style: const TextStyle(color: Colors.white, fontSize: 14)),
                        trailing: Text(
                          compactFormat.format(coop['revenue']),
                          style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
    );
  }
}
