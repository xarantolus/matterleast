import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/extras_providers.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/bookmark_actions.dart';
import 'package:matterleast/domain/bookmarks.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/channel/composer.dart';
import 'package:matterleast/screens/channel/link_opener.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/clickable.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/file_icon.dart';
import 'package:matterleast/ui/post_files.dart';
import 'package:matterleast/ui/sheet_header.dart';
import 'package:matterleast/ui/tokens.dart';

/// A channel's bookmarks in a row under the app bar, from the cache at
/// once and refreshed behind it. Takes no room when the channel has none.
class BookmarkBar extends ConsumerWidget {
  const BookmarkBar({required this.url, required this.channelId, super.key});

  final String url;
  final String channelId;

  /// The bar's height at the normal text size.
  static const height = 48.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(bookmarksRefreshProvider(url, channelId), (_, _) {});
    final bookmarks =
        ref.watch(channelBookmarksProvider(url, channelId)).value ?? const [];
    if (bookmarks.isEmpty) return const SizedBox.shrink();
    final rights =
        ref.watch(bookmarkRightsInProvider(url, channelId)).value ??
        noBookmarkRights;
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    return Material(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: SizedBox(
        height: height * scale,
        child: Row(
          children: [
            Expanded(
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                itemCount: bookmarks.length,
                separatorBuilder: (_, _) => const SizedBox(width: Spacing.sm),
                itemBuilder: (context, i) => Center(
                  child: _BookmarkChip(
                    url: url,
                    bookmark: bookmarks[i],
                    index: i,
                    count: bookmarks.length,
                    rights: rights,
                  ),
                ),
              ),
            ),
            if (rights.add)
              IconButton(
                tooltip: 'Add a bookmark',
                icon: const Icon(Icons.add),
                onPressed: () => showAddBookmark(context, url, channelId),
              ),
          ],
        ),
      ),
    );
  }
}

class _BookmarkChip extends ConsumerWidget {
  const _BookmarkChip({
    required this.url,
    required this.bookmark,
    required this.index,
    required this.count,
    required this.rights,
  });

  final String url;
  final Bookmark bookmark;
  final int index;
  final int count;
  final BookmarkRights rights;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emoji = bookmark.emoji;
    final file = bookmark.file;
    final avatar = emoji != null && emoji.isNotEmpty
        ? EmojiGlyph(name: emoji, size: 18, serverUrl: url)
        : Icon(
            file != null
                ? fileIcon(file.kind, file.extension)
                : bookmark.isFile
                ? Icons.insert_drive_file_outlined
                : Icons.link,
            size: 18,
          );
    return GestureDetector(
      onLongPress: () => _showMenu(context, ref),
      onSecondaryTapUp: isDesktop
          ? (d) => _showMenu(context, ref, d.globalPosition & Size.zero)
          : null,
      child: ActionChip(
        mouseCursor: clickCursor,
        avatar: avatar,
        label: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 200),
          child: Text(
            bookmark.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        onPressed: () => _open(context, ref),
      ),
    );
  }

  void _open(BuildContext context, WidgetRef ref) {
    final link = bookmark.linkUrl;
    final file = bookmark.file;
    if (file != null) {
      openFile(
        context,
        ref,
        url: url,
        file: file,
        author: bookmark.displayName,
        sentAt: bookmark.changedAt ?? DateTime.now(),
      );
    } else if (link != null) {
      final uri = Uri.tryParse(link);
      if (uri != null) {
        unawaited(openLinkFromMessage(Navigator.of(context), uri));
      }
    }
  }

  void _showMenu(BuildContext context, WidgetRef ref, [Rect? anchor]) {
    final link = bookmark.linkUrl;
    unawaited(
      showAppSheet<void>(
        context: context,
        anchor: anchor,
        showDragHandle: true,
        builder: (sheet) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SheetHeader(bookmark.displayName),
              if (link != null)
                ListTile(
                  leading: const Icon(Icons.content_copy),
                  title: const Text('Copy link'),
                  onTap: () {
                    Navigator.of(sheet).pop();
                    unawaited(Clipboard.setData(ClipboardData(text: link)));
                  },
                ),
              if (rights.edit)
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Edit'),
                  onTap: () {
                    Navigator.of(sheet).pop();
                    unawaited(
                      showBookmarkEditor(
                        context,
                        url,
                        bookmark.channelId,
                        bookmark: bookmark,
                      ),
                    );
                  },
                ),
              if (rights.reorder && index > 0)
                ListTile(
                  leading: const Icon(Icons.arrow_back),
                  title: const Text('Move left'),
                  onTap: () {
                    Navigator.of(sheet).pop();
                    _run(
                      context,
                      ref,
                      (a) => a.move(bookmark.channelId, bookmark.id, index - 1),
                    );
                  },
                ),
              if (rights.reorder && index < count - 1)
                ListTile(
                  leading: const Icon(Icons.arrow_forward),
                  title: const Text('Move right'),
                  onTap: () {
                    Navigator.of(sheet).pop();
                    _run(
                      context,
                      ref,
                      (a) => a.move(bookmark.channelId, bookmark.id, index + 1),
                    );
                  },
                ),
              if (rights.delete)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Delete'),
                  onTap: () async {
                    Navigator.of(sheet).pop();
                    final sure = await confirm(
                      context,
                      title: 'Delete bookmark?',
                      body:
                          '"${bookmark.displayName}" goes from the channel '
                          'for everyone.',
                      action: 'Delete',
                      destructive: true,
                    );
                    if (sure && context.mounted) {
                      _run(
                        context,
                        ref,
                        (a) => a.delete(bookmark.channelId, bookmark.id),
                      );
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _run(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(BookmarkActions) action,
  ) => unawaited(runBookmarkAction(context, ref, url, action));
}

/// Runs a bookmark change and says what the server answered when it fails.
Future<void> runBookmarkAction(
  BuildContext context,
  WidgetRef ref,
  String url,
  Future<void> Function(BookmarkActions) action,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action(await ref.read(bookmarkActionsProvider(url).future));
  } on Object catch (e) {
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          "Couldn't change the bookmark. "
          '${requestProblemText(e, Uri.parse(url).host)}',
        ),
      ),
    );
  }
}

