import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatRupiah(num amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  static String formatRupiahCompact(num amount) {
    if (amount >= 1000000) {
      return 'Rp ${(amount / 1000000).toStringAsFixed(amount % 1000000 == 0 ? 0 : 1)} jt';
    } else if (amount >= 1000) {
      return 'Rp ${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)} rb';
    }
    return formatRupiah(amount);
  }

  static String formatCurrency(num amount, String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return NumberFormat.currency(locale: 'en_US', symbol: r'$ ').format(amount);
      case 'EUR':
        return NumberFormat.currency(locale: 'fr_FR', symbol: '€ ').format(amount);
      case 'JPY':
        return NumberFormat.currency(locale: 'ja_JP', symbol: '¥ ', decimalDigits: 0).format(amount);
      case 'SGD':
        return NumberFormat.currency(locale: 'en_SG', symbol: r'S$ ').format(amount);
      case 'AUD':
        return NumberFormat.currency(locale: 'en_AU', symbol: r'A$ ').format(amount);
      case 'IDR':
      default:
        return formatRupiah(amount);
    }
  }
}
