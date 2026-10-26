/// The widest mention in a message.
enum ChannelWideMention {
  /// @all or @channel: everyone in the channel.
  everyone,

  /// @here: everyone in the channel who is online.
  online,
}

/// Channels with more members than this ask before notifying all of them,
/// as in the official apps.
const confirmMentionsAbove = 5;

final _code = RegExp(
  r'(`+)([^`]|[^`][\s\S]*?[^`])\1(?!`)| *(`{3,}|~{3,})[ .]*(\S+)? *\n([\s\S]*?\s*)\3 *(?:\n+|$)',
);
final _everyone = RegExp(
  r'(?:\B|\b_+)@(channel|all)(?!(\.|-|_)*[^\W_])',
  caseSensitive: false,
);
final _online = RegExp(
  r'(?:\B|\b_+)@(here)(?!(\.|-|_)*[^\W_])',
  caseSensitive: false,
);

/// Pure: whether [text] notifies the whole channel, outside code.
ChannelWideMention? channelWideMention(String text) {
  final prose = text.replaceAll(_code, '');
  if (_everyone.hasMatch(prose)) return ChannelWideMention.everyone;
  if (_online.hasMatch(prose)) return ChannelWideMention.online;
  return null;
}

/// Pure: the question to ask before sending [text] to a channel of
/// [memberCount] people, or null when it can go at once. Only asked when
/// the server wants it ([confirm]) and the user's channel-wide mentions
/// notify anyone ([allowed]).
String? channelMentionQuestion(
  String text, {
  required bool confirm,
  required bool allowed,
  required int? memberCount,
}) {
  if (!confirm || !allowed) return null;
  final count = memberCount ?? 0;
  if (count <= confirmMentionsAbove) return null;
  final others = count - 1;
  final people = others == 1 ? '1 person' : '$others people';
  return switch (channelWideMention(text)) {
    null => null,
    ChannelWideMention.everyone =>
      'By using @all or @channel you are about to send notifications to '
          '$people. Are you sure you want to do this?',
    ChannelWideMention.online =>
      'By using @here you are about to send notifications to up to '
          '$people. Are you sure you want to do this?',
  };
}
