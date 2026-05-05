import 'package:flutter/material.dart';
import 'package:pal_journal/components/pnl_calendar/pnl_calendar.dart';
import 'package:pal_journal/components/pnl_calendar/pnl_monthly_view.dart';
import 'package:pal_journal/components/pnl_calendar/pnl_yearly_view.dart';

enum CalendarView { daily, monthly, yearly }

class PnLMainCalendarView extends StatefulWidget {
  const PnLMainCalendarView({super.key});

  @override
  State<PnLMainCalendarView> createState() => _PnLMainCalendarViewState();
}

class _PnLMainCalendarViewState extends State<PnLMainCalendarView> {
  CalendarView _currentView = .daily;

  @override
  Widget build(BuildContext context) {
    return Column(children: [segmentedButtonDisplay(), animatedView()]);
  }

  Expanded animatedView() {
    return Expanded(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: _transitionBuilder,
        child: _buildCurrentView(),
      ),
    );
  }

  Widget _transitionBuilder(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.05),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }

  Padding segmentedButtonDisplay() {
    return Padding(
      padding: const .symmetric(vertical: 8.0),
      child: SegmentedButton<CalendarView>(
        segments: const [
          ButtonSegment(
            value: .daily,
            label: Text('Daily'),
            icon: Icon(Icons.calendar_view_day),
          ),
          ButtonSegment(
            value: .monthly,
            label: Text('Monthly'),
            icon: Icon(Icons.calendar_view_month),
          ),
          ButtonSegment(
            value: .yearly,
            label: Text('Yearly'),
            icon: Icon(Icons.calendar_view_week),
          ),
        ],
        selected: {_currentView},
        onSelectionChanged: (Set<CalendarView> newSelection) {
          setState(() => _currentView = newSelection.first);
        },
      ),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case .daily:
        return const PnLCalendar(key: ValueKey('daily'));
      case .monthly:
        return const PnLMonthlyView(key: ValueKey('monthly'));
      case .yearly:
        return const PnLYearlyView(key: ValueKey('yearly'));
    }
  }
}
