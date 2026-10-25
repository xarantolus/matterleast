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
}
