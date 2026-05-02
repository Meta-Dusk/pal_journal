import 'package:flutter/material.dart';
import 'package:pal_journal/screens/settings/exchange_rates_screen.dart';

class ListTileExchangeRates extends StatelessWidget {
  const ListTileExchangeRates({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: const RoundedRectangleBorder(
        borderRadius: .vertical(bottom: .circular(16)),
      ),
      leading: const Icon(Icons.show_chart),
      title: const Text("View Exchange Rates"),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExchangeRatesScreen()),
        );
      },
    );
  }
}
