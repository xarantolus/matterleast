import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/markdown/links.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/markdown/link_gestures.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/tokens.dart';

const _specialMentions = {'here', 'channel', 'all'};

/// One paragraph, heading or cell: a single [Text.rich], so the pieces wrap
/// together. Owns the recognizers of its links and mentions.
class InlineText extends StatefulWidget {
  const InlineText({
    required this.inlines,
    required this.style,
    this.trailing,
    this.channelNames = const {},
    super.key,
  });

  final List<Inline> inlines;
  final TextStyle style;

  /// Appended after the text, such as "(edited)".
  final InlineSpan? trailing;

  /// Display names of channels the post mentions, by name.
  final Map<String, String> channelNames;

  @override
  State<InlineText> createState() => _InlineTextState();
}

class _InlineTextState extends State<InlineText> {
  final _recognizers = <GestureRecognizer>[];

  void _clear() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _clear();
    super.dispose();
  }

  T _keep<T extends GestureRecognizer>(T recognizer) {
    _recognizers.add(recognizer);
    return recognizer;
  }

  @override
  Widget build(BuildContext context) {
    _clear();
    final env = PostEnvironment.maybeOf(context);
    final tokens = context.tokens;
    final base = widget.style;
    final fontSize = base.fontSize ?? 14;
    final emojiBox = fontSize * 1.25;
    final spans = <InlineSpan>[];

    TextStyle styled(int marks, {String? link}) {
      var style = const TextStyle();
      if (marks & Marks.bold != 0) {
        style = style.copyWith(fontWeight: FontWeight.w700);
      }
      if (marks & Marks.italic != 0) {
        style = style.copyWith(fontStyle: FontStyle.italic);
      }
      if (marks & Marks.strike != 0) {
        style = style.copyWith(decoration: TextDecoration.lineThrough);
      }
      if (link != null) style = style.copyWith(color: tokens.accent);
      return style;
    }

    GestureRecognizer? linkTap(String? link) {
      if (link == null || env == null) return null;
      return _keep(
        TapOrHoldRecognizer(
          onTapped: () => env.onLink(classifyLink(link, env.server)),
          onHeld: () => showLinkSheet(context, link, env),
        ),
      );
    }

    for (final part in widget.inlines) {
      switch (part) {
        case TextPart(:final text, :final marks, :final link):
          spans.add(
            TextSpan(
              text: text,
              style: styled(marks, link: link),
              recognizer: linkTap(link),
            ),
          );
        case CodePart(:final text, :final marks, :final link):
          spans.add(
            TextSpan(
              text: text,
              style: styled(marks, link: link).copyWith(
                fontFamily: 'monospace',
                fontSize: fontSize * 0.92,
                backgroundColor: tokens.codeBackground,
              ),
              recognizer: linkTap(link),
            ),
          );
        case MentionPart(:final name, :final marks):
          final lower = name.toLowerCase();
          final mine =
              _specialMentions.contains(lower) ||
              mentionedUsername(lower, {env?.myUsername ?? ''}) != null;
          spans.add(
            TextSpan(
              text: '@$name',
              style: styled(marks).copyWith(
                color: tokens.accent,
                backgroundColor: mine ? tokens.accentWash : null,
              ),
              recognizer: env == null || _specialMentions.contains(lower)
                  ? null
                  : _keep(
                      TapGestureRecognizer()..onTap = () => env.onMention(name),
                    ),
            ),
          );
        case ChannelPart(:final name, :final marks):
          spans.add(
            TextSpan(
              text: '~${widget.channelNames[name] ?? name}',
              style: styled(marks).copyWith(color: tokens.accent),
              recognizer: env == null
                  ? null
                  : _keep(
                      TapGestureRecognizer()..onTap = () => env.onChannel(name),
                    ),
            ),
          );
        case HashtagPart(:final tag, :final marks):
          spans.add(
            TextSpan(
              text: '#$tag',
              style: styled(marks).copyWith(color: tokens.accent),
            ),
          );
        case EmojiPart(:final name, :final literal, :final marks, :final link):
          final unicode = unicodeForName(name);
          final custom = unicode == null
              ? env?.customEmoji?.call(name, emojiBox)
              : null;
          if (unicode != null) {
            spans.add(
              TextSpan(
                text: unicode,
                style: styled(marks, link: link),
              ),
            );
          } else if (custom != null) {
            spans.add(
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Tooltip(message: ':$name:', child: custom),
              ),
            );
          } else {
            spans.add(
              TextSpan(
                text: literal,
                style: styled(marks, link: link),
                recognizer: linkTap(link),
              ),
            );
          }
        case MathPart(:final tex):
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Math.tex(
                tex,
                mathStyle: MathStyle.text,
                textStyle: base.copyWith(color: base.color),
                onErrorFallback: (_) => Text(
                  '\$$tex\$',
                  style: base.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
          );
        case ImagePart(:final alt):
          spans.add(TextSpan(text: alt));
        case BreakPart():
          spans.add(const TextSpan(text: '\n'));
      }
    }
    if (widget.trailing != null) spans.add(widget.trailing!);
    return Text.rich(TextSpan(children: spans), style: base);
  }
}

/// Pure: which of [usernames] a typed `@name` refers to. Mattermost lets a
/// mention end in `.`, `-` or `_` that belongs to the sentence, so those are
/// trimmed one at a time until a name matches.
String? mentionedUsername(String typed, Set<String> usernames) {
  var name = typed.toLowerCase();
  while (name.isNotEmpty) {
    if (usernames.contains(name)) return name;
    final last = name[name.length - 1];
    if (last != '.' && last != '-' && last != '_') return null;
    name = name.substring(0, name.length - 1);
  }
  return null;
}

/// Long press on a link: open it, or copy the address.
void showLinkSheet(BuildContext context, String url, PostEnvironment env) {
  final isMail = url.startsWith('mailto:');
  final shown = isMail ? url.substring(7) : url;
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheet) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              0,
              Spacing.lg,
              Spacing.sm,
            ),
            child: Text(
              shown,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(sheet).textTheme.bodySmall,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.open_in_new),
            title: const Text('Open'),
            onTap: () {
              Navigator.pop(sheet);
              env.onLink(classifyLink(url, env.server));
            },
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: Text(isMail ? 'Copy email address' : 'Copy link'),
            onTap: () {
              Clipboard.setData(ClipboardData(text: shown));
              Navigator.pop(sheet);
            },
          ),
        ],
      ),
    ),
  );
}
