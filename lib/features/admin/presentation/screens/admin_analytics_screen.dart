import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

/// Admin Analytics Screen — Revenue charts, top products, user distribution
class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  String _selectedPeriod = 'daily';
  bool _isLoading = true;

  // Dummy data — replace with API call
  List<Map<String, dynamic>> _revenueData = [];
  List<Map<String, dynamic>> _topProducts = [];
  List<Map<String, dynamic>> _topCoops = [];
  List<Map<String, dynamic>> _userRoles = [];

  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  final compactFormat = NumberFormat.compactCurrency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _isLoading = true);

    // TODO: Replace with GET /admin/analytics?period=_selectedPeriod
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _revenueData = [
        {'day': 1, 'revenue': 12500000},
        {'day': 2, 'revenue': 18700000},
        {'day': 3, 'revenue': 15300000},
        {'day': 4, 'revenue': 22100000},
        {'day': 5, 'revenue': 19800000},
        {'day': 6, 'revenue': 28400000},
        {'day': 7, 'revenue': 24600000},
      ];
      _topProducts = [
        {'name': 'Beras Premium', 'sold': 450},
        {'name': 'Pupuk Organik', 'sold': 380},
        {'name': 'Benih Padi', 'sold': 320},
        {'name': 'Jagung Hibrida', 'sold': 280},
        {'name': 'Kopi Arabika', 'sold': 250},
      ];
      _topCoops = List.generate(10, (i) => {
        'name': 'Koperasi ${['Tani Makmur', 'Sumber Rejeki', 'Agro Mandiri', 'Nelayan Sejahtera', 'Peternakan Maju', 'Sawit Indo', 'Cacao Prima', 'Gula Nusantara', 'Rempah Nusa', 'Karet Jaya'][i]}',
        'revenue': (30000000 - i * 2500000),
      });
      _userRoles = [
        {'role': 'Konsumen', 'count': 800, 'color': const Color(0xFF3B82F6)},
        {'role': 'Koperasi', 'count': 250, 'color': const Color(0xFF22C55E)},
        {'role': 'Hotel/Resto', 'count': 120, 'color': const Color(0xFFF59E0B)},
        {'role': 'Eksportir', 'count': 75, 'color': const Color(0xFF8B5CF6)},
        {'role': 'Admin', 'count': 5, 'color': const Color(0xFFEF4444)},
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Analytics'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF22C55E)))
          : SingleChildScrollView(
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
                              _loadAnalytics();
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
                            spots: _revenueData.map((d) => FlSpot(
                              d['day'].toDouble(),
                              (d['revenue'] as num).toDouble(),
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
                  _sectionTitle('Top 5 Produk Terlaris'),
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
                        maxY: (_topProducts.isNotEmpty ? (_topProducts[0]['sold'] as num).toDouble() * 1.2 : 100),
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
                                if (idx >= 0 && idx < _topProducts.length) {
                                  final name = _topProducts[idx]['name'] as String;
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
                        barGroups: _topProducts.asMap().entries.map((e) {
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
                                toY: (e.value['sold'] as num).toDouble(),
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
                              sections: _userRoles.map((r) {
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
                            children: _userRoles.map((r) => Padding(
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
                  _sectionTitle('Top 10 Koperasi by Revenue'),
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
                      itemCount: _topCoops.length,
                      separatorBuilder: (_, __) => Divider(color: const Color(0xFF334155), height: 1),
                      itemBuilder: (_, i) {
                        final coop = _topCoops[i];
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFF22C55E).withValues(alpha: 0.15),
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                          title: Text(coop['name'], style: const TextStyle(color: Colors.white, fontSize: 14)),
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
