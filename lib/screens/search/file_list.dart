import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/file_providers.dart';
import 'package:matterleast/app/today_provider.dart';
import 'package:matterleast/domain/message_search.dart';
import 'package:matterleast/domain/post_files.dart' show FileKind, formatBytes;
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/screens/channel/link_opener.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/ui/clickable.dart';
import 'package:matterleast/ui/density.dart';
import 'package:matterleast/ui/file_icon.dart';
import 'package:matterleast/ui/hover_tint.dart';
import 'package:matterleast/ui/post_files.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/user_avatar.dart';

/// A file found on one server.
typedef FoundFile = ({String url, FileHit file});

const _gap = 2.0;

/// Narrows file results to one kind of file.
class FileFilterChips extends StatelessWidget {
  const FileFilterChips({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final FileFilter? selected;
  final ValueChanged<FileFilter?> onSelected;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.fromLTRB(Spacing.md, 0, Spacing.md, Spacing.sm),
    child: Row(
      spacing: Spacing.sm,
      children: [
        ChoiceChip(
          mouseCursor: clickCursor,
          label: const Text('All types'),
          selected: selected == null,
          onSelected: (_) => onSelected(null),
        ),
        for (final kind in FileFilter.values)
          ChoiceChip(
            mouseCursor: clickCursor,
            label: Text(kind.label),
            selected: kind == selected,
            onSelected: (_) => onSelected(kind),
          ),
      ],
    ),
  );
}

/// One date group of files as a sliver: a pinned header, the pictures and
/// videos as a grid, then the other files as rows. [media] is every
/// picture and video of the list, which the gallery pages through.
class FileGroupSliver extends StatelessWidget {
  const FileGroupSliver({
    required this.group,
    required this.columns,
    required this.media,
    required this.names,
    super.key,
  });

  final FileGroup<FoundFile> group;
  final int columns;
  final List<FoundFile> media;
  final Map<String, String> names;

  @override
  Widget build(BuildContext context) => SliverMainAxisGroup(
    slivers: [
      SliverPersistentHeader(
        pinned: true,
        delegate: _GroupHeader(
          group,
          height: MediaQuery.textScalerOf(context).scale(14) + Spacing.lg + 8,
        ),
      ),
      if (group.media.isNotEmpty)
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              mainAxisSpacing: _gap,
              crossAxisSpacing: _gap,
            ),
            itemCount: group.media.length,
            itemBuilder: (context, i) =>
                _MediaFileTile(found: group.media[i], media: media),
          ),
        ),
      SliverList.builder(
        itemCount: group.others.length,
        itemBuilder: (context, i) => FileRow(
          found: group.others[i],
          serverName: names[group.others[i].url],
        ),
      ),
    ],
  );
}

class _GroupHeader extends SliverPersistentHeaderDelegate {
  _GroupHeader(this.group, {required this.height});

  final FileGroup<FoundFile> group;
  final double height;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  bool shouldRebuild(_GroupHeader old) =>
      old.group != group || old.height != height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlaps) =>
      _GroupHeaderRow(group: group);
}

class _GroupHeaderRow extends ConsumerWidget {
  const _GroupHeaderRow({required this.group});

  final FileGroup<FoundFile> group;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ColoredBox(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: Align(
      alignment: AlignmentDirectional.centerStart,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        child: Text(
          group.label(ref.watch(todayProvider)).toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.tokens.smallCaps,
        ),
      ),
    ),
  );
}

/// What a file's menu does besides what its bytes allow.
Future<void> _runExtra(
  BuildContext context,
  WidgetRef ref,
  FoundFile found,
  MediaAction action, {
  bool showsProgress = false,
}) async {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);
  switch (action) {
    case MediaAction.openInChannel:
      await openPost(
        navigator,
        found.url,
        found.file.postId,
        showsProgress: showsProgress,
      );
    case MediaAction.copyLink:
      final link = await ref.read(
        postLinkProvider(
          found.url,
          found.file.channelId,
          found.file.postId,
        ).future,
      );
      if (link == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text("Couldn't find this message's link.")),
        );
        return;
      }
      await Clipboard.setData(ClipboardData(text: link));
      messenger.showSnackBar(const SnackBar(content: Text('Copied the link.')));
    default:
      break;
  }
}

const _extras = [MediaAction.openInChannel, MediaAction.copyLink];

/// Opens the gallery at [found] over every picture and video in [media],
/// each with its own sender and time.
Future<void> _openGallery(
  BuildContext context,
  WidgetRef ref,
  FoundFile found,
  List<FoundFile> media, {
  double? tileWidth,
}) async {
  final index = media.indexWhere((m) => m.file.id == found.file.id);
  if (index < 0) return;
  final senders = <String, String>{};
  for (final m in media) {
    final id = m.file.userId;
    if (id.isEmpty || senders.containsKey(id)) continue;
    senders[id] = await senderName(ref, m.url, id);
  }
  if (!context.mounted) return;
  openGallery(
    context,
    url: found.url,
    media: [for (final m in media) m.file.postFile],
    index: index,
    heroPrefix: 'files',
    author: senders[found.file.userId] ?? '',
    sentAt: found.file.createAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    tileWidth: tileWidth,
    bylines: {
      for (final m in media)
        m.file.id: (
          author: senders[m.file.userId] ?? '',
          sentAt: m.file.createAt ?? DateTime.fromMillisecondsSinceEpoch(0),
        ),
    },
    extras: _extras,
    onExtra: (action, file) {
      if (!context.mounted) return;
      final shown = media.firstWhere((m) => m.file.id == file.id);
      if (action == MediaAction.openInChannel) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      unawaited(_runExtra(context, ref, shown, action));
    },
  );
}

