import 'dart:async';
import 'dart:io';
import 'dart:ui' show ImageFilter;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/file_providers.dart';
import 'package:matterleast/data/files/file_downloads.dart';
import 'package:matterleast/data/files/file_handoff.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/screens/gallery/gallery_screen.dart';
import 'package:matterleast/screens/gallery/pdf_screen.dart';
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
    super.key,
  });

  final List<PostFile> files;

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
              onOpen: (index) => Navigator.of(context).push(
                galleryRoute(
                  url: url,
                  files: media,
                  initialIndex: index,
                  heroPrefix: heroPrefix,
                  author: author,
                  sentAt: sentAt,
                ),
              ),
              heroPrefix: heroPrefix,
            ),
          ),
        for (final f in files)
          if (!f.isMedia) FileCard(url: url, file: f),
      ],
    );
  }
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
      final screen = MediaQuery.sizeOf(context);
      final maxHeight = screen.longestSide * 0.45;
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
          leading: Icon(_iconOf(file), color: tokens.accent),
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
              : PopupMenuButton<_FileAction>(
                  tooltip: 'More',
                  onSelected: (action) =>
                      _runFileAction(context, ref, url, file, action),
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: _FileAction.save,
                      child: Text('Save to Downloads'),
                    ),
                    PopupMenuItem(
                      value: _FileAction.share,
                      child: Text('Share'),
                    ),
                    PopupMenuItem(
                      value: _FileAction.openWith,
                      child: Text('Open with…'),
                    ),
                  ],
                ),
          onTap: running
              ? null
              : () => _runFileAction(context, ref, url, file, _FileAction.view),
        ),
      ),
    );
  }
}

IconData _iconOf(PostFile file) => switch (file.kind) {
  FileKind.pdf => Icons.picture_as_pdf_outlined,
  FileKind.text => Icons.description_outlined,
  FileKind.image || FileKind.gif => Icons.image_outlined,
  FileKind.video => Icons.movie_outlined,
  FileKind.other => switch (file.extension) {
    'zip' || 'gz' || 'tar' || '7z' || 'rar' => Icons.folder_zip_outlined,
    'mp3' || 'ogg' || 'wav' || 'm4a' || 'flac' => Icons.audio_file_outlined,
    _ => Icons.insert_drive_file_outlined,
  },
};

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
  File? local;
  try {
    local = await ref.read(fileTransfersProvider(url).notifier).fetch(file);
  } on FileTooLargeException catch (e) {
    say(
      '${file.name} is larger than ${formatBytes(e.limit)}, the most this '
      'server allows.',
    );
    return;
  } on ApiError {
    say("Couldn't download ${file.name}. Check the connection and try again.");
    return;
  }
  if (local == null) return;
  switch (action) {
    case _FileAction.view when file.kind == FileKind.pdf:
      unawaited(navigator.push(pdfRoute(local, file.name)));
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
            ),
          ),
        ),
      );
    case _FileAction.view || _FileAction.openWith:
      if (!await FileHandoff.open(local, file)) {
        say('No app on this phone opens ${file.name}.');
      }
    case _FileAction.share:
      await FileHandoff.share(local, file);
    case _FileAction.save:
      final saved = await FileHandoff.save(local, file);
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

String _folderOf(PostFile file) => switch (file.kind) {
  FileKind.image || FileKind.gif => 'Pictures',
  FileKind.video => 'Movies',
  _ => 'Downloads',
};
