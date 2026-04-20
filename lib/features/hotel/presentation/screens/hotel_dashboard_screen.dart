import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Home screen khusus role Hotel & Restoran
class HotelDashboardScreen extends StatefulWidget {
  const HotelDashboardScreen({super.key});

  @override
  State<HotelDashboardScreen> createState() => _HotelDashboardScreenState();
}

class _HotelDashboardScreenState extends State<HotelDashboardScreen> {
  bool _isLoading = true;

  // Dummy data
  final String _hotelName = 'Hotel Nusantara';
  final Map<String, dynamic> _stats = {
    'totalOrderBulanIni': 12,
    'tagihanBelumLunas': 2,
    'langgananAktif': 3,
  };

  final List<Map<String, dynamic>> _activeSubscriptions = [
    {
      'id': 'sub_1',
      'productName': 'Beras Premium 5kg',
      'qty': 10,
      'frequency': 'weekly',
      'nextDelivery': '2026-04-22',
    },
    {
      'id': 'sub_2',
      'productName': 'Telur Ayam Kampung Asli',
      'qty': 50,
      'frequency': 'biweekly',
      'nextDelivery': '2026-04-25',
    },
  ];

  final List<Map<String, dynamic>> _recentBulkOrders = [
    {
      'id': 'bo_001',
      'date': '2026-04-18',
      'total': 4500000,
      'status': 'processing',
    },
    {
      'id': 'bo_002',
      'date': '2026-04-10',
      'total': 1250000,
      'status': 'delivered',
    },
  ];

  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.business_center, color: Color(0xFF22C55E)),
            const SizedBox(width: 8),
            Text(_hotelName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/hotel/bulk-order/create'),
        backgroundColor: const Color(0xFF22C55E),
        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
        label: const Text('Order Massal', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF22C55E)))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: const Color(0xFF22C55E),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Quick Stats ---
                    Row(
                      children: [
                        Expanded(child: _StatCard(title: 'Order Bulan Ini', value: '${_stats['totalOrderBulanIni']}', color: const Color(0xFF3B82F6))),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(title: 'Tagihan Belum Lunas', value: '${_stats['tagihanBelumLunas']}', color: const Color(0xFFEF4444))),
                        const SizedBox(width: 12),
                        Expanded(child: _StatCard(title: 'Langganan Aktif', value: '${_stats['langgananAktif']}', color: const Color(0xFF22C55E))),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- Menu Navigasi ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _MenuBtn(icon: Icons.repeat, label: 'Langganan', color: const Color(0xFF8B5CF6), onTap: () => Navigator.pushNamed(context, '/hotel/subscriptions')),
                        _MenuBtn(icon: Icons.receipt_long, label: 'Invoice', color: const Color(0xFFF59E0B), onTap: () => Navigator.pushNamed(context, '/hotel/invoices')),
                        _MenuBtn(icon: Icons.history, label: 'Riwayat', color: const Color(0xFF64748B), onTap: () => Navigator.pushNamed(context, '/hotel/bulk-order')),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // --- Langganan Aktif ---
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Langganan Aktif', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () => Navigator.pushNamed(context, '/hotel/subscriptions'),
                          child: const Text('Lihat Semua', style: TextStyle(color: Color(0xFF22C55E))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 140,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _activeSubscriptions.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final sub = _activeSubscriptions[index];
                          final freqMap = {'daily': 'Harian', 'weekly': 'Mingguan', 'biweekly': 'Dua Mingguan', 'monthly': 'Bulanan'};
                          return Container(
                            width: 260,
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
                                  children: [
                                    const Icon(Icons.inventory_2, color: Color(0xFF22C55E), size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(sub['productName'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text('${sub['qty']} unit • ${freqMap[sub['frequency']]}', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(8)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.calendar_today, color: Colors.white, size: 12),
                                      const SizedBox(width: 6),
                                      Text('Kirim: ${DateFormat('dd MMM').format(DateTime.parse(sub['nextDelivery']))}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- Order Massal Terakhir ---
                    const Text('Order Massal Terakhir', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ..._recentBulkOrders.map((order) {
                      final statusColor = order['status'] == 'delivered' ? const Color(0xFF22C55E) : const Color(0xFFF59E0B);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12)),
                              child: const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(order['id'].toString().toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Text(DateFormat('dd MMM yyyy').format(DateTime.parse(order['date'])), style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(currencyFormat.format(order['total']), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                const SizedBox(height: 4),
                                Text(
                                  order['status'].toString().toUpperCase(),
                                  style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 80), // Spacer for FAB
                  ],
                ),
              ),
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
        ],
      ),
    );
  }
}

class _MenuBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
