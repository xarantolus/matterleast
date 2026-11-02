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
import 'package:matterleast/ui/try_action.dart';

/// The menu of a category header: sort it, mute it, mark it read, reorder
/// the list, add a category, and rename or delete a custom one.
Future<void> showCategoryMenu(
  BuildContext context, {
  required String url,
  required String teamId,
  required CategorySection section,
  required VoidCallback onReorder,
  int directLimit = defaultDirectLimit,
  Rect? anchor,
}) => showAppSheet<void>(
  context: context,
  showDragHandle: true,
  anchor: anchor,
  builder: (sheet) {
    void close(void Function() then) {
      Navigator.of(sheet).pop();
      then();
    }

    final kind = section.kind;
    final unread = unreadIds(section);
    final mutable =
        kind == CategoryKind.custom || kind == CategoryKind.channels;
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SheetHeader(section.title),
            if (unread.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.done_all),
                title: const Text('Mark category as read'),
                onTap: () => close(
                  () => unawaited(
                    runCategoryAction(
                      context,
                      url,
                      "Couldn't mark the category as read.",
                      (a) => a.markAllRead(unread),
                    ),
                  ),
                ),
              ),
            ListTile(
              leading: const Icon(Icons.sort),
              title: const Text('Sort'),
              subtitle: Text(_sortLabel(section.sorting)),
              onTap: () => close(
                () => unawaited(
                  _chooseSorting(context, url, teamId, section, anchor),
                ),
              ),
            ),
            if (kind == CategoryKind.directMessages)
              ListTile(
                leading: const Icon(Icons.forum_outlined),
                title: const Text('Show recent messages'),
                subtitle: Text(directLimitLabel(directLimit)),
                onTap: () => close(
                  () => unawaited(
                    _chooseDirectLimit(context, url, directLimit, anchor),
                  ),
                ),
              ),
            if (mutable)
              ListTile(
                leading: Icon(
                  section.muted
                      ? Icons.notifications_outlined
                      : Icons.notifications_off_outlined,
                ),
                title: Text(
                  section.muted ? 'Unmute category' : 'Mute category',
                ),
                onTap: () => close(
                  () => unawaited(
                    runCategoryAction(
                      context,
                      url,
                      "Couldn't change the category.",
                      (a) => a.setCategoryMuted(
                        teamId,
                        section.id,
                        muted: !section.muted,
                      ),
                    ),
                  ),
                ),
              ),
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
                () => unawaited(
                  createCategory(context, url: url, teamId: teamId),
                ),
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
      ),
    );
  },
);

const _sortings = [
  ('alpha', 'Alphabetically'),
  ('recent', 'Recent activity'),
  ('manual', 'Manually'),
];

/// An unset sorting is alphabetical, as in the list.
String _sortLabel(String sorting) => _sortings
    .firstWhere((s) => s.$1 == sorting, orElse: () => _sortings.first)
    .$2;

Future<void> _chooseSorting(
  BuildContext context,
  String url,
  String teamId,
  CategorySection section,
  Rect? anchor,
) async {
  final current = _sortings.any((s) => s.$1 == section.sorting)
      ? section.sorting
      : _sortings.first.$1;
  final picked = await _choose(
    context,
    anchor: anchor,
    title: 'Sort ${section.title}',
    current: current,
    options: [
      for (final s in _sortings)
        // Direct messages have no manual order in Mattermost.
        if (section.kind != CategoryKind.directMessages || s.$1 != 'manual') s,
    ],
  );
  if (picked == null || picked == current || !context.mounted) return;
  await runCategoryAction(
    context,
    url,
    "Couldn't sort the category.",
    (a) => a.setCategorySorting(teamId, section.id, picked),
  );
}

Future<void> _chooseDirectLimit(
  BuildContext context,
  String url,
  int current,
  Rect? anchor,
) async {
  final picked = await _choose(
    context,
    anchor: anchor,
    title: 'Show recent messages',
    current: current,
    options: [for (final n in directLimitChoices) (n, directLimitLabel(n))],
  );
  if (picked == null || picked == current || !context.mounted) return;
  await runCategoryAction(
    context,
    url,
    "Couldn't save the setting.",
    (a) => a.setDirectLimit(picked),
  );
}

Future<T?> _choose<T>(
  BuildContext context, {
  required String title,
  required Rect? anchor,
  required T current,
  required List<(T, String)> options,
}) => showAppSheet<T>(
  context: context,
  anchor: anchor,
  builder: (sheet) => SafeArea(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SheetHeader(title),
        for (final (value, label) in options)
          ListTile(
            title: Text(label),
            trailing: value == current ? const Icon(Icons.check) : null,
            onTap: () => Navigator.of(sheet).pop(value),
          ),
      ],
    ),
  ),
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
  final container = ProviderScope.containerOf(context, listen: false);
  await tryAction(
    context,
    hostOf(url),
    failure: failure,
    () async =>
        action(await container.read(channelActionsProvider(url).future)),
  );
}

Future<String?> _askName(
  BuildContext context, {
  required String title,
  required String action,
  String initial = '',
}) => promptText(
  context,
  title: title,
  action: action,
  initial: initial,
  label: 'Name',
  required: true,
);
