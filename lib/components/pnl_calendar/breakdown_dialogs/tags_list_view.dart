import 'package:flutter/material.dart';

class TagsListView extends StatelessWidget {
  const TagsListView({
    super.key,
    required this.editableTags,
    required this.onListItemDelete,
  });

  final List<String> editableTags;
  final void Function(int) onListItemDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListView.builder(
      shrinkWrap: true,
      itemCount: editableTags.length,
      itemBuilder: (_, index) {
        return ListTile(
          contentPadding: .zero,
          title: Text(editableTags[index]),
          trailing: IconButton(
            icon: Icon(Icons.delete_outline, color: colors.error, size: 20),
            onPressed: () => onListItemDelete(index),
          ),
        );
      },
    );
  }
}
