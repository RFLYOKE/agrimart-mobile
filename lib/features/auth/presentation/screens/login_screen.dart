import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/route_names.dart';
import '../../domain/providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _loginEmail() {
    ref.read(authProvider.notifier).loginWithEmail(
      _emailController.text.trim(),
      _passwordController.text,
    );
  }

  void _sendOtp() {
    final phone = _phoneController.text.trim();
    if (phone.isNotEmpty) {
      // In a real app, you would call sendOtp API first, then navigate
      context.go('${RouteNames.verifyOtp}?phone=$phone&isNewUser=false');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.value is Loading;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Masuk AgriMart'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Email'),
              Tab(text: 'Nomor HP'),
            ],
            labelColor: AppColors.primaryGreen,
            indicatorColor: AppColors.primaryGreen,
          ),
        ),
        body: TabBarView(
          children: [
            // Tab Email
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  TextField(
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
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                      onPressed: isLoading ? null : _loginEmail,
                      child: isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Masuk', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("atau")),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.g_mobiledata, size: 32),
                      label: const Text('Masuk dengan Google'),
                      onPressed: isLoading ? null : () => ref.read(authProvider.notifier).loginWithGoogle(),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go(RouteNames.register),
                    child: const Text('Belum punya akun? Daftar disini', style: TextStyle(color: AppColors.primaryGreen)),
                  )
                ],
              ),
            ),
            
            // Tab Nomor HP
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Handphone',
                      prefixText: '+62 ',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                      onPressed: isLoading ? null : _sendOtp,
                      child: const Text('Kirim OTP', style: TextStyle(color: Colors.white, fontSize: 16)),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go(RouteNames.register),
                    child: const Text('Belum punya akun? Daftar disini', style: TextStyle(color: AppColors.primaryGreen)),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
