import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pal_journal/models/quantified_goal.dart';
import 'package:pal_journal/services/isar_service.dart';

class GoalCreationSheet extends StatefulWidget {
  const GoalCreationSheet({super.key, this.existingGoal});

  final QuantifiedGoal? existingGoal;

  @override
  State<GoalCreationSheet> createState() => _GoalCreationSheetState();
}

class _GoalCreationSheetState extends State<GoalCreationSheet> {
  final _titleController = TextEditingController();
  final _targetController = TextEditingController();
  final _unitController = TextEditingController(text: 'items');
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 7));
  bool _isPinned = false;
  GoalValueType _valueType = .integer;

  @override
  void initState() {
    super.initState();
    if (widget.existingGoal != null) {
      _titleController.text = widget.existingGoal!.title;
      _targetController.text = widget.existingGoal!.targetValue.toString();
      _unitController.text = widget.existingGoal!.unit;
      _selectedDate = widget.existingGoal!.deadline;
      _isPinned = widget.existingGoal!.isPinned;
      _valueType = widget.existingGoal!.valueType;
    }
  }

  Future<void> _saveGoal() async {
    if (_titleController.text.isEmpty || _targetController.text.isEmpty) return;

    final goalToSave = widget.existingGoal ?? QuantifiedGoal();

    goalToSave
      ..title = _titleController.text
      ..targetValue = double.tryParse(_targetController.text) ?? 0
      ..unit = _unitController.text
      ..deadline = _selectedDate
      ..isPinned = _isPinned
      ..valueType = _valueType;

    await IsarService().saveQuantifiedGoal(goalToSave);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final mainContent = [
      Text("Track a New Item", style: textTheme.headlineSmall),
      const SizedBox(height: 20),
      Text(
        "Quantity Type",
        style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
      ),
      const SizedBox(height: 8),
      segmentedButton(),
      const SizedBox(height: 16),
      TextField(
        controller: _titleController,
        decoration: const InputDecoration(
          labelText: 'What are you tracking? (e.g. Gold)',
        ),
      ),
      const SizedBox(height: 16),
      amountTextFields(),
      const SizedBox(height: 16),
      listTileChangeDeadline(colors, context),
      SwitchListTile(
        contentPadding: .zero,
        title: const Text("Pin to Home View"),
        value: _isPinned,
        onChanged: (val) => setState(() => _isPinned = val),
      ),
      const SizedBox(height: 20),
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          onPressed: _saveGoal,
          child: Text(
            widget.existingGoal == null ? "Create Goal" : "Update Goal",
          ),
        ),
      ),
      const SizedBox(height: 20),
    ];

    return Padding(
      padding: .only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: mainContent,
      ),
    );
  }

  SizedBox segmentedButton() {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<GoalValueType>(
        segments: const [
          ButtonSegment(
            value: .integer,
            label: Text("Integer (1, 2, 3)"),
            icon: Icon(Icons.pin_outlined),
          ),
          ButtonSegment(
            value: .decimal,
            label: Text("Decimal (1.5, 2.0)"),
            icon: Icon(Icons.precision_manufacturing_outlined),
          ),
        ],
        selected: {_valueType},
        onSelectionChanged: (set) => setState(() => _valueType = set.first),
      ),
    );
  }

  Row amountTextFields() {
    final mainContent = [
      Expanded(
        child: TextField(
          controller: _targetController,
          keyboardType: .number,
          decoration: const InputDecoration(labelText: 'Target Amount'),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: TextField(
          controller: _unitController,
          decoration: const InputDecoration(
            labelText: 'Unit (grams, oz, etc.)',
          ),
        ),
      ),
    ];

    return Row(children: mainContent);
  }

  ListTile listTileChangeDeadline(ColorScheme colors, BuildContext context) {
    return ListTile(
      contentPadding: .zero,
      leading: const Icon(Icons.calendar_today),
      title: Text("Deadline: ${DateFormat('yMMMd').format(_selectedDate)}"),
      trailing: Text("Change", style: TextStyle(color: colors.primary)),
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now(),
          lastDate: DateTime(2035),
        );
        if (picked != null) setState(() => _selectedDate = picked);
      },
    );
  }
}
