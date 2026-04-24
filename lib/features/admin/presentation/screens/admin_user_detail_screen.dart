import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/providers/admin_provider.dart';

/// Admin User Detail — Profil lengkap user + aksi admin
class AdminUserDetailScreen extends ConsumerStatefulWidget {
  final String userId;
  const AdminUserDetailScreen({super.key, required this.userId});

  @override
  ConsumerState<AdminUserDetailScreen> createState() => _AdminUserDetailScreenState();
}

class _AdminUserDetailScreenState extends ConsumerState<AdminUserDetailScreen> {
  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  void _showStatusDialog(String action, String userName) {
    final reasonController = TextEditingController();
    final color = action == 'active'
        ? const Color(0xFF22C55E)
        : action == 'suspended'
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);
    final label = action == 'active' ? 'Aktifkan' : action == 'suspended' ? 'Suspend' : 'Ban';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Konfirmasi $label Akun',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Apakah Anda yakin ingin ${label.toLowerCase()} akun "$userName"?',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Alasan (wajib)...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
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
                await ref.read(adminActionsProvider).updateUserStatus(
                      widget.userId,
                      action,
                      reasonController.text.trim(),
                    );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Akun berhasil di-${label.toLowerCase()}'),
                      backgroundColor: color,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(label, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(adminUserDetailProvider(widget.userId));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Detail Pengguna'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF22C55E))),
        error: (error, stack) => Center(child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
        data: (user) {
          final coop = user['cooperative'] as Map<String, dynamic>?;
          final orders = user['recentOrders'] as List<dynamic>? ?? [];
          final currentStatus = user['status'] as String;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Profile Card ──────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: const Color(0xFF22C55E).withValues(alpha: 0.2),
                        child: Text(
                          user['name'].toString().substring(0, user['name'].toString().length >= 2 ? 2 : 1).toUpperCase(),
                          style: const TextStyle(color: Color(0xFF22C55E), fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(user['name'], style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(user['email'] ?? '', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                      if (user['phone'] != null) ...[
                        const SizedBox(height: 2),
                        Text(user['phone'], style: TextStyle(color: Colors.grey[400], fontSize: 14)),
                      ],
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildBadge(user['role'], const Color(0xFF3B82F6)),
                          const SizedBox(width: 8),
                          _buildBadge(
                            currentStatus == 'active' ? 'Aktif' : currentStatus == 'suspended' ? 'Suspended' : 'Banned',
                            currentStatus == 'active' ? const Color(0xFF22C55E) : currentStatus == 'suspended' ? const Color(0xFFF59E0B) : const Color(0xFFEF4444),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ─── Cooperative Info (jika koperasi) ──────────────────────
                if (coop != null) ...[
                  const Text('Info Koperasi', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      children: [
                        if (coop['freshRate'] != null) _buildInfoRow('Fresh Rate', '${coop['freshRate']}%'),
                        if (coop['totalSales'] != null) _buildInfoRow('Total Penjualan', currencyFormat.format(coop['totalSales'])),
                        if (coop['activeProducts'] != null) _buildInfoRow('Produk Aktif', '${coop['activeProducts']}'),
                        _buildInfoRow('Sektor', '${coop['sector']}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ─── Recent Orders ──────────────────────
                if (orders.isNotEmpty) ...[
                  const Text('10 Order Terakhir', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  ...orders.map((order) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(order['id'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                                  Text(DateFormat('dd MMM yyyy').format(DateTime.parse(order['created_at'])), style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                ],
                              ),
                            ),
                            Text(currencyFormat.format(order['total']), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 8),
                            _buildBadge(
                              order['status'],
                              order['status'] == 'delivered' ? const Color(0xFF22C55E) : const Color(0xFF3B82F6),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 24),
                ],

                // ─── Action Buttons ──────────────────────
                const Text('Aksi Admin', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),

                if (currentStatus != 'active')
                  _buildActionButton('Aktifkan Akun', const Color(0xFF22C55E), Icons.check_circle_outline, () => _showStatusDialog('active', user['name'])),
                if (currentStatus != 'suspended')
                  _buildActionButton('Suspend Akun', const Color(0xFFF59E0B), Icons.pause_circle_outline, () => _showStatusDialog('suspended', user['name'])),
                if (currentStatus != 'banned')
                  _buildActionButton('Ban Akun', const Color(0xFFEF4444), Icons.block, () => _showStatusDialog('banned', user['name'])),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon, color: color),
          label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            side: BorderSide(color: color.withValues(alpha: 0.5)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ),
    );
  }
}
