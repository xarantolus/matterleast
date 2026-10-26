import 'package:matterleast/domain/people.dart';

/// What the word at the cursor asks to complete.
sealed class Trigger {
  const Trigger(this.start, this.prefix);

  /// Offset of the trigger character (`@`, `~`, `:`, `/`).
  final int start;

  /// What was typed after it, up to the cursor.
  final String prefix;
}

final class UserTrigger extends Trigger {
  const UserTrigger(super.start, super.prefix);
}

final class ChannelTrigger extends Trigger {
  const ChannelTrigger(super.start, super.prefix);
}

final class EmojiTrigger extends Trigger {
  const EmojiTrigger(super.start, super.prefix);
}

/// A slash command; only at the start of the message.
final class CommandTrigger extends Trigger {
  const CommandTrigger(String prefix) : super(0, prefix);

  /// Past the command word: the server suggests its arguments.
  bool get hasArguments => prefix.contains(' ');
}

final _mention = RegExp(r'\B@([^@\s]*)$');
final _channel = RegExp(r'\B~([^~\s]*)$');
final _emoji = RegExp(r'(^|\s|^\+|^-):([^:\s]*)$');

/// Emoji are only suggested after this many characters, as in the official
/// app, so a colon in prose doesn't open a list.
const emojiMinChars = 2;

/// Pure: the completion asked for by the text before [cursor], or null.
Trigger? triggerAt(String text, int cursor) {
  if (cursor < 0 || cursor > text.length) return null;
  final before = text.substring(0, cursor);
  if (before.startsWith('/') && !before.contains('\n')) {
    return CommandTrigger(before.substring(1));
  }
  if (_mention.firstMatch(before) case final m?) {
    return UserTrigger(m.start, m.group(1)!);
  }
  if (_channel.firstMatch(before) case final m?) {
    return ChannelTrigger(m.start, m.group(1)!);
  }
  if (_emoji.firstMatch(before) case final m?) {
    final prefix = m.group(2)!;
    if (prefix.length < emojiMinChars) return null;
    return EmojiTrigger(cursor - prefix.length - 1, prefix);
  }
  return null;
}

/// Pure: [text] with the triggered word replaced by [replacement] and a
/// space, and the cursor after it.
({String text, int cursor}) applySuggestion(
  String text,
  int cursor,
  Trigger trigger,
  String replacement,
) {
  final after = text.substring(cursor);
  final inserted = after.startsWith(' ') ? replacement : '$replacement ';
  final head = text.substring(0, trigger.start) + inserted;
  return (
    text: head + after,
    cursor: head.length + (after.startsWith(' ') ? 1 : 0),
  );
}

/// One row of the suggestion list. [replacement] is what goes into the text.
sealed class Suggestion {
  const Suggestion();

  String get replacement;
}

final class UserSuggestion extends Suggestion {
  const UserSuggestion({
    required this.id,
    required this.username,
    this.firstName = '',
    this.lastName = '',
    this.nickname = '',
    this.outOfChannel = false,
  });

  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final String nickname;

  /// Mentioning them won't notify them unless they are added.
  final bool outOfChannel;

  @override
  String get replacement => '@$username';
}

/// `@all`, `@channel` or `@here`.
final class SpecialMention extends Suggestion {
  const SpecialMention(this.handle);

  final String handle;

  static const handles = ['all', 'channel', 'here'];

  /// `here` reaches only the people online.
  bool get onlineOnly => handle == 'here';

  @override
  String get replacement => '@$handle';
}

/// A user group; mentioning it notifies its members.
final class GroupSuggestion extends Suggestion {
  const GroupSuggestion({
    required this.id,
    required this.name,
    required this.displayName,
  });

  final String id;
  final String name;
  final String displayName;

  @override
  String get replacement => '@$name';
}

final class ChannelSuggestion extends Suggestion {
  const ChannelSuggestion({
    required this.id,
    required this.name,
    required this.displayName,
    required this.type,
    this.member = true,
  });

  final String id;
  final String name;
  final String displayName;

  /// `O` or `P`.
  final String type;

  /// The user is in the channel; others can be joined.
  final bool member;

  @override
  String get replacement => '~$name';
}

final class EmojiSuggestion extends Suggestion {
  const EmojiSuggestion(this.name, {this.unicode});

  final String name;

  /// Null for custom emoji, which go in as `:name:`.
  final String? unicode;

  bool get custom => unicode == null;

  @override
  String get replacement => unicode ?? ':$name:';
}

final class CommandSuggestion extends Suggestion {
  const CommandSuggestion({
    required this.complete,
    this.hint = '',
    this.description = '',
    this.iconUrl = '',
  });

  /// The command line it completes to, without the slash.
  final String complete;
  final String hint;
  final String description;
  final String iconUrl;

  @override
  String get replacement => '/$complete';
}

typedef UserCandidate = ({
  String id,
  String username,
  String firstName,
  String lastName,
  String nickname,

  /// Null when not known.
  bool? inChannel,
});

typedef GroupCandidate = ({String id, String name, String displayName});

const _listLimit = 25;

bool _startsWithWord(String text, String prefix) {
  final lower = text.toLowerCase();
  return lower.startsWith(prefix) ||
      lower.split(RegExp(r'\s+')).any((w) => w.startsWith(prefix));
}

