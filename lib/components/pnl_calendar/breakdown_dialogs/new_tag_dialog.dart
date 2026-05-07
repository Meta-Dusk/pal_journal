import 'package:flutter/material.dart';
import 'package:pal_journal/components/buttons.dart';
import 'tags_list_view.dart';

class NewTagDialog extends StatelessWidget {
  const NewTagDialog({
    super.key,
    required this.newTagController,
    required this.onAddNewTag,
    required this.onSaveTags,
    required this.listView,
  });

  final TextEditingController newTagController;
  final VoidCallback onAddNewTag;
  final VoidCallback onSaveTags;
  final TagsListView listView;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final tagEditors = [
      Expanded(
        child: TextField(
          controller: newTagController,
          decoration: const InputDecoration(hintText: "New Tag Name"),
        ),
      ),
      IconButton(
        icon: Icon(Icons.add, color: colors.primary),
        onPressed: onAddNewTag,
      ),
    ];

    final dialogContent = [
      Row(children: tagEditors),
      const SizedBox(height: 16),
      ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 250),
        child: listView,
      ),
    ];

    return AlertDialog(
      backgroundColor: colors.surfaceContainer,
      title: const Text("Edit Tags"),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(mainAxisSize: .min, children: dialogContent),
      ),
      actions: [
        DialogCancelButton(),
        TextButton(
          onPressed: onSaveTags,
          child: Text("Save", style: TextStyle(color: colors.primary)),
        ),
      ],
    );
  }
}
