import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'package:pal_journal/services/goal_service.dart';
import 'package:pal_journal/utils/formatters.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/main.dart';
import 'subcomponents/calendar_components.dart';

class PnLCalendar extends StatefulWidget {
  const PnLCalendar({super.key});

  @override
  State<PnLCalendar> createState() => _PnLCalendarState();
}

class _PnLCalendarState extends State<PnLCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, PnLEntry> _dailyEntries = {};
  GoalData? _currentMonthGoal;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadMonthGoal(_focusedDay);
    _loadPnLData();
  }

  /// Smarter calculation that respects the current focused month and goal type
  double _calculateMonthlyProgress() {
    if (_currentMonthGoal == null) return 0.0;
    double total = 0.0;

    for (var entry in _dailyEntries.values) {
      // FIX 1: Only check entries belonging to the currently viewed month!
      if (entry.date.year == _focusedDay.year &&
          entry.date.month == _focusedDay.month) {
        if (_currentMonthGoal!.type == .budget && entry.amount < 0) {
          // Budgets sum up losses (absolute value)
          total += entry.amount.abs();
        } else if (_currentMonthGoal!.type == .profit) {
          // Profit goals sum up Net PnL (combining wins and losses)
          total += entry.amount;
        }
      }
    }
    return total;
  }

  Future<void> _loadMonthGoal(DateTime month) async {
    final goal = await GoalService.getGoal(month);
    setState(() => _currentMonthGoal = goal);
  }

  Future<void> _loadPnLData() async {
    final isar = await isarService.db;
    final entries = await isar.collection<PnLEntry>().where().findAll();

    final Map<DateTime, PnLEntry> loadedData = {};
    for (var entry in entries) {
      final normalizedDate = DateTime.utc(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      loadedData[normalizedDate] = entry;
    }

    setState(() {
      _dailyEntries = loadedData;
    });
  }

  PnLEntry? _getEntryForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _dailyEntries[normalizedDay];
  }

  // Opens the read-only view
  void _openDetailsSheet(DateTime day) {
    final entry = _getEntryForDay(day);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: .vertical(top: .circular(20)),
      ),
      builder: (context) => DetailsSheet(
        day: day,
        entry: entry,
        onEditPressed: () {
          Navigator.pop(context); // Close details
          _openEditSheet(day); // Open editor immediately
        },
      ),
    );
  }

  // Opens the editor, and reloads data if the user hit save
  void _openEditSheet(DateTime day) async {
    final entry = _getEntryForDay(day);

    final bool? didDataChange = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: .vertical(top: .circular(20)),
      ),
      builder: (context) => EditSheet(day: day, entry: entry),
    );

    //? If the widget popped with 'true', the user saved or reset data
    if (didDataChange == true) {
      await _loadPnLData();
    }
  }

  void _openMonthSettings() async {
    final shouldClearMonth = await showMonthSettingsDialog(
      context,
      _focusedDay,
    );

    await _loadMonthGoal(_focusedDay);

    if (shouldClearMonth == true) {
      await _loadPnLData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final tableCalendar = TableCalendar(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),

      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        _openDetailsSheet(selectedDay);
      },

      onDayLongPressed: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        _openEditSheet(selectedDay);
      },

      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
          _loadMonthGoal(focusedDay);
        });
      },

      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: false,
        leftChevronIcon: Icon(Icons.chevron_left, color: colors.onSurface),
        rightChevronIcon: Icon(Icons.chevron_right, color: colors.onSurface),
        titleTextStyle: TextStyle(fontSize: 18, color: colors.onSurface),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(color: colors.onSurfaceVariant),
        weekendStyle: TextStyle(color: colors.onSurfaceVariant),
      ),
      calendarBuilders: CalendarBuilders(
        headerTitleBuilder: (context, day) {
          final monthText = DateFormat('yMMMM').format(day);
          return Row(
            mainAxisSize: .min,
            children: [
              Text(
                monthText,
                style: TextStyle(
                  color: colors.onSurface,
                  fontSize: 18,
                  fontWeight: .bold,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.settings_outlined,
                  color: colors.onSurfaceVariant,
                  size: 20,
                ),
                onPressed: _openMonthSettings,
                splashRadius: 20, // Keeps the ripple effect tight
              ),
            ],
          );
        },
        defaultBuilder: (context, day, focusedDay) =>
            CustomDayCell(day: day, entry: _getEntryForDay(day)),
        todayBuilder: (context, day, focusedDay) =>
            CustomDayCell(day: day, entry: _getEntryForDay(day), isToday: true),
        selectedBuilder: (context, day, focusedDay) => CustomDayCell(
          day: day,
          entry: _getEntryForDay(day),
          isSelected: true,
        ),
        outsideBuilder: (context, day, focusedDay) => Center(
          child: Text(
            '${day.day}',
            style: TextStyle(color: colors.onSurface.withValues(alpha: 0.3)),
          ),
        ),
      ),
    );

    return Column(
      children: [
        tableCalendar,
        if (_currentMonthGoal != null) ...[
          const SizedBox(height: 16),
          buildMonthlyGoalIndicator(colors),
        ],
      ],
    );
  }

  Widget buildMonthlyGoalIndicator(ColorScheme colors) {
    if (_currentMonthGoal == null) return const SizedBox.shrink();

    final target = _currentMonthGoal!.amount;
    final isBudget = _currentMonthGoal!.type == .budget;

    // We get the specific calculated value based on the Goal Type
    final currentValue = _calculateMonthlyProgress();

    double progress;
    bool isOverBudget = false;
    bool isGoalMet = false;
    Color barColor;
    String label;

    if (isBudget) {
      label = "Monthly Budget";
      progress = target > 0 ? (currentValue / target).clamp(0.0, 1.0) : 0.0;
      isOverBudget = currentValue > target;
      barColor = isOverBudget ? colors.error : colors.primary;
    } else {
      label = "Profit Target";
      progress = target > 0 ? (currentValue / target).clamp(0.0, 1.0) : 0.0;
      // If currentValue is negative (they are at a net loss), progress is 0.
      if (currentValue < 0) progress = 0.0;
      isGoalMet = currentValue >= target;
      barColor = isGoalMet ? Colors.greenAccent : colors.primary;
    }

    final mainContent = [
      Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                isBudget ? Icons.money_off : Icons.trending_up,
                color: barColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: colors.onSurfaceVariant)),
            ],
          ),
          Text(
            "₱${AppFormatters.toCurrency(currentValue)} "
            "/ ₱${AppFormatters.toCurrency(target)}",
            style: TextStyle(color: barColor, fontWeight: .bold, fontSize: 14),
          ),
        ],
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
      if (isOverBudget) ...[
        const SizedBox(height: 8),
        Text(
          "You have exceeded your monthly budget!",
          style: TextStyle(color: colors.error, fontSize: 12),
        ),
      ] else if (isGoalMet) ...[
        const SizedBox(height: 8),
        Text(
          "You hit your profit target! Awesome!",
          style: TextStyle(color: Colors.greenAccent, fontSize: 12),
        ),
      ],
    ];

    return Padding(
      padding: const .symmetric(horizontal: 16.0),
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
