/// Preference categories and names the app reads or writes, as
/// `(category, name)`; a name of null stands for one per channel or user id.
abstract final class Prefs {
  static const teamsOrder = ('teams_order', '');
  static const collapsedThreads = (
    'display_settings',
    'collapsed_reply_threads',
  );
  static const favoriteChannel = 'favorite_channel';
  static const directChannelShow = 'direct_channel_show';
  static const groupChannelShow = 'group_channel_show';
  static const channelOpenTime = 'channel_open_time';
  static const channelViewTime = 'channel_approximate_view_time';
  static const directLimit = ('sidebar_settings', 'limit_visible_dms_gms');
  static const nameFormat = ('display_settings', 'name_format');
  static const flaggedPost = 'flagged_post';
  static const skinTone = ('emoji', 'emoji_skintone');
}
