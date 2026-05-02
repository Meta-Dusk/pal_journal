import 'package:flutter/material.dart';

class DialogCancelButton extends StatelessWidget {
  const DialogCancelButton({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context),
      child: const Text("Cancel"),
    );
  }
}
