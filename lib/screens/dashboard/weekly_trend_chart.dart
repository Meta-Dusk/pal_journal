import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pal_journal/models/pnl_entry.dart';

class WeeklyTrendChart extends StatelessWidget {
  final List<PnLEntry> recentEntries;

  const WeeklyTrendChart({super.key, required this.recentEntries});

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
            "Not enough data for this week",
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ),
      );
    }

    final bottomSideTitles = SideTitles(
      showTitles: true,
      getTitlesWidget: (double value, TitleMeta meta) {
        if (value.toInt() >= 0 && value.toInt() < recentEntries.length) {
          final date = recentEntries[value.toInt()].date;
          return Padding(
            padding: const .only(top: 8.0),
            child: Text(
              DateFormat('EEE').format(date),
              style: TextStyle(color: colors.secondary, fontSize: 12),
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
                  width: 16,
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
