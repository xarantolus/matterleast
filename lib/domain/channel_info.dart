import 'package:freezed_annotation/freezed_annotation.dart';

part 'channel_info.freezed.dart';

/// Everything the channel info screen shows about one channel.
@freezed
abstract class ChannelInfo with _$ChannelInfo {
  const factory ChannelInfo({
    required String id,

    /// `O`, `P`, `D` or `G`.
    required String type,
    required String name,
    required String title,
    required String teamId,
    required String teamName,
    required String teamDisplayName,
    required String purpose,
    required String header,
    required bool archived,
    required bool joined,
    required bool favorite,
    required bool muted,
    int? memberCount,

    /// The other person of a direct message.
    String? partnerId,
    String? creatorName,
    DateTime? createAt,
    required ChannelNotify notify,
    required bool canEdit,
    required bool canArchive,
    required bool canManageMembers,
  }) = _ChannelInfo;

  const ChannelInfo._();

  bool get conversation => type == 'D' || type == 'G';

  /// The team's default channel can't be left or archived.
  bool get isDefault => name == 'town-square';
}

/// The user's notification settings for one channel, each `default` when
/// it follows their account setting.
@freezed
abstract class ChannelNotify with _$ChannelNotify {
  const factory ChannelNotify({
    @Default('default') String push,
    @Default('default') String desktop,
    @Default('default') String ignoreChannelMentions,

    /// The account's own settings, which `default` stands for.
    @Default('mention') String accountPush,
    @Default('mention') String accountDesktop,
  }) = _ChannelNotify;
}

/// Words for a notification level.
String notifyLevelLabel(String level) => switch (level) {
  'all' => 'All new messages',
  'mention' => 'Mentions, direct and group messages',
  'none' => 'Nothing',
  _ => 'Default',
};

/// Pure: what a channel setting does in effect, in words, such as
/// `Default (Mentions, direct and group messages)`.
String effectiveLevel(String level, String account) => level == 'default'
    ? 'Default (${notifyLevelLabel(account)})'
    : notifyLevelLabel(level);

/// Pure: a channel name (the URL part) from a display name, as the web app
/// makes them: lower case, letters and digits joined by single dashes. A
/// name with nothing usable left is empty, and the caller picks one.
String channelSlug(String displayName) {
  final slug = displayName
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp('^-+|-+\$'), '');
  return slug.length > 64 ? slug.substring(0, 64) : slug;
}

/// Pure: the link to a channel as the web app shows it.
String channelLink(String serverUrl, String teamName, String channelName) {
  final base = serverUrl.endsWith('/')
      ? serverUrl.substring(0, serverUrl.length - 1)
      : serverUrl;
  return '$base/$teamName/channels/$channelName';
}
