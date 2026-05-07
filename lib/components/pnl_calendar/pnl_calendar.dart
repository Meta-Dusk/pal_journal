import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:pal_journal/models/data_models.dart';
import 'package:pal_journal/services/isar_service.dart';
import './subcomponents/calendar_components.dart';

class PnLCalendar extends StatefulWidget {
  const PnLCalendar({super.key});

  @override
  State<PnLCalendar> createState() => PnLCalendarState();
}

class PnLCalendarState extends State<PnLCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, PnLEntry> _dailyEntries = {};
  MonthlyGoal? _currentMonthGoal;
  Map<DateTime, List<QuantifiedGoal>> _goalDeadlines = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadMonthGoal(_focusedDay);
    _loadAllData();
  }

  void refreshAllData() async {
    await _loadAllData();
    await _loadMonthGoal(_focusedDay);
    if (mounted) setState(() {});
  }

  static DateTime _normalizeDate(DateTime date) =>
      DateTime.utc(date.year, date.month, date.day);

  Future<void> _loadMonthGoal(DateTime date) async {
    final normalizedMonth = DateTime(date.year, date.month, 1);
    final goal = await IsarService().getGoal(normalizedMonth);
    setState(() => _currentMonthGoal = goal);
  }

  Future<void> _loadPnLData() async {
    final entries = await IsarService().getAllEntries();
    final Map<DateTime, PnLEntry> loadedData = {};
    for (PnLEntry entry in entries) {
      final normalizedDate = _normalizeDate(entry.date);
      loadedData[normalizedDate] = entry;
    }

    if (mounted) setState(() => _dailyEntries = loadedData);
  }

  Future<void> _loadAllData() async {
    await _loadPnLData();
    final allGoals = await IsarService().getAllQuantifiedGoals();
    final Map<DateTime, List<QuantifiedGoal>> loadedGoals = {};

    for (QuantifiedGoal goal in allGoals) {
      final normalizedDate = _normalizeDate(goal.deadline);
      loadedGoals.putIfAbsent(normalizedDate, () => []).add(goal);
    }

    if (mounted) setState(() => _goalDeadlines = loadedGoals);
  }

  PnLEntry? _getEntryForDay(DateTime day) => _dailyEntries[_normalizeDate(day)];

  List<QuantifiedGoal>? _getQuantifiedGoalForDay(DateTime day) =>
      _goalDeadlines[_normalizeDate(day)];

  /// Opens the read-only view
  void _openDetailsSheet(DateTime day) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: .vertical(top: .circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final entry = _getEntryForDay(day);
          final goals = _getQuantifiedGoalForDay(day);

          return DetailsSheet(
            day: day,
            entry: entry,
            goals: goals,
            onEditPressed: () {
              Navigator.pop(context);
              _openEditSheet(day);
            },
            onRefresh: () async {
              await _loadAllData();
              setSheetState(() {});
            },
          );
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
    if (didDataChange == true) await _loadAllData();
  }

  void _openMonthSettings() async {
    final shouldClearMonth = await showMonthSettingsDialog(
      context,
      _focusedDay,
    );

    await _loadMonthGoal(_focusedDay);
    if (shouldClearMonth == true) await _loadAllData();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final stats = PnLStatsEngine(
      entries: _dailyEntries,
      focusedDay: _focusedDay,
    );

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
            borderRadius: .all(.circular(16)),
          ),
          child: tableCalendar,
        ),
        if (_currentMonthGoal != null) ...[
          const SizedBox(height: 16),
          MonthlyGoalIndicator(
            goal: _currentMonthGoal!,
            income: stats.monthlyIncome,
            expenses: stats.monthlyExpenses,
            netProfit: stats.netProfit,
            onSync: () => _handleSmartSync(stats),
          ),
        ],
      ],
    );
  }

  void _handleSmartSync(PnLStatsEngine stats) async {
    final totalIncome = stats.monthlyIncome;
    final newGoal = _currentMonthGoal!
      ..month = DateTime.utc(_focusedDay.year, _focusedDay.month, 1)
      ..syncedOffset = totalIncome;

    await IsarService().saveGoal(newGoal);
    await _loadMonthGoal(_focusedDay);
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
      defaultBuilder: (context, day, focusedDay) => CustomDayCell(
        day: day,
        entry: _getEntryForDay(day),
        hasGoal: _checkHasGoal(day),
      ),
      todayBuilder: (context, day, focusedDay) => CustomDayCell(
        day: day,
        entry: _getEntryForDay(day),
        isToday: true,
        hasGoal: _checkHasGoal(day),
      ),
      selectedBuilder: (context, day, focusedDay) => CustomDayCell(
        day: day,
        entry: _getEntryForDay(day),
        isSelected: true,
        hasGoal: _checkHasGoal(day),
      ),
      outsideBuilder: (context, day, focusedDay) => Center(
        child: Text(
          '${day.day}',
          style: TextStyle(color: colors.onSurface.withValues(alpha: 0.3)),
        ),
      ),
    );
  }

  bool _checkHasGoal(DateTime day) =>
      _goalDeadlines[_normalizeDate(day)]?.isNotEmpty ?? false;
}
