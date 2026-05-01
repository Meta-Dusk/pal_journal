import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/main.dart';
import 'custom_day_cell.dart';
import 'details_sheet.dart';
import 'edit_sheet.dart';
import 'month_settings_dialog.dart';

class PnLCalendar extends StatefulWidget {
  const PnLCalendar({super.key});

  @override
  State<PnLCalendar> createState() => _PnLCalendarState();
}

class _PnLCalendarState extends State<PnLCalendar> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, PnLEntry> _dailyEntries = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadPnLData();
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

    if (shouldClearMonth == true) {
      await _loadPnLData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return TableCalendar(
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
  }
}
