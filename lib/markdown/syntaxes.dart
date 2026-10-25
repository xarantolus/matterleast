import 'package:markdown/markdown.dart' as md;

// Ports of the inline rules of Mattermost's commonmark fork. Each produces an
// element with its own tag that the converter turns into an [Inline].

final _word = RegExp(r'\w');
final _whitespace = RegExp(r'\s');
final _delimiterBefore = RegExp(r'[*_~]');

/// True when the character before [pos] is absent or not a word character,
/// the rule most custom syntaxes share.
bool _afterNonWord(md.InlineParser parser, [int? pos]) {
  final at = pos ?? parser.pos;
  return at == 0 || !_word.hasMatch(parser.source[at - 1]);
}

String _before(md.InlineParser parser) =>
    parser.pos == 0 ? '' : parser.source[parser.pos - 1];

abstract class _GuardedSyntax extends md.InlineSyntax {
  _GuardedSyntax(super.pattern, {super.startCharacter, super.caseSensitive});

  bool allowedAt(md.InlineParser parser);

  @override
  bool tryMatch(md.InlineParser parser, [int? startMatchPos]) =>
      allowedAt(parser) && super.tryMatch(parser, startMatchPos);
}

/// `~~gone~~`. Needs two tildes, so a single `~` can start a channel link.
class StrikeSyntax extends md.DelimiterSyntax {
  StrikeSyntax()
    : super(
        '~+',
        requiresDelimiterRun: true,
        allowIntraWord: true,
        startCharacter: 0x7E,
        tags: [md.DelimiterTag('del', 2), md.DelimiterTag('del', 3)],
      );

  @override
  bool tryMatch(md.InlineParser parser, [int? startMatchPos]) {
    final at = startMatchPos ?? parser.pos;
    final source = parser.source;
    if (at + 1 >= source.length || source.codeUnitAt(at + 1) != 0x7E) {
      return false;
    }
    return super.tryMatch(parser, startMatchPos);
  }
}

class AtMentionSyntax extends _GuardedSyntax {
  AtMentionSyntax()
    : super(
        r'@([a-z][a-z0-9._-]*)',
        startCharacter: 0x40,
        caseSensitive: false,
      );

  @override
  bool allowedAt(md.InlineParser parser) => _afterNonWord(parser);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.empty('mention')..attributes['name'] = match[1]!);
    return true;
  }
}

class ChannelLinkSyntax extends _GuardedSyntax {
  ChannelLinkSyntax()
    : super(r'~([a-z0-9_-]+)', startCharacter: 0x7E, caseSensitive: false);

  @override
  bool allowedAt(md.InlineParser parser) => _afterNonWord(parser);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.empty('channel')..attributes['name'] = match[1]!);
    return true;
  }
}

class EmojiSyntax extends _GuardedSyntax {
  // `\B` after the closing colon: the next character is not a word character.
  EmojiSyntax()
    : super(
        r':([a-z0-9_\-+]+):(?!\w)',
        startCharacter: 0x3A,
        caseSensitive: false,
      );

  @override
  bool allowedAt(md.InlineParser parser) => _afterNonWord(parser);

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(
      md.Element.empty('emoji')
        ..attributes['name'] = match[1]!
        ..attributes['literal'] = match[0]!,
    );
    return true;
  }
}

const _emoticonNames = [
  'slightly_smiling_face',
  'wink',
  'open_mouth',
  'scream',
  'smirk',
  'smile',
  'stuck_out_tongue_closed_eyes',
  'stuck_out_tongue',
  'rage',
  'slightly_frowning_face',
  'cry',
  'confused',
  'confounded',
  'neutral_face',
  'flushed',
  'mask',
  'heart',
  'broken_heart',
];

class EmoticonSyntax extends _GuardedSyntax {
  EmoticonSyntax()
    : super(
        r'(?:(:-?\))|(;-?\))|(:o)|(:-o)|(:-?])|(:-?d)|(x-d)|(:-?p)|(:-?[[@])'
        r"|(:-?\()|(:[`'’]-?\()|(:-?\/)|(:-?s)|(:-?\|)|(:-?\$)|(:-x)|(<3)"
        r'|(<\/3))(?=$|\W)',
        caseSensitive: false,
      );

  static const _starts = {0x3A, 0x3B, 0x78, 0x58, 0x3C};

  @override
  bool allowedAt(md.InlineParser parser) {
    if (!_starts.contains(parser.charAt(parser.pos))) return false;
    final before = _before(parser);
    return before.isEmpty ||
        _whitespace.hasMatch(before) ||
        !_word.hasMatch(before);
  }

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    var name = '';
    for (var i = 0; i < _emoticonNames.length; i++) {
      if (match[i + 1] != null) name = _emoticonNames[i];
    }
    parser.addNode(
      md.Element.empty('emoji')
        ..attributes['name'] = name
        ..attributes['literal'] = match[0]!,
    );
    return true;
  }
}

class HashtagSyntax extends _GuardedSyntax {
  HashtagSyntax(this.minimumLength) : super('(?!)', startCharacter: 0x23);

  final int minimumLength;

  static final _pattern = RegExp(
    r'#(\p{L}[\p{L}\d\-_.]*[\p{L}\d])',
    unicode: true,
  );

  @override
  bool allowedAt(md.InlineParser parser) =>
      _afterNonWord(parser) || _delimiterBefore.hasMatch(_before(parser));

  @override
  bool tryMatch(md.InlineParser parser, [int? startMatchPos]) {
    if (parser.charAt(parser.pos) != 0x23 || !allowedAt(parser)) return false;
    final match = _pattern.matchAsPrefix(parser.source, parser.pos);
    if (match == null || match[1]!.length < minimumLength) return false;
    parser.writeText();
    onMatch(parser, match);
    parser.consume(match[0]!.length);
    return true;
  }

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(md.Element.empty('hashtag')..attributes['tag'] = match[1]!);
    return true;
  }
}

