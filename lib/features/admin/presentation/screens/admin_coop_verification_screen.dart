import 'package:flutter/material.dart';

/// Admin Cooperative Verification Screen
/// List koperasi pending verifikasi — Approve/Reject dengan animasi
class AdminCoopVerificationScreen extends StatefulWidget {
  const AdminCoopVerificationScreen({super.key});

  @override
  State<AdminCoopVerificationScreen> createState() => _AdminCoopVerificationScreenState();
}

class _AdminCoopVerificationScreenState extends State<AdminCoopVerificationScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _coops = [];

  @override
  void initState() {
    super.initState();
    _loadPendingCoops();
  }

  Future<void> _loadPendingCoops() async {
    setState(() => _isLoading = true);

    // TODO: Replace with GET /admin/cooperatives/pending
    await Future.delayed(const Duration(milliseconds: 800));

    setState(() {
      _coops = [
        {
          'id': 'coop_1',
          'name': 'Koperasi Sumber Rejeki',
          'sector': 'Perikanan',
          'location': 'Banyuwangi, Jawa Timur',
          'description': 'Koperasi nelayan dengan 120 anggota aktif.',
          'userName': 'Ahmad Fauzi',
          'userEmail': 'fauzi@email.com',
          'userPhone': '+6282345678901',
          'joinDate': '2026-04-10',
          'documents': [
            {'type': 'Sertifikat BPOM', 'url': 'https://example.com/doc1.pdf'},
            {'type': 'Akta Pendirian', 'url': 'https://example.com/doc2.pdf'},
          ],
        },
        {
          'id': 'coop_2',
          'name': 'Koperasi Agro Mandiri',
          'sector': 'Pertanian',
          'location': 'Malang, Jawa Timur',
          'description': 'Koperasi pertanian organik.',
          'userName': 'Siti Rahayu',
          'userEmail': 'siti@email.com',
          'userPhone': '+6283456789012',
          'joinDate': '2026-04-12',
          'documents': [
            {'type': 'Sertifikat Organik', 'url': 'https://example.com/doc3.pdf'},
          ],
        },
      ];
      _isLoading = false;
    });
  }

  void _handleApprove(int index) {
    final coop = _coops[index];
    // TODO: Call PUT /admin/cooperatives/verify { coop_id, action: 'approve' }
    setState(() => _coops.removeAt(index));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ ${coop['name']} berhasil diverifikasi!'),
        backgroundColor: const Color(0xFF22C55E),
      ),
    );
  }

  void _handleReject(int index) {
    final coop = _coops[index];
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tolak Verifikasi', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alasan penolakan untuk "${coop['name']}":',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLines: 3,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Tuliskan alasan penolakan (min. 10 karakter)...',
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
            onPressed: () {
              if (reasonController.text.length < 10) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Alasan minimal 10 karakter'), backgroundColor: Colors.orange),
                );
                return;
              }
              Navigator.pop(ctx);
              // TODO: Call PUT /admin/cooperatives/verify { coop_id, action: 'reject', reason }
              setState(() => _coops.removeAt(index));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('❌ ${coop['name']} ditolak.'),
                  backgroundColor: const Color(0xFFEF4444),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Verifikasi Koperasi'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF22C55E)))
          : _coops.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: Colors.grey[600]),
                      const SizedBox(height: 16),
                      Text('Tidak ada koperasi pending', style: TextStyle(color: Colors.grey[400], fontSize: 16)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadPendingCoops,
                  color: const Color(0xFF22C55E),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _coops.length,
                    itemBuilder: (context, index) {
                      final coop = _coops[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.business, color: Color(0xFFF59E0B), size: 24),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(coop['name'], style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                      Text('${coop['sector']} • ${coop['location']}', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (coop['description'] != null) ...[
                              const SizedBox(height: 10),
                              Text(coop['description'], style: TextStyle(color: Colors.grey[300], fontSize: 13)),
                            ],

                            const SizedBox(height: 12),
                            // User Info
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: [
                                  _infoRow(Icons.person_outline, coop['userName']),
                                  _infoRow(Icons.email_outlined, coop['userEmail']),
                                  _infoRow(Icons.phone_outlined, coop['userPhone']),
                                  _infoRow(Icons.calendar_today, 'Bergabung: ${coop['joinDate']}'),
                                ],
                              ),
                            ),

                            // Documents
                            if ((coop['documents'] as List).isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text('Dokumen:', style: TextStyle(color: Colors.grey[400], fontSize: 12, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              ...(coop['documents'] as List).map((doc) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.insert_drive_file_outlined, color: Color(0xFF60A5FA), size: 16),
                                        const SizedBox(width: 6),
                                        Text(doc['type'], style: const TextStyle(color: Color(0xFF60A5FA), fontSize: 13)),
                                      ],
                                    ),
                                  )),
                            ],

                            const SizedBox(height: 16),

                            // Action Buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _handleReject(index),
                                    icon: const Icon(Icons.close, size: 18),
                                    label: const Text('Tolak'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFEF4444),
                                      side: const BorderSide(color: Color(0xFFEF4444)),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _handleApprove(index),
                                    icon: const Icon(Icons.check, size: 18),
                                    label: const Text('Approve'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF22C55E),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[500], size: 16),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: Colors.grey[300], fontSize: 13)),
        ],
      ),
    );
  }
}
