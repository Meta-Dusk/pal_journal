import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pal_journal/core/default_data.dart';
import 'new_tag_dialog.dart';
import 'tags_list_view.dart';

class TagEditorDialog extends StatefulWidget {
  final List<String> currentTags;
  const TagEditorDialog({super.key, required this.currentTags});

  @override
  State<TagEditorDialog> createState() => _TagEditorDialogState();
}

class _TagEditorDialogState extends State<TagEditorDialog> {
  late final TextEditingController _newTagController;
  late final List<String> _editableTags;

  @override
  void initState() {
    super.initState();
    _newTagController = TextEditingController();
    _editableTags = List.from(widget.currentTags);
  }

  @override
  void dispose() {
    _newTagController.dispose();
    super.dispose();
  }

  Future<void> _savePrefsAndPop() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(tagsKey, _editableTags);
    if (mounted) Navigator.pop(context, _editableTags);
  }

  void _onAddNewTag() {
    if (_newTagController.text.isEmpty) return;
    setState(() {
      _editableTags.add(_newTagController.text.trim());
      _newTagController.clear();
    });
  }

  void _onListItemDelete(int index) {
    setState(() => _editableTags.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return NewTagDialog(
      newTagController: _newTagController,
      onAddNewTag: _onAddNewTag,
      onSaveTags: _savePrefsAndPop,
      listView: TagsListView(
        editableTags: _editableTags,
        onListItemDelete: _onListItemDelete,
      ),
    );
  }
}
