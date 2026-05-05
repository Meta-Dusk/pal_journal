import 'package:flutter/material.dart';
import 'package:pal_journal/core/images.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: colors.primaryContainer.withValues(alpha: 0.3),
        shape: .circle,
        border: .all(
          width: 1,
          color: colors.onPrimaryContainer.withValues(alpha: 0.3),
        ),
      ),
      child: ClipOval(
        child: Image.asset(
          ImageAssets.icon,
          width: 80,
          height: 80,
          fit: .contain,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.pets),
          colorBlendMode: .srcIn,
          color: colors.primary,
        ),
      ),
    );
  }
}
