import 'dart:async';
import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/file_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/files/file_downloads.dart';
import 'package:matterleast/data/files/file_handoff.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/gallery/gallery_screen.dart';
import 'package:matterleast/screens/gallery/pdf_screen.dart';
import 'package:matterleast/ui/file_icon.dart';
import 'package:matterleast/ui/markdown/code_block.dart';
import 'package:matterleast/ui/markdown/image_box.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/server_image.dart';
import 'package:matterleast/ui/tokens.dart';

const _gap = 4.0;
const _unknownBox = 48.0;

/// The files of one message: images and videos in a grid of up to four,
/// then a card per other file.
class PostFiles extends StatelessWidget {
  const PostFiles({
    required this.files,
    required this.heroPrefix,
    required this.author,
    required this.sentAt,
    this.leading,
    super.key,
  });

  final List<PostFile> files;

  /// Pictures from the message's text, which come first in the gallery.
  final List<PostFile> Function()? leading;

  /// Unique per message row, so a file shown twice gets two heroes.
  final String heroPrefix;
  final String author;
  final DateTime sentAt;

  @override
  Widget build(BuildContext context) {
    final env = PostEnvironment.maybeOf(context);
    if (env == null) return const SizedBox.shrink();
    final url = env.server.toString();
    final media = [
      for (final f in files)
        if (f.isMedia) f,
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (media.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: Spacing.xs),
            child: _MediaGrid(
              url: url,
              media: media,
              onOpen: (index) {
                final before = leading?.call() ?? const <PostFile>[];
                openGallery(
                  context,
                  url: url,
                  media: [...before, ...media],
                  index: before.length + index,
                  heroPrefix: heroPrefix,
                  author: author,
                  sentAt: sentAt,
                );
              },
              heroPrefix: heroPrefix,
            ),
          ),
        for (final f in files)
          if (!f.isMedia) FileCard(url: url, file: f),
      ],
    );
  }
}

/// Opens [media] in the gallery at [index].
void openGallery(
  BuildContext context, {
  required String url,
  required List<PostFile> media,
  required int index,
  required String heroPrefix,
  required String author,
  required DateTime sentAt,
}) {
  // Coming back must not bring the keyboard up for a field that kept its
  // focus behind the gallery.
  FocusManager.instance.primaryFocus?.unfocus();
  unawaited(
    Navigator.of(context).push(
      galleryRoute(
        url: url,
        files: media,
        initialIndex: index,
        heroPrefix: heroPrefix,
        author: author,
        sentAt: sentAt,
      ),
    ),
  );
}

class _MediaGrid extends StatelessWidget {
  const _MediaGrid({
    required this.url,
    required this.media,
    required this.onOpen,
    required this.heroPrefix,
  });

