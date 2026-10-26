import 'package:freezed_annotation/freezed_annotation.dart';

part 'quick_switch.freezed.dart';

enum SwitchKind {
  /// A public or private channel the user is in.
  channel,
  privateChannel,
  direct,
  group,

  /// Someone the user has no direct message with yet.
  person,

  /// An archived channel the user was in.
  archived,

  /// A public channel the user can join.
  joinable,
}

/// Someone in a group message, for its picture.
typedef SwitchMember = ({String userId, String name, int? pictureUpdate});

/// One row of the quick switcher.
@freezed
abstract class SwitchItem with _$SwitchItem {
  const factory SwitchItem({
    required String serverUrl,
    required SwitchKind kind,

    /// The channel id, or the user id for [SwitchKind.person].
    required String id,
    required String title,

    /// The team or `@username` under the title.
    String? subtitle,

    /// How search modifiers name it: the channel's name, `@username` for a
    /// direct message, or the person's username.
    String? handle,

    /// What the term is matched against, besides the title.
    @Default(<String>[]) List<String> keys,

    /// The team to show in the rail when opened.
    String? teamId,

    /// Whose picture the row shows: the other person of a direct message, or
    /// the person.
    String? userId,
    int? pictureUpdate,
    String? status,

    /// The others of a group message, as far as they are known.
    @Default(<SwitchMember>[]) List<SwitchMember> members,
    DateTime? lastViewedAt,
    DateTime? lastPostAt,
    @Default(false) bool unread,
    @Default(0) int mentions,
    @Default(false) bool muted,
  }) = _SwitchItem;

  const SwitchItem._();

  String get key => '$serverUrl/${kind.name}/$id';

  bool get joined => switch (kind) {
    SwitchKind.person || SwitchKind.joinable => false,
    _ => true,
  };
}

/// How well [term] matches [text]: 0 for not at all, higher is better.
/// Exact, prefix, word prefix, substring, letters in order, and one typo in
/// a word prefix all count, in that order.
int matchScore(String term, String text) {
  final t = normalizeTerm(term);
  final s = text.toLowerCase();
  if (t.isEmpty || s.isEmpty) return 0;
  if (s == t) return 100;
  if (s.startsWith(t)) return 80;
  final words = s.split(_wordBreak).where((w) => w.isNotEmpty).toList();
  if (words.any((w) => w.startsWith(t))) return 60;
  if (s.contains(t)) return 40;
  if (t.length >= 4 &&
      words.any((w) => w.length >= t.length - 1 && _oneEditPrefix(t, w))) {
    return 25;
  }
  if (t.length >= 2 && _inOrder(t, s)) return 15;
  return 0;
}

final _wordBreak = RegExp(r'[\s\-_.,]+');

/// The term as typed, without the `@`, `~` or `#` people put in front of
/// names, and lower case.
String normalizeTerm(String term) =>
    term.trim().toLowerCase().replaceFirst(RegExp(r'^[@~#]+'), '');

/// Whether [term] differs from the start of [word] by one inserted, removed,
/// replaced or swapped letter.
bool _oneEditPrefix(String term, String word) {
  for (final length in [term.length - 1, term.length, term.length + 1]) {
    if (length < 1 || length > word.length) continue;
    if (_withinOneEdit(term, word.substring(0, length))) return true;
  }
  return false;
}

bool _withinOneEdit(String a, String b) {
  if ((a.length - b.length).abs() > 1) return false;
  var i = 0;
  while (i < a.length && i < b.length && a[i] == b[i]) {
    i++;
  }
  if (i == a.length && i == b.length) return true;
  if (a.length == b.length) {
    if (a.substring(i + 1) == b.substring(i + 1)) return true;
    return i + 1 < a.length &&
        a[i] == b[i + 1] &&
        a[i + 1] == b[i] &&
        a.substring(i + 2) == b.substring(i + 2);
  }
  return a.length > b.length
      ? a.substring(i + 1) == b.substring(i)
      : a.substring(i) == b.substring(i + 1);
}

bool _inOrder(String term, String text) {
  var at = 0;
  for (final char in term.split('')) {
    at = text.indexOf(char, at);
    if (at < 0) return false;
    at++;
  }
  return true;
}

