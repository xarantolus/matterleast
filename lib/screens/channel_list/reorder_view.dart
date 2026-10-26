import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/category_moves.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/screens/channel_list/category_menu.dart';
import 'package:matterleast/screens/channel_list/channel_tile.dart';
import 'package:matterleast/ui/tokens.dart';

/// The channel list with drag handles on every category and channel, plus
/// adding, renaming and deleting custom categories. Collapsed categories
/// show all their channels here.
class ReorderView extends StatefulWidget {
  const ReorderView({
    required this.url,
    required this.teamId,
    required this.sections,
    required this.onDone,
    super.key,
  });

  final String url;
  final String teamId;
  final List<CategorySection> sections;
  final VoidCallback onDone;

  @override
  State<ReorderView> createState() => _ReorderViewState();
}

class _ReorderViewState extends State<ReorderView> {
  late List<ReorderEntry> _entries = _entriesOf(widget.sections);
  late Map<String, CategorySection> _sections = _byId(widget.sections);
  late Map<String, ChannelItem> _items = _itemsOf(widget.sections);

  @override
  void didUpdateWidget(ReorderView old) {
    super.didUpdateWidget(old);
    if (old.sections != widget.sections) {
      _entries = _entriesOf(widget.sections);
      _sections = _byId(widget.sections);
      _items = _itemsOf(widget.sections);
    }
  }

  static List<ReorderEntry> _entriesOf(List<CategorySection> sections) => [
    for (final s in sections) ...[
      HeaderEntry(s.id),
      for (final row in s.rows) RowEntry(s.id, row.id),
    ],
  ];

  static Map<String, CategorySection> _byId(List<CategorySection> sections) => {
    for (final s in sections) s.id: s,
  };

  static Map<String, ChannelItem> _itemsOf(List<CategorySection> sections) => {
    for (final s in sections)
      for (final row in s.rows) row.id: row,
  };

  void _onReorder(int oldIndex, int newIndex) {
    final drop = dropOf(_entries, oldIndex, newIndex);
    if (drop == null) return;
    final messenger = ScaffoldMessenger.of(context);
    if (drop case ChannelDrop(:final channelId, :final toCategory)) {
      final item = _items[channelId]!;
      final target = _sections[toCategory]!;
      if (!canPlace(item.kind, target.kind)) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(switch (target.kind) {
              CategoryKind.channels =>
                'Direct messages can’t go into ${target.title}.',
              _ => 'Only direct messages go into ${target.title}.',
            }),
          ),
        );
        return;
      }
    }
    final next = reorderEntries(_entries, oldIndex, newIndex);
    setState(() => _entries = next);
    unawaited(switch (drop) {
      ChannelDrop() => runCategoryAction(
        context,
        widget.url,
        "Couldn't move the channel.",
        (a) => a.moveChannel(
          widget.teamId,
          drop,
          shown: [
            for (final e in next)
              if (e is RowEntry && e.categoryId == drop.toCategory)
                if (e.channelId != drop.channelId) e.channelId,
          ],
        ),
      ),
      CategoryDrop() => runCategoryAction(
        context,
        widget.url,
        "Couldn't move the category.",
        (a) => a.moveCategory(widget.teamId, drop),
      ),
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.sm,
            Spacing.md,
            Spacing.sm,
          ),
          child: Row(
            spacing: Spacing.sm,
            children: [
              Expanded(
                child: Text(
                  'Drag to reorder',
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                tooltip: 'New category',
                icon: const Icon(Icons.create_new_folder_outlined),
                onPressed: () => unawaited(
                  createCategory(
                    context,
                    url: widget.url,
                    teamId: widget.teamId,
                  ),
                ),
              ),
              FilledButton(onPressed: widget.onDone, child: const Text('Done')),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ReorderableListView.builder(
            buildDefaultDragHandles: false,
            padding: const EdgeInsets.only(bottom: Spacing.lg),
            itemCount: _entries.length,
            onReorderItem: _onReorder,
            itemBuilder: (context, i) {
              final handle = ReorderableDragStartListener(
                index: i,
                child: Padding(
                  padding: const EdgeInsets.all(Spacing.sm),
                  child: Icon(Icons.drag_handle, color: tokens.muted),
                ),
              );
              return switch (_entries[i]) {
                HeaderEntry(:final categoryId) => _Header(
                  key: ValueKey('header/$categoryId'),
                  url: widget.url,
                  teamId: widget.teamId,
                  section: _sections[categoryId]!,
                  handle: handle,
                ),
                RowEntry(:final channelId) => ChannelTile(
                  key: ValueKey('row/$channelId'),
                  serverUrl: widget.url,
                  item: _items[channelId]!,
                  trailing: Semantics(
                    label: 'Move ${_items[channelId]!.title}',
                    child: handle,
                  ),
                ),
              };
            },
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.url,
    required this.teamId,
    required this.section,
    required this.handle,
    super.key,
  });

  final String url;
  final String teamId;
  final CategorySection section;
  final Widget handle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final custom = section.kind == CategoryKind.custom;
    return Material(
      color: tokens.accentWash,
      child: Padding(
        padding: const EdgeInsets.only(left: Spacing.lg, right: Spacing.md),
        child: Row(
          children: [
            Expanded(
              child: Text(
                section.title.toUpperCase(),
                style: tokens.smallCaps,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (custom) ...[
              IconButton(
                tooltip: 'Rename ${section.title}',
                icon: const Icon(Icons.edit_outlined, size: 20),
                onPressed: () => unawaited(
                  renameCategory(
                    context,
                    url: url,
                    teamId: teamId,
                    section: section,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Delete ${section.title}',
                icon: const Icon(Icons.delete_outline, size: 20),
                onPressed: () => unawaited(
                  deleteCategory(
                    context,
                    url: url,
                    teamId: teamId,
                    section: section,
                  ),
                ),
              ),
            ] else
              const SizedBox(height: kMinInteractiveDimension),
            Semantics(label: 'Move ${section.title}', child: handle),
          ],
        ),
      ),
    );
  }
}
