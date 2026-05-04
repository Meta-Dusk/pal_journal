import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:pal_journal/main.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/services/currency/currency_service.dart';
import 'package:pal_journal/utils/formatters.dart';

enum PnLFilter { today, thisWeek, thisMonth, thisYear }

class PnLFilterCard extends StatefulWidget {
  const PnLFilterCard({super.key});

  @override
  State<PnLFilterCard> createState() => _PnLFilterCardState();
}

class _PnLFilterCardState extends State<PnLFilterCard> {
  PnLFilter _selectedFilter = .thisMonth;
  double _filteredSum = 0.0;

  @override
  void initState() {
    super.initState();
    _calculatePnL();
  }

  Future<void> _calculatePnL() async {
    final now = DateTime.now();
    DateTime start;
    DateTime end = DateTime(now.year, now.month, now.day, 23, 59, 59);

    switch (_selectedFilter) {
      case PnLFilter.today:
        start = DateTime(now.year, now.month, now.day);
        break;
      case PnLFilter.thisWeek:
        // Find the most recent Monday
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case PnLFilter.thisMonth:
        start = DateTime(now.year, now.month, 1);
        break;
      case PnLFilter.thisYear:
        start = DateTime(now.year, 1, 1);
        break;
    }

    final isar = await isarService.db;
    final entries = await isar
        .collection<PnLEntry>()
        .filter()
        .dateBetween(start, end)
        .findAll();

    double sum = 0;
    for (PnLEntry e in entries) {
      sum += e.amount;
    }

    setState(() => _filteredSum = sum);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final sign = _filteredSum >= 0 ? '+' : '-';
    final symbol = CurrencyService.symbol;
    final filteredSum = AppFormatters.toCurrency(
      CurrencyService.toDisplay(_filteredSum.abs()),
    );

    final mainContent = [
      Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Text(
            _getFilterLabel(_selectedFilter),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          _buildFilterPicker(),
        ],
      ),
      const SizedBox(height: 10),
      Text(
        "$sign $symbol$filteredSum",
        style: TextStyle(
          fontSize: 24,
          fontWeight: .bold,
          color: _filteredSum >= 0 ? colors.primary : colors.error,
        ),
      ),
    ];

    return Card(
      shape: const RoundedRectangleBorder(borderRadius: .all(.circular(16))),
      surfaceTintColor: colors.onSurface,
      shadowColor: colors.shadow,
      elevation: 2,
      child: Padding(
        padding: const .all(16.0),
        child: Column(children: mainContent),
      ),
    );
  }

  Widget _buildFilterPicker() {
    return PopupMenuButton<PnLFilter>(
      icon: const Icon(Icons.filter_list),
      onSelected: (filter) {
        setState(() => _selectedFilter = filter);
        _calculatePnL();
      },
      itemBuilder: (context) => [
        const PopupMenuItem(value: .today, child: Text("Today")),
        const PopupMenuItem(value: .thisWeek, child: Text("This Week")),
        const PopupMenuItem(value: .thisMonth, child: Text("This Month")),
        const PopupMenuItem(value: .thisYear, child: Text("This Year")),
      ],
    );
  }

  String _getFilterLabel(PnLFilter filter) {
    switch (filter) {
      case .today:
        return "Today's PnL";
      case .thisWeek:
        return "Weekly PnL";
      case .thisMonth:
        return "Monthly PnL";
      case .thisYear:
        return "Yearly PnL";
    }
  }
}
