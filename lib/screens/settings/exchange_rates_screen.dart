import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pal_journal/services/currency/currency_service.dart';

class ExchangeRatesScreen extends StatefulWidget {
  const ExchangeRatesScreen({super.key});

  @override
  State<ExchangeRatesScreen> createState() => _ExchangeRatesScreenState();
}

class _ExchangeRatesScreenState extends State<ExchangeRatesScreen> {
  bool _isRefreshing = false;

  void _refreshRates() async {
    setState(() => _isRefreshing = true);
    final success = await CurrencyService.forceFetchRates();

    if (mounted) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? "Rates updated successfully!"
                : "Failed to fetch rates. Check your connection.",
          ),
          backgroundColor: success
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Exchange Rates"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isRefreshing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshRates,
          ),
        ],
      ),
      body: ListenableBuilder(
        // We listen to both the rates and the timestamp!
        listenable: Listenable.merge([
          CurrencyService.allRatesNotifier,
          CurrencyService.lastUpdatedNotifier,
        ]),
        builder: (context, _) {
          final rates = CurrencyService.allRatesNotifier.value;
          final lastUpdated = CurrencyService.lastUpdatedNotifier.value;

          if (rates.isEmpty) {
            return const Center(
              child: Text("No rate data available. Tap refresh."),
            );
          }

          return ExchangeRatesView(
            colors: colors,
            lastUpdated: lastUpdated,
            rates: rates,
          );
        },
      ),
    );
  }
}

class ExchangeRatesView extends StatelessWidget {
  const ExchangeRatesView({
    super.key,
    required this.colors,
    required this.lastUpdated,
    required this.rates,
  });

  final ColorScheme colors;
  final DateTime? lastUpdated;
  final Map<String, double> rates;

  @override
  Widget build(BuildContext context) {
    final formattedDate = lastUpdated != null
        ? DateFormat('MMM d, h:mm a').format(lastUpdated!)
        : "";

    final infoWidgets = [
      Icon(Icons.info_outline, size: 16, color: colors.onSurfaceVariant),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          lastUpdated != null ? "Last updated: $formattedDate" : "Updating...",
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
        ),
      ),
    ];

    final listDisplays = ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const .all(16),
      itemCount: rates.length,
      itemBuilder: (context, index) {
        final targetCode = rates.keys.elementAt(index);
        final rate = rates[targetCode]!;
        final targetSymbol = CurrencyService.supportedCurrencies[targetCode];

        // Base Currency (PHP) doesn't need to be compared to itself
        if (targetCode == 'PHP') return const SizedBox.shrink();

        // Calculate the inverse (1 Target = X PHP)
        final inverseRate = 1 / rate;
        final formattedInverse = NumberFormat('#,##0.00').format(inverseRate);

        return DisplayCard(
          colors: colors,
          targetSymbol: targetSymbol,
          targetCode: targetCode,
          formattedInverse: formattedInverse,
        );
      },
    );

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const .symmetric(vertical: 12, horizontal: 24),
          color: colors.surfaceContainerHighest,
          child: Row(children: infoWidgets),
        ),
        Expanded(child: listDisplays),
      ],
    );
  }
}

class DisplayCard extends StatelessWidget {
  const DisplayCard({
    super.key,
    required this.colors,
    required this.targetSymbol,
    required this.targetCode,
    required this.formattedInverse,
  });

  final ColorScheme colors;
  final String? targetSymbol;
  final String targetCode;
  final String formattedInverse;

  @override
  Widget build(BuildContext context) {
    final isGold = targetCode == 'GOLD';

    final avatarBgColor = isGold
        ? Colors.amber.shade200
        : colors.primaryContainer;
    final avatarFgColor = isGold
        ? Colors.amber.shade900
        : colors.onPrimaryContainer;

    final displayTitle = isGold ? "1 Gram Gold" : "1 $targetCode";

    return Card(
      elevation: 0,
      color: colors.surfaceContainer,
      margin: const .only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: .circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: avatarBgColor,
          child: isGold
              ? Icon(Icons.workspace_premium, color: avatarFgColor)
              : Text(
                  targetSymbol ?? '',
                  style: TextStyle(color: avatarFgColor, fontWeight: .bold),
                ),
        ),
        title: Text(displayTitle),
        trailing: Text(
          "₱ $formattedInverse",
          style: TextStyle(
            fontWeight: .bold,
            fontSize: 16,
            color: colors.primary,
          ),
        ),
      ),
    );
  }
}
