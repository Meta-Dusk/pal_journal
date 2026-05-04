import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CustomAssetInjector {
  static const String yahooFinanceUri =
      'https://query1.finance.yahoo.com/v8/finance/chart/GC=F';

  /// Takes the raw fiat rates, fetches any custom assets, and merges them.
  static Future<Map<String, dynamic>> inject({
    required Map<String, dynamic> rawRates,
    required SharedPreferences prefs,
    required String cacheKey,
  }) async {
    final phpToUsd = (rawRates['USD'] as num?)?.toDouble() ?? 0.017;
    final oneUsdToPhp = 1 / phpToUsd;

    double goldRateInPhpMultiplier;
    try {
      final response = await http.get(
        Uri.parse(yahooFinanceUri),
        headers: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final goldOunceInUsd =
            data['chart']['result'][0]['meta']['regularMarketPrice'].toDouble();

        final goldGramInUsd = goldOunceInUsd / 31.1034768;
        final goldGramInPhp = goldGramInUsd * oneUsdToPhp;

        goldRateInPhpMultiplier = 1 / goldGramInPhp;
      } else {
        throw Exception("Yahoo API failed: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Failed to fetch Gold: $e");
      final oldCache = prefs.getString(cacheKey);
      if (oldCache != null) {
        final oldRates = jsonDecode(oldCache)['rates'];
        goldRateInPhpMultiplier =
            (oldRates['GOLD'] as num?)?.toDouble() ?? 0.00025;
      } else {
        goldRateInPhpMultiplier = 0.00025;
      }
    }

    rawRates['GOLD'] = goldRateInPhpMultiplier;
    return rawRates;
  }
}
