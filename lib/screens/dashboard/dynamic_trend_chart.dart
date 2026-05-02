import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pal_journal/models/pnl_entry.dart';

class DynamicTrendChart extends StatelessWidget {
  final List<PnLEntry> recentEntries;

  const DynamicTrendChart({super.key, required this.recentEntries});

  double _getMaxY() {
    if (recentEntries.isEmpty) return 100;
    double max = 0;
    for (var entry in recentEntries) {
      if (entry.amount > max) max = entry.amount;
    }
    return max > 0 ? max * 1.2 : 100;
  }

  double _getMinY() {
    if (recentEntries.isEmpty) return 0;
    double min = 0;
    for (var entry in recentEntries) {
      if (entry.amount < min) min = entry.amount;
    }
    return min < 0 ? min * 1.2 : 0;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (recentEntries.isEmpty) {
      return Container(
        height: 250,
        width: double.infinity,
        padding: const .all(16),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: .circular(20),
        ),
        child: Center(
          child: Text(
            "No data for this date range",
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ),
      );
    }

    // --- DYNAMIC GRANULARITY INTERVAL ---
    // If we have 30 days, dividing by 6 gives an interval of 5.
    // It will only show labels for Day 1, Day 6, Day 11, etc.
    final int labelInterval = (recentEntries.length > 7)
        ? (recentEntries.length / 6).ceil()
        : 1;

    final bottomSideTitles = SideTitles(
      showTitles: true,
      // Tell FlChart to respect our mathematical interval
      interval: labelInterval.toDouble(),
      getTitlesWidget: (double value, TitleMeta meta) {
        final index = value.toInt();
        if (index >= 0 && index < recentEntries.length) {
          final date = recentEntries[index].date;
          // If it's a long range, show Date (Oct 12). If short, show Day (Mon).
          final formatStr = recentEntries.length > 14 ? 'MMM d' : 'EEE';

          return Padding(
            padding: const .only(top: 8.0),
            child: Text(
              DateFormat(formatStr).format(date),
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 10),
            ),
          );
        }
        return const Text('');
      },
    );

    return Container(
      height: 250,
      width: double.infinity,
      padding: const .all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: .circular(20),
      ),
      child: BarChart(
        BarChartData(
          alignment: .spaceAround,
          maxY: _getMaxY(),
          minY: _getMinY(),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(sideTitles: bottomSideTitles),
          ),
          barGroups: recentEntries.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;
            final isProfit = data.amount >= 0;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: data.amount,
                  color: isProfit ? Colors.greenAccent : colors.error,
                  width: recentEntries.length > 30
                      ? 4
                      : 16, // Thin the bars out if there are tons of them
                  borderRadius: .circular(4),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