/// Offers to add a link or a file to [channelId]'s bookmarks.
Future<void> showAddBookmark(
  BuildContext context,
  String url,
  String channelId,
) => showAppSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (sheet) => Consumer(
    builder: (sheet, ref, _) {
      final uploads =
          ref.watch(featuresProvider(url)).value?.fileUploads ?? false;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SheetHeader('Add a bookmark'),
            ListTile(
              leading: const Icon(Icons.link),
              title: const Text('Add a link'),
              onTap: () {
                Navigator.of(sheet).pop();
                unawaited(showBookmarkEditor(context, url, channelId));
              },
            ),
            if (uploads)
              ListTile(
                leading: const Icon(Icons.attach_file),
                title: const Text('Attach a file'),
                onTap: () async {
                  Navigator.of(sheet).pop();
                  final picked = await pickFiles(PickSource.files, 1);
                  final first = picked.firstOrNull;
                  if (first == null || !context.mounted) return;
                  await runBookmarkAction(
                    context,
                    ref,
                    url,
                    (a) => a.addFile(
                      channelId,
                      name: first.name,
                      open: first.file.openRead,
                      length: first.size,
                    ),
                  );
                },
              ),
          ],
        ),
      );
    },
  ),
);

/// A dialog to add a link, or to rename a bookmark (and change a link's
/// address).
Future<void> showBookmarkEditor(
  BuildContext context,
  String url,
  String channelId, {
  Bookmark? bookmark,
}) => showDialog<void>(
  context: context,
  builder: (_) =>
      _BookmarkEditor(url: url, channelId: channelId, bookmark: bookmark),
);

class _BookmarkEditor extends ConsumerStatefulWidget {
  const _BookmarkEditor({
    required this.url,
    required this.channelId,
    this.bookmark,
  });

  final String url;
  final String channelId;
  final Bookmark? bookmark;

  @override
  ConsumerState<_BookmarkEditor> createState() => _BookmarkEditorState();
}

class _BookmarkEditorState extends ConsumerState<_BookmarkEditor> {
  late final _link = TextEditingController(
    text: widget.bookmark?.linkUrl ?? '',
  );
  late final _name = TextEditingController(
    text: widget.bookmark?.displayName ?? '',
  );
  bool _saving = false;
  String? _error;

  bool get _isFile => widget.bookmark?.isFile ?? false;

  @override
  void dispose() {
    _link.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final link = _isFile ? null : bookmarkLink(_link.text);
    if (!_isFile && link == null) {
      setState(() => _error = 'Enter a web address, such as example.com.');
      return;
    }
    final name = _name.text.trim().isEmpty
        ? (link?.host ?? widget.bookmark?.displayName ?? '')
        : _name.text.trim();
    setState(() {
      _saving = true;
      _error = null;
    });
    final navigator = Navigator.of(context);
    try {
      final actions = await ref.read(
        bookmarkActionsProvider(widget.url).future,
      );
      final existing = widget.bookmark;
      if (existing == null) {
        await actions.addLink(widget.channelId, name: name, link: link!);
      } else {
        await actions.edit(
          widget.channelId,
          existing.id,
          name: name,
          link: link,
          emoji: existing.emoji,
        );
      }
      navigator.pop();
    } on Object catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = requestProblemText(e, Uri.parse(widget.url).host);
      });
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.bookmark == null ? 'Add a link' : 'Edit bookmark'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!_isFile)
          TextField(
            controller: _link,
            autofocus: widget.bookmark == null,
            keyboardType: TextInputType.url,
            decoration: const InputDecoration(labelText: 'Link'),
          ),
        TextField(
          controller: _name,
          decoration: const InputDecoration(labelText: 'Title'),
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => _save(),
        ),
        if (_error case final error?)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.sm),
            child: Text(
              error,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: _saving ? null : () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: _saving ? null : _save,
        child: Text(widget.bookmark == null ? 'Add' : 'Save'),
      ),
    ],
  );
}
