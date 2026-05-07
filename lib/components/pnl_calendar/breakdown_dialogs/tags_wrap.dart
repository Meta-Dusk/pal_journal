import 'package:flutter/material.dart';

class TagsWrap extends StatelessWidget {
  const TagsWrap({
    super.key,
    required this.tags,
    required this.categoryController,
    required this.onEditAction,
  });

  final List<String> tags;
  final TextEditingController categoryController;
  final VoidCallback onEditAction;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final List<Widget> chips = tags.map((tag) {
      return ActionChip(
        label: Text(
          tag,
          style: TextStyle(fontSize: 12, color: colors.onSurfaceVariant),
        ),
        backgroundColor: colors.surfaceContainer,
        side: .none,
        shape: RoundedRectangleBorder(borderRadius: .circular(8)),
        onPressed: () {
          categoryController.text = tag;
          categoryController.selection = .fromPosition(
            TextPosition(offset: categoryController.text.length),
          );
        },
      );
    }).toList();

    chips.add(
      ActionChip(
        label: Row(
          mainAxisSize: .min,
          children: [
            Icon(Icons.edit, size: 12, color: colors.primary),
            SizedBox(width: 4),
            Text("Edit", style: TextStyle(fontSize: 12, color: colors.primary)),
          ],
        ),
        backgroundColor: colors.primaryContainer.withValues(alpha: 0.1),
        side: .none,
        shape: RoundedRectangleBorder(borderRadius: .circular(8)),
        onPressed: onEditAction,
      ),
    );

    return Wrap(spacing: 8.0, runSpacing: 8.0, children: chips);
  }
}
