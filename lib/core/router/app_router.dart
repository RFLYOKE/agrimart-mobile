import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../features/auth/domain/providers/auth_provider.dart';
import '../../features/auth/data/models/user_model.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  String _getDashboardForRole(String role) {
    switch (role) {
      case 'koperasi': return RouteNames.koperasiDashboard;
      case 'hotel_restoran': return RouteNames.hotelDashboard;
      case 'eksportir': return RouteNames.exporterDashboard;
      case 'admin': return RouteNames.adminDashboard;
      case 'konsumen':
      default: return RouteNames.home;
    }
  }

  bool _isPublicRoute(String path) {
    return [
      RouteNames.splash,
      RouteNames.login,
      RouteNames.register,
      RouteNames.sendOtp,
      RouteNames.verifyOtp,
    ].contains(path);
  }

  bool _isRouteAllowedForRole(String path, String role) {
    if (path.startsWith('/admin') && role != 'admin') return false;
    if (path.startsWith('/hotel') && role != 'hotel_restoran') return false;
    if (path.startsWith('/koperasi') && role != 'koperasi') return false;
    if (path.startsWith('/exporter') && role != 'eksportir') return false;
    return true; // shared or correctly namespaced routes
  }

  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final isAuth = authState.value is Authenticated;
      final isUnauth = authState.value is Unauthenticated;
      final path = state.matchedLocation;

      // 1. Jika loading, tunggu dulu
      if (!isAuth && !isUnauth) return null;

      // 2. Jika belum login dan coba akses private route -> login
      if (isUnauth && !_isPublicRoute(path)) {
        return RouteNames.login;
      }

      // 3 & 4. Jika sudah login
      if (isAuth) {
        final user = (authState.value as Authenticated).user;
        final roleStr = user.toJson()['role'];

        // Jika akses public route padahal sudah login -> arahkan ke dashboard
        if (_isPublicRoute(path)) {
          return _getDashboardForRole(roleStr);
        }

        // Jika akses route role lain -> arahkan ke dashboard sendiri
        if (!_isRouteAllowedForRole(path, roleStr)) {
          return _getDashboardForRole(roleStr);
        }
      }

      return null; // no redirect needed
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.verifyOtp,
        builder: (context, state) {
          final isNewUser = state.uri.queryParameters['isNewUser'] == 'true';
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpVerificationScreen(phone: phone, isNewUser: isNewUser);
        },
      ),

      // Konsumen routes (Mock ShellRoute)
      ShellRoute(
        builder: (context, state, child) => Scaffold(
          body: child,
          bottomNavigationBar: BottomNavigationBar(
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Konsultasi'),
            ]
          ),
        ),
        routes: [
          GoRoute(path: RouteNames.home, builder: (context, state) => Scaffold(appBar: AppBar(title: const Text('Home')))),
          GoRoute(path: RouteNames.consult, builder: (context, state) => const Scaffold(body: Center(child: Text('Consult')))),
        ]
      ),

      // Add actual mock routes for the rest of dashboards to prevent GoRouter crashes on undefined
      GoRoute(path: RouteNames.koperasiDashboard, builder: (context, state) => Scaffold(appBar: AppBar(title: const Text('Koperasi Dashboard')))),
      GoRoute(path: RouteNames.hotelDashboard, builder: (context, state) => Scaffold(appBar: AppBar(title: const Text('Hotel Dashboard')))),
      GoRoute(path: RouteNames.exporterDashboard, builder: (context, state) => Scaffold(appBar: AppBar(title: const Text('Exporter Dashboard')))),
      GoRoute(path: RouteNames.adminDashboard, builder: (context, state) => Scaffold(appBar: AppBar(title: const Text('Admin Dashboard')))),
    ],
  );
});