class _MediaFileTile extends ConsumerWidget {
  const _MediaFileTile({required this.found, required this.media});

  final FoundFile found;
  final List<FoundFile> media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final file = found.file;
    final post = file.postFile;
    return LayoutBuilder(
      builder: (context, box) {
        final size = box.biggest;
        void open() => unawaited(
          _openGallery(context, ref, found, media, tileWidth: size.width),
        );
        return Tooltip(
          message: file.name,
          child: Semantics(
            button: true,
            label: post.kind == FileKind.video
                ? 'Video ${file.name}'
                : file.name,
            excludeSemantics: true,
            onTap: open,
            child: FileRightClick(
              url: found.url,
              file: post,
              longPress: true,
              extras: _extras,
              onExtra: (a) => unawaited(_runExtra(context, ref, found, a)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.density.radius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'files:${file.id}',
                      child: MediaPicture(
                        url: found.url,
                        file: post,
                        size: size,
                      ),
                    ),
                    if (post.kind == FileKind.video)
                      const Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: Color(0x8A000000),
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: EdgeInsets.all(Spacing.sm),
                            child: Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    Material(
                      type: MaterialType.transparency,
                      child: InkWell(
                        mouseCursor: clickCursor,
                        onTap: open,
                        hoverColor: pictureHoverTint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A file that isn't a picture or video: a coloured type tile, its name,
/// and its size, sender and time, with the download shown on it.
class FileRow extends ConsumerStatefulWidget {
  const FileRow({required this.found, this.serverName, super.key});

  final FoundFile found;
  final String? serverName;

  @override
  ConsumerState<FileRow> createState() => _FileRowState();
}

class _FileRowState extends ConsumerState<FileRow> {
  bool _locating = false;

  Future<void> _extra(MediaAction action) async {
    if (action == MediaAction.openInChannel) {
      if (_locating) return;
      setState(() => _locating = true);
      try {
        await _runExtra(
          context,
          ref,
          widget.found,
          action,
          showsProgress: true,
        );
      } finally {
        if (mounted) setState(() => _locating = false);
      }
    } else {
      await _runExtra(context, ref, widget.found, action);
    }
  }

  @override
  Widget build(BuildContext context) {
    final found = widget.found;
    final file = found.file;
    final post = file.postFile;
    final tokens = context.tokens;
    final url = found.url;
    final (:running, :progress) = fileTransferOf(ref, url, file.id);
    final downloaded =
        !running &&
        (ref.watch(fileDownloadedProvider(url, file.id)).value ?? false);
    final sender = file.userId.isEmpty
        ? null
        : ref.watch(fileSenderProvider(url, file.userId)).value;
    final at = file.createAt;
    final detail = TextStyle(color: tokens.muted);
    return FileRightClick(
      url: url,
      file: post,
      extras: _extras,
      onExtra: (a) => unawaited(_extra(a)),
      child: ListTile(
        mouseCursor: clickCursor,
        onTap: running
            ? null
            : () => openFile(
                context,
                ref,
                url: url,
                file: post,
                author: sender?.name ?? '',
                sentAt: at ?? DateTime.fromMillisecondsSinceEpoch(0),
              ),
        leading: _TypeTile(extension: file.extension),
        title: Text(file.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: running
            ? Padding(
                padding: const EdgeInsets.only(top: Spacing.xs),
                child: LinearProgressIndicator(value: progress),
              )
            : Text.rich(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: detail,
                TextSpan(
                  children: [
                    TextSpan(text: formatBytes(file.size)),
                    if (sender != null) ...[
                      const TextSpan(text: ' · '),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.only(right: Spacing.xs),
                          child: ExcludeSemantics(
                            child: UserAvatar(
                              serverUrl: url,
                              userId: file.userId,
                              name: sender.name,
                              lastPictureUpdate: sender.picture,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                      TextSpan(text: sender.name),
                    ],
                    if (at != null)
                      TextSpan(
                        text:
                            ' · ${shortWhen(at, ref.watch(todayProvider), use24: MediaQuery.alwaysUse24HourFormatOf(context))}',
                      ),
                    if (widget.serverName != null)
                      TextSpan(text: ' · ${widget.serverName}'),
                  ],
                ),
              ),
        trailing: running
            ? IconButton(
                tooltip: 'Cancel download',
                icon: const Icon(Icons.close),
                onPressed: () => ref
                    .read(fileTransfersProvider(url).notifier)
                    .cancel(file.id),
              )
            : _locating
            ? const SizedBox.square(
                dimension: 24,
                child: CircularProgressIndicator.adaptive(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (downloaded)
                    Tooltip(
                      message: 'Downloaded',
                      child: Icon(
                        Icons.download_done,
                        size: 18,
                        color: tokens.muted,
                      ),
                    ),
                  FileActionsMenu(
                    url: url,
                    file: post,
                    extras: _extras,
                    onExtra: (a) => unawaited(_extra(a)),
                  ),
                ],
              ),
      ),
    );
  }
}

class _TypeTile extends StatelessWidget {
  const _TypeTile({required this.extension});

  final String extension;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox.square(
      dimension: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fileTypeColor(extension),
          borderRadius: BorderRadius.circular(context.density.radius),
        ),
        child: Center(
          child: Text(
            fileTypeLabel(extension),
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ),
  );
}
