import 'package:flutter/material.dart';

class RfqListScreen extends StatefulWidget {
  const RfqListScreen({super.key});

  @override
  State<RfqListScreen> createState() => _RfqListScreenState();
}

class _RfqListScreenState extends State<RfqListScreen> {
  String _filter = 'Semua';

  final List<Map<String, dynamic>> _rfqs = [
    {
      'id': 'RFQ-001',
      'title': 'Kebutuhan Udang Vannamei 10 Ton untuk Jepang',
      'commodity': 'Udang Vannamei Size 40',
      'qty': '10 Ton',
      'targetPrice': 'Rp 80.000 / kg',
      'deadline': '2026-05-01',
      'quotes': 5,
      'status': 'open',
    },
    {
      'id': 'RFQ-002',
      'title': 'Kopi Arabika Gayo Grade 1',
      'commodity': 'Biji Kopi Hijau (Green Beans)',
      'qty': '5 Ton',
      'targetPrice': 'Rp 95.000 / kg',
      'deadline': '2026-04-25',
      'quotes': 3,
      'status': 'open',
    },
    {
      'id': 'RFQ-003',
      'title': 'Daging Sapi Beku Grade A',
      'commodity': 'Daging Sapi Import Quality',
      'qty': '2 Ton',
      'targetPrice': 'Rp 110.000 / kg',
      'deadline': '2026-03-15',
      'quotes': 12,
      'status': 'awarded',
    },
  ];

  List<Map<String, dynamic>> get _filteredRfqs {
    if (_filter == 'Semua') return _rfqs;
    final statusMap = {'Terbuka': 'open', 'Selesai/Awarded': 'awarded'};
    return _rfqs.where((r) => r['status'] == statusMap[_filter]).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Kelola RFQ Saya'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: ['Semua', 'Terbuka', 'Selesai/Awarded'].map((f) {
                final active = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: active,
                    onSelected: (_) => setState(() => _filter = f),
                    backgroundColor: const Color(0xFF1E293B),
                    selectedColor: const Color(0xFF3B82F6).withOpacity(0.2),
                    labelStyle: TextStyle(
                      color: active ? const Color(0xFF3B82F6) : Colors.grey[400],
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(color: active ? const Color(0xFF3B82F6) : const Color(0xFF334155)),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredRfqs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final rfq = _filteredRfqs[index];
                final isOpen = rfq['status'] == 'open';
                
                return InkWell(
                  onTap: () => Navigator.pushNamed(context, '/exporter/rfq/detail', arguments: rfq['id']),
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
                            Expanded(child: Text(rfq['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: isOpen ? const Color(0xFF10B981).withOpacity(0.15) : const Color(0xFF64748B).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                              child: Text(isOpen ? 'OPEN' : 'AWARDED', style: TextStyle(color: isOpen ? const Color(0xFF10B981) : const Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(rfq['commodity'], style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFF334155), height: 1)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Target Harga', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                const SizedBox(height: 2),
                                Text(rfq['targetPrice'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Kuantitas', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                const SizedBox(height: 2),
                                Text(rfq['qty'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.inbox, color: Colors.grey[400], size: 16),
                                const SizedBox(width: 6),
                                Text('${rfq['quotes']} Penawaran', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.grey[400], size: 16),
                                const SizedBox(width: 6),
                                Text(rfq['deadline'], style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
