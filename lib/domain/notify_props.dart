/// When the user's devices are notified, from the server's `push` value.
enum PushLevel {
  all('all', 'All new messages'),
  mention('mention', 'Mentions and direct messages'),
  none('none', 'Never');

  const PushLevel(this.value, this.label);
  final String value;
  final String label;
}

/// While which status notifications still arrive, from `push_status`.
enum PushTrigger {
  online('online', 'Online, away or offline'),
  away('away', 'Away or offline'),
  offline('offline', 'Offline');

  const PushTrigger(this.value, this.label);
  final String value;
  final String label;
}

/// The user's account-wide notification settings. The server replaces the
/// whole map on a patch, so every key it sent is kept and sent back.
class NotifyProps {
  const NotifyProps(this.raw);

  /// Keeps the string values only; anything else is not ours to edit.
  factory NotifyProps.fromJson(Object? json) => NotifyProps({
    if (json is Map)
      for (final MapEntry(:key, :value) in json.entries)
        if (key is String && value is String) key: value,
  });

  final Map<String, String> raw;

  PushLevel get push =>
      PushLevel.values.where((l) => l.value == raw['push']).firstOrNull ??
      PushLevel.mention;

  PushTrigger get pushTrigger =>
      PushTrigger.values
          .where((t) => t.value == raw['push_status'])
          .firstOrNull ??
      PushTrigger.away;

  bool get threadReplies => raw['push_threads'] != 'none';

  bool get channelWide => raw['channel'] != 'false';

  bool get firstName => raw['first_name'] == 'true';

  /// Extra words that count as a mention, without the username ones the
  /// server always adds.
  List<String> mentionKeys(String username) => [
    for (final key in (raw['mention_keys'] ?? '').split(','))
      if (key.trim() case final k
          when k.isNotEmpty && k != username && k != '@$username')
        k,
  ];

  NotifyProps withValue(String key, String value) =>
      NotifyProps({...raw, key: value});

  NotifyProps withPush(PushLevel level) => withValue('push', level.value);

  NotifyProps withPushTrigger(PushTrigger trigger) =>
      withValue('push_status', trigger.value);

  NotifyProps withThreadReplies(bool on) =>
      withValue('push_threads', on ? 'all' : 'none');

  NotifyProps withChannelWide(bool on) => withValue('channel', '$on');

  NotifyProps withFirstName(bool on) => withValue('first_name', '$on');

  NotifyProps withMentionKeys(String username, Iterable<String> keys) {
    final kept = (raw['mention_keys'] ?? '')
        .split(',')
        .map((k) => k.trim())
        .where((k) => k == username || k == '@$username');
    final words = {
      ...kept,
      for (final k in keys)
        if (k.trim().isNotEmpty) k.trim(),
    };
    return withValue('mention_keys', words.join(','));
  }
}

/// Teammate name display, the `display_settings/name_format` preference.
enum NameFormat {
  username('username', 'Username'),
  nickname('nickname_full_name', 'Nickname, else full name'),
  fullName('full_name', 'Full name');

  const NameFormat(this.value, this.label);
  final String value;
  final String label;

  static NameFormat of(String? value) =>
      values.where((f) => f.value == value).firstOrNull ?? username;
}

/// Splits what the user typed into mention words.
List<String> parseMentionKeys(String text) => [
  for (final word in text.split(RegExp('[,\\s]+')))
    if (word.isNotEmpty) word,
];
