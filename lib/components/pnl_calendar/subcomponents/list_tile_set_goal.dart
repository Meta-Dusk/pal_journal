import 'package:flutter/material.dart';
import 'package:pal_journal/models/monthly_goal.dart';
import 'package:pal_journal/services/currency_service.dart';
import 'package:pal_journal/services/isar_service.dart';
import 'package:pal_journal/utils/formatters.dart';

class ListTileSetGoal extends StatefulWidget {
  final DateTime month;
  const ListTileSetGoal({super.key, required this.month});

  @override
  State<ListTileSetGoal> createState() => _ListTileSetGoalState();
}

class _ListTileSetGoalState extends State<ListTileSetGoal> {
  MonthlyGoal? _currentGoal;
  final symbol = CurrencyService.symbol;

  @override
  void initState() {
    super.initState();
    _fetchGoal();
  }

  Future<void> _fetchGoal() async {
    final goal = await IsarService().getGoal(widget.month);
    setState(() => _currentGoal = goal);
  }

  void _showGoalDialog(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final controller = TextEditingController(
      text: _currentGoal != null ? _getCurrency(_currentGoal!.amount) : '',
    );
    GoalType selectedType = _currentGoal?.type ?? .budget;

    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder ensures the chips update visually when tapped!
        return statefulBuilder(selectedType, colors, controller);
      },
    );
  }

  StatefulBuilder statefulBuilder(
    GoalType selectedType,
    ColorScheme colors,
    TextEditingController controller,
  ) {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        final dialogContent = [
          Expanded(
            child: ChoiceChip(
              label: const Center(child: Text('Budget')),
              selected: selectedType == .budget,
              showCheckmark: false,
              selectedColor: colors.errorContainer,
              onSelected: (selected) {
                setDialogState(() => selectedType = .budget);
              },
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ChoiceChip(
              label: const Center(child: Text('Profit')),
              selected: selectedType == .profit,
              showCheckmark: false,
              selectedColor: colors.primary.withValues(alpha: 0.2),
              onSelected: (selected) {
                setDialogState(() => selectedType = .profit);
              },
            ),
          ),
        ];

        return monthlyGoalDialog(
          dialogContent,
          controller,
          colors,
          context,
          selectedType,
        );
      },
    );
  }

  AlertDialog monthlyGoalDialog(
    List<Widget> dialogContent,
    TextEditingController controller,
    ColorScheme colors,
    BuildContext context,
    GoalType selectedType,
  ) {
    final dialogAction = [
      if (_currentGoal != null)
        TextButton(
          onPressed: () async {
            await IsarService().clearGoal(widget.month);
            _fetchGoal();
            if (context.mounted) Navigator.pop(context);
          },
          child: Text("Remove", style: TextStyle(color: colors.error)),
        ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text("Cancel", style: TextStyle(color: colors.onSurfaceVariant)),
      ),
      TextButton(
        onPressed: () async {
          final displayAmount = AppFormatters.parseCurrency(controller.text);
          if (displayAmount > 0) {
            final baseAmount = CurrencyService.toBase(displayAmount);
            final newGoal = MonthlyGoal()
              ..month = widget.month
              ..amount = baseAmount
              ..type = selectedType;
            await IsarService().saveGoal(newGoal);
          } else {
            await IsarService().clearGoal(widget.month);
          }
          _fetchGoal();
          if (context.mounted) Navigator.pop(context);
        },
        child: Text(
          "Save",
          style: TextStyle(color: colors.primary, fontWeight: .bold),
        ),
      ),
    ];

    return AlertDialog(
      title: const Text("Set Monthly Goal", textAlign: .center),
      content: Column(
        mainAxisSize: .min,
        children: [
          Row(children: dialogContent),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            autofocus: true,
            keyboardType: const .numberWithOptions(decimal: true),
            inputFormatters: [PnLFormatter()],
            decoration: InputDecoration(
              hintText: "0.00",
              prefixText: "$symbol ",
              filled: true,
              fillColor: colors.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: .circular(12),
                borderSide: .none,
              ),
            ),
          ),
        ],
      ),
      actions: dialogAction,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    String subtitleText = "No goal set";
    if (_currentGoal != null) {
      final typeLabel = _currentGoal!.type == .profit
          ? "Profit Target"
          : "Budget Limit";
      subtitleText =
          "$typeLabel: $symbol"
          "${_getCurrency(_currentGoal!.amount)}";
    }

    return ListTile(
      leading: Icon(
        Icons.flag,
        color: _currentGoal?.type == .profit ? colors.primary : colors.tertiary,
      ),
      title: const Text("Set Monthly Goal"),
      subtitle: Text(
        subtitleText,
        style: TextStyle(
          color: _currentGoal != null
              ? colors.primary
              : colors.onSurfaceVariant,
        ),
      ),
      onTap: () => _showGoalDialog(context),
    );
  }
}

String _getCurrency(double value) =>
    AppFormatters.toCurrency(CurrencyService.toDisplay(value));
