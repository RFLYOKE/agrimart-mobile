import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Admin Claims Screen — List semua klaim Fresh Guarantee
class AdminClaimsScreen extends StatefulWidget {
  const AdminClaimsScreen({super.key});

  @override
  State<AdminClaimsScreen> createState() => _AdminClaimsScreenState();
}

class _AdminClaimsScreenState extends State<AdminClaimsScreen> {
  String _selectedFilter = 'all';
  bool _isLoading = true;
  List<Map<String, dynamic>> _claims = [];

  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadClaims();
  }

  Future<void> _loadClaims() async {
    setState(() => _isLoading = true);

    // TODO: Replace with GET /admin/claims?status=...
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _claims = [
        {
          'id': 'clm_1',
          'buyerName': 'Budi Santoso',
          'productName': 'Beras Premium 5kg',
          'issueType': 'Produk Rusak',
          'description': 'Kemasan sobek, beras terkontaminasi air.',
          'photoUrls': ['https://example.com/photo1.jpg', 'https://example.com/photo2.jpg'],
          'refundAmount': 75000,
          'status': 'pending',
          'createdAt': '2026-04-18T10:30:00Z',
        },
        {
          'id': 'clm_2',
          'buyerName': 'Siti Aminah',
          'productName': 'Pupuk Organik 10L',
          'issueType': 'Tidak Sesuai',
          'description': 'Produk tidak sesuai deskripsi.',
          'photoUrls': ['https://example.com/photo3.jpg'],
          'refundAmount': 120000,
          'status': 'approved',
          'createdAt': '2026-04-15T14:00:00Z',
        },
        {
          'id': 'clm_3',
          'buyerName': 'Andi Wijaya',
          'productName': 'Benih Jagung Hibrida',
          'issueType': 'Kadaluarsa',
          'description': 'Benih sudah lewat tanggal expired.',
          'photoUrls': [],
          'refundAmount': 50000,
          'status': 'rejected',
          'createdAt': '2026-04-10T08:00:00Z',
        },
      ];
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredClaims {
    if (_selectedFilter == 'all') return _claims;
    return _claims.where((c) => c['status'] == _selectedFilter).toList();
  }

  void _handleApprove(String claimId) {
    // TODO: PUT /admin/claims/:id/approve
    setState(() {
      final idx = _claims.indexWhere((c) => c['id'] == claimId);
      if (idx != -1) _claims[idx]['status'] = 'approved';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Klaim disetujui'), backgroundColor: Color(0xFF22C55E)),
    );
  }

  void _handleReject(String claimId) {
    // TODO: PUT /admin/claims/:id/reject
    setState(() {
      final idx = _claims.indexWhere((c) => c['id'] == claimId);
      if (idx != -1) _claims[idx]['status'] = 'rejected';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('❌ Klaim ditolak'), backgroundColor: Color(0xFFEF4444)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filters = [
      {'key': 'all', 'label': 'Semua'},
      {'key': 'pending', 'label': 'Pending'},
      {'key': 'approved', 'label': 'Disetujui'},
      {'key': 'rejected', 'label': 'Ditolak'},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Kelola Klaim'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Chips
          SizedBox(
            height: 52,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                  selectedColor: const Color(0xFF22C55E).withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: active ? const Color(0xFF22C55E) : Colors.grey[400],
                    fontWeight: active ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(color: active ? const Color(0xFF22C55E) : const Color(0xFF334155)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                );
              },
            ),
          ),

          // Claims List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF22C55E)))
                : _filteredClaims.isEmpty
                    ? Center(child: Text('Tidak ada klaim', style: TextStyle(color: Colors.grey[500])))
                    : RefreshIndicator(
                        onRefresh: _loadClaims,
                        color: const Color(0xFF22C55E),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredClaims.length,
                          itemBuilder: (_, i) {
                            final claim = _filteredClaims[i];
                            return _ClaimCard(
                              claim: claim,
                              currencyFormat: currencyFormat,
                              onApprove: claim['status'] == 'pending' ? () => _handleApprove(claim['id']) : null,
                              onReject: claim['status'] == 'pending' ? () => _handleReject(claim['id']) : null,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// ─── Claim Card ────────────────────────────────────────────

class _ClaimCard extends StatelessWidget {
  final Map<String, dynamic> claim;
  final NumberFormat currencyFormat;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _ClaimCard({
    required this.claim,
    required this.currencyFormat,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = claim['status'] == 'pending'
        ? const Color(0xFFF59E0B)
        : claim['status'] == 'approved'
            ? const Color(0xFF22C55E)
            : const Color(0xFFEF4444);
    final statusLabel = claim['status'] == 'pending'
        ? 'Pending'
        : claim['status'] == 'approved'
            ? 'Disetujui'
            : 'Ditolak';
    final photos = claim['photoUrls'] as List;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF334155)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(claim['buyerName'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(claim['productName'], style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(statusLabel, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Issue Type & Description
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(claim['issueType'], style: const TextStyle(color: Color(0xFFF87171), fontSize: 12, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 6),
          Text(claim['description'] ?? '', style: TextStyle(color: Colors.grey[300], fontSize: 13)),

          // Photos thumbnails
          if (photos.isNotEmpty) ...[
            const SizedBox(height: 10),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, idx) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 60,
                    height: 60,
                    color: const Color(0xFF334155),
                    child: const Icon(Icons.image, color: Colors.grey, size: 24),
                    // TODO: Replace with CachedNetworkImage(imageUrl: photos[idx])
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Refund Amount & Date
          Row(
            children: [
              Text(
                'Refund: ${currencyFormat.format(claim['refundAmount'])}',
                style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const Spacer(),
              Text(
                DateFormat('dd MMM yyyy').format(DateTime.parse(claim['createdAt'])),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
            ],
          ),

          // Action buttons (only for pending claims)
          if (onApprove != null || onReject != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (onReject != null)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFEF4444)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Tolak'),
                    ),
                  ),
                if (onApprove != null && onReject != null) const SizedBox(width: 10),
                if (onApprove != null)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Approve'),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
