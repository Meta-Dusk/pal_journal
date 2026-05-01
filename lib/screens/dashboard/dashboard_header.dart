import 'package:flutter/material.dart';
import 'package:pal_journal/utils/formatters.dart';

class DashboardHeader extends StatelessWidget {
  final double totalAmount;
  final bool isPositive;

  const DashboardHeader({
    super.key,
    required this.totalAmount,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final displayAmount = AppFormatters.toCurrency(totalAmount.abs());
    final sign = isPositive ? "+" : "-";
    final accentColor = isPositive ? Colors.greenAccent : colors.error;

    final headerContent = [
      Text(
        "Lifetime Net PnL",
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
      ),
      const SizedBox(height: 8),
      Text(
        "$sign ₱$displayAmount",
        style: TextStyle(fontSize: 42, fontWeight: .bold, color: accentColor),
      ),
    ];

    return Hero(
      tag: 'lifetime_pnl_card',
      placeholderBuilder: (context, heroSize, child) {
        return Opacity(opacity: 0.0, child: child);
      },
      child: Material(
        type: .transparency,
        child: Container(
          width: double.infinity,
          padding: const .all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                colors.surfaceContainerHighest,
                colors.surfaceContainerHighest.withValues(alpha: 0.7),
              ],
              begin: .topLeft,
              end: .bottomRight,
            ),
            borderRadius: .circular(24),
            border: .all(color: accentColor.withValues(alpha: 0.3), width: 1),
          ),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: headerContent,
            ),
          ),
        ),
      ),
    );
  }
}
