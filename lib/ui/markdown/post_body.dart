import 'package:flutter_math_fork/flutter_math.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/json/post_extras.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/data/images/image_rules.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/markdown/markdown_cache.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/markdown/spoken_post.dart';
import 'package:matterleast/ui/markdown/code_block.dart';
import 'package:matterleast/ui/markdown/image_box.dart';
import 'package:matterleast/ui/markdown/inline_text.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/markdown/show_more.dart';
import 'package:matterleast/ui/markdown/table_block.dart';
import 'package:matterleast/ui/message_display.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/top_notice.dart';

final markdownCache = MarkdownCache();

/// A message's formatted text. Parses once per message version (cached),
/// then only lays out blocks.
class PostBody extends StatelessWidget {
  const PostBody({
    required this.postId,
    required this.message,
    this.editAt,
    this.edited = false,
    this.imageSizes = const {},
    this.channelNames = const {},
    this.unsafeLinks = false,
    this.collapsible = true,
    this.style,
    super.key,
  });

  final String postId;
  final String message;
  final DateTime? editAt;
  final bool edited;

  /// `metadata.images`: only images the server measured are shown.
  final Map<String, ImageSize> imageSizes;
  final Map<String, String> channelNames;
  final bool unsafeLinks;
  final bool collapsible;

  /// Replaces the body text style, for lines quieter than a message.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final env = PostEnvironment.maybeOf(context);
    var options = env?.options ?? const ParseOptions();
    if (unsafeLinks) options = options.copyWith(unsafeLinks: true);
    final doc = markdownCache.get(postId, editAt, message, options);
    final tokens = context.tokens;
    final scale = MessageDisplay.of(context).textScale;
    final body =
        (style ??
                Theme.of(context).textTheme.bodyMedium!
                    .copyWith(color: tokens.text))
            .forMessages(context);
    final editedAt = editAt;
    final editedSpan = edited && editedAt != null
        ? WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: EditedMark(
              editAt: editedAt,
              style: body.copyWith(color: tokens.muted, fontSize: 12 * scale),
            ),
          )
        : null;
    final content = switch (doc) {
      TooLongPost() => Text(
        'This message is too long to be shown fully on a mobile device. '
        'Open it on a computer to read it.',
        style: body.copyWith(color: tokens.muted, fontStyle: FontStyle.italic),
      ),
      PlainPost(:final text) => Text.rich(
        TextSpan(text: text, children: [?editedSpan]),
        style: body,
      ),
      ParsedPost(:final blocks) => _Blocks(
        blocks: blocks,
        style: isJumbo(blocks)
            ? body.copyWith(fontSize: 32 * scale, height: 1.25)
            : body,
        trailing: editedSpan,
        images: imageSizes,
        channelNames: channelNames,
      ),
    };
    return collapsible ? ShowMore(id: postId, child: content) : content;
  }
}

final _spoken = Expando<SpokenPost>();

/// A message's text as a screen reader says it, worked out once per
/// parsed version.
SpokenPost spokenMessage(
  BuildContext context, {
  required String postId,
  required String message,
  DateTime? editAt,
  bool unsafeLinks = false,
  Map<String, String> channelNames = const {},
}) {
  var options =
      context.getInheritedWidgetOfExactType<PostEnvironment>()?.options ??
      const ParseOptions();
  if (unsafeLinks) options = options.copyWith(unsafeLinks: true);
  final doc = markdownCache.get(postId, editAt, message, options);
  return _spoken[doc] ??= spokenPost(
    doc,
    unicode: unicodeForName,
    channelNames: channelNames,
  );
}

/// The pictures written into a message's text, in reading order, as the
/// gallery takes them.
List<PostFile> messageImages(
  BuildContext context, {
  required String postId,
  required String message,
  DateTime? editAt,
  bool unsafeLinks = false,
  Map<String, ImageSize> sizes = const {},
}) {
  var options =
      context.getInheritedWidgetOfExactType<PostEnvironment>()?.options ??
      const ParseOptions();
  if (unsafeLinks) options = options.copyWith(unsafeLinks: true);
  final doc = markdownCache.get(postId, editAt, message, options);
  if (doc is! ParsedPost) return const [];
  final urls = <String>{};
  void walk(List<Block> blocks) {
    for (final block in blocks) {
      switch (block) {
        case Paragraph(:final inlines) || Heading(:final inlines):
          for (final part in inlines) {
            if (part is ImagePart && canLoadImage(part.url)) urls.add(part.url);
          }
        case Quote(:final blocks):
          walk(blocks);
        case ListBlock(:final items):
          for (final item in items) {
            walk(item.blocks);
          }
        default:
      }
    }
  }

  walk(doc.blocks);
  return [
    for (final url in urls)
      PostFile.link(
        url,
        width: sizes[url]?.width,
        height: sizes[url]?.height,
        format: sizes[url]?.format,
      ),
  ];
}

