import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyService {
  // Notifiers so the app can react instantly
  static final targetCurrencyNotifier = ValueNotifier<String>('PHP');
  static final exchangeRateNotifier = ValueNotifier<double>(1.0);

  static final allRatesNotifier = ValueNotifier<Map<String, double>>({});
  static final lastUpdatedNotifier = ValueNotifier<DateTime?>(null);

  static const String _currencyKey = 'app_target_currency';
  static const String _ratesCacheKey = 'app_rates_cache';
  static const String _lastFetchKey = 'app_last_fetch';
  static const String url = 'https://open.er-api.com/v6/latest/PHP';

  /// Map of supported currencies and their symbols
  static final Map<String, String> supportedCurrencies = {
    'PHP': '₱',
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'JPY': '¥',
    'AUD': 'A\$',
  };

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    targetCurrencyNotifier.value = prefs.getString(_currencyKey) ?? 'PHP';

    await _loadCachedRates();
    _fetchRatesInBackground(); // Silently updates in the background
  }

  static Future<void> _fetchRatesInBackground() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetch = prefs.getInt(_lastFetchKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Only fetch once every 12 hours to save bandwidth and battery
      if (now - lastFetch < 12 * 60 * 60 * 1000) return;

      // PHP is our base database currency
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        await prefs.setString(_ratesCacheKey, response.body);
        await prefs.setInt(_lastFetchKey, now);
        await _loadCachedRates(); // Update the active rate
      }
    } catch (e) {
      debugPrint("Forex fetch failed (Offline mode active): $e");
    }
  }

  static Future<bool> forceFetchRates() async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_ratesCacheKey, response.body);
        await prefs.setInt(
          _lastFetchKey,
          DateTime.now().millisecondsSinceEpoch,
        );
        await _loadCachedRates();
        return true; // Success!
      }
    } catch (e) {
      debugPrint("Forex manual fetch failed: $e");
    }
    return false; // Failed!
  }

  static Future<void> _loadCachedRates() async {
    final prefs = await SharedPreferences.getInstance();
    final cache = prefs.getString(_ratesCacheKey);
    final lastFetch = prefs.getInt(_lastFetchKey);

    // Update the Last Fetched Timestamp UI
    if (lastFetch != null) {
      lastUpdatedNotifier.value = DateTime.fromMillisecondsSinceEpoch(
        lastFetch,
      );
    }

    if (cache != null) {
      final data = jsonDecode(cache);
      final rawRates = data['rates'] as Map<String, dynamic>;

      // Filter out junk currencies so the UI list is clean
      final Map<String, double> filteredRates = {};
      for (var code in supportedCurrencies.keys) {
        if (rawRates.containsKey(code)) {
          filteredRates[code] = (rawRates[code] as num).toDouble();
        }
      }

      // Populate the notifier so the UI can draw the list!
      allRatesNotifier.value = filteredRates;

      final target = targetCurrencyNotifier.value;
      exchangeRateNotifier.value = (rawRates[target] ?? 1.0).toDouble();
    }
  }

  static Future<void> setCurrency(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_currencyKey, code);
    targetCurrencyNotifier.value = code;
    await _loadCachedRates(); // Instantly recalculate the multiplier
  }

  //* --- HELPER METHODS FOR THE UI ---

  /// Database -> Screen (Multiply by rate) \
  /// Use this for Text widgets, Charts, and Dashboard totals.
  static double toDisplay(double phpAmount) =>
      phpAmount * exchangeRateNotifier.value;

  /// Screen -> Database (Divide by rate) \
  /// Use this ONLY when saving a user's text input back to Isar.
  static double toBase(double displayAmount) =>
      displayAmount / exchangeRateNotifier.value;

  static String get symbol =>
      supportedCurrencies[targetCurrencyNotifier.value] ?? '';
}
