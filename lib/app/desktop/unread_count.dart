import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/unread_badge.dart';
import 'package:matterleast/screens/home/home_providers.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'unread_count.g.dart';

/// Unread mentions and direct messages over every signed-in server, from
/// the same lists the rail badges and Home show; null until all of them
/// were read once.
@riverpod
int? unreadCount(Ref ref) {
  final servers = ref.watch(serversProvider).value;
  if (servers == null) return null;
  var total = 0;
  var known = true;
  for (final s in servers) {
    if (!s.signedIn) continue;
    final teams = ref.watch(railTeamsProvider(s.url)).value;
    final inbox = ref.watch(serverInboxProvider(s.url)).value;
    if (teams == null || inbox == null) {
      known = false;
      continue;
    }
    total += unreadMentions(teams: teams, unread: inbox.unread);
  }
  return known ? total : null;
}

/// Whether any team on a signed-in server has unread messages in channels
/// that aren't muted, as its rail icon shows.
@riverpod
bool anyUnread(Ref ref) {
  for (final s in ref.watch(serversProvider).value ?? const <ServerEntry>[]) {
    if (!s.signedIn) continue;
    final teams = ref.watch(railTeamsProvider(s.url)).value ?? const [];
    if (teams.any((t) => t.unread)) return true;
  }
  return false;
}
