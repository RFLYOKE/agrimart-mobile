import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'route_names.dart';
import '../../features/auth/domain/providers/auth_provider.dart';
import '../../features/auth/data/models/user_model.dart';

// Auth Screens
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';

// Marketplace Screens
import '../../features/marketplace/presentation/screens/product_list_screen.dart';
import '../../features/marketplace/presentation/screens/product_detail_screen.dart';
import '../../features/marketplace/presentation/screens/cart_screen.dart';
import '../../features/marketplace/presentation/screens/checkout_screen.dart';

// Consult Screens
import '../../features/consult/presentation/screens/consultant_list_screen.dart';

// Auction Screens
import '../../features/auction/presentation/screens/auction_list_screen.dart';

// Analytics Screens
import '../../features/analytics/presentation/screens/price_home_screen.dart';
import '../../features/analytics/presentation/screens/price_alert_list_screen.dart';

// Dashboard Screens (placeholder shells)
import '../widgets/konsumen_shell.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authAsyncState = ref.watch(authProvider);

  String _getDashboardForUser(UserModel user) {
    switch (user.role) {
      case UserRole.koperasi:      return RouteNames.koperasiDashboard;
      case UserRole.hotelRestoran: return RouteNames.hotelDashboard;
      case UserRole.eksportir:     return RouteNames.exporterDashboard;
      case UserRole.admin:         return RouteNames.adminDashboard;
      case UserRole.konsumen:
      default:                     return RouteNames.home;
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

  bool _isRoleAllowed(String path, UserRole role) {
    if (path.startsWith('/admin') && role != UserRole.admin) return false;
    if (path.startsWith('/hotel') && role != UserRole.hotelRestoran) return false;
    if (path.startsWith('/koperasi') && role != UserRole.koperasi) return false;
    if (path.startsWith('/exporter') && role != UserRole.eksportir) return false;
    return true;
  }

  return GoRouter(
    initialLocation: RouteNames.splash,
    redirect: (context, state) {
      final value = authAsyncState.value;
      final isAuth = value is Authenticated;
      final isUnauth = value is Unauthenticated;
      final path = state.matchedLocation;

      // Still loading
      if (!isAuth && !isUnauth) return null;

      // Not logged in -> block private routes
      if (isUnauth && !_isPublicRoute(path)) return RouteNames.login;

      if (isAuth) {
        final user = (value as Authenticated).user;

        // Already logged in -> skip auth screens
        if (_isPublicRoute(path)) return _getDashboardForUser(user);

        // Wrong role for route
        if (!_isRoleAllowed(path, user.role)) return _getDashboardForUser(user);
      }

      return null;
    },
    routes: [
      // ─── Splash ───────────────────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      ),

      // ─── Auth ─────────────────────────────────────────────
      GoRoute(path: RouteNames.login,    builder: (_, __) => const LoginScreen()),
      GoRoute(path: RouteNames.register, builder: (_, __) => const RegisterScreen()),
      GoRoute(
        path: RouteNames.verifyOtp,
        builder: (context, state) {
          final isNewUser = state.uri.queryParameters['isNewUser'] == 'true';
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpVerificationScreen(phone: phone, isNewUser: isNewUser);
        },
      ),

      // ─── Konsumen Shell (Bottom Nav) ───────────────────────
      ShellRoute(
        builder: (context, state, child) => KonsumenShell(child: child),
        routes: [
          GoRoute(
            path: RouteNames.home,
            builder: (_, __) => const ProductListScreen(),
          ),
          GoRoute(
            path: RouteNames.consult,
            builder: (_, __) => const ConsultantListScreen(),
          ),
          GoRoute(
            path: RouteNames.auction,
            builder: (_, __) => const AuctionListScreen(),
          ),
          GoRoute(
            path: RouteNames.analytics,
            builder: (_, __) => const PriceHomeScreen(),
          ),
        ],
      ),

      // ─── Marketplace Detail Routes ─────────────────────────
      GoRoute(
        path: '/products/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(path: RouteNames.cart,     builder: (_, __) => const CartScreen()),
      GoRoute(path: RouteNames.checkout, builder: (_, __) => const CheckoutScreen()),

      // ─── Analytics ────────────────────────────────────────
      GoRoute(
        path: '/analytics/alerts',
        builder: (_, __) => const PriceAlertListScreen(),
      ),

      // ─── Role Dashboards (placeholder Scaffolds) ──────────
      GoRoute(path: RouteNames.koperasiDashboard, builder: (_, __) => Scaffold(appBar: AppBar(title: const Text('Dashboard Koperasi')))),
      GoRoute(path: RouteNames.hotelDashboard,    builder: (_, __) => Scaffold(appBar: AppBar(title: const Text('Dashboard Hotel')))),
      GoRoute(path: RouteNames.exporterDashboard, builder: (_, __) => Scaffold(appBar: AppBar(title: const Text('Dashboard Eksportir')))),
      GoRoute(path: RouteNames.adminDashboard,    builder: (_, __) => Scaffold(appBar: AppBar(title: const Text('Dashboard Admin')))),
    ],
  );
});
