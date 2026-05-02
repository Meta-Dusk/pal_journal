import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:intl/intl.dart';

import 'package:pal_journal/main.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/services/goal_service.dart';
import 'subcomponents/components.dart';

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
  GoalData? _monthlyGoal;

  String _selectedFilter = '7D';
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _setFilter('7D'); // Initialize with the last 7 days
  }

  /// Maps our logic keys to user-friendly verbose labels.
  final Map<String, String> _filterLabels = {
    '7D': 'Last 7 Days',
    '30D': 'Last 30 Days',
    'MTD': 'This Month',
    'YTD': 'This Year',
    'Custom': 'Custom Range',
  };

  /// Generates a readable description of the current timeframe.
  String _getDateRangeString() {
    final format = DateFormat('MMM d, yyyy');
    final text =
        "Showing data from ${format.format(_startDate)} "
        "to ${format.format(_endDate)}";
    return text;
  }

  /// Handles the Smart Date Range Picker logic.
  Future<void> _setFilter(String filter) async {
    final now = DateTime.now();
    DateTime start;
    DateTime end = now;

    if (filter == '7D') {
      start = now.subtract(const Duration(days: 7));
    } else if (filter == '30D') {
      start = now.subtract(const Duration(days: 30));
    } else if (filter == 'MTD') {
      start = DateTime(now.year, now.month, 1);
      // Push end to the exact last microsecond of the current month
      end = DateTime(
        now.year,
        now.month + 1,
        1,
      ).subtract(const Duration(microseconds: 1));
    } else if (filter == 'YTD') {
      start = DateTime(now.year, 1, 1);
      // YTD should also go to the absolute end of the current day
      end = DateTime(
        now.year,
        now.month,
        now.day + 1,
      ).subtract(const Duration(microseconds: 1));
    } else {
      // Custom Date Range Picker
      final picked = await showDateRangePicker(
        context: context,
        firstDate: now.subtract(const Duration(days: 365)),
        lastDate: now.add(const Duration(days: 365)),
        initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(
              context,
            ).copyWith(colorScheme: Theme.of(context).colorScheme),
            child: child!,
          );
        },
      );
      if (picked != null) {
        start = picked.start;
        end = picked.end;
        filter = 'Custom';
      } else {
        return; // User canceled
      }
    }

    GoalData? goal;
    if (filter == 'MTD') {
      goal = await GoalService.getGoal(start);
    }

    setState(() {
      _selectedFilter = filter;
      _startDate = start;
      _endDate = end;
      _monthlyGoal = goal;
      _isLoading = true;
    });

    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final isar = await isarService.db;

    final entries = await isar
        .collection<PnLEntry>()
        .filter()
        .dateBetween(
          DateTime.utc(_startDate.year, _startDate.month, _startDate.day),
          DateTime.utc(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59),
        )
        .sortByDate()
        .findAll();

    //? Uncomment for testing the UI skeleton
    // await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    setState(() {
      _recentEntries = entries;
      _isLoading = false;
    });
  }

  /// Analyzes the current data to generate Quick Insights.
  Map<String, dynamic> _calculateInsights() {
    double totalExpense = 0;
    double maxLoss = 0;
    Map<String, double> catTotals = {};

    for (var entry in _recentEntries) {
      if (entry.amount < maxLoss) maxLoss = entry.amount;
      for (var item in entry.breakdown ?? []) {
        final cat = item.category ?? "Unknown";
        final amt = (item.amount ?? 0.0).abs();
        catTotals[cat] = (catTotals[cat] ?? 0) + amt;
        totalExpense += amt;
      }
    }

    String topCategory = "N/A";
    if (catTotals.isNotEmpty) {
      var sorted = catTotals.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      topCategory = sorted.first.key;
    }

    int days = _endDate.difference(_startDate).inDays;
    if (days == 0) days = 1; // Prevent division by zero
    final dailyAvg = totalExpense / days;

    return {'avg': dailyAvg, 'topCat': topCategory, 'maxLoss': maxLoss.abs()};
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const DashboardSkeleton();
    }

    final insights = _calculateInsights();

    final smartDateFilter = Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: _filterLabels.entries.map((entry) {
        final filterKey = entry.key;
        final label = entry.value;
        final isSelected = _selectedFilter == filterKey;

        return FilterChip(
          label: Text(label),
          selected: isSelected,
          showCheckmark: false,
          onSelected: (_) => _setFilter(filterKey),
          selectedColor: colors.primaryContainer,
          backgroundColor: colors.surfaceContainerHighest,
          side: BorderSide.none,
          labelStyle: TextStyle(
            color: isSelected
                ? colors.onPrimaryContainer
                : colors.onSurfaceVariant,
            fontWeight: isSelected ? .bold : .normal,
          ),
        );
      }).toList(),
    );

    final dynamicHelperText = Row(
      children: [
        Icon(Icons.calendar_today, size: 14, color: colors.primary),
        const SizedBox(width: 6),
        Text(
          _getDateRangeString(),
          style: TextStyle(
            color: colors.primary,
            fontSize: 12,
            fontWeight: .w500,
          ),
        ),
      ],
    );

    final mainContent = [
      DashboardHeader(
        totalAmount: widget.totalAmount,
        isPositive: widget.isPositive,
      ),
      const SizedBox(height: 24),
      smartDateFilter,
      const SizedBox(height: 12),
      dynamicHelperText,
      const SizedBox(height: 24),

      // --- QUICK INSIGHTS CARDS ---
      QuickInsightsGrid(
        insights: insights,
        selectedFilter: _selectedFilter,
        monthlyGoal: _monthlyGoal,
        entryCount: _recentEntries.length,
      ),
      const SizedBox(height: 32),

      // --- DYNAMIC CHARTS ---
      Text(
        "Trend Over Time",
        style: TextStyle(
          fontSize: 20,
          fontWeight: .bold,
          color: colors.onSurface,
        ),
      ),
      const SizedBox(height: 16),
      DynamicTrendChart(recentEntries: _recentEntries),
      const SizedBox(height: 32),

      Text(
        "Category Breakdown",
        style: TextStyle(
          fontSize: 20,
          fontWeight: .bold,
          color: colors.onSurface,
        ),
      ),
      const SizedBox(height: 16),
      CategoryBreakdownChart(recentEntries: _recentEntries),
      const SizedBox(height: 48),
    ];

    // --- NEW TABBED LAYOUT ---
    return DefaultTabController(
      length: 2, // We have two tabs now!
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text("Analytics"),
          centerTitle: true,
          // 1. Add the TabBar to the bottom of the AppBar
          bottom: TabBar(
            indicatorColor: colors.primary,
            labelColor: colors.primary,
            unselectedLabelColor: colors.onSurfaceVariant,
            tabs: const [
              Tab(text: "Overview", icon: Icon(Icons.dashboard)),
              Tab(text: "Categories", icon: Icon(Icons.category)),
            ],
          ),
        ),
        // 2. Wrap your views in a TabBarView!
        body: TabBarView(
          children: [
            // TAB 1: The original Overview content
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const .symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: .start,
                  children: mainContent,
                ),
              ),
            ),

            // TAB 2: The new Granular Analytics tool
            const Padding(
              padding: .only(top: 16.0), // Give it a little breathing room
              child: CategoryAnalyticsView(),
            ),
          ],
        ),
      ),
    );
  }
}
