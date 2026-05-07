import 'package:pal_journal/models/pnl_entry.dart';

class PnLStatsEngine {
  final Map<DateTime, PnLEntry> entries;
  final DateTime focusedDay;

  PnLStatsEngine({required this.entries, required this.focusedDay});

  double get monthlyExpenses => entries.values
      .where((e) => _isSameMonth(e.date) && e.amount < 0)
      .fold(0.0, (sum, e) => sum + e.amount.abs());

  double get monthlyIncome => entries.values
      .where((e) => _isSameMonth(e.date) && e.amount > 0)
      .fold(0.0, (sum, e) => sum + e.amount);

  double get netProfit => monthlyIncome - monthlyExpenses;

  bool _isSameMonth(DateTime date) =>
      date.year == focusedDay.year && date.month == focusedDay.month;
}
