import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String phone;
  final bool isNewUser;

  const OtpVerificationScreen({
    super.key,
    required this.phone,
    required this.isNewUser,
  });

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  String? _selectedRole;

  @override
  void dispose() {
    _otpController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _verify() {
    if (widget.isNewUser) {
      if (_nameController.text.isEmpty || _selectedRole == null) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Lengkapi nama dan role')));
         return;
      }
    }

    ref.read(authProvider.notifier).loginWithPhone(
      widget.phone, 
      _otpController.text,
      name: widget.isNewUser ? _nameController.text : null,
      role: widget.isNewUser ? _selectedRole : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.value is Loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Verifikasi OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text('Kode OTP telah dikirim ke ${widget.phone}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 32),
            TextField(
              controller: _otpController,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                hintText: '000000',
                border: OutlineInputBorder(),
              ),
            ),
            if (widget.isNewUser) ...[
              const SizedBox(height: 24),
              const Text('Lengkapi Profil Anda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Daftar Sebagai', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: 'konsumen', child: Text('Konsumen')),
                  DropdownMenuItem(value: 'koperasi', child: Text('Koperasi')),
                  DropdownMenuItem(value: 'hotel_restoran', child: Text('Hotel & Restoran')),
                  DropdownMenuItem(value: 'eksportir', child: Text('Eksportir')),
                ],
                onChanged: (val) => setState(() => _selectedRole = val),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                onPressed: isLoading ? null : _verify,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Verifikasi', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
