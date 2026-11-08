import 'package:flutter/foundation.dart';
import 'package:matterleast/domain/notify_props.dart';

/// Why a stretch of text is marked.
enum Highlight { none, mention, keyword }

/// A mention word and whether capitals count.
@immutable
class MentionKey {
  const MentionKey(this.key, {this.caseSensitive = false});

  final String key;
  final bool caseSensitive;

  @override
  bool operator ==(Object other) =>
      other is MentionKey &&
      other.key == key &&
      other.caseSensitive == caseSensitive;

  @override
  int get hashCode => Object.hash(key, caseSensitive);
}

/// The words a message marks for its reader: Mattermost's mention words
/// (they notify) and highlight words (they don't).
@immutable
class MentionKeys {
  const MentionKeys({
    this.mentions = const [],
    this.highlights = const [],
    this.broadcast = false,
  });

  /// As the webapp builds them: the user's mention words, the first name
  /// when asked for (capitals count), and `@username`.
  factory MentionKeys.forUser({
    required String username,
    required String firstName,
    required NotifyProps props,
  }) {
    final mentions = <MentionKey>[
      for (final key in (props.raw['mention_keys'] ?? '').split(','))
        if (key.trim().isNotEmpty) MentionKey(key.trim()),
      if (props.firstName && firstName.isNotEmpty)
        MentionKey(firstName, caseSensitive: true),
    ];
    if (username.isNotEmpty && !mentions.any((m) => m.key == '@$username')) {
      mentions.add(MentionKey('@$username'));
    }
    return MentionKeys(
      mentions: mentions,
      highlights: [
        for (final key in (props.raw['highlight_keys'] ?? '').split(','))
          if (key.trim().isNotEmpty) key.trim(),
      ],
      broadcast: props.raw['channel'] != 'false',
    );
  }

  final List<MentionKey> mentions;

  /// Words that are marked without notifying; empty unless the server
  /// has stored some.
  final List<String> highlights;

  /// `@channel`, `@all` and `@here` count as mentions of the user.
  final bool broadcast;

  bool get isEmpty => mentions.isEmpty && highlights.isEmpty;

  @override
  bool operator ==(Object other) =>
      other is MentionKeys &&
      other.broadcast == broadcast &&
      listEquals(other.mentions, mentions) &&
      listEquals(other.highlights, highlights);

  @override
  int get hashCode => Object.hash(
    broadcast,
    Object.hashAll(mentions),
    Object.hashAll(highlights),
  );

  /// Whether a typed `@name` is one of the user's mention words. A trailing
  /// `.`, `-` or `_` may belong to the sentence.
  bool mentionsName(String name) {
    var typed = name;
    while (typed.isNotEmpty) {
      final at = '@$typed'.toLowerCase();
      if (mentions.any((m) => m.key.toLowerCase() == at)) return true;
      final last = typed[typed.length - 1];
      if (last != '.' && last != '-' && last != '_') return false;
      typed = typed.substring(0, typed.length - 1);
    }
    return false;
  }
}

/// A marked stretch of a text.
typedef HighlightRange = ({int start, int end, Highlight kind});

// Chinese, Japanese, Korean, Cyrillic and Thai words have no spaces or
// `\b`-style edges (Dart's `\b` knows ASCII only), so they match anywhere.
final _noEdges = RegExp(
  r'[　-〿぀-ゟ゠-ヿ＀-ﾟ一-龯'
  r'㐀-䶿가-힣ᄀ-ᇿ㄰-㆏Ѐ-ӿ'
  r'Ԁ-ԯⷠ-ⷿ฀-๿]',
);

RegExp _pattern(String key, {required bool caseSensitive}) {
  final escaped = RegExp.escape(key);
  return RegExp(
    _noEdges.hasMatch(key) ? '()($escaped)()' : '(^|\\W)($escaped)(\\b|_+\\b)',
    caseSensitive: caseSensitive,
  );
}

/// Pure: the stretches of [text] the webapp marks, in order: all mention
/// words first (in their order), then highlight words longest first, the
/// latter never inside a stretch already marked.
List<HighlightRange> highlightRanges(String text, MentionKeys keys) {
  if (text.isEmpty || keys.isEmpty) return const [];
  final found = <HighlightRange>[];
  void collect(RegExp pattern, Highlight kind) {
    for (final m in pattern.allMatches(text)) {
      final start = m.start + m[1]!.length;
      final end = start + m[2]!.length;
      if (end == start) continue;
      if (found.any((r) => start < r.end && end > r.start)) continue;
      found.add((start: start, end: end, kind: kind));
    }
  }

  for (final m in keys.mentions) {
    if (m.key.trim().isEmpty) continue;
    collect(_pattern(m.key, caseSensitive: m.caseSensitive), Highlight.mention);
  }
  final words = [...keys.highlights]..sort((a, b) => b.length - a.length);
  for (final word in words) {
    if (word.trim().isEmpty) continue;
    collect(_pattern(word, caseSensitive: false), Highlight.keyword);
  }
  return found..sort((a, b) => a.start - b.start);
}
