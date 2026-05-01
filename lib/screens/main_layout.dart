import 'package:flutter/material.dart';
import 'package:pal_journal/screens/home_screen.dart';
import 'package:pal_journal/components/pnl_calendar/pnl_calendar.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  // NEW: The controller that handles the sliding animation
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    // Initialize the controller to start on the correct tab
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    // Always dispose controllers to prevent memory leaks!
    _pageController.dispose();
    super.dispose();
  }

  final List<Widget> _screens = [const HomeScreen(), const PnLCalendar()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const BouncingScrollPhysics(),
          onPageChanged: (index) {
            // Updates the bottom nav bar if the user manually swipes the screen
            setState(() {
              _currentIndex = index;
            });
          },
          children: _screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: Colors.tealAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (index) {
          // Updates the state and animates the page simultaneously
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(
              milliseconds: 300,
            ), // The speed of the transition
            curve: Curves.easeInOut,
          );
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: "Calendar",
          ),
        ],
      ),
    );
  }
}
