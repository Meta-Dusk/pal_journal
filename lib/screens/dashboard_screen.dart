import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/utils/formatters.dart';
import 'package:pal_journal/main.dart';

class DashboardScreen extends StatefulWidget {
  final double totalAmount;
  final bool isPositive;

  const DashboardScreen({
    super.key,
    required this.totalAmount,
    required this.isPositive,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<PnLEntry> _recentEntries = [];
  bool _isLoading = true;

  final List<Color> _chartColors = [
    Colors.tealAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.orangeAccent,
    Colors.pinkAccent,
    Colors.amberAccent,
    Colors.cyanAccent,
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final isar = await isarService.db;

    // Fetch the last 7 days of data
    final today = DateTime.now();
    final sevenDaysAgo = today.subtract(const Duration(days: 7));

    final entries = await isar
        .collection<PnLEntry>()
        .filter()
        .dateBetween(
          DateTime.utc(sevenDaysAgo.year, sevenDaysAgo.month, sevenDaysAgo.day),
          DateTime.utc(today.year, today.month, today.day),
        )
        .sortByDate()
        .findAll();

    if (mounted) {
      setState(() {
        _recentEntries = entries;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayAmount = AppFormatters.toCurrency(widget.totalAmount.abs());
    final sign = widget.isPositive ? "+" : "-";
    final accentColor = widget.isPositive
        ? Colors.tealAccent
        : Colors.redAccent;

    final heroHeader = Hero(
      tag: 'lifetime_pnl_card',
      child: Material(
        type: .transparency,
        child: Container(
          width: double.infinity,
          padding: const .all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1E1E1E), Color(0xFF2A2A2A)],
              begin: .topLeft,
              end: .bottomRight,
            ),
            borderRadius: .circular(24),
            border: .all(color: accentColor.withValues(alpha: 0.3), width: 1),
          ),
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                const Text(
                  "Lifetime Net PnL",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  "$sign ₱$displayAmount",
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: .bold,
                    color: accentColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final scrollView = SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const .symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            heroHeader,
            const SizedBox(height: 32),

            // --- WEEKLY TREND CHART ---
            const Text(
              "7-Day Trend",
              style: TextStyle(
                fontSize: 20,
                fontWeight: .bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              height: 250,
              width: double.infinity,
              padding: const .all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: .circular(20),
              ),
              child: _recentEntries.isEmpty
                  ? const Center(
                      child: Text(
                        "Not enough data for this week",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : pnlBarChart(),
            ),

            const SizedBox(height: 32),

            // --- CATEGORY BREAKDOWN SECTION ---
            const Text(
              "Breakdown",
              style: TextStyle(
                fontSize: 20,
                fontWeight: .bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _buildPieChart(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );

    final loadingWidget = const Center(
      child: CircularProgressIndicator(color: Colors.tealAccent),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Analytics", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: _isLoading ? loadingWidget : scrollView,
    );
  }

  BarChart pnlBarChart() {
    return BarChart(
      BarChartData(
        alignment: .spaceAround,
        maxY: _getMaxY(), // Dynamic height calculation
        minY: _getMinY(), // Dynamic depth calculation
        // Removes the background grid lines for a cleaner look
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),

        // Formats the labels on the X and Y axes
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
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                if (value.toInt() >= 0 &&
                    value.toInt() < _recentEntries.length) {
                  final date = _recentEntries[value.toInt()].date;
                  // Returns abbreviated day names (Mon, Tue, etc.)
                  return Padding(
                    padding: const .only(top: 8.0),
                    child: Text(
                      DateFormat('EEE').format(date),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),

        // Maps the database entries to the actual visual bars
        barGroups: _recentEntries.asMap().entries.map((entry) {
          final index = entry.key;
          final data = entry.value;
          final isProfit = data.amount >= 0;

          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: data.amount,
                color: isProfit ? Colors.tealAccent : Colors.redAccent,
                width: 16, // Thickness of the bars
                borderRadius: .circular(4),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPieChart() {
    final breakdownData = _getCategoryBreakdown();

    if (breakdownData.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: .circular(20),
        ),
        child: const Center(
          child: Text(
            "No breakdown data available",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Container(
      padding: const .all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: .circular(20),
      ),
      child: Column(
        children: [
          // The Donut Chart
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: breakdownData.entries.toList().asMap().entries.map((
                  mapEntry,
                ) {
                  final index = mapEntry.key;
                  final amount = mapEntry.value.value;
                  final color = _chartColors[index % _chartColors.length];

                  return PieChartSectionData(
                    color: color,
                    value: amount,
                    title: '', // Hidden to keep it clean
                    radius: 50,
                  );
                }).toList(),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // The Clean Legend List
          ...breakdownData.entries.toList().asMap().entries.map((mapEntry) {
            final index = mapEntry.key;
            final category = mapEntry.value.key;
            final amount = mapEntry.value.value;
            final color = _chartColors[index % _chartColors.length];

            return Padding(
              padding: const .only(bottom: 12.0),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(color: color, shape: .circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      category,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                  Text(
                    "₱${AppFormatters.toCurrency(amount)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: .bold,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- Helper Methods for Chart Scaling ---
  // These ensure the chart dynamically resizes whether you made ₱10 or ₱10,000
  double _getMaxY() {
    if (_recentEntries.isEmpty) return 100;
    double max = 0;
    for (var entry in _recentEntries) {
      if (entry.amount > max) max = entry.amount;
    }
    // Add a 20% buffer to the top so bars don't touch the ceiling
    return max > 0 ? max * 1.2 : 100;
  }

  double _getMinY() {
    if (_recentEntries.isEmpty) return 0;
    double min = 0;
    for (var entry in _recentEntries) {
      if (entry.amount < min) min = entry.amount;
    }
    // Add a 20% buffer to the bottom for negative numbers
    return min < 0 ? min * 1.2 : 0;
  }

  // --- Helper Method for Pie Chart ---
  Map<String, double> _getCategoryBreakdown() {
    final Map<String, double> aggregatedData = {};

    for (var entry in _recentEntries) {
      if (entry.breakdown != null) {
        for (var item in entry.breakdown!) {
          final category = item.category != null && item.category!.isNotEmpty
              ? item.category!
              : "Uncategorized";

          // We use .abs() because pie charts deal in physical "slices" of a total,
          // so we treat both incoming and outgoing money as absolute volumes.
          final amount = (item.amount ?? 0.0).abs();

          if (aggregatedData.containsKey(category)) {
            aggregatedData[category] = aggregatedData[category]! + amount;
          } else {
            aggregatedData[category] = amount;
          }
        }
      }
    }

    // Sort so the biggest slices appear first
    final sortedEntries = aggregatedData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries);
  }
}
