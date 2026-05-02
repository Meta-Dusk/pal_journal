import 'package:flutter/material.dart';
import 'package:pal_journal/services/goal_service.dart';
import 'package:pal_journal/utils/formatters.dart';

class ListTileSetGoal extends StatefulWidget {
  final DateTime month;
  const ListTileSetGoal({super.key, required this.month});

  @override
  State<ListTileSetGoal> createState() => _ListTileSetGoalState();
}

class _ListTileSetGoalState extends State<ListTileSetGoal> {
  GoalData? _currentGoal;

  @override
  void initState() {
    super.initState();
    _fetchGoal();
  }

  Future<void> _fetchGoal() async {
    final goal = await GoalService.getGoal(widget.month);
    setState(() => _currentGoal = goal);
  }

  void _showGoalDialog(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final controller = TextEditingController(
      text: _currentGoal != null
          ? AppFormatters.toCurrency(_currentGoal!.amount)
          : '',
    );
    GoalType selectedType = _currentGoal?.type ?? .budget;

    showDialog(
      context: context,
      builder: (context) {
        // StatefulBuilder ensures the chips update visually when tapped!
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
                      prefixText: "₱ ",
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
              actions: [
                if (_currentGoal != null)
                  TextButton(
                    onPressed: () async {
                      await GoalService.clearGoal(widget.month);
                      _fetchGoal();
                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text(
                      "Remove",
                      style: TextStyle(color: colors.error),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final amount = AppFormatters.parseCurrency(controller.text);
                    if (amount > 0) {
                      await GoalService.setGoal(
                        widget.month,
                        amount,
                        selectedType,
                      );
                    } else {
                      await GoalService.clearGoal(widget.month);
                    }
                    _fetchGoal();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(color: colors.primary, fontWeight: .bold),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  AlertDialog monthlyGoalDialog(
    GoalType selectedType,
    StateSetter setDialogState,
    ColorScheme colors,
    TextEditingController controller,
    BuildContext context,
  ) {
    final dialogActions = [
      if (_currentGoal != null)
        TextButton(
          onPressed: () async {
            await GoalService.clearGoal(widget.month);
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
          final amount = AppFormatters.parseCurrency(controller.text);
          if (amount > 0) {
            await GoalService.setGoal(widget.month, amount, selectedType);
          } else {
            await GoalService.clearGoal(widget.month);
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

    final dialogContent = [
      SegmentedButton<GoalType>(
        segments: const [
          ButtonSegment(
            value: .budget,
            label: Text('Budget'),
            icon: Icon(Icons.money_off),
          ),
          ButtonSegment(
            value: .profit,
            label: Text('Profit'),
            icon: Icon(Icons.trending_up),
          ),
        ],
        selected: {selectedType},
        onSelectionChanged: (Set<GoalType> newSelection) {
          setDialogState(() => selectedType = newSelection.first);
        },
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.selected)) {
              return selectedType == .budget
                  ? colors.tertiary
                  : colors.primary.withValues(alpha: 0.2);
            }
            return null;
          }),
        ),
      ),
      const SizedBox(height: 16),
      TextField(
        controller: controller,
        autofocus: true,
        keyboardType: const .numberWithOptions(decimal: true),
        inputFormatters: [PnLFormatter()],
        decoration: InputDecoration(
          hintText: "0.00",
          prefixText: "₱ ",
          filled: true,
          fillColor: colors.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: .circular(12),
            borderSide: .none,
          ),
        ),
      ),
    ];

    return AlertDialog(
      title: const Text("Set Monthly Goal", textAlign: .center),
      content: Column(mainAxisSize: .min, children: dialogContent),
      actions: dialogActions,
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
          "$typeLabel: ₱${AppFormatters.toCurrency(_currentGoal!.amount)}";
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
