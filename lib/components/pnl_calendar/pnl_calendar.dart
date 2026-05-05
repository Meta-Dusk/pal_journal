import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:pal_journal/models/monthly_goal.dart';
import 'package:pal_journal/services/currency/currency_service.dart';
import 'package:pal_journal/services/isar_service.dart';
import 'package:pal_journal/utils/formatters.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import './subcomponents/calendar_components.dart';

class PnLCalendar extends StatefulWidget {
  const PnLCalendar({super.key});

  @override
  State<PnLCalendar> createState() => _PnLCalendarState();
}

class _PnLCalendarState extends State<PnLCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, PnLEntry> _dailyEntries = {};
  MonthlyGoal? _currentMonthGoal;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadMonthGoal(_focusedDay);
    _loadPnLData();
  }

  // --- THE NEW SPLIT MATH ENGINE ---

  double get _monthlyExpenses {
    return _dailyEntries.values
        .where(_checkFocusedDateLoss)
        .fold(0.0, (sum, e) => sum + e.amount.abs());
  }

  bool _checkFocusedDateLoss(PnLEntry entry) {
    return entry.date.year == _focusedDay.year &&
        entry.date.month == _focusedDay.month &&
        entry.amount < 0;
  }

  double get _monthlyIncome {
    return _dailyEntries.values
        .where(_checkFocusedDateProfit)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  bool _checkFocusedDateProfit(PnLEntry entry) {
    return entry.date.year == _focusedDay.year &&
        entry.date.month == _focusedDay.month &&
        entry.amount > 0;
  }

  /// Profit naturally goes up and down via algebraic Net PnL!
  /// Returns the true algebraic Net PnL.
  double get _netProfit => _monthlyIncome - _monthlyExpenses;

  Future<void> _loadMonthGoal(DateTime month) async {
    final goal = await IsarService().getGoal(month);
    setState(() => _currentMonthGoal = goal);
  }

  Future<void> _loadPnLData() async {
    final entries = await IsarService().getAllEntries();
    final Map<DateTime, PnLEntry> loadedData = {};
    for (var entry in entries) {
      final normalizedDate = DateTime.utc(
        entry.date.year,
        entry.date.month,
        entry.date.day,
      );
      loadedData[normalizedDate] = entry;
    }

    if (!mounted) return;
    setState(() => _dailyEntries = loadedData);
  }

  PnLEntry? _getEntryForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return _dailyEntries[normalizedDay];
  }

  /// Opens the read-only view
  void _openDetailsSheet(DateTime day) {
    final entry = _getEntryForDay(day);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
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

  /// Opens the editor, and reloads data if the user hit save
  void _openEditSheet(DateTime day) async {
    final entry = _getEntryForDay(day);

    final bool? didDataChange = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: .vertical(top: .circular(20)),
      ),
      builder: (context) => EditSheet(day: day, entry: entry),
    );

    //? If the widget popped with 'true', the user saved or reset data
    if (didDataChange == true) await _loadPnLData();
  }

  void _openMonthSettings() async {
    final shouldClearMonth = await showMonthSettingsDialog(
      context,
      _focusedDay,
    );

    await _loadMonthGoal(_focusedDay);
    if (shouldClearMonth == true) await _loadPnLData();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final tableCalendar = TableCalendar(
      pageJumpingEnabled: true,
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
      calendarBuilders: _calendarBuilders(colors),
    );

    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: .vertical(bottom: .circular(16)),
          ),
          child: tableCalendar,
        ),
        if (_currentMonthGoal != null) ...[
          const SizedBox(height: 16),
          buildMonthlyGoalIndicator(colors),
        ],
      ],
    );
  }

  CalendarBuilders<dynamic> _calendarBuilders(ColorScheme colors) {
    return CalendarBuilders(
      headerTitleBuilder: (context, day) {
        final monthText = DateFormat('yMMMM').format(day);
        final mainContent = [
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
        ];
        return Container(
          decoration: BoxDecoration(
            // color: colors.surfaceContainerHigh,
            borderRadius: .all(.circular(16)),
            border: .all(color: colors.surfaceContainerHigh, width: 2),
          ),
          padding: .symmetric(horizontal: 8),
          child: Row(mainAxisSize: .min, children: mainContent),
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
    );
  }

  Widget buildMonthlyGoalIndicator(ColorScheme colors) {
    if (_currentMonthGoal == null) return const SizedBox.shrink();

    final isBudget = _currentMonthGoal!.type == .budget;

    double target;
    double progress;
    bool isOverBudget = false;
    bool isGoalMet = false;
    Color barColor;
    String label;
    String valueText;

    // The "Unsynced Income" is the total income
    // minus what has already been added to the budget
    final unsyncedIncome = _monthlyIncome - _currentMonthGoal!.syncedOffset;
    final symbol = CurrencyService.symbol;

    if (isBudget) {
      label = "Monthly Budget";
      // The target is visually increased by the synced offset!
      target = _currentMonthGoal!.amount + _currentMonthGoal!.syncedOffset;
      final currentValue = _monthlyExpenses;

      progress = target > 0 ? (currentValue / target).clamp(0.0, 1.0) : 0.0;
      isOverBudget = currentValue > target;
      barColor = isOverBudget ? colors.error : colors.primary;
      valueText =
          "$symbol${_getCurrency(currentValue)} "
          "/ $symbol${_getCurrency(target)}";
    } else {
      label = "Profit Target";
      target = _currentMonthGoal!.amount;
      final currentValue = _netProfit;

      progress = target > 0 ? (currentValue / target).clamp(0.0, 1.0) : 0.0;
      if (currentValue < 0) progress = 0.0;
      isGoalMet = currentValue >= target;
      barColor = isGoalMet ? colors.primary : colors.error;
      valueText =
          "$symbol${_getCurrency(currentValue)} "
          "/ $symbol${_getCurrency(target)}";
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
            valueText,
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

      // --- DYNAMIC NOTIFICATIONS & SYNC BUTTON ---
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
      ] else if (isBudget && unsyncedIncome > 0) ...[
        // The Smart Sync Button!
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () async {
            // Re-save the goal with the new offset
            // (which perfectly equals total income)
            final newGoal = MonthlyGoal()
              ..month = _focusedDay
              ..amount = _currentMonthGoal!.amount
              ..type = .budget
              ..syncedOffset = _monthlyIncome;
            await IsarService().saveGoal(newGoal);
            _loadMonthGoal(_focusedDay); // Refresh the UI instantly
          },
          child: Container(
            padding: const .symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.1),
              borderRadius: .circular(8),
              border: .all(color: colors.primary.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: .min,
              children: [
                Icon(Icons.auto_awesome, color: colors.primary, size: 14),
                const SizedBox(width: 6),
                Text(
                  "Earned +$symbol${_getCurrency(unsyncedIncome)}! "
                  "Tap to add to budget.",
                  style: TextStyle(
                    color: colors.primary,
                    fontSize: 12,
                    fontWeight: .bold,
                  ),
                ),
              ],
            ),
          ),
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

  String _getCurrency(double value) =>
      AppFormatters.toCurrency(CurrencyService.toDisplay(value));
}
