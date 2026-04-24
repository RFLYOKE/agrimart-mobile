import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UploadExportDocScreen extends StatefulWidget {
  const UploadExportDocScreen({super.key});

  @override
  State<UploadExportDocScreen> createState() => _UploadExportDocScreenState();
}

class _UploadExportDocScreenState extends State<UploadExportDocScreen> {
  String _docType = 'phytosanitary';
  DateTime? _issueDate;
  DateTime? _expiryDate;
  bool _isFileUploaded = false;

  void _uploadFile() {
    // Mock file picker
    setState(() => _isFileUploaded = true);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File PDF berhasil dipilih!')));
  }

  void _submit() {
    if (_isFileUploaded && _issueDate != null && _expiryDate != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Dokumen berhasil diunggah ke S3!'), backgroundColor: Color(0xFF10B981)));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi form dan pilih file'), backgroundColor: Color(0xFFEF4444)));
    }
  }

  Future<DateTime?> _pickDate() async {
    return showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFF3B82F6), surface: Color(0xFF1E293B)),
        ),
        child: child!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Upload Dokumen Ekspor'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tipe Dokumen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: const Color(0xFF1E293B),
                  value: _docType,
                  isExpanded: true,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (v) => setState(() => _docType = v!),
                  items: const [
                    DropdownMenuItem(value: 'phytosanitary', child: Text('Phytosanitary Certificate')),
                    DropdownMenuItem(value: 'health_certificate', child: Text('Health Certificate')),
                    DropdownMenuItem(value: 'certificate_of_origin', child: Text('Certificate of Origin')),
                    DropdownMenuItem(value: 'packing_list', child: Text('Packing List')),
                    DropdownMenuItem(value: 'commercial_invoice', child: Text('Commercial Invoice')),
                    DropdownMenuItem(value: 'bill_of_lading', child: Text('Bill of Lading')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Diterbitkan Oleh (Lembaga)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Misal: Karantina Pertanian',
                hintStyle: TextStyle(color: Colors.grey[600]),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Tgl Terbit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final date = await _pickDate();
                          if (date != null) setState(() => _issueDate = date);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
                          child: Text(_issueDate == null ? '-' : DateFormat('dd MMM yyyy').format(_issueDate!), style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Exp Date', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () async {
                          final date = await _pickDate();
                          if (date != null) setState(() => _expiryDate = date);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
                          child: Text(_expiryDate == null ? '-' : DateFormat('dd MMM yyyy').format(_expiryDate!), style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Upload File Dokumen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            InkWell(
              onTap: _uploadFile,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: _isFileUploaded ? const Color(0xFF10B981).withValues(alpha: 0.1) : const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _isFileUploaded ? const Color(0xFF10B981) : const Color(0xFF334155), style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Icon(_isFileUploaded ? Icons.check_circle : Icons.upload_file, color: _isFileUploaded ? const Color(0xFF10B981) : Colors.grey, size: 48),
                    const SizedBox(height: 12),
                    Text(_isFileUploaded ? 'Dokumen_Sertifikat.pdf siap diunggah' : 'Ketuk untuk pilih file PDF', style: TextStyle(color: _isFileUploaded ? const Color(0xFF10B981) : Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Simpan Dokumen', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
