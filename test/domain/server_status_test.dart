import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/websocket/server_socket.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/server_status.dart';

ServerStatusView view({
  SocketState? socket,
  SyncStatus? sync,
  StoredCounts? stored,
}) => serverStatusView(
  socket: socket,
  sync: sync,
  stored: stored,
  host: 'chat.example.test',
  time: (at) => '${at.hour}:${at.minute.toString().padLeft(2, '0')}',
);

void main() {
  test('the sync line follows the runner', () {
    final at = DateTime.utc(2026, 10, 25, 9, 5);
    expect(view().sync, 'Not refreshed yet');
    expect(
      view(sync: const SyncRefreshing(running: 1, queued: 2)).sync,
      'Refreshing…',
    );
    expect(view(sync: SyncIdle(lastSuccess: at)).sync, 'Up to date · 9:05');
    final failed = view(
      sync: SyncFailed(cause: const RequestTimeout(), at: at, lastSuccess: at),
    );
    expect(failed.problem, isTrue);
    expect(
      failed.sync,
      startsWith("Couldn't refresh · 9:05: chat.example.test"),
    );
  });

  test('connection and stored data in words', () {
    expect(view(socket: SocketState.connected).connection, 'Connected');
    expect(view(socket: SocketState.connecting).connection, 'Connecting…');
    expect(view().connection, 'Offline');
    final stored = view(stored: (channels: 1, posts: 340, bytes: 1536000));
    expect(stored.stored, '1 channel · 340 messages');
    expect(stored.size, '1.5 MB');
  });
}
