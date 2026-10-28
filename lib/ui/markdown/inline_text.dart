import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/domain/integration_blocks.dart';
import 'package:matterleast/markdown/links.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/context_menu.dart';
import 'package:matterleast/ui/emoji_card.dart';
import 'package:matterleast/ui/link_status.dart';
import 'package:matterleast/ui/markdown/inline_actions.dart';
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
  // Kept across rebuilds: a hover rebuilds the text in the middle of a
  // click, and a recognizer replaced then would drop that click.
  final _recognizers = <Object, GestureRecognizer>{};
  var _used = <Object>{};

  /// The link or name under the mouse.
  Object? _hovered;

  @override
  void dispose() {
    for (final r in _recognizers.values) {
      r.dispose();
    }
    super.dispose();
  }

  T _recognizer<T extends GestureRecognizer>(Object key, T Function() create) {
    _used.add(key);
    if (_recognizers[key] case final T same) return same;
    _recognizers[key]?.dispose();
    final made = create();
    _recognizers[key] = made;
    return made;
  }

  void _dropUnused() {
    _recognizers.removeWhere((key, r) {
      if (_used.contains(key)) return false;
      r.dispose();
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    _used = {};
    final env = PostEnvironment.maybeOf(context);
    final tokens = context.tokens;
    final base = widget.style;
    final fontSize = base.fontSize ?? 14;
    final emojiBox = fontSize * 1.25;
    final spans = <InlineSpan>[];
    final actions = InlineActions.maybeOf(context);
    InlineAction? action(String link) =>
        actions == null || env?.onAction == null
        ? null
        : parseInlineAction(link);

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
      if (link != null && isInlineActionLink(link)) {
        // An action looks like a small button where it can run.
        if (action(link) != null) {
          style = style.copyWith(
            color: tokens.accent,
            backgroundColor: tokens.accentWash,
            fontWeight: FontWeight.w600,
          );
        }
      } else if (link != null) {
        style = style.copyWith(color: tokens.accent);
      }
      return style;
    }

    GestureRecognizer? linkTap(int i, String? link) {
      if (link == null || env == null) return null;
      if (isInlineActionLink(link)) {
        final run = action(link);
        if (run == null) return null;
        return _recognizer<TapGestureRecognizer>(
          ('action', i),
          TapGestureRecognizer.new,
        )..onTap = () => env.onAction?.call(actions!.request(run));
      }
      return _recognizer<TapOrHoldRecognizer>((
        'link',
        i,
      ), TapOrHoldRecognizer.new)..update(
        onTapped: () => env.onLink(classifyLink(link, env.server)),
        onHeld: () => showLinkSheet(context, link, env),
        onRightClick: isDesktop
            ? (at) => showLinkMenu(context, link, at)
            : null,
        onMiddleClick: isDesktop
            ? () => env.onLink(classifyLink(link, env.server))
            : null,
      );
    }

    final status = LinkStatus.maybeOf(context);
    // Hover recolours a span, or only underlines it with [underlineOnly].
    TextSpan hoverable(
      Object? key,
      TextSpan span, {
      bool underlineOnly = false,
    }) {
      if (key == null || !isDesktop) return span;
      final style = span.style ?? const TextStyle();
      return TextSpan(
        text: span.text,
        recognizer: span.recognizer,
        mouseCursor: span.mouseCursor,
        style: _hovered != key
            ? style
            : style.copyWith(
                color: underlineOnly ? null : tokens.hoveredAccent,
                decoration: TextDecoration.combine([
                  TextDecoration.underline,
                  ?style.decoration,
                ]),
              ),
        onEnter: (_) {
          setState(() => _hovered = key);
          if (key case ('link', final String link)) status?.value = link;
        },
        onExit: (_) {
          // Also called when the text goes away under the mouse.
          if (key case ('link', final String link) when status?.value == link) {
            status?.value = null;
          }
          if (mounted && _hovered == key) setState(() => _hovered = null);
        },
      );
    }

    Object? linkKey(String? link) =>
        link == null || isInlineActionLink(link) ? null : ('link', link);

    for (final (i, part) in widget.inlines.indexed) {
      switch (part) {
        case TextPart(:final text, :final marks, :final link):
          spans.add(
            hoverable(
              linkKey(link),
              TextSpan(
                text: text,
                style: styled(marks, link: link),
                recognizer: linkTap(i, link),
              ),
            ),
          );
        case CodePart(:final text, :final marks, :final link):
          spans.add(
            hoverable(
              linkKey(link),
              TextSpan(
                text: text,
                style: styled(marks, link: link).copyWith(
                  fontFamily: 'monospace',
                  fontSize: fontSize * 0.92,
                  backgroundColor: seeThroughCode(tokens),
                ),
                recognizer: linkTap(i, link),
              ),
            ),
          );
        case MentionPart(:final name, :final marks):
          final lower = name.toLowerCase();
          final mine =
              _specialMentions.contains(lower) ||
              mentionedUsername(lower, {env?.myUsername ?? ''}) != null;
          spans.add(
            hoverable(
              ('part', i),
              TextSpan(
                text: '@$name',
                style: styled(marks).copyWith(
                  color: tokens.accent,
                  backgroundColor: mine ? tokens.accentWash : null,
                ),
                recognizer: env == null || _specialMentions.contains(lower)
                    ? null
                    : (_recognizer<TapGestureRecognizer>(
                        ('mention', i),
                        TapGestureRecognizer.new,
                      )..onTap = () => env.onMention(name)),
                mouseCursor: env == null || _specialMentions.contains(lower)
                    ? null
                    : SystemMouseCursors.click,
              ),
            ),
          );
        case ChannelPart(:final name, :final marks):
          spans.add(
            hoverable(
              ('part', i),
              TextSpan(
                text: '~${widget.channelNames[name] ?? name}',
                style: styled(marks).copyWith(color: tokens.accent),
                recognizer: env == null
                    ? null
                    : (_recognizer<TapGestureRecognizer>(
                        ('channel', i),
                        TapGestureRecognizer.new,
                      )..onTap = () => env.onChannel(name)),
                mouseCursor: env == null ? null : SystemMouseCursors.click,
              ),
            ),
          );
        case HashtagPart(:final tag, :final marks):
          final onHashtag = env?.onHashtag;
          spans.add(
            hoverable(
              ('part', i),
              TextSpan(
                text: '#$tag',
                style: styled(marks),
                recognizer: onHashtag == null
                    ? null
                    : (_recognizer<TapGestureRecognizer>(
                        ('hashtag', i),
                        TapGestureRecognizer.new,
                      )..onTap = () => onHashtag(tag)),
                mouseCursor: onHashtag == null
                    ? null
                    : SystemMouseCursors.click,
              ),
              underlineOnly: true,
            ),
          );
        case EmojiPart(:final name, :final literal, :final marks, :final link):
          final unicode = unicodeForName(name);
          final custom = unicode == null
              ? env?.customEmoji?.call(name, emojiBox)
              : null;
          // An emoji in a link stays part of the link.
          final named = link == null;
          void showCard() => showEmojiCard(
            context,
            name: name,
            serverUrl: env?.server.toString(),
          );
          if (unicode != null && named && isDesktop) {
            // A span can't carry a tooltip.
            spans.add(
              WidgetSpan(
                alignment: PlaceholderAlignment.baseline,
                baseline: TextBaseline.alphabetic,
                child: Tooltip(
                  message: ':$name:',
                  child: Text(unicode, style: base.merge(styled(marks))),
                ),
              ),
            );
          } else if (unicode != null) {
            spans.add(
              TextSpan(
                text: unicode,
                style: styled(marks, link: link),
                recognizer: named
                    ? (_recognizer<TapGestureRecognizer>((
                        'card',
                        i,
                      ), TapGestureRecognizer.new)..onTap = showCard)
                    : linkTap(i, link),
              ),
            );
          } else if (custom != null) {
            spans.add(
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: !named
                    ? custom
                    : isDesktop
                    ? Tooltip(message: ':$name:', child: custom)
                    : GestureDetector(onTap: showCard, child: custom),
              ),
            );
          } else {
            spans.add(
              TextSpan(
                text: literal,
                style: styled(marks, link: link),
                recognizer: linkTap(i, link),
              ),
            );
          }
        case MathPart(:final tex):
          spans.add(
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Semantics(
                label: tex,
                excludeSemantics: true,
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
            ),
          );
        case ImagePart(:final alt):
          spans.add(TextSpan(text: alt));
        case BreakPart():
          spans.add(const TextSpan(text: '\n'));
      }
    }
    if (widget.trailing != null) spans.add(widget.trailing!);
    _dropUnused();
    return Text.rich(TextSpan(children: spans), style: base);
  }
}

