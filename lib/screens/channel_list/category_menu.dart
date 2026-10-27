import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/data/actions/channel_actions.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/sheet_header.dart';

/// The menu of a category header: reorder the list, add a category, and
/// rename or delete a custom one.
Future<void> showCategoryMenu(
  BuildContext context, {
  required String url,
  required String teamId,
  required CategorySection section,
  required VoidCallback onReorder,
}) => showAppSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (sheet) {
    void close(void Function() then) {
      Navigator.of(sheet).pop();
      then();
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(section.title),
          ListTile(
            leading: const Icon(Icons.swap_vert),
            title: const Text('Reorder'),
            subtitle: const Text('Move channels and categories'),
            onTap: () => close(onReorder),
          ),
          ListTile(
            leading: const Icon(Icons.create_new_folder_outlined),
            title: const Text('New category'),
            onTap: () => close(
              () =>
                  unawaited(createCategory(context, url: url, teamId: teamId)),
            ),
          ),
          if (section.kind == CategoryKind.custom) ...[
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename category'),
              onTap: () => close(
                () => unawaited(
                  renameCategory(
                    context,
                    url: url,
                    teamId: teamId,
                    section: section,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Delete category'),
              onTap: () => close(
                () => unawaited(
                  deleteCategory(
                    context,
                    url: url,
                    teamId: teamId,
                    section: section,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  },
);

Future<void> createCategory(
  BuildContext context, {
  required String url,
  required String teamId,
}) async {
  final name = await _askName(context, title: 'New category', action: 'Create');
  if (name == null || !context.mounted) return;
  await runCategoryAction(
    context,
    url,
    "Couldn't create the category.",
    (a) => a.createCategory(teamId, name),
  );
}

Future<void> renameCategory(
  BuildContext context, {
  required String url,
  required String teamId,
  required CategorySection section,
}) async {
  final name = await _askName(
    context,
    title: 'Rename category',
    action: 'Rename',
    initial: section.title,
  );
  if (name == null || name == section.title || !context.mounted) return;
  await runCategoryAction(
    context,
    url,
    "Couldn't rename the category.",
    (a) => a.renameCategory(teamId, section.id, name),
  );
}

Future<void> deleteCategory(
  BuildContext context, {
  required String url,
  required String teamId,
  required CategorySection section,
}) async {
  final sure = await confirm(
    context,
    title: 'Delete ${section.title}?',
    body:
        'Its channels go back to Channels and Direct Messages. '
        'You stay in all of them.',
    action: 'Delete',
    destructive: true,
  );
  if (!sure || !context.mounted) return;
  await runCategoryAction(
    context,
    url,
    "Couldn't delete the category.",
    (a) => a.deleteCategory(teamId, section.id),
  );
}

/// Runs [action] and shows what the server said when it fails.
Future<void> runCategoryAction(
  BuildContext context,
  String url,
  String failure,
  Future<void> Function(ChannelActions) action,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final container = ProviderScope.containerOf(context, listen: false);
  try {
    await action(await container.read(channelActionsProvider(url).future));
  } on Object catch (e) {
    messenger.showSnackBar(
      SnackBar(
        content: Text('$failure ${requestProblemText(e, Uri.parse(url).host)}'),
      ),
    );
  }
}

Future<String?> _askName(
  BuildContext context, {
  required String title,
  required String action,
  String initial = '',
}) => showDialog<String>(
  context: context,
  builder: (_) => _NameDialog(title: title, action: action, initial: initial),
);

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.action,
    required this.initial,
  });

  final String title;
  final String action;
  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _name = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _name.text.trim();
    if (name.isNotEmpty) Navigator.pop(context, name);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _name,
      autofocus: true,
      textCapitalization: TextCapitalization.sentences,
      decoration: const InputDecoration(labelText: 'Name'),
      onSubmitted: (_) => _submit(),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ListenableBuilder(
        listenable: _name,
        builder: (context, _) => TextButton(
          onPressed: _name.text.trim().isEmpty ? null : _submit,
          child: Text(widget.action),
        ),
      ),
    ],
  );
}
