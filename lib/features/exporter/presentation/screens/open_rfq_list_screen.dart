import 'package:flutter/material.dart';

class OpenRfqListScreen extends StatefulWidget {
  const OpenRfqListScreen({super.key});

  @override
  State<OpenRfqListScreen> createState() => _OpenRfqListScreenState();
}

class _OpenRfqListScreenState extends State<OpenRfqListScreen> {
  String _categoryFilter = 'Semua';

  final List<Map<String, dynamic>> _openRfqs = [
    {
      'id': 'RFQ-001',
      'title': 'Kebutuhan Udang Vannamei 10 Ton',
      'category': 'perikanan',
      'targetPrice': 'Rp 80.000 / kg',
      'qty': '10 Ton',
      'deadline': '2026-05-01',
      'exporter': 'PT Ekspor Indo Global',
      'certs': ['HACCP', 'GlobalGAP'],
    },
    {
      'id': 'RFQ-002',
      'title': 'Biji Kopi Arabika Gayo Grade 1',
      'category': 'pertanian',
      'targetPrice': 'Rp 95.000 / kg',
      'qty': '5 Ton',
      'deadline': '2026-04-25',
      'exporter': 'Coffee World Trade',
      'certs': ['Organik', 'FairTrade'],
    },
  ];

  List<Map<String, dynamic>> get _filtered {
    if (_categoryFilter == 'Semua') return _openRfqs;
    return _openRfqs.where((r) => r['category'] == _categoryFilter.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Peluang Ekspor Terbuka'),
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
              children: ['Semua', 'Pertanian', 'Perikanan', 'Peternakan'].map((f) {
                final active = _categoryFilter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
                    selected: active,
                    onSelected: (_) => setState(() => _categoryFilter = f),
                    backgroundColor: const Color(0xFF1E293B),
                    selectedColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: active ? const Color(0xFFF59E0B) : Colors.grey[400],
                      fontWeight: active ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(color: active ? const Color(0xFFF59E0B) : const Color(0xFF334155)),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final rfq = _filtered[index];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: Text(rfq['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                          const Icon(Icons.public, color: Color(0xFF3B82F6), size: 20),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(rfq['exporter'], style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                      const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFF334155), height: 1)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Penawaran Terbaik', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                              const SizedBox(height: 2),
                              Text(rfq['targetPrice'], style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold)),
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
                        children: [
                          Icon(Icons.timer, color: Colors.red[400], size: 14),
                          const SizedBox(width: 4),
                          Text('Ditutup: ${rfq['deadline']}', style: TextStyle(color: Colors.red[400], fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        children: (rfq['certs'] as List<String>).map((c) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(8)),
                          child: Text(c, style: const TextStyle(color: Colors.white, fontSize: 10)),
                        )).toList(),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pushNamed(context, '/koperasi/rfq/submit', arguments: rfq['id']),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF59E0B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Kirim Penawaran Harga', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
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
