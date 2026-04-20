import 'dart:async';
import 'package:flutter/material.dart';

class ExporterDashboardScreen extends StatefulWidget {
  const ExporterDashboardScreen({super.key});

  @override
  State<ExporterDashboardScreen> createState() => _ExporterDashboardScreenState();
}

class _ExporterDashboardScreenState extends State<ExporterDashboardScreen> {
  final String _exporterName = 'PT Ekspor Indo Global';
  bool _isLoading = true;

  final Map<String, int> _stats = {
    'rfqAktif': 4,
    'penawaranMasuk': 12,
    'dokumenWarning': 1,
  };

  final List<Map<String, dynamic>> _myRFQs = [
    {
      'id': 'RFQ-001',
      'title': 'Udang Vannamei Size 40',
      'qty': '10 Ton',
      'deadline': '2026-05-01',
      'quotes': 5,
      'status': 'open',
    },
    {
      'id': 'RFQ-002',
      'title': 'Kopi Arabika Gayo Grade 1',
      'qty': '5 Ton',
      'deadline': '2026-04-25',
      'quotes': 3,
      'status': 'open',
    },
  ];

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.flight_takeoff, color: Color(0xFF3B82F6)),
            const SizedBox(width: 8),
            Text(_exporterName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/exporter/rfq/create'),
        backgroundColor: const Color(0xFF3B82F6),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Buat RFQ Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF3B82F6)))
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _CurrencyTickerWidget(),
                  
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Urgency Docs Warning ---
                        if (_stats['dokumenWarning']! > 0)
                          Container(
                            margin: const EdgeInsets.bottom(24),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFEF4444)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Peringatan: ${_stats['dokumenWarning']} dokumen ekspor akan kedaluwarsa dalam 30 hari.',
                                    style: const TextStyle(color: Color(0xFFEF4444), fontSize: 13),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pushNamed(context, '/exporter/documents'),
                                  child: const Text('Lihat', style: TextStyle(color: Color(0xFFEF4444), fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                          ),

                        // --- Quick Stats ---
                        Row(
                          children: [
                            Expanded(child: _StatCard(title: 'RFQ Aktif', value: '${_stats['rfqAktif']}', color: const Color(0xFF3B82F6))),
                            const SizedBox(width: 12),
                            Expanded(child: _StatCard(title: 'Penawaran', value: '${_stats['penawaranMasuk']}', color: const Color(0xFF10B981))),
                            const SizedBox(width: 12),
                            Expanded(child: _StatCard(title: 'Dokumen', value: 'Lihat', isAction: true, color: const Color(0xFFF59E0B), onTap: () => Navigator.pushNamed(context, '/exporter/documents'))),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // --- Menu Navigasi Tambahan ---
                        Row(
                          children: [
                            Expanded(
                              child: _MenuBtn(
                                icon: Icons.currency_exchange,
                                label: 'Kalkulator Kurs',
                                color: const Color(0xFF8B5CF6),
                                onTap: () => Navigator.pushNamed(context, '/exporter/currency'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _MenuBtn(
                                icon: Icons.list_alt,
                                label: 'Kelola RFQ',
                                color: const Color(0xFF3B82F6),
                                onTap: () => Navigator.pushNamed(context, '/exporter/rfq/list'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // --- RFQ Saya Aktif ---
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('RFQ Aktif Terbaru', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(context, '/exporter/rfq/list'),
                              child: const Text('Lihat Semua', style: TextStyle(color: Color(0xFF3B82F6))),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._myRFQs.map((rfq) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: InkWell(
                            onTap: () => Navigator.pushNamed(context, '/exporter/rfq/detail', arguments: rfq['id']),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: Text(rfq['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                                      child: const Text('OPEN', style: TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Kuantitas', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                        Text(rfq['qty'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('Batas Waktu', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                        Text(rfq['deadline'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                      ],
                                    ),
                                  ],
                                ),
                                const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFF334155), height: 1)),
                                Row(
                                  children: [
                                    Icon(Icons.inbox, color: Colors.grey[400], size: 16),
                                    const SizedBox(width: 8),
                                    Text('${rfq['quotes']} Penawaran Masuk', style: TextStyle(color: Colors.grey[300], fontSize: 13)),
                                    const Spacer(),
                                    const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
                                  ],
                                ),
                              ],
                            ),
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
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final bool isAction;
  final VoidCallback? onTap;

  const _StatCard({required this.title, required this.value, required this.color, this.isAction = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: isAction ? 18 : 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[400], fontSize: 11)),
          ],
        ),
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
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF334155)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

/// Marquee-like widget for displaying live currency rates
class _CurrencyTickerWidget extends StatefulWidget {
  const _CurrencyTickerWidget();

  @override
  State<_CurrencyTickerWidget> createState() => _CurrencyTickerWidgetState();
}

class _CurrencyTickerWidgetState extends State<_CurrencyTickerWidget> {
  final List<String> _rates = ['USD/IDR: 15,850 ▲', 'EUR/IDR: 17,200 ▼', 'JPY/IDR: 105.4 ▲', 'SGD/IDR: 11,800 ▲', 'AUD/IDR: 10,400 ▼'];
  late ScrollController _scrollController;
  Timer? _timer;
  
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScrolling());
  }

  void _startScrolling() {
    if (!mounted) return;
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final currentScroll = _scrollController.offset;
        
        if (currentScroll >= maxScroll) {
          _scrollController.jumpTo(0);
        } else {
          _scrollController.jumpTo(currentScroll + 1.0); // 1.0 px per 50ms
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: double.infinity,
      color: const Color(0xFF0F172A),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _rates.length * 10, // Artificial loop
        separatorBuilder: (_, __) => const SizedBox(width: 32),
        itemBuilder: (context, index) {
          final text = _rates[index % _rates.length];
          final isUp = text.contains('▲');
          return Text(
            text,
            style: TextStyle(color: isUp ? const Color(0xFF10B981) : const Color(0xFFEF4444), fontSize: 14, fontWeight: FontWeight.w600),
          );
        },
      ),
    );
  }
}
