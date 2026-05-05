import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:isar/isar.dart';
import 'package:pal_journal/main.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/services/currency/currency_service.dart';
import 'package:pal_journal/utils/formatters.dart';

enum PnLFilter { today, thisWeek, thisMonth, thisYear, custom }

class PnLFilterCard extends StatefulWidget {
  const PnLFilterCard({super.key});

  @override
  State<PnLFilterCard> createState() => _PnLFilterCardState();
}

class _PnLFilterCardState extends State<PnLFilterCard> {
  PnLFilter _selectedFilter = .thisMonth;
  double _filteredSum = 0.0;
  DateTime? _customStart;
  DateTime? _customEnd;

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
      case .today:
        start = DateTime(now.year, now.month, now.day);
        break;
      case .thisWeek:
        // Find the most recent Monday
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case .thisMonth:
        start = DateTime(now.year, now.month, 1);
        break;
      case .thisYear:
        start = DateTime(now.year, 1, 1);
        break;
      case .custom:
        start = _customStart ?? DateTime(now.year, now.month, 1);
        end = _customEnd ?? DateTime(now.year, now.month, now.day, 23, 59, 59);
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

  Future<void> _pickCustomRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: _customStart != null && _customEnd != null
          ? DateTimeRange(start: _customStart!, end: _customEnd!)
          : null,
    );

    if (picked == null) return;
    setState(() {
      _customStart = picked.start;
      //? Ensure end date covers the full final day
      _customEnd = DateTime(
        picked.end.year,
        picked.end.month,
        picked.end.day,
        23,
        59,
        59,
      );
      _selectedFilter = .custom;
    });
    _calculatePnL();
  }

  static String _formattedDate(DateTime date) =>
      DateFormat('MMM d, yyyy').format(date);

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final sign = _filteredSum >= 0 ? '+' : '-';
    final symbol = CurrencyService.symbol;
    final filteredSum = AppFormatters.toCurrency(
      CurrencyService.toDisplay(_filteredSum.abs()),
    );

    final subContent = [
      Text(_getFilterLabel(_selectedFilter), style: textTheme.titleMedium),
      if (_selectedFilter == .custom && _customStart != null)
        Text(
          "${_formattedDate(_customStart!)} - ${_formattedDate(_customEnd!)}",
          style: textTheme.bodySmall,
        ),
    ];

    final mainContent = [
      Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Column(crossAxisAlignment: .start, children: subContent),
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
      onSelected: (filter) => _onSelected(filter),
      itemBuilder: (context) => [
        const PopupMenuItem(value: .today, child: Text("Today")),
        const PopupMenuItem(value: .thisWeek, child: Text("This Week")),
        const PopupMenuItem(value: .thisMonth, child: Text("This Month")),
        const PopupMenuItem(value: .thisYear, child: Text("This Year")),
        const PopupMenuDivider(),
        const PopupMenuItem(value: .custom, child: Text("Custom Range...")),
      ],
    );
  }

  void _onSelected(PnLFilter filter) {
    if (filter == .custom) {
      _pickCustomRange();
    } else {
      setState(() => _selectedFilter = filter);
      _calculatePnL();
    }
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
      case .custom:
        return "Custom PnL";
    }
  }
}
