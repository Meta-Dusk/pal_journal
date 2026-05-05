import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/services/currency/currency_service.dart';
import 'package:pal_journal/services/isar_service.dart';
import 'package:pal_journal/utils/formatters.dart';

class MonthlySummary {
  final DateTime month;
  double income = 0;
  double expenses = 0;

  MonthlySummary(this.month);

  double get net => income - expenses;
}

class PnLMonthlyView extends StatefulWidget {
  const PnLMonthlyView({super.key});

  @override
  State<PnLMonthlyView> createState() => _PnLMonthlyViewState();
}

class _PnLMonthlyViewState extends State<PnLMonthlyView> {
  List<MonthlySummary> _summaries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMonthlyData();
  }

  Future<void> _loadMonthlyData() async {
    final entries = await IsarService().getAllEntries();
    final Map<String, MonthlySummary> groupMap = {};

    for (PnLEntry entry in entries) {
      // Key format: "2026-05"
      final key = DateFormat('yyyy-MM').format(entry.date);

      if (!groupMap.containsKey(key)) {
        groupMap[key] = MonthlySummary(
          DateTime(entry.date.year, entry.date.month),
        );
      }

      if (entry.amount > 0) {
        groupMap[key]!.income += entry.amount;
      } else {
        groupMap[key]!.expenses += entry.amount.abs();
      }
    }

    // Sort by date descending (newest first)
    final sortedList = groupMap.values.toList()
      ..sort((a, b) => b.month.compareTo(a.month));

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
            DateFormat('MMMM yyyy').format(summary.month),
            style: const TextStyle(fontWeight: .bold, fontSize: 16),
          ),
          Text(
            "In: ${_format(summary.income)}\n"
            "Out: ${_format(summary.expenses)}",
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
        ];

        final mainContent = [
          _buildDateIcon(summary.month, colors),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: .start, children: subContent),
          ),
          Text(
            "${isPositive ? '+' : '-'} $symbol${_format(summary.net.abs())}",
            style: TextStyle(
              fontWeight: FontWeight.bold,
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

  Widget _buildDateIcon(DateTime date, ColorScheme colors) {
    final mainContent = [
      Text(
        DateFormat('MMM').format(date).toUpperCase(),
        style: TextStyle(
          color: colors.onPrimaryContainer,
          fontWeight: .bold,
          fontSize: 12,
        ),
      ),
      Text(
        date.year.toString().substring(2),
        style: TextStyle(
          color: colors.onPrimaryContainer,
          fontSize: 16,
          fontWeight: .bold,
        ),
      ),
    ];

    return Container(
      padding: const .symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: .circular(12),
      ),
      child: Column(children: mainContent),
    );
  }

  String _format(double value) =>
      AppFormatters.toCurrency(CurrencyService.toDisplay(value));
}
