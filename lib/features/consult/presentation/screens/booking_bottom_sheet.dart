import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/consultant_model.dart';
import '../../data/models/session_model.dart';
import 'chat_screen.dart';

class BookingBottomSheet extends StatefulWidget {
  final ConsultantModel consultant;

  const BookingBottomSheet({super.key, required this.consultant});

  @override
  State<BookingBottomSheet> createState() => _BookingBottomSheetState();
}

class _BookingBottomSheetState extends State<BookingBottomSheet> {
  String? _selectedSlot;
  final _problemController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _problemController.dispose();
    super.dispose();
  }

  void _confirmAndPay() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih jadwal terlebih dahulu')));
      return;
    }
    if (_problemController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Jelaskan masalah Anda')));
      return;
    }

    setState(() => _isLoading = true);

    // Mock API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock create session
    final session = SessionModel(
      id: const Uuid().v4(),
      consultant: widget.consultant,
      status: 'active',
      durationMin: 30,
      startedAt: DateTime.now(),
      messages: [],
    );

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context); // close bottom sheet
      
      // Push to chat screen
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ChatScreen(session: session),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Konfirmasi Booking', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Pilih Slot:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.consultant.availableSlots.map((slot) {
              final isSelected = _selectedSlot == slot;
              return ChoiceChip(
                label: Text(slot),
                selected: isSelected,
                selectedColor: AppColors.primaryGreen,
                labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                onSelected: (val) {
                  if (val) setState(() => _selectedSlot = slot);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text('Jelaskan Masalah Anda:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _problemController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Misal: Sapi perah saya akhir-akhir ini makannya berkurang...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            color: AppColors.backgroundLight,
            elevation: 0,
            shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [Text('Durasi Sesi'), Text('30 Menit', style: TextStyle(fontWeight: FontWeight.bold))],
                  ),
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Pembayaran'),
                      Text(CurrencyFormatter.formatRupiah(widget.consultant.price), 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              onPressed: _isLoading ? null : _confirmAndPay,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Bayar & Mulai Konsultasi', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
