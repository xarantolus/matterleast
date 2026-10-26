import 'dart:convert';

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

  /// As stored: a JSON object, or nothing.
  factory NotifyProps.fromJsonText(String? text) {
    if (text == null || text.isEmpty) return const NotifyProps({});
    try {
      return NotifyProps.fromJson(jsonDecode(text));
    } on FormatException {
      return const NotifyProps({});
    }
  }

  final Map<String, String> raw;

  bool get isEmpty => raw.isEmpty;

  /// The settings in [edited] that differ from these.
  Map<String, String> changesIn(NotifyProps edited) => {
    for (final MapEntry(:key, :value) in edited.raw.entries)
      if (raw[key] != value) key: value,
  };

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

  /// Notification emails, where the server sends them.
  bool get email => raw['email'] != 'false';

  /// The automatic reply to direct messages is on; the server then shows
  /// the user as out of office.
  bool get autoReply => raw['auto_responder_active'] == 'true';

  String get autoReplyMessage => switch (raw['auto_responder_message']) {
    final message? when message.trim().isNotEmpty => message,
    _ => defaultAutoReply,
  };

  static const defaultAutoReply =
      'Hello, I am out of office and unable to respond to messages.';

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

  NotifyProps withEmail(bool on) => withValue('email', '$on');

  /// The automatic reply switched [on], always with a message so the
  /// server has one to send.
  NotifyProps withAutoReply(bool on, [String? message]) => NotifyProps({
    ...raw,
    'auto_responder_active': '$on',
    'auto_responder_message': (message ?? autoReplyMessage).trim().isEmpty
        ? defaultAutoReply
        : (message ?? autoReplyMessage).trim(),
  });

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

/// Splits what the user typed into mention words.
List<String> parseMentionKeys(String text) => [
  for (final word in text.split(RegExp('[,\\s]+')))
    if (word.isNotEmpty) word,
];
