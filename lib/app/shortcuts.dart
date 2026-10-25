import 'package:matterleast/domain/quick_switch.dart';

/// How many recent conversations the launcher icon offers.
const shortcutCount = 4;

/// Pure: the conversations most recently viewed, newest first.
List<SwitchItem> recentConversations(List<SwitchItem> items) {
  final viewed = [
    for (final item in items)
      if (item.lastViewedAt != null &&
          const {
            SwitchKind.channel,
            SwitchKind.privateChannel,
            SwitchKind.direct,
            SwitchKind.group,
          }.contains(item.kind))
        item,
  ]..sort((a, b) => b.lastViewedAt!.compareTo(a.lastViewedAt!));
  return viewed.take(shortcutCount).toList();
}

/// A shortcut's id: the server and the channel it opens.
String shortcutType(SwitchItem item) => '${item.serverUrl}\n${item.id}';

/// The server and channel of a shortcut; null for anything else.
({String url, String channelId})? parseShortcutType(String type) {
  final parts = type.split('\n');
  if (parts.length != 2 || parts.any((p) => p.isEmpty)) return null;
  return (url: parts[0], channelId: parts[1]);
}
