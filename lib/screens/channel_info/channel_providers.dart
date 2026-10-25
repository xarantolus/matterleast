import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/channel_actions.dart';
import 'package:matterleast/data/actions/directory.dart';
import 'package:matterleast/data/views/channel_views.dart';
import 'package:matterleast/domain/channel_info.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'channel_providers.g.dart';

@riverpod
Future<ChannelViews> channelViews(Ref ref, String url) async {
  final session = await ref.watch(serverSessionProvider(url).future);
  return ChannelViews(session.db, serverUrl: url);
}

@riverpod
Future<Directory> directory(Ref ref, String url) async {
  final session = await ref.watch(serverSessionProvider(url).future);
  return Directory(session, serverUrl: url);
}

/// One channel for its info screen; null once it is gone.
@riverpod
Stream<ChannelInfo?> channelInfo(Ref ref, String url, String channelId) async* {
  final views = await ref.watch(channelViewsProvider(url).future);
  yield* views.info(channelId);
}

/// Fetched when the info screen opens; the member count is also stored.
@Riverpod(retry: noRetry)
Future<api.ChannelStats> channelStats(
  Ref ref,
  String url,
  String channelId,
) async {
  final actions = await ref.watch(channelActionsProvider(url).future);
  return actions.refreshStats(channelId);
}

/// The stored pinned messages of a channel, newest first.
@riverpod
Stream<List<String>> pinnedIds(Ref ref, String url, String channelId) async* {
  final views = await ref.watch(channelViewsProvider(url).future);
  yield* views.listIds(ChannelActions.pinnedList(channelId));
}

/// Fetches the pinned messages again.
@Riverpod(retry: noRetry)
Future<void> pinnedRefresh(Ref ref, String url, String channelId) async {
  final actions = await ref.watch(channelActionsProvider(url).future);
  await actions.refreshPinned(channelId);
}

/// People by id (comma-separated), with live names and presence.
@riverpod
Stream<List<SwitchItem>> peopleRows(Ref ref, String url, String ids) async* {
  final views = await ref.watch(channelViewsProvider(url).future);
  yield* views.people(ids.isEmpty ? const [] : ids.split(','));
}

@riverpod
Future<({bool public, bool private, bool join})> teamRights(
  Ref ref,
  String url,
  String teamId,
) async {
  final views = await ref.watch(channelViewsProvider(url).future);
  return views.teamRights(teamId);
}