class InlineLatexSyntax extends _GuardedSyntax {
  InlineLatexSyntax() : super(r'\$([^\$\n]+)\$(?!\w)', startCharacter: 0x24);

  @override
  bool allowedAt(md.InlineParser parser) =>
      _afterNonWord(parser) || _delimiterBefore.hasMatch(_before(parser));

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    parser.addNode(
      md.Element.empty('math')..attributes['tex'] = match[1]!.trim(),
    );
    return true;
  }
}

final _url = RegExp(
  r'''(?:[a-z][a-z\d\-.+]*:(?:\/{1,3}|[\p{L}\d%])|www\d{0,3}[.]|[\p{L}\d.\-]+[.]\p{L}{2,4}\/)'''
  r'''(?:\[[\da-f:]+\]|[^\s`!()\[\]{;:'",<>?«»“”‘’*_]|[*_]+(?=[^_*\s])|'''
  r'''[`!\[\]{;:'",<>?«»“”‘’](?=[^\s()<>])|\((?:[^\s()<>]|(?:\([^\s()<>]+\)))*\))+''',
  caseSensitive: false,
  unicode: true,
);

final _schemeOrWww = RegExp(
  r'^(?:[a-z][a-z\d\-.+]*:|www\d{0,3}[.])',
  caseSensitive: false,
);

// Mattermost's parser reads ordinary text in runs that end only at these
// characters, so a link without a scheme or `www.` is found only right after
// one of them.
const _textBreaks = '\n`[]\\!<&*_\'"@:;xX~#\$';

final _trailingPunctuation = RegExp(r'''[?!.,:*_~'"]$''');

/// Bare `https://…`, `www.…` and `host.tld/…`, after a non-word character
/// or `_`, with trailing punctuation left out of the link.
class BareUrlSyntax extends md.InlineSyntax {
  BareUrlSyntax() : super('(?!)');

  @override
  bool tryMatch(md.InlineParser parser, [int? startMatchPos]) {
    final at = parser.pos;
    final first = parser.source.codeUnitAt(at);
    final isAlnum =
        (first >= 0x30 && first <= 0x39) ||
        (first >= 0x41 && first <= 0x5A) ||
        (first >= 0x61 && first <= 0x7A) ||
        first > 0x7F;
    if (!isAlnum) return false;
    if (!(_afterNonWord(parser) || _before(parser) == '_')) return false;
    final match = _url.matchAsPrefix(parser.source, at);
    if (match == null) return false;
    var url = match[0]!;
    if (!_schemeOrWww.hasMatch(url) &&
        at > 0 &&
        !_textBreaks.contains(parser.source[at - 1])) {
      return false;
    }
    while (_trailingPunctuation.hasMatch(url)) {
      url = url.substring(0, url.length - 1);
    }
    if (url.isEmpty) return false;
    parser.writeText();
    parser.addNode(md.Element('a', [md.Text(url)])..attributes['href'] = url);
    parser.consume(url.length);
    return true;
  }

  @override
  bool onMatch(md.InlineParser parser, Match match) => false;
}

const _emailChars = r"\p{L}\d!#$%&'*+\-/=?^_`{|}~";
final _email = RegExp(
  '(?:[$_emailChars](?:[$_emailChars]|\\.(?!\\.|@))*)@'
  r'[\p{L}\d.\-]+[.]\p{L}{2,4}(?=$|[^\p{L}])',
  unicode: true,
);

/// Cheap check before the regex: an `@` within the next 64 characters,
/// before any whitespace.
bool _atSignAhead(String source, int at) {
  final end = at + 65 < source.length ? at + 65 : source.length;
  for (var i = at + 1; i < end; i++) {
    final c = source.codeUnitAt(i);
    if (c == 0x40) return true;
    if (c == 0x20 || c == 0x0A || c == 0x09) return false;
  }
  return false;
}

/// Bare `name@host.tld`, linked as `mailto:`.
class BareEmailSyntax extends md.InlineSyntax {
  BareEmailSyntax() : super('(?!)');

  @override
  bool tryMatch(md.InlineParser parser, [int? startMatchPos]) {
    if (!_afterNonWord(parser)) return false;
    final source = parser.source;
    final at = parser.pos;
    if (!_atSignAhead(source, at)) return false;
    final match = _email.matchAsPrefix(source, at);
    if (match == null) return false;
    final address = match[0]!;
    parser.writeText();
    parser.addNode(
      md.Element('a', [md.Text(address)])
        ..attributes['href'] = 'mailto:$address',
    );
    parser.consume(address.length);
    return true;
  }

  @override
  bool onMatch(md.InlineParser parser, Match match) => false;
}

/// `![alt](url =WxH "title")`, `=W` or `=xH`: the size part the standard
/// image syntax doesn't know.
class SizedImageSyntax extends md.InlineSyntax {
  SizedImageSyntax()
    : super(
        r'!\[([^\[\]]*)\]\(\s*<?([^\s<>()]+)>?\s+=(\d*)(?:x(\d*))?'
        r'(?:\s+"[^"]*")?\s*\)',
        startCharacter: 0x21,
      );

  @override
  bool onMatch(md.InlineParser parser, Match match) {
    final element = md.Element.empty('img')
      ..attributes['src'] = match[2]!
      ..attributes['alt'] = match[1]!;
    if (match[3]?.isNotEmpty ?? false) element.attributes['width'] = match[3]!;
    if (match[4]?.isNotEmpty ?? false) {
      element.attributes['height'] = match[4]!;
    }
    parser.addNode(element);
    return true;
  }
}
