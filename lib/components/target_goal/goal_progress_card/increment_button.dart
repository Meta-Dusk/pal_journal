import 'package:flutter/material.dart';

class IncrementButton extends StatelessWidget {
  const IncrementButton({
    super.key,
    required this.amount,
    required this.label,
    required this.onIncrement,
  });

  final double amount;
  final String label;
  final void Function(double) onIncrement;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        padding: const .symmetric(horizontal: 12),
        minimumSize: const Size(60, 40),
      ),
      onPressed: () => onIncrement(amount),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: .bold),
      ),
    );
  }
}
