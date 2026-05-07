import 'package:flutter/material.dart';

class CreationTextFields extends StatelessWidget {
  const CreationTextFields({
    super.key,
    required this.targetController,
    required this.unitController,
  });

  final TextEditingController targetController;
  final TextEditingController unitController;

  @override
  Widget build(BuildContext context) {
    final mainContent = [
      Expanded(
        child: TextField(
          controller: targetController,
          keyboardType: .number,
          decoration: const InputDecoration(labelText: 'Target Amount'),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: TextField(
          controller: unitController,
          decoration: const InputDecoration(
            labelText: 'Unit (grams, oz, etc.)',
          ),
        ),
      ),
    ];
    return Row(children: mainContent);
  }
}
