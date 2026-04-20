import 'dart:io';

class ApiConstants {
  // baseUrl: get from env, or hardcoded for dev
  static String get baseUrl {
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:5000/api'; // Using 5000 based on backend running on 5000
    } else {
      return 'http://localhost:5000/api';
    }
  }

  // Auth
  static const String auth = '/auth';
  static const String registerEmail = '/auth/register/email';
  static const String loginEmail = '/auth/login/email';
  static const String sendOtp = '/auth/otp/send';
  static const String verifyOtp = '/auth/otp/verify';
  static const String loginGoogle = '/auth/google';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Marketplace
  static const String products = '/products';
  static const String orders = '/orders';

  // Hotel
  static const String hotelBulkOrders = '/hotel/bulk-orders';
  static const String hotelSubscriptions = '/hotel/subscriptions';
  static const String hotelInvoices = '/hotel/invoices';

  // Eksportir
  static const String exporterRfq = '/exporter/rfq';
  static const String exporterDocuments = '/exporter/documents';
  static const String currencyRates = '/exporter/currency/rates';

  // Admin
  static const String adminStats = '/admin/stats';
  static const String adminUsers = '/admin/users';
}
