import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/utils/formatters.dart';

class CategoryBreakdownChart extends StatefulWidget {
  final List<PnLEntry> recentEntries;

  const CategoryBreakdownChart({super.key, required this.recentEntries});

  @override
  State<CategoryBreakdownChart> createState() => _CategoryBreakdownChartState();
}

class _CategoryBreakdownChartState extends State<CategoryBreakdownChart> {
  /// Keeps track of categories the user has clicked to hide
  final Set<String> _hiddenCategories = {};

  Map<String, double> _getCategoryBreakdown() {
    final Map<String, double> aggregatedData = {};

    for (var entry in widget.recentEntries) {
      if (entry.breakdown == null) continue;
      for (var item in entry.breakdown!) {
        final category = item.category != null && item.category!.isNotEmpty
            ? item.category!
            : "Uncategorized";

        // --- THE FILTER ---
        if (_hiddenCategories.contains(category)) continue;

        final amount = (item.amount ?? 0.0).abs();

        if (aggregatedData.containsKey(category)) {
          aggregatedData[category] = aggregatedData[category]! + amount;
        } else {
          aggregatedData[category] = amount;
        }
      }
    }

    final sortedEntries = aggregatedData.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return Map.fromEntries(sortedEntries);
  }

  /// Get ALL unique categories so we can build the toggle buttons.
  List<String> _getAllUniqueCategories() {
    final Set<String> allCats = {};
    for (var entry in widget.recentEntries) {
      for (var item in entry.breakdown ?? []) {
        allCats.add(item.category ?? "Uncategorized");
      }
    }
    return allCats.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final breakdownData = _getCategoryBreakdown();
    final allCategories = _getAllUniqueCategories();

    final List<Color> dynamicChartColors = [
      colors.primary,
      colors.secondary,
      colors.tertiary,
      colors.primaryContainer,
      colors.secondaryContainer,
      colors.tertiaryContainer,
    ];

    if (allCategories.isEmpty) {
      return Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: .circular(20),
        ),
        child: Center(
          child: Text(
            "No breakdown data available",
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
        ),
      );
    }

    final breakdownDataEntries = SizedBox(
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
            final color = dynamicChartColors[index % dynamicChartColors.length];
            return PieChartSectionData(
              color: color,
              value: amount,
              title: '',
              radius: 50,
            );
          }).toList(),
        ),
      ),
    );

    final mainContent = [
      Container(
        padding: const .all(24),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: .circular(20),
        ),
        child: Column(
          children: [
            if (breakdownData.isNotEmpty)
              breakdownDataEntries
            else
              const SizedBox(
                height: 200,
                child: Center(child: Text("All categories hidden")),
              ),

            const SizedBox(height: 24),
            ...breakdownData.entries.toList().asMap().entries.map((mapEntry) {
              final index = mapEntry.key;
              final category = mapEntry.value.key;
              final amount = mapEntry.value.value;
              final color =
                  dynamicChartColors[index % dynamicChartColors.length];

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
                        style: TextStyle(color: colors.onSurface, fontSize: 14),
                      ),
                    ),
                    Text(
                      "₱${AppFormatters.toCurrency(amount)}",
                      style: TextStyle(
                        color: colors.onSurface,
                        fontWeight: .bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      const SizedBox(height: 16),

      // --- EXCLUSION TOGGLES ---
      Text(
        "Filter Categories",
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
      ),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8.0,
        runSpacing: 8.0,
        children: allCategories.map((category) {
          final isHidden = _hiddenCategories.contains(category);
          return FilterChip(
            label: Text(
              category,
              style: TextStyle(
                fontSize: 12,
                color: isHidden ? colors.onSurfaceVariant : colors.onPrimary,
              ),
            ),
            selected: !isHidden,
            showCheckmark: false,
            selectedColor: colors.primary,
            backgroundColor: colors.surfaceContainerHighest,
            onSelected: (bool selected) {
              setState(() {
                if (selected) {
                  _hiddenCategories.remove(category);
                } else {
                  _hiddenCategories.add(category);
                }
              });
            },
          );
        }).toList(),
      ),
    ];

    return Column(crossAxisAlignment: .start, children: mainContent);
  }
}
