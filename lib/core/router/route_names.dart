class RouteNames {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String sendOtp = '/otp/send';
  static const String verifyOtp = '/otp/verify';
  
  // Konsumen
  static const String home = '/home';
  static const String productDetail = '/products/:id';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderTracking = '/orders/:id';
  
  // Koperasi
  static const String koperasiDashboard = '/koperasi/dashboard';
  static const String koperasiProducts = '/koperasi/products';
  static const String koperasiOrders = '/koperasi/orders';
  static const String koperasiRfqOpportunities = '/koperasi/rfq';
  
  // Hotel
  static const String hotelDashboard = '/hotel/dashboard';
  static const String hotelBulkOrder = '/hotel/bulk-order';
  static const String hotelSubscriptions = '/hotel/subscriptions';
  static const String hotelInvoices = '/hotel/invoices';
  
  // Eksportir
  static const String exporterDashboard = '/exporter/dashboard';
  static const String exporterRfq = '/exporter/rfq';
  static const String exporterDocuments = '/exporter/documents';
  static const String currencyConverter = '/exporter/currency';
  
  // Admin
  static const String adminDashboard = '/admin/dashboard';
  static const String adminUsers = '/admin/users';
  static const String adminCoopVerification = '/admin/cooperatives';
  static const String adminClaims = '/admin/claims';
  static const String adminAnalytics = '/admin/analytics';
  
  // Shared
  static const String consult = '/consult';
  static const String auction = '/auction';
  static const String analytics = '/analytics';
  static const String profile = '/profile';
}
