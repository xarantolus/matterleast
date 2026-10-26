import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/sign_in_problems.dart';

part 'channel_list_state.freezed.dart';

/// What the channel list pane shows.
@freezed
sealed class ChannelListState with _$ChannelListState {
  /// Nothing stored yet and the first sync is still running.
  const factory ChannelListState.loading() = ChannelListLoading;

  /// Nothing stored and the sync failed.
  const factory ChannelListState.failed({
    required String title,
    required String detail,
  }) = ChannelListFailed;

  /// The stored list, while [refreshing] or after a refresh failed
  /// ([notice] says so).
  const factory ChannelListState.ready(
    ChannelList list, {
    required bool refreshing,
    String? notice,
  }) = ChannelListReady;
}

/// Pure: the pane's state from the stored list and the server's sync status.
ChannelListState channelListState({
  required ChannelList? list,
  required SyncStatus? status,
  required String serverName,
  required String host,
  bool liveUpdatesDown = false,
}) {
  final stored = list != null && (list.synced || list.sections.isNotEmpty);
  if (!stored) {
    return switch (status) {
      SyncFailed(:final cause) => ChannelListState.failed(
        title: "Couldn't load channels for $serverName",
        detail: connectionProblemText(cause, host),
      ),
      _ => const ChannelListState.loading(),
    };
  }
  return ChannelListState.ready(
    list,
    refreshing: status is SyncRefreshing,
    notice: switch (status) {
      SyncFailed(:final cause) => staleDataNotice(cause),
      _ when liveUpdatesDown => 'Reconnecting…',
      _ => null,
    },
  );
}
