import 'package:flutter/material.dart';
import 'package:pal_journal/components/app_logo.dart';
import 'package:pal_journal/services/currency/currency_service.dart';
import 'package:pal_journal/utils/formatters.dart';

class DashboardHeader extends StatefulWidget {
  final double totalAmount;
  final bool isPositive;

  const DashboardHeader({
    super.key,
    required this.totalAmount,
    required this.isPositive,
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _gradientController;
  late Animation<double> _breathingAnimation;

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final displayAmount = AppFormatters.toCurrency(
      CurrencyService.toDisplay(widget.totalAmount.abs()),
    );
    final sign = widget.isPositive ? "+" : "-";
    final accentColor = widget.isPositive ? colors.primary : colors.error;

    return Hero(
      tag: 'lifetime_pnl_card',
      placeholderBuilder: (context, heroSize, child) {
        return Opacity(opacity: 0.0, child: child);
      },
      child: Material(
        type: .transparency,
        child: animatedCard(
          colors,
          accentColor,
          headerContent(colors, sign, displayAmount, accentColor),
        ),
      ),
    );
  }

  Column headerContent(
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

    final mainContent = [
      Row(
        crossAxisAlignment: .center,
        children: [lifetimeNetPnlText, const SizedBox(width: 16), AppLogo()],
      ),
      const SizedBox(height: 16),
      Opacity(
        opacity: 0.0,
        child: Row(
          children: [
            Text(
              "Tap for detailed analytics",
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            ),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: accentColor, size: 14),
          ],
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      children: mainContent,
    );
  }

  AnimatedBuilder animatedCard(
    ColorScheme colors,
    Color accentColor,
    Column headerContent,
  ) {
    return AnimatedBuilder(
      animation: _breathingAnimation,
      builder: (context, child) {
        final alignShift = (_breathingAnimation.value * 0.5) - 0.25;
        final gradientColors = [
          colors.surfaceContainer,
          Color.lerp(
            colors.surfaceContainer,
            accentColor.withValues(alpha: 0.15),
            _breathingAnimation.value,
          )!,
          colors.surfaceContainerHighest,
        ];
        final boxDecoration = BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment(alignShift - 1.0, -1.0),
            end: Alignment(alignShift + 1.0, 1.0),
          ),
          borderRadius: .circular(24),
          border: .all(color: accentColor.withValues(alpha: 0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(
                alpha: 0.05 + (_breathingAnimation.value * 0.05),
              ),
              blurRadius: 20 + (_breathingAnimation.value * 10),
              offset: const Offset(0, 10),
            ),
          ],
        );
        return Container(
          width: double.infinity,
          padding: const .all(24),
          decoration: boxDecoration,
          child: child,
        );
      },
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: headerContent,
      ),
    );
  }
}
