import 'package:flutter/material.dart';
import 'package:pal_journal/services/currency/currency_service.dart';
import 'package:pal_journal/utils/formatters.dart';

class SmartSyncButton extends StatelessWidget {
  final VoidCallback onSync;
  final double amount;
  final String symbol;

  const SmartSyncButton({
    super.key,
    required this.onSync,
    required this.amount,
    required this.symbol,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    var value = amount;
    final displayAmount = AppFormatters.toCurrency(
      CurrencyService.toDisplay(value),
    );

    return OutlinedButton(
      onPressed: onSync,
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: .all(.circular(8))),
        backgroundColor: colors.primary.withValues(alpha: 0.1),
        side: BorderSide(color: colors.primary.withValues(alpha: 0.3)),
      ),
      child: SmartSyncLabel(symbol: symbol, displayAmount: displayAmount),
    );
  }
}

class SmartSyncLabel extends StatelessWidget {
  const SmartSyncLabel({
    super.key,
    required this.symbol,
    required this.displayAmount,
  });

  final String symbol;
  final String displayAmount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final content = [
      Icon(Icons.auto_awesome, color: colors.primary, size: 14),
      const SizedBox(width: 8),
      Text(
        "Earned +$symbol$displayAmount! Add to budget?",
        style: TextStyle(
          color: colors.primary,
          fontSize: 12,
          fontWeight: .bold,
        ),
      ),
    ];
    return Row(mainAxisSize: .min, children: content);
  }
}
