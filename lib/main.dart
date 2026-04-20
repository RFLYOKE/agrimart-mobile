import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_colors.dart';
import 'core/network/dio_client.dart';
import 'core/providers/connectivity_provider.dart';
import 'core/router/app_router.dart';
import 'core/services/fcm_service.dart';
import 'features/auth/domain/providers/auth_provider.dart';

// ─── FCM Background handler (top-level, wajib di luar class) ──────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('BG message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Init Firebase
  await Firebase.initializeApp();

  // 2. Register FCM background handler (sebelum runApp!)
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // 3. Init local notifications channel (Android)
  await FcmService().initLocalNotifications();

  // 4. Touch DioClient singleton
  DioClient.instance;

  runApp(const ProviderScope(child: AgriMartApp()));
}

class AgriMartApp extends ConsumerStatefulWidget {
  const AgriMartApp({super.key});

  @override
  ConsumerState<AgriMartApp> createState() => _AgriMartAppState();
}

class _AgriMartAppState extends ConsumerState<AgriMartApp> {
  @override
  void initState() {
    super.initState();

    // Listen auth state changes untuk init FCM setelah login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listen(authProvider, (previous, next) {
        final val = next.value;
        if (val is Authenticated) {
          _initFCM();
        }
      });
    });
  }

  Future<void> _initFCM() async {
    final fcm = FcmService();
    await fcm.requestPermission();
    await fcm.getToken();
    fcm.setupForegroundHandler();
    fcm.setupOnMessageOpenedApp();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);
    final isOnline = ref.watch(connectivityProvider);

    return MaterialApp.router(
      title: 'AgriMart',
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryGreen,
          primary: AppColors.primaryGreen,
          secondary: AppColors.secondaryGreen,
        ),
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
          ),
        ),
      ),
      locale: const Locale('id', 'ID'),
      builder: (context, child) {
        return _ConnectivityWrapper(isOnline: isOnline, child: child ?? const SizedBox());
      },
    );
  }
}

/// Wrapper yang menampilkan banner offline di atas seluruh app
class _ConnectivityWrapper extends StatelessWidget {
  final bool isOnline;
  final Widget child;

  const _ConnectivityWrapper({required this.isOnline, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Offline Banner
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: isOnline ? 0 : 38,
          color: AppColors.errorRed,
          child: isOnline
              ? const SizedBox()
              : const SafeArea(
                  bottom: false,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Tidak ada koneksi internet',
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
        ),
        Expanded(child: child),
      ],
    );
  }
}
