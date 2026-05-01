import 'package:flutter/material.dart';

import 'package:pal_journal/main.dart';
import 'package:pal_journal/screens/dashboard/dashboard_screen.dart';
import 'package:pal_journal/utils/formatters.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double _lifetimePnL = 0.0;

  @override
  void initState() {
    super.initState();
    _loadLifetimeData();
  }

  Future<void> _loadLifetimeData() async {
    final total = await isarService.getLifetimePnL();
    setState(() {
      _lifetimePnL = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPositive = _lifetimePnL >= 0;
    final displayAmount = AppFormatters.toCurrency(_lifetimePnL.abs());
    final sign = isPositive ? "+" : "-";
    final accentColor = isPositive ? colors.primary : colors.error;

    final lifetimeNetPnlView = SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        children: [
          Text(
            "Lifetime Net PnL",
            style: TextStyle(color: colors.secondary, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            "$sign ₱$displayAmount",
            style: TextStyle(
              fontSize: 36,
              fontWeight: .bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                "Tap for detailed analytics",
                style: TextStyle(color: colors.secondary, fontSize: 12),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: accentColor, size: 14),
            ],
          ),
        ],
      ),
    );

    final hero = Hero(
      tag: 'lifetime_pnl_card',
      // Material is required inside Hero to prevent text rendering glitches
      placeholderBuilder: (context, heroSize, child) {
        return Opacity(opacity: 0.0, child: child);
      },
      child: Material(
        type: .transparency,
        child: Container(
          width: double.infinity,
          padding: const .all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colors.surfaceContainer, colors.surfaceContainerHigh],
              begin: .topLeft,
              end: .bottomRight,
            ),
            borderRadius: .circular(24),
            border: .all(color: accentColor.withValues(alpha: 0.3), width: 1),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: lifetimeNetPnlView,
        ),
      ),
    );

    final heroTransitionHandler = GestureDetector(
      onTap: () async {
        // Navigate to the Dashboard
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              totalAmount: _lifetimePnL,
              isPositive: isPositive,
            ),
          ),
        );
        // Refresh data when we come back, just in case
        _loadLifetimeData();
      },
      child: hero,
    );

    final homeScreenView = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const .all(24.0),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            const Text(
              "Overview",
              style: TextStyle(fontSize: 28, fontWeight: .bold),
            ),
            const SizedBox(height: 24),

            // The Hero Widget connects this card to the Dashboard
            heroTransitionHandler,
          ],
        ),
      ),
    );
    return homeScreenView;
  }
}
