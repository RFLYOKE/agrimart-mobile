import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/upload_service.dart';

class ClaimFormScreen extends ConsumerStatefulWidget {
  final String orderId;

  const ClaimFormScreen({super.key, required this.orderId});

  @override
  ConsumerState<ClaimFormScreen> createState() => _ClaimFormScreenState();
}

class _ClaimFormScreenState extends ConsumerState<ClaimFormScreen> {
  String? _issueType;
  String _refundType = 'full';
  final _descController = TextEditingController();
  final List<File> _photos = [];
  bool _isUploading = false;
  bool _isSubmitting = false;
  double _uploadProgress = 0;
  final _picker = ImagePicker();

  static const int maxPhotos = 5;

  final _issueTypes = [
    ('not_fresh', 'Tidak Segar', Icons.eco_outlined),
    ('wrong_item', 'Produk Salah', Icons.swap_horiz),
    ('damaged', 'Rusak', Icons.broken_image_outlined),
    ('incomplete', 'Tidak Lengkap', Icons.remove_shopping_cart_outlined),
  ];

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    if (_photos.length >= maxPhotos) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Maksimal $maxPhotos foto')));
      return;
    }
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _photos.add(File(picked.path)));
  }

  Future<void> _submitClaim() async {
    if (_issueType == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih jenis masalah')));
      return;
    }
    if (_descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jelaskan masalah Anda')));
      return;
    }
    if (_photos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tambahkan minimal 1 foto bukti')));
      return;
    }

    setState(() { _isUploading = true; _uploadProgress = 0; });

    try {
      // Upload photos with progress tracking
      final List<String> photoUrls = [];
      for (int i = 0; i < _photos.length; i++) {
        final url = await UploadService().uploadImage(_photos[i], 'claims/${widget.orderId}');
        photoUrls.add(url);
        if (mounted) setState(() => _uploadProgress = (i + 1) / _photos.length);
      }

      setState(() { _isUploading = false; _isSubmitting = true; });

      // TODO: Panggil API create claim
      // await claimRepo.createClaim(orderId: widget.orderId, issueType: _issueType!, ...)
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Klaim berhasil diajukan!'), backgroundColor: AppColors.successGreen));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() { _isUploading = false; _isSubmitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajukan Klaim')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ─── Issue Type ────────────────────────────────────
            const Text('Jenis Masalah *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _issueTypes.map((item) {
                final (type, label, icon) = item;
                final isSelected = _issueType == type;
                return FilterChip(
                  avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.primaryGreen),
                  label: Text(label),
                  selected: isSelected,
                  selectedColor: AppColors.primaryGreen,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.w500),
                  onSelected: (_) => setState(() => _issueType = type),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ─── Description ───────────────────────────────────
            const Text('Deskripsi Masalah *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _descController,
              maxLines: 4,
              maxLength: 500,
              decoration: const InputDecoration(
                hintText: 'Jelaskan secara detail kondisi produk yang Anda terima...',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            // ─── Refund Type ───────────────────────────────────
            const Text('Tipe Refund', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('Refund Penuh (100%)'),
                    subtitle: const Text('Seluruh nilai pesanan dikembalikan'),
                    value: 'full',
                    groupValue: _refundType,
                    activeColor: AppColors.primaryGreen,
                    onChanged: (val) => setState(() => _refundType = val!),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    title: const Text('Refund Sebagian (50%)'),
                    subtitle: const Text('Setengah nilai pesanan dikembalikan'),
                    value: 'partial',
                    groupValue: _refundType,
                    activeColor: AppColors.primaryGreen,
                    onChanged: (val) => setState(() => _refundType = val!),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ─── Photos ─────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Foto Bukti *', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('${_photos.length}/$maxPhotos', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),

            // Upload progress bar
            if (_isUploading) ...[
              LinearPercentIndicator(
                lineHeight: 10.0,
                percent: _uploadProgress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey[200]!,
                progressColor: AppColors.primaryGreen,
                barRadius: const Radius.circular(5),
                animation: true,
                animateFromLastPercent: true,
              ),
              const SizedBox(height: 4),
              Text('Mengupload ${(_uploadProgress * 100).toStringAsFixed(0)}%...', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              const SizedBox(height: 8),
            ],

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _photos.length + (_photos.length < maxPhotos ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _photos.length) {
                  return GestureDetector(
                    onTap: _addPhoto,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, color: Colors.grey[600], size: 32),
                          const SizedBox(height: 4),
                          Text('Tambah', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                  );
                }
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(_photos[index], fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4, right: 4,
                      child: GestureDetector(
                        onTap: () => setState(() => _photos.removeAt(index)),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 14),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))]),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity, height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
              onPressed: (_isUploading || _isSubmitting) ? null : _submitClaim,
              child: (_isUploading || _isSubmitting)
                  ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
                      SizedBox(width: 12),
                      Text('Memproses...', style: TextStyle(color: Colors.white)),
                    ])
                  : const Text('Ajukan Klaim', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}
