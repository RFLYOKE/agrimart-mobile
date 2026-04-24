import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import 'set_alert_bottom_sheet.dart';
import 'price_alert_list_screen.dart';

class PriceHomeScreen extends StatefulWidget {
  const PriceHomeScreen({super.key});

  @override
  State<PriceHomeScreen> createState() => _PriceHomeScreenState();
}

class _PriceHomeScreenState extends State<PriceHomeScreen> {
  final List<String> _commodities = ['Cabai Merah', 'Bawang Putih', 'Udang Vannamei', 'Kopi Arabica', 'Telur Ayam'];
  String _selectedCommodity = 'Cabai Merah';
  
  // 0: 7 Hari, 1: 30 Hari, 2: 3 Bulan
  int _selectedTimeRange = 0;

  // Mock Data: List of FlSpot (x: date index, y: price in thousands)
  List<FlSpot> _getChartData() {
    if (_selectedTimeRange == 0) {
      return const [
        FlSpot(0, 45), FlSpot(1, 46.5), FlSpot(2, 44), 
        FlSpot(3, 48), FlSpot(4, 50), FlSpot(5, 52), FlSpot(6, 55)
      ];
    } else if (_selectedTimeRange == 1) {
      return List.generate(30, (index) => FlSpot(index.toDouble(), 40 + (index * 0.5) + (index % 3)));
    } else {
      return List.generate(12, (index) => FlSpot(index.toDouble(), 35 + (index * 2))); // mapping to weeks
    }
  }

  void _showSetAlertDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SetAlertBottomSheet(commodity: _selectedCommodity),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chartData = _getChartData();
    double highest = chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    double lowest = chartData.map((e) => e.y).reduce((a, b) => a < b ? a : b);
    double avg = chartData.map((e) => e.y).reduce((a, b) => a + b) / chartData.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriAnalytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_active),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PriceAlertListScreen())),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Pilih Komoditas', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCommodity,
                        isExpanded: true,
                        items: _commodities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCommodity = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  Center(
                    child: SegmentedButton<int>(
                      segments: const [
                        ButtonSegment(value: 0, label: Text('7 Hari')),
                        ButtonSegment(value: 1, label: Text('30 Hari')),
                        ButtonSegment(value: 2, label: Text('3 Bulan')),
                      ],
                      selected: {_selectedTimeRange},
                      onSelectionChanged: (Set<int> newSelection) {
                        setState(() => _selectedTimeRange = newSelection.first);
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) return AppColors.primaryGreen;
                          return Colors.transparent;
                        }),
                        foregroundColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
                          if (states.contains(WidgetState.selected)) return Colors.white;
                          return AppColors.primaryGreen;
                        }),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // LINE CHART
                  SizedBox(
                    height: 250,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              getTitlesWidget: (value, meta) {
                                return Text(value.toInt().toString(), style: const TextStyle(fontSize: 10, color: Colors.grey));
                              },
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                // Simplified date formatting for x-axis
                                if (_selectedTimeRange == 0) {
                                  final dates = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
                                  return Padding(padding: const EdgeInsets.only(top: 8), child: Text(dates[value.toInt() % 7], style: const TextStyle(fontSize: 10, color: Colors.grey)));
                                }
                                return const SizedBox();
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: 0,
                        maxX: chartData.length.toDouble() - 1,
                        minY: lowest - 5,
                        maxY: highest + 5,
                        lineBarsData: [
                          LineChartBarData(
                            spots: chartData,
                            isCurved: true,
                            color: AppColors.primaryGreen,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: const FlDotData(show: true),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors.primaryGreen.withValues(alpha: 0.2), // Gradient equivalent
                            ),
                          ),
                        ],
                        lineTouchData: LineTouchData(
                          touchTooltipData: LineTouchTooltipData(
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                return LineTooltipItem(
                                  CurrencyFormatter.formatRupiah(spot.y * 1000),
                                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                );
                              }).toList();
                            },
                          ),
                        )
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  const Align(alignment: Alignment.center, child: Text('*Harga dalam ribuan Rupiah', style: TextStyle(color: Colors.grey, fontSize: 12))),
                  const SizedBox(height: 32),
                  
                  // INFO CARDS
                  Row(
                    children: [
                      Expanded(child: _buildInfoCard('Tertinggi', highest * 1000, Colors.red)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildInfoCard('Terendah', lowest * 1000, Colors.blue)),
                      const SizedBox(width: 8),
                      Expanded(child: _buildInfoCard('Rata-rata', avg * 1000, AppColors.primaryGreen)),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))]),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add_alert, color: Colors.white),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              onPressed: _showSetAlertDialog,
              label: const Text('Set Price Alert', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.formatRupiahCompact(value),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }
}
