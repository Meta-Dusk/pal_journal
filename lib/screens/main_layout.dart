import 'package:flutter/material.dart';
import '../components/target_goal/goal_creation_sheet/goal_creation_sheet.dart';
import '../components/pnl_calendar/edit_sheet.dart';
import '../components/pnl_calendar/pnl_calendar.dart';
import '../components/pnl_calendar/pnl_main_calendar_view.dart';
import '../services/isar_service.dart';
import 'home_screen.dart';
import 'settings/settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  int _homeKeyTrigger = 0;
  late PageController _pageController;
  final GlobalKey<PnLCalendarState> _calendarKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    // Initialize the controller to start on the correct tab
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final List<Widget> screens = [
      HomeScreen(key: ValueKey('home_$_homeKeyTrigger')),
      PnLMainCalendarView(calendarKey: _calendarKey),
      const SettingsScreen(),
    ];

    final navBarItems = const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      BottomNavigationBarItem(
        icon: Icon(Icons.calendar_month),
        label: "Calendar",
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.settings_applications),
        label: "Settings",
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            // Updates the bottom nav bar if the user manually swipes the screen
            setState(() => _currentIndex = index);
          },
          children: screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: colors.surfaceContainer,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.onSurfaceVariant,
        currentIndex: _currentIndex,
        onTap: (index) {
          // Updates the state and animates the page simultaneously
          setState(() => _currentIndex = index);
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        items: navBarItems,
      ),
      floatingActionButton: _currentIndex == 2 ? null : getFAB(colors, context),
    );
  }

  FloatingActionButton getFAB(ColorScheme colors, BuildContext context) {
    return FloatingActionButton(
      backgroundColor: colors.primary,
      onPressed: () {
        if (_currentIndex == 0) {
          _showGoalCreation(context);
        } else if (_currentIndex == 1) {
          _openTodayEditor(context);
        }
      },
      child: Icon(
        _currentIndex == 0 ? Icons.add_task : Icons.edit_calendar_sharp,
        color: colors.onPrimary,
      ),
    );
  }

  void _showGoalCreation(BuildContext context) async {
    final bool? didChange = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const .vertical(top: .circular(24)),
        ),
        child: const GoalCreationSheet(),
      ),
    );

    if (didChange == true) {
      setState(() => _homeKeyTrigger++);
    }
  }

  void _openTodayEditor(BuildContext context) async {
    final today = DateTime.now();
    final existingEntry = await IsarService().getEntryByDate(today);

    if (!context.mounted) return;

    final bool? didChange = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: .vertical(top: .circular(20)),
      ),
      builder: (context) => EditSheet(day: today, entry: existingEntry),
    );

    if (didChange == true) {
      setState(() => _homeKeyTrigger++);

      if (_calendarKey.currentState == null) return;
      _calendarKey.currentState!.refreshAllData();
    }
  }
}
