import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';

class SetAlertBottomSheet extends StatefulWidget {
  final String commodity;

  const SetAlertBottomSheet({super.key, required this.commodity});

  @override
  State<SetAlertBottomSheet> createState() => _SetAlertBottomSheetState();
}

class _SetAlertBottomSheetState extends State<SetAlertBottomSheet> {
  final _priceController = TextEditingController();
  num _targetPrice = 0;
  bool _isLoading = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  // Called when text changes
  void _onPriceChanged(String value) {
    final val = num.tryParse(value.replaceAll(RegExp(r'[^0-9]'), ''));
    setState(() {
      _targetPrice = val ?? 0;
    });
  }

  void _saveAlert() async {
    if (_targetPrice <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Masukkan target harga yang valid')));
      return;
    }

    setState(() => _isLoading = true);

    // Mock API call to save alert
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context); // close sheet
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Alert untuk ${widget.commodity} berhasil dipasang!')));
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
              Text('Set Alert: ${widget.commodity}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Masukkan Target Harga (Rp)', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _priceController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: _onPriceChanged,
            decoration: const InputDecoration(
              hintText: 'Misal: 45000',
              border: OutlineInputBorder(),
              prefixText: 'Rp ',
            ),
          ),
          const SizedBox(height: 24),
          if (_targetPrice > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Kamu akan diberitahu (melalui Push Notification) saat harga turun menyentuh atau di bawah ${CurrencyFormatter.formatRupiah(_targetPrice)}.',
                      style: const TextStyle(color: Colors.blueGrey),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
              onPressed: _isLoading ? null : _saveAlert,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Aktifkan Alert', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
