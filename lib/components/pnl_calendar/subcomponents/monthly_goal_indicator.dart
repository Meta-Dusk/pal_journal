import 'package:flutter/material.dart';
import 'package:pal_journal/models/monthly_goal.dart';
import 'package:pal_journal/services/currency/currency_service.dart';
import 'package:pal_journal/utils/formatters.dart';
import 'smart_sync_button.dart';

class MonthlyGoalIndicator extends StatelessWidget {
  final MonthlyGoal goal;
  final double income;
  final double expenses;
  final double netProfit;
  final VoidCallback onSync;

  const MonthlyGoalIndicator({
    super.key,
    required this.goal,
    required this.income,
    required this.expenses,
    required this.netProfit,
    required this.onSync,
  });

  String _format(double value, String symbol) =>
      "$symbol${AppFormatters.toCurrency(CurrencyService.toDisplay(value))}";

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isBudget = goal.type == .budget;
    final symbol = CurrencyService.symbol;

    double target;
    double progress;
    bool isOverBudget = false;
    bool isGoalMet = false;
    Color barColor;
    String label;
    String valueText;

    // Budget Logic (Expenses vs Limit + Income Offset)
    if (isBudget) {
      label = "Monthly Budget";
      target = goal.amount + goal.syncedOffset;
      final current = expenses;
      progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
      isOverBudget = current > target;
      barColor = isOverBudget ? colors.error : colors.primary;
      valueText = "${_format(current, symbol)} / ${_format(target, symbol)}";
    }
    // Profit Logic (Net Profit vs Target)
    else {
      label = "Profit Target";
      target = goal.amount;
      final current = netProfit;
      progress = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
      if (current < 0) progress = 0.0;
      isGoalMet = current >= target;
      barColor = isGoalMet ? colors.primary : colors.secondary;
      valueText = "${_format(current, symbol)} / ${_format(target, symbol)}";
    }

    final unsyncedIncome = income - goal.syncedOffset;

    final mainContent = [
      MonthlyGoalLabel(
        isBudget: isBudget,
        barColor: barColor,
        label: label,
        valueText: valueText,
      ),
      const SizedBox(height: 12),
      ClipRRect(
        borderRadius: .circular(8),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor: colors.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation<Color>(barColor),
        ),
      ),
      ...getDynamicNotifications(isOverBudget, isGoalMet, isBudget, colors),
      if (isBudget && unsyncedIncome > 0) ...[
        const SizedBox(height: 12),
        SmartSyncButton(onSync: onSync, amount: unsyncedIncome, symbol: symbol),
      ],
    ];

    return Padding(
      padding: const .symmetric(horizontal: 16.0, vertical: 8),
      child: Container(
        padding: const .all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: .circular(16),
          border: .all(color: barColor.withValues(alpha: 0.3)),
        ),
        child: Column(crossAxisAlignment: .start, children: mainContent),
      ),
    );
  }
}

List<Widget> getDynamicNotifications(
  bool isOverBudget,
  bool isGoalMet,
  bool isBudget,
  ColorScheme colors,
) {
  return [
    if (isOverBudget) ...[
      const SizedBox(height: 8),
      Text(
        "You have exceeded your monthly budget!",
        style: TextStyle(color: colors.error, fontSize: 12),
      ),
    ] else if (isGoalMet && !isBudget) ...[
      const SizedBox(height: 8),
      Text(
        "You hit your profit target! Awesome!",
        style: TextStyle(color: colors.primary, fontSize: 12),
      ),
    ],
  ];
}

class MonthlyGoalLabel extends StatelessWidget {
  const MonthlyGoalLabel({
    super.key,
    required this.isBudget,
    required this.barColor,
    required this.label,
    required this.valueText,
  });

  final bool isBudget;
  final Color barColor;
  final String label;
  final String valueText;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final leadingLabelContents = [
      Icon(
        isBudget ? Icons.wallet : Icons.trending_up,
        color: barColor,
        size: 20,
      ),
      const SizedBox(width: 8),
      Text(label, style: TextStyle(color: colors.onSurfaceVariant)),
    ];

    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Row(children: leadingLabelContents),
        Text(
          valueText,
          style: TextStyle(color: barColor, fontWeight: .bold),
        ),
      ],
    );
  }
}
