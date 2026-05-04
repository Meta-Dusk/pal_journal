import 'package:flutter/material.dart';
import 'package:pal_journal/services/currency/currency_service.dart';

class ListTileCurrency extends StatelessWidget {
  const ListTileCurrency({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return ValueListenableBuilder<String>(
      valueListenable: CurrencyService.targetCurrencyNotifier,
      builder: (context, currentCurrency, child) {
        return ListTile(
          tileColor: colors.surfaceContainer,
          leading: Icon(Icons.currency_exchange, color: colors.primary),
          title: const Text("Display Currency"),
          subtitle: const Text(
            "Auto-converts your ledger values",
            style: TextStyle(fontSize: 12),
          ),
          trailing: Text(
            currentCurrency,
            style: TextStyle(color: colors.primary, fontWeight: .bold),
          ),
          onTap: () => _showCurrencyDialog(context, currentCurrency),
        );
      },
    );
  }

  void _showCurrencyDialog(BuildContext context, String currentCurrency) {
    showDialog(
      context: context,
      builder: (context) {
        return CurrencyDialog(currentCurrency: currentCurrency);
      },
    );
  }
}

class CurrencyDialog extends StatelessWidget {
  final String currentCurrency;

  const CurrencyDialog({super.key, required this.currentCurrency});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Currency"),
      contentPadding: const .only(top: 12, bottom: 24),
      content: SizedBox(
        width: double.maxFinite,
        child: RadioGroup<String>(
          groupValue: currentCurrency,
          onChanged: (value) {
            if (value != null) {
              CurrencyService.setCurrency(value);
              Navigator.pop(context); // Close dialog on selection
            }
          },
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: CurrencyService.supportedCurrencies.length,
            itemBuilder: (context, index) {
              return IndexedRadioListTile(index: index);
            },
          ),
        ),
      ),
    );
  }
}

class IndexedRadioListTile extends StatelessWidget {
  final int index;

  const IndexedRadioListTile({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final code = CurrencyService.supportedCurrencies.keys.elementAt(index);
    final symbol = CurrencyService.supportedCurrencies[code];

    return RadioListTile<String>(
      title: Text("$code ($symbol)"),
      value: code,
      activeColor: colors.primary,
    );
  }
}
