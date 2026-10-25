import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/sign_in_problems.dart';

part 'home_state.freezed.dart';

/// What Home shows.
@freezed
sealed class HomeState with _$HomeState {
  /// Nothing stored for this chip yet and a fetch is still running.
  const factory HomeState.loading() = HomeLoading;

  /// Nothing stored and every server failed.
  const factory HomeState.failed({
    required String title,
    required String detail,
  }) = HomeFailed;

  /// The stored rows (maybe none), with a quiet [notice] when a refresh
  /// failed.
  const factory HomeState.ready(
    List<InboxItem> items, {
    required bool refreshing,
    String? notice,
  }) = HomeReady;
}

/// One signed-in server as Home sees it.
typedef HomeServer = ({
  String name,
  String host,
  ServerInbox? inbox,
  SyncStatus? status,
});

/// Pure: Home's state for [filter] from every server's rows and sync status.
HomeState homeState(InboxFilter filter, List<HomeServer> servers) {
  final inboxes = [for (final s in servers) ?s.inbox];
  final items = mergeInbox(inboxes, filter);
  final known = inboxes.any((i) => i.known.contains(filter));
  final failed = [
    for (final s in servers)
      if (s.status case final SyncFailed status) (server: s, status: status),
  ];
  if (items.isEmpty && !known) {
    if (servers.isNotEmpty && failed.length == servers.length) {
      final first = failed.first;
      return HomeState.failed(
        title: servers.length == 1
            ? "Couldn't load ${first.server.name}"
            : "Couldn't load your servers",
        detail: connectionProblemText(first.status.cause, first.server.host),
      );
    }
    return const HomeState.loading();
  }
  String problem(SyncFailed status) =>
      status.offline ? 'offline' : "couldn't refresh";
  final notice = switch (failed) {
    [] => null,
    [final first, ...] when failed.length == servers.length =>
      '${_capitalised(problem(first.status))} · showing saved data',
    [final only] =>
      '${only.server.name} ${problem(only.status)} · showing saved data',
    _ => 'Some servers are offline · showing saved data',
  };
  return HomeState.ready(
    items,
    refreshing: servers.any((s) => s.status is SyncRefreshing),
    notice: notice,
  );
}

String _capitalised(String text) =>
    text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
