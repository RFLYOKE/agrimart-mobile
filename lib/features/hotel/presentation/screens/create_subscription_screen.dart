import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Screen untuk membuat kontrak langganan baru (4 step wizard)
class CreateSubscriptionScreen extends StatefulWidget {
  const CreateSubscriptionScreen({super.key});

  @override
  State<CreateSubscriptionScreen> createState() => _CreateSubscriptionScreenState();
}

class _CreateSubscriptionScreenState extends State<CreateSubscriptionScreen> {
  int _currentStep = 0;

  // Form State
  Map<String, dynamic>? _selectedProduct;
  String _frequency = 'weekly';
  int _deliveryDay = 1; // Senin
  int _qty = 10;
  DateTime _startDate = DateTime.now().add(const Duration(days: 3));
  DateTime _endDate = DateTime.now().add(const Duration(days: 93)); // 3 bulan

  final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  double get _estimatedMonthlyCost {
    if (_selectedProduct == null) return 0;
    int deliveriesPerMonth = 1;
    if (_frequency == 'daily') deliveriesPerMonth = 30;
    if (_frequency == 'weekly') deliveriesPerMonth = 4;
    if (_frequency == 'biweekly') deliveriesPerMonth = 2;
    return (_selectedProduct!['priceB2B'] * _qty * deliveriesPerMonth).toDouble();
  }

  void _submit() {
    // TODO: POST /hotel/subscriptions
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Icon(Icons.check_circle, color: Color(0xFF8B5CF6), size: 64),
        content: const Text(
          'Kontrak Langganan Berhasil Dibuat!\n\nOrder otomatis akan di-generate sesuai jadwal pengiriman Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Selesai', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
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
        title: const Text('Buat Kontrak Langganan'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF8B5CF6),
            background: Color(0xFF0F172A),
            surface: Color(0xFF1E293B),
          ),
        ),
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep == 0 && _selectedProduct == null) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih produk terlebih dahulu'), backgroundColor: Colors.red));
              return;
            }
            if (_currentStep < 3) {
              setState(() => _currentStep++);
            } else {
              _submit();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) setState(() => _currentStep--);
          },
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: details.onStepContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(_currentStep == 3 ? 'Buat Kontrak' : 'Lanjut', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: const BorderSide(color: Color(0xFF334155)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Text('Kembali', style: TextStyle(color: Colors.white)),
                      ),
                    ),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text('Pilih Produk', style: TextStyle(color: Colors.white)),
              isActive: _currentStep >= 0,
              content: Column(
                children: [
                  // Dummy product selection
                  InkWell(
                    onTap: () {
                      setState(() {
                        _selectedProduct = {'id': 'p1', 'name': 'Beras Premium 5kg', 'coop': 'Koperasi Tani Makmur', 'priceB2B': 60000};
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _selectedProduct != null ? const Color(0xFF8B5CF6).withOpacity(0.1) : const Color(0xFF1E293B),
                        border: Border.all(color: _selectedProduct != null ? const Color(0xFF8B5CF6) : const Color(0xFF334155)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.image, color: Colors.grey)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Beras Premium 5kg', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                Text('Koperasi Tani Makmur • Rp 60.000/bks', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                              ],
                            ),
                          ),
                          if (_selectedProduct != null) const Icon(Icons.check_circle, color: Color(0xFF8B5CF6)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Frekuensi & Kuantitas', style: TextStyle(color: Colors.white)),
              isActive: _currentStep >= 1,
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Frekuensi Pengiriman', style: TextStyle(color: Colors.white, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: const Color(0xFF1E293B),
                        value: _frequency,
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white),
                        onChanged: (v) => setState(() => _frequency = v!),
                        items: const [
                          DropdownMenuItem(value: 'daily', child: Text('Harian')),
                          DropdownMenuItem(value: 'weekly', child: Text('Mingguan')),
                          DropdownMenuItem(value: 'biweekly', child: Text('Dua Mingguan')),
                          DropdownMenuItem(value: 'monthly', child: Text('Bulanan')),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Kuantitas (per pengiriman)', style: TextStyle(color: Colors.white, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(border: Border.all(color: const Color(0xFF334155)), borderRadius: BorderRadius.circular(8)),
                        child: Row(
                          children: [
                            IconButton(icon: const Icon(Icons.remove, color: Colors.white), onPressed: () { if (_qty > 1) setState(() => _qty--); }),
                            Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('$_qty', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                            IconButton(icon: const Icon(Icons.add, color: Colors.white), onPressed: () => setState(() => _qty++)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Step(
              title: const Text('Periode Kontrak', style: TextStyle(color: Colors.white)),
              isActive: _currentStep >= 2,
              content: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Mulai', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8)),
                              child: Text(DateFormat('dd MMM yyyy').format(_startDate), style: const TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Berakhir', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8)),
                              child: Text(DateFormat('dd MMM yyyy').format(_endDate), style: const TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Dummy "Ubah Periode" button for UI purposes
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.date_range, color: Color(0xFF8B5CF6), size: 18),
                    label: const Text('Ubah Rentang Tanggal', style: TextStyle(color: Color(0xFF8B5CF6))),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFF8B5CF6))),
                  )
                ],
              ),
            ),
            Step(
              title: const Text('Review', style: TextStyle(color: Colors.white)),
              isActive: _currentStep >= 3,
              content: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.5))),
                child: Column(
                  children: [
                    _reviewRow('Produk', _selectedProduct?['name'] ?? ''),
                    _reviewRow('Harga Terkunci', _selectedProduct != null ? currencyFormat.format(_selectedProduct!['priceB2B']) : '-'),
                    _reviewRow('Pengiriman', '$_qty unit (${_frequency})'),
                    _reviewRow('Periode', '${DateFormat('dd MMM yyyy').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}'),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(color: Color(0xFF334155))),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Estimasi Biaya / Bulan', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                        Text(currencyFormat.format(_estimatedMonthlyCost), style: const TextStyle(color: Color(0xFF22C55E), fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
