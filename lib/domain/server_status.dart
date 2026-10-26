import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matterleast/api/websocket/server_socket.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/domain/sign_in_problems.dart';

part 'server_status.freezed.dart';

/// One server on the status page, in words.
@freezed
abstract class ServerStatusView with _$ServerStatusView {
  const factory ServerStatusView({
    required String connection,
    required String sync,

    /// The sync line reports a failure.
    required bool problem,
    required String stored,
    required String size,
  }) = _ServerStatusView;
}

typedef StoredCounts = ({int channels, int posts, int bytes});

/// Pure: the status page lines from the socket, the sync runner and what is
/// stored. [time] names a moment the way the user reads it.
ServerStatusView serverStatusView({
  required SocketState? socket,
  required SyncStatus? sync,
  required StoredCounts? stored,
  required String host,
  required String Function(DateTime) time,
}) {
  String since(DateTime? at) => at == null ? '' : ' · ${time(at)}';
  return ServerStatusView(
    connection: switch (socket) {
      SocketState.connected => 'Connected',
      SocketState.connecting => 'Connecting…',
      SocketState.disconnected || null => 'Offline',
    },
    sync: switch (sync) {
      null => 'Not refreshed yet',
      SyncRefreshing() => 'Refreshing…',
      SyncIdle(:final lastSuccess) =>
        lastSuccess == null
            ? 'Not refreshed yet'
            : 'Up to date${since(lastSuccess)}',
      SyncFailed(:final cause, :final at) =>
        "Couldn't refresh · ${time(at)}: ${connectionProblemText(cause, host)}",
    },
    problem: sync is SyncFailed,
    stored: stored == null
        ? '…'
        : '${_count(stored.channels, 'channel')} · '
              '${_count(stored.posts, 'message')}',
    size: stored == null ? '…' : formatBytes(stored.bytes),
  );
}

String _count(int n, String noun) => '$n ${n == 1 ? noun : '${noun}s'}';
