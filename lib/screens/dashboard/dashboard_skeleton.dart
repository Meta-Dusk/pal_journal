import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    //? We use `Shimmer.fromColors` to wrap the entire layout at once.
    final mainContent = [
      // Dashboard Header Skeleton
      Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: .circular(24),
        ),
      ),
      const SizedBox(height: 24),

      // Filter Chips Skeleton
      Row(
        children: List.generate(
          4,
          (index) => Padding(
            padding: const .only(right: 8.0),
            child: Container(
              height: 32,
              width: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: .circular(16),
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 12),

      // Date Subtitle Skeleton
      Container(height: 14, width: 200, color: Colors.white),
      const SizedBox(height: 24),

      // Quick Insights Grid Skeleton
      Row(
        children: [
          Expanded(child: _buildSkeletonCard()),
          const SizedBox(width: 12),
          Expanded(child: _buildSkeletonCard()),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(child: _buildSkeletonCard()),
          const SizedBox(width: 12),
          Expanded(child: _buildSkeletonCard()),
        ],
      ),
      const SizedBox(height: 32),

      // Trend Chart Skeleton
      Container(height: 24, width: 150, color: Colors.white), // Title
      const SizedBox(height: 16),
      Container(
        height: 250,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: .circular(20),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Analytics"),
        centerTitle: true,
      ),
      body: Shimmer.fromColors(
        baseColor: colors.surfaceContainer,
        highlightColor: colors.surfaceContainerHighest,
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          padding: const .symmetric(horizontal: 24.0),
          child: Column(crossAxisAlignment: .start, children: mainContent),
        ),
      ),
    );
  }

  // Helper for the insight cards
  Widget _buildSkeletonCard() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: .circular(16),
      ),
    );
  }
}
