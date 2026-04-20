import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  static const String _cacheKey = 'currency_rates_cache';
  static const String _timeKey = 'currency_rates_time';
  
  // Cache Valid 30 Minutes
  static const int _cacheTtlMinutes = 30;

  // Mock initial fetch from backend (GET /exporter/currency/rates)
  Future<Map<String, double>> fetchRates() async {
    final prefs = await SharedPreferences.getInstance();
    
    final lastFetch = prefs.getString(_timeKey);
    if (lastFetch != null) {
      final fetchTime = DateTime.parse(lastFetch);
      final diff = DateTime.now().difference(fetchTime).inMinutes;
      
      if (diff < _cacheTtlMinutes) {
        final cachedData = prefs.getString(_cacheKey);
        if (cachedData != null) {
          final Map<String, dynamic> decoded = jsonDecode(cachedData);
          return decoded.map((key, value) => MapEntry(key, (value as num).toDouble()));
        }
      }
    }

    // MOCK API Call
    await Future.delayed(const Duration(seconds: 1));
    final mockRates = {
      'IDR': 1.0,
      'USD': 15850.0,
      'EUR': 17200.0,
      'JPY': 105.4,
      'SGD': 11800.0,
      'AUD': 10400.0,
    };

    // Save to cache
    await prefs.setString(_cacheKey, jsonEncode(mockRates));
    await prefs.setString(_timeKey, DateTime.now().toIso8601String());

    return mockRates;
  }

  Future<double> convert(double amount, String from, String to) async {
    final rates = await fetchRates();
    
    if (!rates.containsKey(from) || !rates.containsKey(to)) {
      throw Exception('Currency rate not found');
    }

    // Convert 'from' to IDR first (as base currency)
    final inIdr = amount * rates[from]!;
    
    // Convert IDR to 'to' currency
    return inIdr / rates[to]!;
  }
}
