import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:pal_journal/utils/formatters.dart';
import 'package:pal_journal/services/currency_service.dart';
import 'package:pal_journal/services/isar_service.dart';
import 'package:pal_journal/models/pnl_entry.dart';
import 'package:pal_journal/utils/default_data.dart';

class CategoryAnalyticsView extends StatefulWidget {
  const CategoryAnalyticsView({super.key});

  @override
  State<CategoryAnalyticsView> createState() => _CategoryAnalyticsViewState();
}

class _CategoryAnalyticsViewState extends State<CategoryAnalyticsView> {
  List<String> _categories = [];
  String? _selectedCategory;

  bool _isLoading = true;
  double _categoryTotal = 0.0;
  List<Map<String, dynamic>> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    // Load available tags
    final prefs = await SharedPreferences.getInstance();
    final tags = prefs.getStringList('user_preset_tags') ?? defaultTags;

    if (tags.isNotEmpty && _selectedCategory == null) {
      _selectedCategory = tags.first;
    }

    final allEntries = await IsarService().getAllEntries();

    // Process the data for the selected category
    double total = 0.0;
    List<Map<String, dynamic>> transactions = [];

    total = getTransactions(allEntries, total, transactions) ?? 0.0;

    if (!mounted) return;
    setState(() {
      _categories = tags;
      _categoryTotal = total;
      _filteredTransactions = transactions;
      _isLoading = false;
    });
  }

  double? getTransactions(
    List<PnLEntry> allEntries,
    double total,
    List<Map<String, dynamic>> transactions,
  ) {
    if (_selectedCategory == null) return null;
    for (var entry in allEntries) {
      if (entry.breakdown == null) continue;

      for (var item in entry.breakdown!) {
        if (item.category != _selectedCategory) continue;
        final amount = item.amount ?? 0.0;
        total += amount;

        // Save the transaction details for the list view
        transactions.add({'date': entry.date, 'amount': amount});
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_categories.isEmpty) {
      return Center(
        child: Text(
          "No categories found. Add some in your entries!",
          style: TextStyle(color: colors.onSurfaceVariant),
        ),
      );
    }

    final symbol = CurrencyService.symbol;

    return Column(
      crossAxisAlignment: .start,
      children: [
        categorySelector(colors),
        const SizedBox(height: 24),
        totalSummaryCard(colors, symbol),
        const SizedBox(height: 24),

        // --- THE TRANSACTION HISTORY LIST ---
        Padding(
          padding: const .symmetric(horizontal: 24.0),
          child: Text(
            "History",
            style: TextStyle(
              fontSize: 18,
              fontWeight: .bold,
              color: colors.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 8),
        transactionView(colors),
      ],
    );
  }

  Padding totalSummaryCard(ColorScheme colors, String symbol) {
    return Padding(
      padding: const .symmetric(horizontal: 24.0),
      child: Container(
        width: double.infinity,
        padding: const .all(24),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: .circular(24),
          border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Text(
              "All-Time Net Flow: $_selectedCategory",
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              "${_categoryTotal >= 0 ? '+' : '-'} $symbol"
              "${_getCurrency(_categoryTotal.abs())}",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: _categoryTotal >= 0 ? colors.primary : colors.error,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "${_filteredTransactions.length} total transactions",
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox categorySelector(ColorScheme colors) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: .horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const .symmetric(horizontal: 24),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;

          return Padding(
            padding: const .only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              selectedColor: colors.primaryContainer,
              labelStyle: TextStyle(
                color: isSelected
                    ? colors.onPrimaryContainer
                    : colors.onSurfaceVariant,
                fontWeight: isSelected ? .bold : .normal,
              ),
              side: .none,
              shape: RoundedRectangleBorder(borderRadius: .circular(12)),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedCategory = category);
                  _loadData(); // Re-run the math engine!
                }
              },
            ),
          );
        },
      ),
    );
  }

  Expanded transactionView(ColorScheme colors) {
    final placeholderText = Center(
      child: Text(
        "No transactions found for this category.",
        style: TextStyle(color: colors.onSurfaceVariant),
      ),
    );

    final transactionsView = TransactionsBuilder(
      filteredTransactions: _filteredTransactions,
      colors: colors,
    );

    return Expanded(
      child: _filteredTransactions.isEmpty ? placeholderText : transactionsView,
    );
  }
}

class TransactionsBuilder extends StatelessWidget {
  const TransactionsBuilder({
    super.key,
    required List<Map<String, dynamic>> filteredTransactions,
    required this.colors,
  }) : _filteredTransactions = filteredTransactions;

  final List<Map<String, dynamic>> _filteredTransactions;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const .symmetric(horizontal: 24, vertical: 8),
      itemCount: _filteredTransactions.length,
      itemBuilder: (context, index) {
        final tx = _filteredTransactions[index];
        final date = tx['date'] as DateTime;
        final amount = tx['amount'] as double;
        final isPositive = amount >= 0;
        final symbol = CurrencyService.symbol;

        final maintContent = [
          Text(
            DateFormat('MMMM d, yyyy').format(date),
            style: const TextStyle(fontWeight: .w500),
          ),
          Text(
            "${isPositive ? '+' : '-'} $symbol"
            "${_getCurrency(amount.abs())}",
            style: TextStyle(
              fontWeight: .bold,
              color: isPositive ? colors.primary : colors.error,
            ),
          ),
        ];

        return Container(
          margin: const .only(bottom: 8),
          padding: const .all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: .circular(12),
          ),
          child: Row(mainAxisAlignment: .spaceBetween, children: maintContent),
        );
      },
    );
  }
}

String _getCurrency(double value) =>
    AppFormatters.toCurrency(CurrencyService.toDisplay(value));