/// Pure: a message of nothing but up to eight emoji is shown large.
bool isJumbo(List<Block> blocks) {
  if (blocks case [Paragraph(:final inlines)]) {
    var emoji = 0;
    for (final part in inlines) {
      switch (part) {
        case EmojiPart(link: null, marks: 0):
          emoji++;
        case TextPart(:final text, link: null) when text.trim().isEmpty:
          continue;
        default:
          return false;
      }
    }
    return emoji > 0 && emoji <= 8;
  }
  return false;
}

class _Blocks extends StatelessWidget {
  const _Blocks({
    required this.blocks,
    required this.style,
    required this.images,
    required this.channelNames,
    this.trailing,
  });

  final List<Block> blocks;
  final TextStyle style;
  final InlineSpan? trailing;
  final Map<String, ImageSize> images;
  final Map<String, String> channelNames;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (final (index, block) in blocks.indexed) {
      final last = index == blocks.length - 1;
      if (index > 0) children.add(const SizedBox(height: Spacing.sm));
      children.add(_block(context, block, last ? trailing : null));
    }
    if (trailing != null &&
        blocks.isNotEmpty &&
        blocks.last is! Paragraph &&
        blocks.last is! Heading) {
      children.add(Text.rich(TextSpan(children: [trailing!]), style: style));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }

  Widget _text(List<Inline> inlines, TextStyle style, [InlineSpan? trailing]) =>
      InlineText(
        inlines: inlines,
        style: style,
        trailing: trailing,
        channelNames: channelNames,
      );

  Widget _block(BuildContext context, Block block, InlineSpan? trailing) {
    final tokens = context.tokens;
    switch (block) {
      case Paragraph(:final inlines):
        return _paragraph(inlines, trailing);
      case Heading(:final level, :final inlines):
        return _text(inlines, headingStyle(style, level), trailing);
      case CodeBlock(:final code, :final language):
        return CodePreview(code: code, language: language);
      case MathBlock(:final tex):
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Math.tex(
            tex,
            textStyle: style,
            onErrorFallback: (_) => CodePreview(code: tex, language: 'latex'),
          ),
        );
      case Quote(:final blocks):
        return Container(
          padding: const EdgeInsetsDirectional.only(start: Spacing.md),
          decoration: BoxDecoration(
            border: BorderDirectional(
              start: BorderSide(color: tokens.divider, width: 3),
            ),
          ),
          child: _Blocks(
            blocks: blocks,
            style: style.copyWith(color: tokens.muted),
            images: images,
            channelNames: channelNames,
          ),
        );
      case ListBlock(:final items, :final ordered, :final start):
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, item) in items.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.textScalerOf(context)
                          .scale(24 * MessageDisplay.of(context).textScale),
                      child: switch (item.checked) {
                        final bool done => Icon(
                          done
                              ? Icons.check_box
                              : Icons.check_box_outline_blank,
                          size: (style.fontSize ?? 14) * 1.3,
                          color: done ? tokens.accent : tokens.muted,
                        ),
                        null => Text(
                          ordered ? '${start + i}.' : '•',
                          style: style.copyWith(color: tokens.muted),
                        ),
                      },
                    ),
                    Expanded(
                      child: _Blocks(
                        blocks: item.blocks,
                        style: style,
                        images: images,
                        channelNames: channelNames,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      case TableBlock():
        return TablePreview(table: block);
      case Rule():
        return const Divider(height: Spacing.md);
    }
  }

  /// Images stand on their own lines between the text around them.
  Widget _paragraph(List<Inline> inlines, InlineSpan? trailing) {
    if (!inlines.any((i) => i is ImagePart)) {
      return _text(inlines, style, trailing);
    }
    final parts = <Widget>[];
    var run = <Inline>[];
    void flush() {
      if (run.any((i) => i is! TextPart || i.text.trim().isNotEmpty)) {
        parts.add(_text(run, style));
      }
      run = [];
    }

    for (final part in inlines) {
      if (part is ImagePart) {
        flush();
        parts.add(MessageImage(image: part, measured: images[part.url]));
      } else {
        run.add(part);
      }
    }
    flush();
    if (trailing != null) {
      parts.add(Text.rich(TextSpan(children: [trailing]), style: style));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts,
    );
  }
}

TextStyle headingStyle(TextStyle base, int level) {
  final size = base.fontSize ?? 14;
  return base.copyWith(
    fontSize: size * const [1.6, 1.4, 1.25, 1.12, 1.0, 0.92][level - 1],
    fontWeight: level <= 2 ? FontWeight.w700 : FontWeight.w600,
    height: 1.3,
  );
}

/// "(edited)" after a message; a tap tells when.
class EditedMark extends StatelessWidget {
  const EditedMark({required this.editAt, required this.style, super.key});

  final DateTime editAt;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    hint: 'Shows when',
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showTopNotice(
        context,
        icon: Icons.edit_outlined,
        text:
            'Edited ${momentLabel(editAt, DateTime.now(), use24: MediaQuery.alwaysUse24HourFormatOf(context))}',
      ),
      child: Text(' (edited)', style: style),
    ),
  );
}
