import 'package:flutter/material.dart';
import 'package:isar/isar.dart';

import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/main.dart';
import 'dashboard_header.dart';
import 'weekly_trend_chart.dart';
import 'category_breakdown_chart.dart';

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

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final isar = await isarService.db;

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

    if (!mounted) return;
    setState(() {
      _recentEntries = entries;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Colors.tealAccent),
        ),
      );
    }

    final dashboardContent = [
      DashboardHeader(
        totalAmount: widget.totalAmount,
        isPositive: widget.isPositive,
      ),
      const SizedBox(height: 32),

      const Text(
        "7-Day Trend",
        style: TextStyle(fontSize: 20, fontWeight: .bold, color: Colors.white),
      ),
      const SizedBox(height: 16),
      WeeklyTrendChart(recentEntries: _recentEntries),
      const SizedBox(height: 32),

      const Text(
        "Breakdown",
        style: TextStyle(fontSize: 20, fontWeight: .bold, color: Colors.white),
      ),
      const SizedBox(height: 16),
      CategoryBreakdownChart(recentEntries: _recentEntries),
      const SizedBox(height: 32),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Analytics", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const .symmetric(horizontal: 24.0),
          child: Column(crossAxisAlignment: .start, children: dashboardContent),
        ),
      ),
    );
  }
}
