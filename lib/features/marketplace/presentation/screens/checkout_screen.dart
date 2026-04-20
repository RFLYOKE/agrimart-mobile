import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../features/auth/domain/providers/auth_provider.dart';
import '../../domain/providers/cart_provider.dart';
import '../../domain/providers/product_provider.dart';
import 'payment_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _provinceController = TextEditingController();
  
  String _paymentMethod = 'va_bca';
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _provinceController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    if (!_formKey.currentState!.validate()) return;
    
    final cartItems = ref.read(cartProvider);
    if (cartItems.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final itemsMap = cartItems.map((item) => {
        'product_id': item.product.id,
        'qty': item.quantity,
      }).toList();

      final addressMap = {
        'receiver_name': _nameController.text,
        'phone': _phoneController.text,
        'street': _addressController.text,
        'city': _cityController.text,
        'province': _provinceController.text,
      };

      final order = await ref.read(productRepositoryProvider).createOrder(
        itemsMap,
        addressMap,
        _paymentMethod,
      );

      ref.read(cartProvider.notifier).clearCart();

      if (!mounted) return;

      if (order.snapToken != null && order.snapToken!.isNotEmpty) {
        // Navigate to payment screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PaymentScreen(snapToken: order.snapToken!),
          )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order berhasil (COD / Pending)')));
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final user = ref.watch(authProvider.notifier).currentUser;
    final isB2B = user?.isHotel == true || user?.isEksportir == true;
    final total = ref.read(cartProvider.notifier).totalPrice;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Alamat Pengiriman', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Penerima', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'No. Handphone', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Alamat Lengkap (Jalan, RT/RW, Patokan)', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _cityController,
                      decoration: const InputDecoration(labelText: 'Kota/Kabupaten', border: OutlineInputBorder()),
                      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _provinceController,
                      decoration: const InputDecoration(labelText: 'Provinsi', border: OutlineInputBorder()),
                      validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text('Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(side: BorderSide(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: [
                    RadioListTile<String>(
                      title: const Text('BCA Virtual Account'),
                      value: 'va_bca',
                      groupValue: _paymentMethod,
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: const Text('Mandiri Virtual Account'),
                      value: 'va_mandiri',
                      groupValue: _paymentMethod,
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: const Text('GoPay'),
                      value: 'gopay',
                      groupValue: _paymentMethod,
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: const Text('QRIS'),
                      value: 'qris',
                      groupValue: _paymentMethod,
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                    ),
                    const Divider(height: 1),
                    RadioListTile<String>(
                      title: const Text('Cash on Delivery (COD)'),
                      value: 'cod',
                      groupValue: _paymentMethod,
                      onChanged: (val) => setState(() => _paymentMethod = val!),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text('Ringkasan Pesanan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              ...cartItems.map((item) {
                final price = isB2B ? item.product.priceB2b : item.product.priceB2c;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text('${item.quantity}x ${item.product.name}', maxLines: 1)),
                      Text(CurrencyFormatter.formatRupiah(price * item.quantity)),
                    ],
                  ),
                );
              }),
              const Divider(thickness: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Beli', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(CurrencyFormatter.formatRupiah(total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primaryGreen)),
                ],
              ),
              const SizedBox(height: 100), // spacing for bottom bar
            ],
          ),
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
              onPressed: _isLoading ? null : _processPayment,
              child: _isLoading 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Bayar Sekarang', style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
        ),
      ),
    );
  }
}
