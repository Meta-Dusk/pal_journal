import 'package:flutter/material.dart';
import 'package:pal_journal/models/monthly_goal.dart';
import 'package:pal_journal/services/currency_service.dart';
import 'package:pal_journal/utils/formatters.dart';
import 'insight_card.dart';

class QuickInsightsGrid extends StatelessWidget {
  final Map<String, dynamic> insights;
  final String selectedFilter;
  final MonthlyGoal? monthlyGoal;
  final int entryCount;

  const QuickInsightsGrid({
    super.key,
    required this.insights,
    required this.selectedFilter,
    required this.monthlyGoal,
    required this.entryCount,
  });

  @override
  Widget build(BuildContext context) {
    final symbol = CurrencyService.symbol;
    final topRow = Row(
      children: [
        InsightCard(
          title: "Daily Avg",
          value: "$symbol${_getCurrency(insights['avg'])}",
          icon: Icons.show_chart,
        ),
        const SizedBox(width: 12),
        if (selectedFilter == 'MTD' && monthlyGoal != null)
          InsightCard(
            title: monthlyGoal!.type == .budget
                ? "Monthly Budget"
                : "Profit Target",
            value: "$symbol${_getCurrency(monthlyGoal!.amount)}",
            icon: monthlyGoal!.type == .budget
                ? Icons.money_off
                : Icons.trending_up,
          )
        else
          InsightCard(
            title: "Top Expense",
            value: insights['topCat'],
            icon: Icons.shopping_bag_outlined,
          ),
      ],
    );

    final bottomRow = Row(
      children: [
        InsightCard(
          title: "Max Loss in a Day",
          value: "$symbol${_getCurrency(insights['maxLoss'])}",
          icon: Icons.warning_amber_rounded,
          isDanger: true,
        ),
        const SizedBox(width: 12),
        InsightCard(
          title: "Entries",
          value: "$entryCount",
          icon: Icons.receipt_long,
        ),
      ],
    );

    return Column(children: [topRow, const SizedBox(height: 12), bottomRow]);
  }
}

String _getCurrency(double value) =>
    AppFormatters.toCurrency(CurrencyService.toDisplay(value));
