import 'package:flutter/material.dart';
import '../components/pnl_calendar/pnl_main_calendar_view.dart';
import 'home_screen.dart';
import 'settings/settings_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;
  late PageController _pageController;

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
      const HomeScreen(),
      const PnLMainCalendarView(),
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
    );
  }
}
