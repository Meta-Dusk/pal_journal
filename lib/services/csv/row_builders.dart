import 'package:intl/intl.dart';
import 'package:pal_journal/core/data_types.dart';
import 'package:pal_journal/models/monthly_goal.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/models/quantified_goal.dart';

class RowBuilders {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  static Dynamic2DList pnLRows(List<PnLEntry> entries) {
    Dynamic2DList rows = [
      ['Date', 'Daily Total', 'Note', 'Breakdown Category', 'Breakdown Amount'],
    ];

    for (PnLEntry entry in entries) {
      final dateStr = _dateFormat.format(entry.date);
      if (entry.breakdown == null || entry.breakdown!.isEmpty) {
        rows.add([dateStr, entry.amount, entry.note ?? '', '', '']);
      } else {
        for (ExpenseItem item in entry.breakdown!) {
          rows.add([
            dateStr,
            entry.amount,
            entry.note ?? '',
            item.category ?? '',
            item.amount ?? 0.0,
          ]);
        }
      }
    }
    return rows;
  }

  static Dynamic2DList targetGoalRows(List<QuantifiedGoal> targets) {
    Dynamic2DList rows = [
      [
        'Title',
        'Target',
        'Current',
        'Unit',
        'Deadline',
        'Pinned',
        'Completed',
        'Type',
      ],
    ];

    for (QuantifiedGoal target in targets) {
      rows.add([
        target.title,
        target.targetValue,
        target.currentValue,
        target.unit,
        _dateFormat.format(target.deadline),
        target.isPinned ? 1 : 0,
        target.isCompleted ? 1 : 0,
        target.valueType.index, // Save enum as index for easier parsing
      ]);
    }
    return rows;
  }

  static Dynamic2DList monthlyGoalRows(List<MonthlyGoal> monthlyGoals) {
    Dynamic2DList rows = [
      ['Month', 'Type', 'Amount', 'Offset'],
    ];

    for (MonthlyGoal goal in monthlyGoals) {
      rows.add([
        _dateFormat.format(goal.month),
        goal.type.index, // Logic for Profit Target vs Budget
        goal.amount,
        goal.syncedOffset,
      ]);
    }
    return rows;
  }
}
