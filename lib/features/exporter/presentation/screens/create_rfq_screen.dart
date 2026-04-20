import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateRfqScreen extends StatefulWidget {
  const CreateRfqScreen({super.key});

  @override
  State<CreateRfqScreen> createState() => _CreateRfqScreenState();
}

class _CreateRfqScreenState extends State<CreateRfqScreen> {
  final _formKey = GlobalKey<FormState>();
  
  String? _category = 'perikanan';
  String _unit = 'ton';
  String _currency = 'USD';
  DateTime? _deadline;

  final _titleController = TextEditingController();
  final _commodityController = TextEditingController();
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _portController = TextEditingController();
  final _descController = TextEditingController();

  final List<String> _selectedCerts = [];
  final List<String> _certOptions = ['HACCP', 'GlobalGAP', 'Halal', 'Organik', 'SNI', 'ISO 22000'];

  // Mock currency conversion to IDR
  double get _convertedToIdr {
    final val = double.tryParse(_priceController.text) ?? 0;
    if (_currency == 'IDR') return val;
    if (_currency == 'USD') return val * 15850;
    if (_currency == 'EUR') return val * 17200;
    if (_currency == 'JPY') return val * 105;
    return val * 15000;
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 14)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFF3B82F6), surface: Color(0xFF1E293B)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _deadline != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('RFQ Berhasil Dipublikasikan!'), backgroundColor: Color(0xFF10B981)));
      Navigator.pop(context);
    } else if (_deadline == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pilih batas waktu penawaran'), backgroundColor: Color(0xFFEF4444)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text('Buat RFQ Baru'),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLabel('Judul RFQ'),
              _buildTextField(_titleController, 'Misal: Kebutuhan Kopi Arabika 10 Ton'),

              _buildLabel('Kategori'),
              _buildDropdown(['pertanian', 'perikanan', 'peternakan'], _category, (v) => setState(() => _category = v)),
              
              _buildLabel('Komoditas Spesifik'),
              _buildTextField(_commodityController, 'Misal: Biji Kopi Arabika Gayo Grade 1'),

              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Kuantitas'),
                        _buildTextField(_qtyController, '0', isNumber: true),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Satuan'),
                        _buildDropdown(['kg', 'ton', 'ekor', 'karton', 'liter'], _unit, (v) => setState(() => _unit = v!)),
                      ],
                    ),
                  ),
                ],
              ),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Target Harga per $_unit'),
                        _buildTextField(_priceController, '0', isNumber: true, onChanged: (_) => setState((){})),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Mata Uang'),
                        _buildDropdown(['IDR', 'USD', 'EUR', 'JPY', 'SGD', 'AUD'], _currency, (v) => setState(() => _currency = v!)),
                      ],
                    ),
                  ),
                ],
              ),
              if (_currency != 'IDR')
                Padding(
                  padding: const EdgeInsets.only(bottom: 16, top: 4),
                  child: Text(
                    'Setara dengan ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(_convertedToIdr)}',
                    style: const TextStyle(color: Color(0xFF10B981), fontSize: 13, fontStyle: FontStyle.italic),
                  ),
                ),

              _buildLabel('Batas Waktu Penawaran'),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  margin: const EdgeInsets.bottom(16),
                  decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_month, color: _deadline == null ? Colors.grey : const Color(0xFF3B82F6)),
                      const SizedBox(width: 12),
                      Text(
                        _deadline == null ? 'Pilih Tanggal' : DateFormat('dd MMM yyyy').format(_deadline!),
                        style: TextStyle(color: _deadline == null ? Colors.grey : Colors.white, fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ),

              _buildLabel('Pelabuhan Tujuan (Port of Delivery)'),
              _buildTextField(_portController, 'Misal: Tanjung Priok, Jakarta'),

              _buildLabel('Sertifikasi yang Dibutuhkan'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _certOptions.map((c) {
                  final active = _selectedCerts.contains(c);
                  return FilterChip(
                    label: Text(c),
                    selected: active,
                    onSelected: (val) => setState(() {
                      val ? _selectedCerts.add(c) : _selectedCerts.remove(c);
                    }),
                    backgroundColor: const Color(0xFF1E293B),
                    selectedColor: const Color(0xFF3B82F6).withOpacity(0.2),
                    side: BorderSide(color: active ? const Color(0xFF3B82F6) : const Color(0xFF334155)),
                    labelStyle: TextStyle(color: active ? const Color(0xFF3B82F6) : Colors.grey[400]),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              _buildLabel('Deskripsi Tambahan'),
              TextFormField(
                controller: _descController,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Spesifikasi detail, persyaratan kemasan, metode pembayaran...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
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
                  child: const Text('Publish RFQ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text, style: TextStyle(color: Colors.grey[300], fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool isNumber = false, Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        onChanged: onChanged,
        validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[600]),
          filled: true,
          fillColor: const Color(0xFF1E293B),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF334155))),
        ),
      ),
    );
  }

  Widget _buildDropdown(List<String> items, String? value, void Function(String?) onChanged) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: const Color(0xFF1E293B),
          value: value,
          isExpanded: true,
          style: const TextStyle(color: Colors.white),
          onChanged: onChanged,
          items: items.map((i) => DropdownMenuItem(value: i, child: Text(toBeginningOfSentenceCase(i) ?? i))).toList(),
        ),
      ),
    );
  }
}