/// Pure: people matching [prefix] by username, first or last name or
/// nickname: those in the channel (or not known to be outside it) first,
/// then [groups] matching by name or display name, then the special
/// mentions, then people outside the channel. Name matches lead within
/// each part.
List<Suggestion> rankUsers(
  String prefix,
  Iterable<UserCandidate> candidates, {
  bool specialMentions = true,
  Iterable<GroupCandidate> groups = const [],
}) {
  final p = prefix.toLowerCase();
  int? score(UserCandidate u) {
    if (u.username.toLowerCase().startsWith(p)) return 0;
    if (_startsWithWord(fullName(u.firstName, u.lastName), p) ||
        _startsWithWord(u.nickname, p)) {
      return 1;
    }
    return null;
  }

  final seen = <String>{};
  final scored = [
    for (final u in candidates)
      if (seen.add(u.id))
        if (score(u) case final s?) (u, s),
  ];
  List<UserSuggestion> group(bool outside) {
    final members =
        [
          for (final (u, s) in scored)
            if ((u.inChannel == false) == outside) (u, s),
        ]..sort(
          (a, b) => a.$2 != b.$2
              ? a.$2.compareTo(b.$2)
              : a.$1.username.compareTo(b.$1.username),
        );
    return [
      for (final (u, _) in members.take(_listLimit))
        UserSuggestion(
          id: u.id,
          username: u.username,
          firstName: u.firstName,
          lastName: u.lastName,
          nickname: u.nickname,
          outOfChannel: outside,
        ),
    ];
  }

  final seenGroups = <String>{};
  final matchingGroups =
      [
        for (final g in groups)
          if (seenGroups.add(g.id))
            if (g.name.toLowerCase().startsWith(p))
              (g, 0)
            else if (_startsWithWord(g.displayName, p))
              (g, 1),
      ]..sort(
        (a, b) => a.$2 != b.$2
            ? a.$2.compareTo(b.$2)
            : a.$1.name.compareTo(b.$1.name),
      );

  return [
    ...group(false),
    for (final (g, _) in matchingGroups.take(_listLimit))
      GroupSuggestion(id: g.id, name: g.name, displayName: g.displayName),
    if (specialMentions)
      for (final handle in SpecialMention.handles)
        if (handle.startsWith(p)) SpecialMention(handle),
    ...group(true),
  ];
}

typedef ChannelCandidate = ({
  String id,
  String name,
  String displayName,
  String type,
  bool member,
});

/// Pure: public and private channels whose name or display name starts with
/// [prefix] (any word of the display name), the user's own first, each
/// group by display name. Direct and group messages have no `~` name.
List<ChannelSuggestion> rankChannels(
  String prefix,
  Iterable<ChannelCandidate> candidates,
) {
  final p = prefix.toLowerCase();
  final seen = <String>{};
  final matches =
      [
        for (final c in candidates)
          if ((c.type == 'O' || c.type == 'P') &&
              seen.add(c.id) &&
              (c.name.toLowerCase().startsWith(p) ||
                  _startsWithWord(c.displayName, p)))
            c,
      ]..sort(
        (a, b) => a.member != b.member
            ? (a.member ? -1 : 1)
            : a.displayName.toLowerCase().compareTo(
                b.displayName.toLowerCase(),
              ),
      );
  return [
    for (final c in matches.take(_listLimit))
      ChannelSuggestion(
        id: c.id,
        name: c.name,
        displayName: c.displayName,
        type: c.type,
        member: c.member,
      ),
  ];
}

/// Pure: emoji whose name or alias starts with [prefix], then those with a
/// later word (after `_`) starting with it; recently used ones lead.
/// [systemNames] include aliases; [unicodeOf] gives a system emoji's
/// character.
List<EmojiSuggestion> rankEmoji(
  String prefix, {
  required Iterable<String> systemNames,
  Iterable<String> customNames = const [],
  List<String> recent = const [],
  required String? Function(String name) unicodeOf,
  int limit = 50,
}) {
  final p = prefix.toLowerCase();
  int? score(String name) {
    if (name.startsWith(p)) return 1;
    if (name.contains('_$p')) return 2;
    return null;
  }

  final custom = customNames.toSet();
  final scored = <String, int>{};
  for (final name in [...systemNames, ...custom]) {
    if (score(name) case final s?) scored[name] = s;
  }
  for (final name in recent) {
    if (scored.containsKey(name)) scored[name] = 0;
  }
  final names = scored.keys.toList()
    ..sort((a, b) {
      final bySource = scored[a]!.compareTo(scored[b]!);
      if (bySource != 0) return bySource;
      if (scored[a] == 0) return recent.indexOf(a).compareTo(recent.indexOf(b));
      final byLength = a.length.compareTo(b.length);
      return byLength != 0 ? byLength : a.compareTo(b);
    });
  return [
    for (final name in names.take(limit))
      EmojiSuggestion(
        name,
        unicode: custom.contains(name) ? null : unicodeOf(name),
      ),
  ];
}

typedef CommandCandidate = ({
  String trigger,
  String hint,
  String description,
  String iconUrl,
});

/// Pure: commands whose trigger starts with [prefix], alphabetically.
List<CommandSuggestion> rankCommands(
  String prefix,
  Iterable<CommandCandidate> commands,
) {
  final p = prefix.toLowerCase();
  final byTrigger = <String, CommandCandidate>{
    for (final c in commands)
      if (c.trigger.isNotEmpty && c.trigger.toLowerCase().startsWith(p))
        c.trigger: c,
  };
  final triggers = byTrigger.keys.toList()..sort();
  return [
    for (final t in triggers)
      CommandSuggestion(
        complete: t,
        hint: byTrigger[t]!.hint,
        description: byTrigger[t]!.description,
        iconUrl: byTrigger[t]!.iconUrl,
      ),
  ];
}

/// Pure: the newest [limit] distinct names, most recent first, after using
/// [used] (in order).
List<String> withRecentEmoji(
  List<String> recent,
  Iterable<String> used, {
  int limit = 27,
}) {
  final result = [...recent];
  for (final name in used) {
    result
      ..remove(name)
      ..insert(0, name);
  }
  return result.take(limit).toList();
}
