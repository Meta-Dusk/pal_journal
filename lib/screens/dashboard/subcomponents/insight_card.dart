import 'package:flutter/material.dart';

class InsightCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final bool isDanger;

  const InsightCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final mainContent = [
      Row(
        children: [
          Icon(icon, size: 16, color: isDanger ? colors.error : colors.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text(
        value,
        style: TextStyle(
          color: isDanger ? colors.error : colors.onSurface,
          fontSize: 16,
          fontWeight: .bold,
        ),
        maxLines: 1,
        overflow: .ellipsis,
      ),
    ];

    return Expanded(
      child: Container(
        padding: const .all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: .circular(16),
        ),
        child: Column(crossAxisAlignment: .start, children: mainContent),
      ),
    );
  }
}
