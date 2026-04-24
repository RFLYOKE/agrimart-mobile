import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// List semua kontrak langganan
class SubscriptionListScreen extends StatefulWidget {
  const SubscriptionListScreen({super.key});

  @override
  State<SubscriptionListScreen> createState() => _SubscriptionListScreenState();
}

class _SubscriptionListScreenState extends State<SubscriptionListScreen> {
  final List<Map<String, dynamic>> _subscriptions = [
    {
      'id': 'sub_1',
      'productName': 'Beras Premium 5kg',
      'coopName': 'Koperasi Tani Makmur',
      'qty': 10,
      'frequency': 'weekly',
      'priceLocked': 60000,
      'status': 'active',
      'endDate': '2026-12-31',
    },
    {
      'id': 'sub_2',
      'productName': 'Telur Ayam Kampung Asli',
      'coopName': 'Peternakan Maju',
      'qty': 50,
      'frequency': 'biweekly',
      'priceLocked': 3000,
      'status': 'paused',
      'endDate': '2026-10-15',
    },
    {
      'id': 'sub_3',
      'productName': 'Minyak Goreng Sawit 2L',
      'coopName': 'Sawit Indo',
      'qty': 20,
      'frequency': 'monthly',
      'priceLocked': 32000,
      'status': 'cancelled',
      'endDate': '2026-03-01',
    },
  ];

  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Kontrak Langganan'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/hotel/subscriptions/create'),
        backgroundColor: const Color(0xFF8B5CF6),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Buat Kontrak', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _subscriptions.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final sub = _subscriptions[index];
          final statusColor = sub['status'] == 'active' 
              ? const Color(0xFF22C55E) 
              : sub['status'] == 'paused' 
                  ? const Color(0xFFF59E0B) 
                  : const Color(0xFFEF4444);
          final statusLabel = sub['status'] == 'active' ? 'Aktif' : sub['status'] == 'paused' ? 'Dihentikan Sementara' : 'Dibatalkan';
          
          final freqMap = {'daily': 'Harian', 'weekly': 'Mingguan', 'biweekly': 'Dua Mingguan', 'monthly': 'Bulanan'};

          return InkWell(
            onTap: () {
              // Tampilkan detail / dialog action (Pause/Cancel)
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sub['productName'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text(sub['coopName'], style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                        child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(color: Color(0xFF334155), height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoCol('Pengiriman', '${sub['qty']} unit\n${freqMap[sub['frequency']]}'),
                      _infoCol('Harga Terkunci', '${currencyFormat.format(sub['priceLocked'])}\nper unit'),
                      _infoCol('Berakhir', DateFormat('dd MMM yyyy').format(DateTime.parse(sub['endDate']))),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _infoCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
