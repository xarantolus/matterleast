import 'dart:async';

import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/channel_actions.dart';
import 'package:matterleast/data/sync/server_connection.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/data/views/root_views.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'root_providers.g.dart';

/// The teams of one server for the rail, with their badges.
@riverpod
Stream<List<RailTeam>> railTeams(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* RootViews(session.db).railTeams();
}

/// One team's channel list.
@riverpod
Stream<ChannelList> channelList(Ref ref, String url, String teamId) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* RootViews(session.db).channelList(teamId);
}

/// What the server's sync runner is doing, for the progress bar and the
/// offline notice.
@riverpod
Stream<SyncStatus> syncStatus(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  final status = session.runner.status;
  final changes = StreamController<SyncStatus>();
  void push() => changes.add(status.value);
  status.addListener(push);
  ref.onDispose(() {
    status.removeListener(push);
    unawaited(changes.close());
  });
  push();
  yield* changes.stream;
}

/// Kept while the app runs, like the session it wraps, so the rail can use
/// it.
@Riverpod(keepAlive: true)
Future<ChannelActions> channelActions(Ref ref, String url) async =>
    ChannelActions(await ref.watch(serverSessionProvider(url).future));

/// Fetches a server's channels, teams and Home lists again; the outcome
/// shows in [syncStatus].
class ServerRefresh {
  const ServerRefresh(this._connection);

  final ServerConnection _connection;

  void call() => _connection.refreshAll();
}

@Riverpod(keepAlive: true)
Future<ServerRefresh> serverRefresh(Ref ref, String url) async => ServerRefresh(
  (await ref.watch(serverSessionProvider(url).future)).connection,
);
