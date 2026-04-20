import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final String invoiceId;
  const InvoiceDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    // Dummy data
    final Map<String, dynamic> invoice = {
      'id': invoiceId,
      'status': 'overdue',
      'periodStart': '2026-03-01',
      'periodEnd': '2026-03-31',
      'dueDate': '2026-04-15',
      'subtotal': 16666667,
      'tax': 1833333,
      'total': 18500000,
      'pdfUrl': 'https://example.com/invoice.pdf',
      'items': [
        {'name': 'Beras Premium 5kg', 'qty': 40, 'price': 60000},
        {'name': 'Telur Ayam Kampung', 'qty': 200, 'price': 3000},
        {'name': 'Daging Sapi Segar 1kg', 'qty': 50, 'price': 130000},
      ]
    };

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Detail Invoice', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // --- Invoice Paper UI ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.eco, color: Color(0xFF22C55E), size: 28),
                              SizedBox(width: 8),
                              Text('AgriMart', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('B2B Supply Chain', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('INVOICE', style: TextStyle(color: Colors.black, fontSize: 28, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(invoice['id'], style: TextStyle(color: Colors.grey[800], fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ditagihkan Kepada:', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          const SizedBox(height: 4),
                          const Text('Hotel Nusantara', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 2),
                          Text('Jl. Sudirman No. 123\nJakarta Pusat, 10220', style: TextStyle(color: Colors.grey[800], fontSize: 13)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Periode Tagihan:', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            '${DateFormat('dd MMM').format(DateTime.parse(invoice['periodStart']))} - ${DateFormat('dd MMM yyyy').format(DateTime.parse(invoice['periodEnd']))}',
                            style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 12),
                          Text('Jatuh Tempo:', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('dd MMM yyyy').format(DateTime.parse(invoice['dueDate'])),
                            style: const TextStyle(color: Colors.red, fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Divider(color: Colors.black26),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(flex: 3, child: Text('Deskripsi Item', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                        Expanded(flex: 1, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('Harga', textAlign: TextAlign.right, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                        Expanded(flex: 2, child: Text('Total', textAlign: TextAlign.right, style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),
                  const Divider(color: Colors.black26),
                  ...((invoice['items'] as List).map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(flex: 3, child: Text(item['name'], style: const TextStyle(color: Colors.black87, fontSize: 13))),
                            Expanded(flex: 1, child: Text('${item['qty']}', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black87, fontSize: 13))),
                            Expanded(flex: 2, child: Text(NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(item['price']), textAlign: TextAlign.right, style: const TextStyle(color: Colors.black54, fontSize: 13))),
                            Expanded(flex: 2, child: Text(NumberFormat.currency(locale: 'id_ID', symbol: '', decimalDigits: 0).format(item['price'] * item['qty']), textAlign: TextAlign.right, style: const TextStyle(color: Colors.black87, fontSize: 13))),
                          ],
                        ),
                      ))),
                  const Divider(color: Colors.black26),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Subtotal:', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          const SizedBox(height: 8),
                          Text('PPN (11%):', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          const SizedBox(height: 12),
                          const Text('TOTAL:', style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(currencyFormat.format(invoice['subtotal']), style: const TextStyle(color: Colors.black87, fontSize: 13)),
                          const SizedBox(height: 8),
                          Text(currencyFormat.format(invoice['tax']), style: const TextStyle(color: Colors.black87, fontSize: 13)),
                          const SizedBox(height: 12),
                          Text(currencyFormat.format(invoice['total']), style: const TextStyle(color: Colors.green, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Buka PDF form S3 di browser
                    },
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: const Text('Download PDF', style: TextStyle(color: Colors.white)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: Color(0xFF334155)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                if (invoice['status'] != 'paid') ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Buka payment gateway / PaymentScreen
                      },
                      icon: const Icon(Icons.payment, color: Colors.white),
                      label: const Text('Bayar Sekarang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ]
              ],
            )
          ],
        ),
      ),
    );
  }
}
