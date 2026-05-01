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
    final displayAmount = AppFormatters.toCurrency(totalAmount.abs());
    final sign = isPositive ? "+" : "-";
    final accentColor = isPositive ? Colors.tealAccent : Colors.redAccent;

    final headerContent = [
      const Text(
        "Lifetime Net PnL",
        style: TextStyle(color: Colors.grey, fontSize: 14),
      ),
      const SizedBox(height: 8),
      Text(
        "$sign ₱$displayAmount",
        style: TextStyle(fontSize: 42, fontWeight: .bold, color: accentColor),
      ),
    ];

    return Hero(
      tag: 'lifetime_pnl_card',
      child: Material(
        type: .transparency,
        child: Container(
          width: double.infinity,
          padding: const .all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1E1E), Color(0xFF2A2A2A)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
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
