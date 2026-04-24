import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../domain/providers/admin_provider.dart';

/// Admin Claims Screen — List semua klaim Fresh Guarantee
class AdminClaimsScreen extends ConsumerStatefulWidget {
  const AdminClaimsScreen({super.key});

  @override
  ConsumerState<AdminClaimsScreen> createState() => _AdminClaimsScreenState();
}

class _AdminClaimsScreenState extends ConsumerState<AdminClaimsScreen> {
  String _selectedFilter = 'all';

  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  void _handleApprove(String claimId) async {
    try {
      await ref.read(adminActionsProvider).approveClaim(claimId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Klaim disetujui'), backgroundColor: Color(0xFF22C55E)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _handleReject(String claimId) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Tolak Klaim', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Alasan penolakan...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            filled: true,
            fillColor: const Color(0xFF0F172A),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal', style: TextStyle(color: Colors.grey[400])),
          ),
          ElevatedButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              
              try {
                await ref.read(adminActionsProvider).rejectClaim(claimId, reasonController.text.trim());
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('❌ Klaim ditolak'), backgroundColor: Color(0xFFEF4444)),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
            child: const Text('Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
                  selectedColor: const Color(0xFF22C55E).withValues(alpha: 0.2),
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
            child: ref.watch(adminClaimsProvider({'status': _selectedFilter})).when(
              loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF22C55E))),
              error: (err, stack) => Center(child: Text('Error: $err', style: const TextStyle(color: Colors.red))),
              data: (data) {
                final claimsList = (data['claims'] as List).cast<Map<String, dynamic>>();

                if (claimsList.isEmpty) {
                  return Center(child: Text('Tidak ada klaim', style: TextStyle(color: Colors.grey[500])));
                }

                return RefreshIndicator(
                  onRefresh: () => ref.refresh(adminClaimsProvider({'status': _selectedFilter}).future),
                  color: const Color(0xFF22C55E),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: claimsList.length,
                    itemBuilder: (_, i) {
                      final claim = claimsList[i];
                      return _ClaimCard(
                        claim: claim,
                        currencyFormat: currencyFormat,
                        onApprove: claim['status'] == 'pending' ? () => _handleApprove(claim['id']) : null,
                        onReject: claim['status'] == 'pending' ? () => _handleReject(claim['id']) : null,
                      );
                    },
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
                    Text(claim['buyer']?['name'] ?? 'Pembeli', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                    const SizedBox(height: 2),
                    Text(claim['order']?['items']?[0]?['productName'] ?? 'Produk', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
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
              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
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
                    child: CachedNetworkImage(
                      imageUrl: photos[idx],
                      fit: BoxFit.cover,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
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