  final String url;
  final List<PostFile> media;
  final ValueChanged<int> onOpen;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final maxHeight = imageMaxHeight(MediaQuery.sizeOf(context));
      final width = constraints.maxWidth;
      final grid = mediaGridRows(media.length);
      Widget tile(int index, Size size) => _MediaTile(
        url: url,
        file: media[index],
        size: size,
        heroTag: '$heroPrefix:${media[index].id}',
        more: index == 3 ? grid.hidden : 0,
        onTap: () => onOpen(index),
      );
      if (media.length == 1) {
        final file = media.single;
        final box =
            imageBox(
              measuredWidth: file.width,
              measuredHeight: file.height,
              maxWidth: width,
              maxHeight: maxHeight,
            ) ??
            (file.kind == FileKind.video
                ? Size(width, width * 9 / 16)
                : const Size.square(_unknownBox));
        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: tile(0, box),
        );
      }
      final rows = grid.rows;
      final rowHeight = [
        (width - _gap) / 2,
        (maxHeight - _gap * (rows.length - 1)) / rows.length,
      ].reduce((a, b) => a < b ? a : b);
      return Column(
        children: [
          for (final (r, row) in rows.indexed) ...[
            if (r > 0) const SizedBox(height: _gap),
            Row(
              children: [
                for (final (i, index) in row.indexed) ...[
                  if (i > 0) const SizedBox(width: _gap),
                  tile(
                    index,
                    Size(
                      (width - _gap * (row.length - 1)) / row.length,
                      rowHeight,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      );
    },
  );
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.url,
    required this.file,
    required this.size,
    required this.heroTag,
    required this.more,
    required this.onTap,
  });

  final String url;
  final PostFile file;
  final Size size;
  final String heroTag;

  /// Items beyond the grid, shown over this tile.
  final int more;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: file.kind == FileKind.video ? 'Video ${file.name}' : file.name,
      child: SizedBox.fromSize(
        size: size,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Spacing.sm),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: heroTag,
                child: MediaPicture(url: url, file: file, size: size),
              ),
              if (file.kind == FileKind.video)
                Center(
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Color(0x8A000000),
                      shape: BoxShape.circle,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.sm),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: size.shortestSide < 96 ? 20 : 36,
                      ),
                    ),
                  ),
                ),
              if (more > 0)
                ColoredBox(
                  color: const Color(0x99000000),
                  child: Center(
                    child: Text(
                      '+$more',
                      style: text.headlineSmall?.copyWith(color: Colors.white),
                    ),
                  ),
                ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onTap,
                  splashColor: scheme.primary.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A picture of [file] filling [size]: its preview (or, for a GIF, the
/// animated original), over the blurred tiny preview while it loads. A
/// video shows a dark tile.
class MediaPicture extends ConsumerWidget {
  const MediaPicture({
    required this.url,
    required this.file,
    required this.size,
    this.fit = BoxFit.cover,
    super.key,
  });

  final String url;
  final PostFile file;
  final Size size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final downloads = ref.watch(fileDownloadsProvider(url)).value;
    final mini = file.miniPreview;
    final placeholder = mini == null
        ? ColoredBox(color: scheme.surfaceContainerHighest)
        : ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Image.memory(
              mini,
              width: size.width,
              height: size.height,
              fit: fit,
              gaplessPlayback: true,
            ),
          );
    if (file.kind == FileKind.video) {
      return ColoredBox(
        color: Colors.black,
        child: Align(
          alignment: AlignmentDirectional.bottomStart,
          child: Padding(
            padding: const EdgeInsets.all(Spacing.sm),
            child: Text(
              [
                if (size.width >= 160) file.name,
                formatBytes(file.size),
              ].join(' · '),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: Colors.white),
            ),
          ),
        ),
      );
    }
    if (downloads == null) return placeholder;
    final source = file.kind == FileKind.image && file.hasPreview
        ? downloads.previewUri(file.id)
        : downloads.originalUri(file.id);
    return ServerImage(
      serverUrl: url,
      url: source.toString(),
      width: size.width,
      height: size.height,
      fit: fit,
      semanticLabel: file.name,
      placeholder: SizedBox.fromSize(size: size, child: placeholder),
    );
  }
}

/// A file that isn't an image or video: its type, name and size. A tap
/// downloads it with progress and opens it.
class FileCard extends ConsumerWidget {
  const FileCard({required this.url, required this.file, super.key});

  final String url;
  final PostFile file;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final transfers = ref.watch(fileTransfersProvider(url));
    final running = transfers.containsKey(file.id);
    final progress = transfers[file.id];
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.xs),
      child: Card.outlined(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsetsDirectional.only(
            start: Spacing.md,
            end: Spacing.xs,
          ),
          leading: Icon(
            fileIcon(file.kind, file.extension),
            color: tokens.accent,
          ),
          title: Text(file.name, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: running
              ? Padding(
                  padding: const EdgeInsets.only(top: Spacing.xs),
                  child: LinearProgressIndicator(value: progress),
                )
              : Text(
                  [
                    if (file.extension.isNotEmpty) file.extension.toUpperCase(),
                    formatBytes(file.size),
                  ].join(' · '),
                ),
          trailing: running
              ? IconButton(
                  tooltip: 'Cancel download',
                  icon: const Icon(Icons.close),
                  onPressed: () => ref
                      .read(fileTransfersProvider(url).notifier)
                      .cancel(file.id),
                )
              : FileActionsMenu(url: url, file: file),
          onTap: running
              ? null
              : () => _runFileAction(context, ref, url, file, _FileAction.view),
        ),
      ),
    );
  }
}

/// Opens a file outside a message (such as a channel bookmark): pictures
/// and videos in the gallery, anything else as a tap on its card would.
void openFile(
  BuildContext context,
  WidgetRef ref, {
  required String url,
  required PostFile file,
  required String author,
  required DateTime sentAt,
}) {
  if (file.isMedia) {
    openGallery(
      context,
      url: url,
      media: [file],
      index: 0,
      heroPrefix: 'file-${file.id}',
      author: author,
      sentAt: sentAt,
    );
  } else {
    unawaited(_runFileAction(context, ref, url, file, _FileAction.view));
  }
}

