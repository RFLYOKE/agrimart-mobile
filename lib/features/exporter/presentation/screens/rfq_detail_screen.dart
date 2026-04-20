import 'package:flutter/material.dart';

class RfqDetailScreen extends StatelessWidget {
  final String rfqId;
  const RfqDetailScreen({super.key, required this.rfqId});

  void _awardQuote(BuildContext context, Map<String, dynamic> quote) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Terima Penawaran?', style: TextStyle(color: Colors.white)),
        content: Text(
          'Menerima penawaran dari ${quote['coopName']} akan menutup RFQ ini dan otomatis membuat draft Order Ekspor senilai ${quote['totalIdr']}.\n\nLanjutkan?',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Penawaran diterima! Order draft dibuat.'), backgroundColor: Color(0xFF10B981)));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF3B82F6)),
            child: const Text('Ya, Terima', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Dummy RFQ data
    final rfq = {
      'title': 'Kebutuhan Udang Vannamei 10 Ton untuk Jepang',
      'commodity': 'Udang Vannamei Size 40',
      'qty': '10 Ton',
      'targetPriceIdr': 'Rp 80.000 / kg',
      'targetPriceUsd': '\$5.04 / kg',
      'deadline': '2026-05-01',
      'port': 'Tanjung Priok, Jakarta',
      'status': 'open',
    };

    final List<Map<String, dynamic>> quotes = [
      {
        'coopName': 'Koperasi Nelayan Sejahtera',
        'priceIdr': 'Rp 78.500 / kg',
        'priceUsd': '\$4.95 / kg',
        'totalIdr': 'Rp 785.000.000',
        'availableQty': '10 Ton',
        'deliveryDate': '2026-04-20',
        'certs': ['HACCP', 'Halal'],
        'notes': 'Produk fresh, siap masuk cold storage Pelabuhan 3 hari sebelum deadline.',
      },
      {
        'coopName': 'Tambak Makmur Bersama',
        'priceIdr': 'Rp 81.000 / kg',
        'priceUsd': '\$5.11 / kg',
        'totalIdr': 'Rp 810.000.000',
        'availableQty': '10 Ton',
        'deliveryDate': '2026-04-28',
        'certs': ['HACCP'],
        'notes': 'Terms pembayaran fleksibel.',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Detail RFQ'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- Info RFQ ---
            Container(
              padding: const EdgeInsets.all(16),
              color: const Color(0xFF1E293B),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                        child: const Text('OPEN', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                      const Spacer(),
                      Text('Batas Waktu: ${rfq['deadline']}', style: TextStyle(color: Colors.red[400], fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(rfq['title']!, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(rfq['commodity']!, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                  const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(color: Color(0xFF334155), height: 1)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _infoCol('Kuantitas', rfq['qty']!),
                      _infoCol('Target IDR', rfq['targetPriceIdr']!),
                      _infoCol('Target USD', rfq['targetPriceUsd']!),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _infoCol('Pelabuhan Tujuan', rfq['port']!),
                ],
              ),
            ),
            
            // --- Quotes List ---
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${quotes.length} Penawaran Masuk', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...quotes.map((q) => Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(backgroundColor: Color(0xFF0F172A), child: Icon(Icons.storefront, color: Color(0xFF3B82F6))),
                            const SizedBox(width: 12),
                            Expanded(child: Text(q['coopName'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(q['priceIdr'], style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('Setara dengan ${q['priceUsd']}', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Kesiapan', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                Text(q['deliveryDate'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          children: (q['certs'] as List<String>).map((c) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: const Color(0xFF334155), borderRadius: BorderRadius.circular(6)),
                            child: Text(c, style: const TextStyle(color: Colors.white, fontSize: 10)),
                          )).toList(),
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFF334155), height: 1)),
                        Text('Catatan: "${q['notes']}"', style: TextStyle(color: Colors.grey[400], fontStyle: FontStyle.italic, fontSize: 12)),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _awardQuote(context, q),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF3B82F6),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Terima Penawaran (Award)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }
}