/// Pure: the items matching [term], best first. A leading `@` asks for
/// people only. Conversations the user is in come before people, and both
/// before archived channels; within a score, the most recently viewed first.
List<SwitchItem> rankSwitchItems(
  String term,
  Iterable<SwitchItem> items, {
  int limit = 30,
}) {
  final peopleOnly = term.trim().startsWith('@');
  final scored = <(SwitchItem, int)>[];
  for (final item in items) {
    if (peopleOnly &&
        item.kind != SwitchKind.person &&
        item.kind != SwitchKind.direct) {
      continue;
    }
    var best = matchScore(term, item.title);
    for (final key in item.keys) {
      final score = matchScore(term, key);
      if (score > best) best = score;
    }
    if (best == 0) continue;
    scored.add((item, best + _groupBonus(item.kind)));
  }
  scored.sort((a, b) {
    final byScore = b.$2.compareTo(a.$2);
    if (byScore != 0) return byScore;
    final aTime = a.$1.lastViewedAt?.millisecondsSinceEpoch ?? 0;
    final bTime = b.$1.lastViewedAt?.millisecondsSinceEpoch ?? 0;
    if (aTime != bTime) return bTime.compareTo(aTime);
    return a.$1.title.toLowerCase().compareTo(b.$1.title.toLowerCase());
  });
  return [for (final (item, _) in scored.take(limit)) item];
}

int _groupBonus(SwitchKind kind) => switch (kind) {
  SwitchKind.channel ||
  SwitchKind.privateChannel ||
  SwitchKind.direct ||
  SwitchKind.group => 5,
  SwitchKind.person => 3,
  SwitchKind.joinable => 0,
  SwitchKind.archived => -10,
};

/// Pure: the server's answers that are not already shown, ranked the same
/// way, to go below the local ones.
List<SwitchItem> extraRemoteItems(
  String term,
  List<SwitchItem> local,
  Iterable<SwitchItem> remote, {
  int limit = 20,
}) {
  final shown = {for (final item in local) '${item.serverUrl}/${item.id}'};
  final users = {
    for (final item in local)
      if (item.userId != null) '${item.serverUrl}/${item.userId}',
  };
  return rankSwitchItems(term, [
    for (final item in remote)
      if (!shown.contains('${item.serverUrl}/${item.id}') &&
          !(item.kind == SwitchKind.person &&
              users.contains('${item.serverUrl}/${item.id}')))
        item,
  ], limit: limit);
}

/// Pure: what the switcher shows before anything is typed: unread
/// conversations, then the ones viewed most recently.
({List<SwitchItem> unread, List<SwitchItem> recent}) switchStart(
  Iterable<SwitchItem> items, {
  int recentLimit = 10,
}) {
  final joined = [
    for (final item in items)
      if (item.joined && item.kind != SwitchKind.archived) item,
  ];
  int newest(SwitchItem a, SwitchItem b) =>
      (b.lastViewedAt?.millisecondsSinceEpoch ?? 0).compareTo(
        a.lastViewedAt?.millisecondsSinceEpoch ?? 0,
      );
  final unread =
      [
        for (final item in joined)
          if ((item.unread && !item.muted) || item.mentions > 0) item,
      ]..sort((a, b) {
        final byMentions = b.mentions.compareTo(a.mentions);
        return byMentions != 0 ? byMentions : newest(a, b);
      });
  final unreadKeys = {for (final item in unread) item.key};
  final recent = [
    for (final item in joined)
      if (item.lastViewedAt != null && !unreadKeys.contains(item.key)) item,
  ]..sort(newest);
  return (unread: unread, recent: recent.take(recentLimit).toList());
}

/// Pure: what a picker shows before anything is typed: the [recentLimit]
/// items used most recently (last viewed, then last post) and the rest by
/// name.
({List<SwitchItem> recent, List<SwitchItem> rest}) pickerStart(
  Iterable<SwitchItem> items, {
  int recentLimit = 8,
}) {
  int time(DateTime? t) => t?.millisecondsSinceEpoch ?? 0;
  final used =
      [
        for (final item in items)
          if (item.lastViewedAt != null || item.lastPostAt != null) item,
      ]..sort((a, b) {
        final byViewed = time(b.lastViewedAt).compareTo(time(a.lastViewedAt));
        return byViewed != 0
            ? byViewed
            : time(b.lastPostAt).compareTo(time(a.lastPostAt));
      });
  final recent = used.take(recentLimit).toList();
  final recentKeys = {for (final item in recent) item.key};
  final rest = [
    for (final item in items)
      if (!recentKeys.contains(item.key)) item,
  ]..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
  return (recent: recent, rest: rest);
}
