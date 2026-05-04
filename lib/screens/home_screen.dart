import 'package:flutter/material.dart';

import 'package:pal_journal/main.dart';
import 'package:pal_journal/screens/dashboard/dashboard_screen.dart';
import 'package:pal_journal/services/currency/currency_service.dart';
import 'package:pal_journal/utils/formatters.dart';
import 'package:pal_journal/core/images.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  double _lifetimePnL = 0.0;

  late AnimationController _gradientController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
    _loadLifetimeData();

    // Initialize the breathing animation
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _breathingAnimation = CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  Future<void> _loadLifetimeData() async {
    final total = await isarService.getLifetimePnL();
    setState(() => _lifetimePnL = total);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isPositive = _lifetimePnL >= 0;
    final displayAmount = AppFormatters.toCurrency(
      CurrencyService.toDisplay(_lifetimePnL.abs()),
    );
    final sign = isPositive ? "+" : "-";
    final accentColor = isPositive ? colors.primary : colors.error;

    final hero = Hero(
      tag: 'lifetime_pnl_card',
      placeholderBuilder: (context, heroSize, child) {
        return Opacity(opacity: 0.0, child: child);
      },
      child: Material(
        type: .transparency,
        child: animatedCard(colors, accentColor, sign, displayAmount),
      ),
    );

    final heroTransitionHandler = GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              totalAmount: _lifetimePnL,
              isPositive: isPositive,
            ),
          ),
        );
        _loadLifetimeData();
      },
      child: hero,
    );

    final mainContent = [
      Text(
        "Overview",
        style: TextStyle(
          fontSize: 28,
          fontWeight: .bold,
          color: colors.onSurface,
        ),
      ),
      const SizedBox(height: 24),
      heroTransitionHandler,
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const .all(24.0),
        child: Column(crossAxisAlignment: .start, children: mainContent),
      ),
    );
  }

  AnimatedBuilder animatedCard(
    ColorScheme colors,
    Color accentColor,
    String sign,
    String displayAmount,
  ) {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        // Calculate a slight alignment shift to make the gradient "sweep"
        final alignShift = (_breathingAnimation.value * 0.5) - 0.25;

        final linearGradient = LinearGradient(
          colors: [
            colors.surfaceContainer,
            Color.lerp(
              colors.surfaceContainer,
              accentColor.withValues(alpha: 0.15),
              _breathingAnimation.value,
            )!,
            colors.surfaceContainerHighest,
          ],
          begin: Alignment(alignShift - 1.0, -1.0),
          end: Alignment(alignShift + 1.0, 1.0),
        );

        final boxShadows = [
          BoxShadow(
            color: accentColor.withValues(
              alpha: 0.05 + (_breathingAnimation.value * 0.05),
            ),
            blurRadius: 20 + (_breathingAnimation.value * 10),
            offset: const Offset(0, 10),
          ),
        ];

        return Container(
          width: double.infinity,
          padding: const .all(24),
          decoration: BoxDecoration(
            gradient: linearGradient,
            borderRadius: .circular(24),
            border: .all(color: accentColor.withValues(alpha: 0.3), width: 1),
            boxShadow: boxShadows,
          ),
          child: child,
        );
      },
      child: lifetimeNetPnlView(colors, sign, displayAmount, accentColor),
    );
  }

  SingleChildScrollView lifetimeNetPnlView(
    ColorScheme colors,
    String sign,
    String displayAmount,
    Color accentColor,
  ) {
    final symbol = CurrencyService.symbol;

    final lifetimeNetPnlText = Expanded(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Text(
            "Lifetime Net PnL",
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
          ),
          const SizedBox(height: 8),
          // FittedBox ensures giant numbers shrink dynamically
          FittedBox(
            fit: .scaleDown,
            alignment: .centerLeft,
            child: Text(
              "$sign $symbol$displayAmount",
              style: TextStyle(
                fontSize: 36,
                fontWeight: .bold,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );

    final image = Image.asset(
      ImageAssets.icon,
      width: 80,
      height: 80,
      fit: .contain,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.1),
            shape: .circle,
          ),
          child: Icon(Icons.pets, color: accentColor, size: 40),
        );
      },
    );

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        children: [
          Row(
            crossAxisAlignment: .center,
            children: [lifetimeNetPnlText, const SizedBox(width: 16), image],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                "Tap for detailed analytics",
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
              ),
              const Spacer(),
              Icon(Icons.arrow_forward_ios, color: accentColor, size: 14),
            ],
          ),
        ],
      ),
    );
  }
}
