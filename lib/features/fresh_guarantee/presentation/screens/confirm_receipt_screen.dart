import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/upload_service.dart';

class ConfirmReceiptScreen extends ConsumerStatefulWidget {
  final String orderId;
  final String productName;
  final num totalAmount;

  const ConfirmReceiptScreen({
    super.key,
    required this.orderId,
    required this.productName,
    required this.totalAmount,
  });

  @override
  ConsumerState<ConfirmReceiptScreen> createState() => _ConfirmReceiptScreenState();
}

class _ConfirmReceiptScreenState extends ConsumerState<ConfirmReceiptScreen> {
  String? _condition; // 'fresh' | 'not_fresh'
  final List<File> _proofPhotos = [];
  bool _isLoading = false;
  // Removed _uploadProgress unused field

  final _picker = ImagePicker();

  Future<void> _pickProofPhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() => _proofPhotos.add(File(picked.path)));
    }
  }

  Future<void> _confirmReceipt() async {
    if (_condition == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih kondisi produk terlebih dahulu')));
      return;
    }

    if (_condition == 'not_fresh' && _proofPhotos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tambahkan foto bukti produk tidak segar')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<String> photoUrls = [];

      // Upload foto bukti jika kondisi tidak segar
      if (_proofPhotos.isNotEmpty) {
        UploadService.showUploadProgress(context, 0);
        for (int i = 0; i < _proofPhotos.length; i++) {
          final url = await UploadService().uploadImage(_proofPhotos[i], 'fresh-guarantee');
          photoUrls.add(url);
          if (mounted) {
            final progress = (i + 1) / _proofPhotos.length;
            UploadService.showUploadProgress(context, progress);
          }
        }
        if (mounted) UploadService.hideUploadProgress(context);
      }

      // TODO: Panggil API confirm receipt
      // await ref.read(freshGuaranteeRepositoryProvider).confirmReceipt(
      //   orderId: widget.orderId, condition: _condition!, photoUrls: photoUrls
      // );

      await Future.delayed(const Duration(seconds: 1)); // Mock

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_condition == 'fresh'
                ? '✓ Terima kasih! Pesanan dikonfirmasi segar.'
                : 'Laporan diterima. Anda bisa mengajukan klaim.'),
            backgroundColor: _condition == 'fresh' ? AppColors.successGreen : AppColors.warningOrange,
          ),
        );
        Navigator.pop(context, {'condition': _condition, 'canClaim': _condition == 'not_fresh'});
      }
    } catch (e) {
      if (mounted) {
        UploadService.hideUploadProgress(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Konfirmasi Penerimaan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Info Card
            Card(
              elevation: 0,
              color: AppColors.backgroundLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Detail Pesanan', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 8),
                    Text(widget.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text('Order #${widget.orderId}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              'Bagaimana kondisi produk yang diterima?',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
            ),
            const SizedBox(height: 16),
            const Text('Pilihan ini akan membantu kami meningkatkan kualitas produk.', style: TextStyle(color: Colors.grey, height: 1.4)),
            const SizedBox(height: 24),

            // ─── Condition Buttons ───────────────────────────────
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _condition = 'fresh'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 110,
                      decoration: BoxDecoration(
                        color: _condition == 'fresh' ? AppColors.successGreen : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _condition == 'fresh' ? AppColors.successGreen : Colors.grey[300]!,
                          width: _condition == 'fresh' ? 2 : 1,
                        ),
                        boxShadow: _condition == 'fresh'
                            ? [BoxShadow(color: AppColors.successGreen.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle, size: 36, color: _condition == 'fresh' ? Colors.white : Colors.green),
                          const SizedBox(height: 8),
                          Text('SEGAR ✓', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _condition == 'fresh' ? Colors.white : Colors.green)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _condition = 'not_fresh'),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 110,
                      decoration: BoxDecoration(
                        color: _condition == 'not_fresh' ? AppColors.errorRed : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _condition == 'not_fresh' ? AppColors.errorRed : Colors.grey[300]!,
                          width: _condition == 'not_fresh' ? 2 : 1,
                        ),
                        boxShadow: _condition == 'not_fresh'
                            ? [BoxShadow(color: AppColors.errorRed.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))]
                            : [],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cancel, size: 36, color: _condition == 'not_fresh' ? Colors.white : AppColors.errorRed),
                          const SizedBox(height: 8),
                          Text('TIDAK SEGAR ✗', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: _condition == 'not_fresh' ? Colors.white : AppColors.errorRed)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // ─── Proof photos (only if not fresh) ────────────────
            if (_condition == 'not_fresh') ...[
              const SizedBox(height: 32),
              const Text('Foto Bukti (wajib)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 4),
              const Text('Ambil foto produk yang tidak segar sebagai bukti.', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._proofPhotos.map((file) => Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(file, width: 80, height: 80, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 2, right: 2,
                        child: GestureDetector(
                          onTap: () => setState(() => _proofPhotos.remove(file)),
                          child: Container(
                            decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      )
                    ],
                  )),
                  GestureDetector(
                    onTap: _pickProofPhoto,
                    child: Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: const Icon(Icons.add_a_photo, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, -2))]),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              onPressed: _isLoading ? null : _confirmReceipt,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Konfirmasi Penerimaan', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ),
    );
  }
}
