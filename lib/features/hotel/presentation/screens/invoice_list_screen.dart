import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvoiceListScreen extends StatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  State<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends State<InvoiceListScreen> {
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _invoices = [
    {
      'id': 'INV-202604-001',
      'periodStart': '2026-03-01',
      'periodEnd': '2026-03-31',
      'total': 18500000,
      'status': 'overdue',
      'dueDate': '2026-04-15',
    },
    {
      'id': 'INV-202603-042',
      'periodStart': '2026-02-01',
      'periodEnd': '2026-02-28',
      'total': 15200000,
      'status': 'paid',
      'dueDate': '2026-03-15',
    },
    {
      'id': 'INV-202604-DRAFT',
      'periodStart': '2026-04-01',
      'periodEnd': '2026-04-30',
      'total': 8400000,
      'status': 'draft',
      'dueDate': '2026-05-15',
    },
  ];

  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  List<Map<String, dynamic>> get _filtered {
    if (_selectedFilter == 'all') return _invoices;
    return _invoices.where((i) => i['status'] == _selectedFilter).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'all', 'label': 'Semua'},
      {'key': 'draft', 'label': 'Belum Final'},
      {'key': 'sent', 'label': 'Terkirim'},
      {'key': 'paid', 'label': 'Lunas'},
      {'key': 'overdue', 'label': 'Jatuh Tempo'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Invoice Digital'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final f = filters[i];
                final active = _selectedFilter == f['key'];
                return FilterChip(
                  label: Text(f['label']!),
                  selected: active,
                  onSelected: (_) => setState(() => _selectedFilter = f['key']!),
                  backgroundColor: const Color(0xFF1E293B),
                  selectedColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                  labelStyle: TextStyle(
                    color: active ? const Color(0xFFF59E0B) : Colors.grey[400],
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(color: active ? const Color(0xFFF59E0B) : const Color(0xFF334155)),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final inv = _filtered[i];
                final isOverdue = inv['status'] == 'overdue';
                
                final statusColor = _getStatusColor(inv['status']);
                final statusLabel = _getStatusLabel(inv['status']);

                return InkWell(
                  onTap: () => Navigator.pushNamed(context, '/hotel/invoices/detail', arguments: inv['id']),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isOverdue ? Colors.red : const Color(0xFF334155), width: isOverdue ? 2 : 1),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(inv['id'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                              child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFF334155), height: 1)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Periode', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(
                                  '${DateFormat('dd MMM').format(DateTime.parse(inv['periodStart']))} - ${DateFormat('dd MMM yyyy').format(DateTime.parse(inv['periodEnd']))}',
                                  style: const TextStyle(color: Colors.white, fontSize: 13),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Total', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                                const SizedBox(height: 4),
                                Text(currencyFormat.format(inv['total']), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ],
                        ),
                        if (inv['status'] != 'paid') ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, color: isOverdue ? Colors.red : Colors.orange, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                'Jatuh Tempo: ${DateFormat('dd MMM yyyy').format(DateTime.parse(inv['dueDate']))}',
                                style: TextStyle(color: isOverdue ? Colors.red : Colors.orange, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ]
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

  Color _getStatusColor(String status) {
    if (status == 'paid') return const Color(0xFF22C55E);
    if (status == 'overdue') return const Color(0xFFEF4444);
    if (status == 'sent') return const Color(0xFF3B82F6);
    return Colors.grey;
  }

  String _getStatusLabel(String status) {
    if (status == 'paid') return 'Lunas';
    if (status == 'overdue') return 'Jatuh Tempo';
    if (status == 'sent') return 'Menunggu Pembayaran';
    return 'Draft';
  }
}