enum _FileAction { view, save, share, openWith }

/// Text files larger than this open in another app instead of our viewer.
const _textViewerLimit = 1024 * 1024;

/// Downloads [file] when needed, then shows, saves, shares or hands it on.
/// Failures show as a snack bar.
Future<void> _runFileAction(
  BuildContext context,
  WidgetRef ref,
  String url,
  PostFile file,
  _FileAction action,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  void say(String message) =>
      messenger.showSnackBar(SnackBar(content: Text(message)));
  final features = await ref.read(featuresProvider(url).future);
  final inApp =
      action == _FileAction.view &&
      (file.kind == FileKind.pdf ||
          (file.kind == FileKind.text && file.size <= _textViewerLimit));
  if (!features.fileDownloads && !inApp) {
    say(
      "This server doesn't allow taking files out of the app, so "
      '${file.name} can only be shown here.',
    );
    return;
  }
  final downloads = ref.read(fileDownloadsProvider(url).future)..ignore();
  File? local;
  try {
    local = await ref.read(fileTransfersProvider(url).notifier).fetch(file);
  } on FileTooLargeException catch (e) {
    say(
      '${file.name} is larger than ${formatBytes(e.limit)}, the most this '
      'server allows.',
    );
    return;
  } on ApiError catch (e) {
    say(
      "Couldn't download ${file.name}. "
      '${requestProblemText(e, Uri.parse(url).host)}',
    );
    return;
  }
  if (local == null) return;
  final handoff = (await downloads).handoffDirectory;
  switch (action) {
    case _FileAction.view when file.kind == FileKind.pdf:
      unawaited(navigator.push(pdfRoute(local, url: url, file: file)));
    case _FileAction.view
        when file.kind == FileKind.text && file.size <= _textViewerLimit:
      final text = await local.readAsString().catchError((_) => '');
      final code = text.endsWith('\n')
          ? text.substring(0, text.length - 1)
          : text;
      unawaited(
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => CodeScreen(
              code: code,
              language: languageOfExtension(file.extension),
              title: file.name,
              actions: [FileActionsMenu(url: url, file: file)],
            ),
          ),
        ),
      );
    case _FileAction.view || _FileAction.openWith:
      if (!await FileHandoff.open(local, file, handoff)) {
        say('No app on this phone opens ${file.name}.');
      }
    case _FileAction.share:
      await FileHandoff.share(local, file, handoff);
    case _FileAction.save:
      final saved = await FileHandoff.save(local, file, handoff);
      say(
        saved == null
            ? "Couldn't save ${file.name}."
            : 'Saved ${file.name} to ${_folderOf(file)}.',
      );
  }
}

/// Runs a gallery action on a media file.
Future<void> runMediaAction(
  BuildContext context,
  WidgetRef ref,
  String url,
  PostFile file,
  MediaAction action,
) => _runFileAction(context, ref, url, file, switch (action) {
  MediaAction.save => _FileAction.save,
  MediaAction.share => _FileAction.share,
  MediaAction.openWith => _FileAction.openWith,
});

enum MediaAction { save, share, openWith }

/// The three-dot menu every file viewer and card carries.
class FileActionsMenu extends ConsumerWidget {
  const FileActionsMenu({
    required this.url,
    required this.file,
    this.color,
    super.key,
  });

  final String url;
  final PostFile file;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Each action hands the file out of the app.
    if (!(ref.watch(featuresProvider(url)).value?.fileDownloads ?? true)) {
      return const SizedBox.shrink();
    }
    return PopupMenuButton<MediaAction>(
      tooltip: 'More',
      iconColor: color,
      onSelected: (action) => runMediaAction(context, ref, url, file, action),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: MediaAction.save,
          child: Text('Save to ${_folderOf(file)}'),
        ),
        const PopupMenuItem(value: MediaAction.share, child: Text('Share')),
        const PopupMenuItem(
          value: MediaAction.openWith,
          child: Text('Open with…'),
        ),
      ],
    );
  }
}

String _folderOf(PostFile file) => switch (file.kind) {
  FileKind.image || FileKind.gif => 'Pictures',
  FileKind.video => 'Movies',
  _ => 'Downloads',
};
