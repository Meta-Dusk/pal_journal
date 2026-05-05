import 'package:flutter/material.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/services/currency/currency_service.dart';
import 'package:pal_journal/services/isar_service.dart';
import 'package:pal_journal/utils/formatters.dart';

class YearlySummary {
  final int year;
  double income = 0;
  double expenses = 0;

  YearlySummary(this.year);
  double get net => income - expenses;
}

class PnLYearlyView extends StatefulWidget {
  const PnLYearlyView({super.key});

  @override
  State<PnLYearlyView> createState() => _PnLYearlyViewState();
}

class _PnLYearlyViewState extends State<PnLYearlyView> {
  List<YearlySummary> _summaries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadYearlyData();
  }

  Future<void> _loadYearlyData() async {
    final entries = await IsarService().getAllEntries();
    final Map<int, YearlySummary> groupMap = {};

    for (PnLEntry entry in entries) {
      final year = entry.date.year;

      if (!groupMap.containsKey(year)) groupMap[year] = YearlySummary(year);

      if (entry.amount > 0) {
        groupMap[year]!.income += entry.amount;
      } else {
        groupMap[year]!.expenses += entry.amount.abs();
      }
    }

    // Sort by year descending (newest first)
    final sortedList = groupMap.values.toList()
      ..sort((a, b) => b.year.compareTo(a.year));

    if (!mounted) return;
    setState(() {
      _summaries = sortedList;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_summaries.isEmpty) {
      return const Center(child: Text("No data found."));
    }

    return ListView.separated(
      padding: const .all(16),
      itemCount: _summaries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final summary = _summaries[index];
        final isPositive = summary.net >= 0;
        final symbol = CurrencyService.symbol;

        final subContent = [
          Text(
            "Year ${summary.year}",
            style: const TextStyle(fontWeight: .bold, fontSize: 16),
          ),
          Text(
            "Total In: ${_format(summary.income)}\n"
            "Total Out: ${_format(summary.expenses)}",
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
        ];

        final mainContent = [
          _buildYearIcon(summary.year, colors),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: .start, children: subContent),
          ),
          Text(
            "${isPositive ? '+' : '-'} $symbol${_format(summary.net)}",
            style: TextStyle(
              fontWeight: .bold,
              fontSize: 18,
              color: isPositive ? colors.primary : colors.error,
            ),
          ),
        ];

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: .circular(16),
            side: BorderSide(color: colors.outlineVariant),
          ),
          child: Padding(
            padding: const .all(16.0),
            child: Row(children: mainContent),
          ),
        );
      },
    );
  }

  Widget _buildYearIcon(int year, ColorScheme colors) {
    final mainContent = [
      const Icon(Icons.analytics_outlined, size: 16),
      Text(
        year.toString(),
        style: TextStyle(
          color: colors.onSecondaryContainer,
          fontSize: 16,
          fontWeight: .bold,
        ),
      ),
    ];

    return Container(
      padding: const .symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        borderRadius: .circular(12),
      ),
      child: Column(children: mainContent),
    );
  }

  String _format(double value) =>
      AppFormatters.toCurrency(CurrencyService.toDisplay(value));
}
