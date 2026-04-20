import 'package:flutter/material.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() => _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final _amountCtrl = TextEditingController(text: '1');
  String _from = 'USD';
  String _to = 'IDR';

  // Mock rates against IDR
  final Map<String, double> _rates = {
    'IDR': 1.0,
    'USD': 15850.0,
    'EUR': 17200.0,
    'JPY': 105.4,
    'SGD': 11800.0,
    'AUD': 10400.0,
  };

  double get _result {
    final amount = double.tryParse(_amountCtrl.text) ?? 0;
    // convert to IDR first
    final inIdr = amount * _rates[_from]!;
    // convert to target
    return inIdr / _rates[_to]!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Kalkulator Kurs'),
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF334155)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _amountCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                          onChanged: (_) => setState((){}),
                          decoration: const InputDecoration(border: InputBorder.none),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: _buildDropDown(_from, (v) => setState(() => _from = v!)),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF334155), height: 32),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          _result.toStringAsFixed(2).replaceAll(RegExp(r'([.]*0)(?!.*\d)'), ''),
                          style: const TextStyle(color: Color(0xFF10B981), fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: _buildDropDown(_to, (v) => setState(() => _to = v!)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '1 $_from = ${(_rates[_from]! / _rates[_to]!).toStringAsFixed(4)} $_to',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Rate Referensi Bank Indonesia Hari Ini', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._rates.entries.where((e) => e.key != 'IDR').map((e) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(8)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('1 ${e.key}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Text('= Rp ${e.value.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF10B981))),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildDropDown(String val, void Function(String?) onChanged) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        dropdownColor: const Color(0xFF1E293B),
        value: val,
        isExpanded: true,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        onChanged: onChanged,
        items: _rates.keys.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
      ),
    );
  }
}
