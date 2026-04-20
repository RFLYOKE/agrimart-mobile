import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../constants/api_constants.dart';
import '../network/dio_client.dart';

// ─── Top-level background handler (harus di luar class) ───────────────────────
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase sudah diinit di main.dart sebelum fungsi ini dipanggil
  debugPrint('Background message: ${message.messageId}');
  // Tampilkan local notification dari isolate background jika perlu
}

// ─── FCM Service ──────────────────────────────────────────────────────────────
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotif = FlutterLocalNotificationsPlugin();

  // Navigator key untuk deep link navigasi di luar BuildContext
  static GlobalKey<NavigatorState>? navigatorKey;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'agrimart_high_importance',
    'AgriMart Notifikasi',
    description: 'Notifikasi penting dari AgriMart',
    importance: Importance.high,
  );

  // ── Init local notifications ──
  Future<void> initLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotif.initialize(
      const InitializationSettings(android: androidInit, iOS: iosInit),
      onDidReceiveNotificationResponse: _onLocalNotifTap,
    );

    // Buat channel Android
    await _localNotif
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);
  }

  // ── Request permission ──
  Future<void> requestPermission() async {
    final settings = await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    debugPrint('FCM Permission: ${settings.authorizationStatus}');
  }

  // ── Get & Register FCM Token ──
  Future<void> getToken() async {
    final token = await _fcm.getToken();
    if (token == null) return;

    debugPrint('FCM Token: $token');

    try {
      await DioClient.instance.dio.post(
        '${ApiConstants.auth.replaceAll('/auth', '')}/notifications/register-token',
        data: {
          'token': token,
          'platform': Platform.isAndroid ? 'android' : 'ios',
        },
      );
    } catch (e) {
      debugPrint('Failed to register FCM token: $e');
    }

    // Listen to token refresh
    _fcm.onTokenRefresh.listen((newToken) async {
      try {
        await DioClient.instance.dio.post(
          '${ApiConstants.auth.replaceAll('/auth', '')}/notifications/register-token',
          data: {'token': newToken, 'platform': Platform.isAndroid ? 'android' : 'ios'},
        );
      } catch (_) {}
    });
  }

  // ── Foreground Handler ──
  void setupForegroundHandler() {
    // Set foreground presentation options (iOS)
    _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });
  }

  // ── On Message Opened App (tap dari background/terminated) ──
  void setupOnMessageOpenedApp() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleDeepLink(message.data);
    });

    // App terminated state: check getInitialMessage
    _fcm.getInitialMessage().then((message) {
      if (message != null) {
        _handleDeepLink(message.data);
      }
    });
  }

  // ── Helper: tampilkan local notification ──
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _localNotif.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: _payloadFromData(message.data),
    );
  }

  // ── Deep Link Handler ──
  void _handleDeepLink(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final navigator = navigatorKey?.currentState;
    if (navigator == null || type == null) return;

    switch (type) {
      case 'order':
        final orderId = data['order_id'] ?? '';
        navigator.pushNamed('/orders/$orderId');
        break;
      case 'auction':
        final auctionId = data['auction_id'] ?? '';
        navigator.pushNamed('/auction/$auctionId');
        break;
      case 'chat':
        final sessionId = data['session_id'] ?? '';
        navigator.pushNamed('/consult/$sessionId');
        break;
      case 'price_alert':
        navigator.pushNamed('/analytics');
        break;
      default:
        break;
    }
  }

  // ── Helper: convert data map to payload string ──
  String _payloadFromData(Map<String, dynamic> data) {
    return data.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  // ── Local notif tap handler ──
  void _onLocalNotifTap(NotificationResponse response) {
    final payload = response.payload ?? '';
    final map = Map<String, dynamic>.fromEntries(
      payload.split('&').where((s) => s.contains('=')).map((s) {
        final parts = s.split('=');
        return MapEntry(parts[0], parts.sublist(1).join('='));
      }),
    );
    _handleDeepLink(map);
  }
}
