import 'package:matterleast/markdown/post_doc.dart';

/// Something in a message a screen reader user can act on from the
/// message's actions menu.
sealed class SpokenTarget {
  const SpokenTarget();
}

class SpokenLink extends SpokenTarget {
  const SpokenLink(this.text, this.url);

  /// The link text as shown.
  final String text;
  final String url;
}

class SpokenMention extends SpokenTarget {
  const SpokenMention(this.name);

  final String name;
}

class SpokenChannel extends SpokenTarget {
  const SpokenChannel(this.name, this.shown);

  final String name;
  final String shown;
}

/// A message as a screen reader says it: the text without markup, and
/// the links, mentions and channels in it, each once.
class SpokenPost {
  const SpokenPost(this.text, this.targets, {this.inlineActions = false});

  final String text;
  final List<SpokenTarget> targets;

  /// The text holds buttons of an integration, which only work as shown.
  final bool inlineActions;
}

const _specialMentions = {'all', 'channel', 'here'};

/// Pure: [doc] in words. Emoji become their character, which TalkBack
/// names, or their name; images their alt text.
SpokenPost spokenPost(
  PostDoc doc, {
  required String? Function(String name) unicode,
  Map<String, String> channelNames = const {},
}) {
  switch (doc) {
    case TooLongPost():
      return const SpokenPost(
        'This message is too long to be shown on a mobile device.',
        [],
      );
    case PlainPost(:final text):
      return SpokenPost(text, const []);
    case ParsedPost(:final blocks):
      final walker = _Walker(unicode, channelNames)..blocks(blocks);
      return SpokenPost(
        walker.lines.where((l) => l.isNotEmpty).join('\n'),
        walker.targets.values.toList(),
        inlineActions: walker.inlineActions,
      );
  }
}

class _Walker {
  _Walker(this.unicode, this.channelNames);

  final String? Function(String name) unicode;
  final Map<String, String> channelNames;
  final lines = <String>[];
  final targets = <String, SpokenTarget>{};
  var inlineActions = false;

  void blocks(List<Block> blocks) {
    for (final block in blocks) {
      switch (block) {
        case Paragraph(:final inlines) || Heading(:final inlines):
          lines.add(this.inlines(inlines));
        case CodeBlock(:final code):
          lines.add(code.trimRight());
        case MathBlock(:final tex):
          lines.add(tex);
        case Quote(blocks: final inner):
          this.blocks(inner);
        case ListBlock(:final items):
          for (final item in items) {
            final start = lines.length;
            this.blocks(item.blocks);
            if (item.checked case final done? when lines.length > start) {
              lines[start] = '${done ? 'Done' : 'Not done'}: ${lines[start]}';
            }
          }
        case TableBlock(:final rows):
          for (final row in rows) {
            lines.add([for (final cell in row) inlines(cell)].join(', '));
          }
        case Rule():
          break;
      }
    }
  }

  String inlines(List<Inline> parts) {
    final out = StringBuffer();
    String? link;
    final linkText = StringBuffer();
    void endLink() {
      final url = link;
      if (url == null) return;
      if (url.startsWith('mmaction://')) {
        inlineActions = true;
      } else {
        final text = linkText.toString().trim();
        targets.putIfAbsent(
          'link:$url',
          () => SpokenLink(text.isEmpty ? url : text, url),
        );
      }
      link = null;
      linkText.clear();
    }

    for (final part in parts) {
      if (part.link != link) endLink();
      link = part.link;
      final words = switch (part) {
        TextPart(:final text) || CodePart(:final text) => text,
        MentionPart(:final name) => '@$name',
        ChannelPart(:final name) => '~${channelNames[name] ?? name}',
        HashtagPart(:final tag) => '#$tag',
        EmojiPart(:final name) => unicode(name) ?? name.replaceAll('_', ' '),
        MathPart(:final tex) => tex,
        ImagePart(:final alt) => alt.isEmpty ? 'image' : alt,
        BreakPart() => '\n',
      };
      if (link != null) linkText.write(words);
      out.write(words);
      switch (part) {
        case MentionPart(:final name)
            when !_specialMentions.contains(name.toLowerCase()):
          targets.putIfAbsent(
            'mention:${name.toLowerCase()}',
            () => SpokenMention(name),
          );
        case ChannelPart(:final name):
          targets.putIfAbsent(
            'channel:$name',
            () => SpokenChannel(name, channelNames[name] ?? name),
          );
        default:
      }
    }
    endLink();
    return out.toString().trim();
  }
}
