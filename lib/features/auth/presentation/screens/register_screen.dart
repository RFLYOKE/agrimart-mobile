import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/providers/auth_provider.dart';
import '../models/user_model.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Specific fields
  final _organizationController = TextEditingController();
  
  UserRole _selectedRole = UserRole.konsumen;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _organizationController.dispose();
    super.dispose();
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
       // Mock for now: user needs a register repo method.
       // The repository only has registerWithEmail, but auth_provider doesn't have it exposed 
       // based on the instruction (only loginWithEmail is defined in provider). 
       // But in real scenario, we call ref.read(authRepositoryProvider).registerWithEmail(...)
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi diproses...')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun AgriMart')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (val) => val!.length < 6 ? 'Minimal 6 karakter' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Daftar Sebagai', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: UserRole.konsumen, child: Row(children: [Icon(Icons.shopping_cart), SizedBox(width: 8), Text('Konsumen')])),
                  DropdownMenuItem(value: UserRole.koperasi, child: Row(children: [Icon(Icons.store), SizedBox(width: 8), Text('Koperasi')])),
                  DropdownMenuItem(value: UserRole.hotelRestoran, child: Row(children: [Icon(Icons.hotel), SizedBox(width: 8), Text('Hotel & Restoran')])),
                  DropdownMenuItem(value: UserRole.eksportir, child: Row(children: [Icon(Icons.directions_boat), SizedBox(width: 8), Text('Eksportir')])),
                ],
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
              if (_selectedRole == UserRole.koperasi) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _organizationController,
                  decoration: const InputDecoration(labelText: 'Nama Koperasi', border: OutlineInputBorder()),
                ),
              ],
              if (_selectedRole == UserRole.hotelRestoran) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _organizationController,
                  decoration: const InputDecoration(labelText: 'Nama Hotel / Restoran', border: OutlineInputBorder()),
                ),
              ],
              if (_selectedRole == UserRole.eksportir) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _organizationController,
                  decoration: const InputDecoration(labelText: 'Nama Perusahaan', border: OutlineInputBorder()),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                  onPressed: _register,
                  child: const Text('Daftar', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
