import 'package:flutter/material.dart';

class ExportDocumentsScreen extends StatefulWidget {
  const ExportDocumentsScreen({super.key});

  @override
  State<ExportDocumentsScreen> createState() => _ExportDocumentsScreenState();
}

class _ExportDocumentsScreenState extends State<ExportDocumentsScreen> {
  final List<Map<String, dynamic>> _docs = [
    {
      'id': 'DOC-Phyto-001',
      'type': 'Phytosanitary Certificate',
      'issuedBy': 'Karantina Pertanian RI',
      'issueDate': '2026-04-01',
      'expiryDate': '2026-04-30',
      'status': 'approved',
      'daysUntilExpiry': 10,
    },
    {
      'id': 'DOC-HC-002',
      'type': 'Health Certificate',
      'issuedBy': 'BPOM RI',
      'issueDate': '2025-10-10',
      'expiryDate': '2026-04-10',
      'status': 'expired',
      'daysUntilExpiry': -10,
    },
    {
      'id': 'DOC-COO-003',
      'type': 'Certificate of Origin',
      'issuedBy': 'Kementerian Perdagangan',
      'issueDate': '2026-04-18',
      'expiryDate': '2026-10-18',
      'status': 'approved',
      'daysUntilExpiry': 180,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Dokumen Ekspor'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/exporter/documents/upload'),
        backgroundColor: const Color(0xFF3B82F6),
        icon: const Icon(Icons.upload_file, color: Colors.white),
        label: const Text('Upload Baru', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _docs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final doc = _docs[index];
          final daysLeft = doc['daysUntilExpiry'] as int;
          
          Color borderColor = const Color(0xFF334155);
          if (daysLeft < 0) borderColor = const Color(0xFFEF4444); // Expired
          else if (daysLeft <= 30) borderColor = const Color(0xFFF59E0B); // Warning
          
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor, width: daysLeft <= 30 ? 2 : 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.description_outlined, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(doc['type'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Issued by: ${doc['issuedBy']}', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Tgl Terbit', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                              Text(doc['issueDate'], style: const TextStyle(color: Colors.white, fontSize: 12)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Expired', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                              Text(
                                doc['expiryDate'],
                                style: TextStyle(color: daysLeft < 0 ? const Color(0xFFEF4444) : daysLeft <= 30 ? const Color(0xFFF59E0B) : Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