/// Pure: the code background as a see-through text shade, so a selection
/// (drawn under the text) still shows.
Color seeThroughCode(AppTokens tokens) {
  final page = tokens.page;
  final text = tokens.text;
  final code = tokens.codeBackground;
  final shares = [
    for (final (c, p, t) in [
      (code.r, page.r, text.r),
      (code.g, page.g, text.g),
      (code.b, page.b, text.b),
    ])
      if ((t - p).abs() > 0.02) (c - p) / (t - p),
  ];
  final alpha = shares.isEmpty
      ? 0.06
      : shares.reduce((a, b) => a + b) / shares.length;
  return text.withValues(alpha: alpha.clamp(0.02, 0.5));
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

/// Right click on a link: copy the address, at the pointer.
void showLinkMenu(BuildContext context, String url, Offset position) {
  final isMail = url.startsWith('mailto:');
  final shown = isMail ? url.substring(7) : url;
  // A left click opens it, so the menu only copies.
  unawaited(
    showMenuAt<VoidCallback>(context, position, [
      PopupMenuItem(
        value: () => unawaited(Clipboard.setData(ClipboardData(text: shown))),
        child: MenuEntry(
          icon: Icons.copy,
          label: isMail ? 'Copy email address' : 'Copy link',
        ),
      ),
    ]).then((picked) => picked?.call()),
  );
}

/// Long press on a link: open it, or copy the address.
void showLinkSheet(BuildContext context, String url, PostEnvironment env) {
  final isMail = url.startsWith('mailto:');
  final shown = isMail ? url.substring(7) : url;
  showAppSheet<void>(
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
