import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/screens/home/home_state.dart';

InboxItem item(String id) => InboxItem(
  serverUrl: 's',
  kind: InboxKind.saved,
  channelId: 'c',
  teamId: null,
  title: 't',
  avatarName: 'a',
  author: null,
  preview: '',
  place: null,
  time: DateTime.utc(2026),
  count: 0,
  unread: false,
  postId: id,
);

ServerInbox inbox({List<InboxItem> saved = const [], bool known = false}) =>
    ServerInbox(
      unread: const [],
      mentions: const [],
      threads: const [],
      saved: saved,
      known: {if (known) InboxFilter.saved},
    );

HomeServer server(String name, {ServerInbox? inbox, SyncStatus? status}) =>
    (name: name, host: '$name.example.test', inbox: inbox, status: status);

final offline = SyncFailed(cause: const Unreachable(), at: DateTime.utc(2026));

void main() {
  test('nothing known yet: a spinner, or the failure with its cause', () {
    expect(
      homeState(InboxFilter.saved, [
        server(
          'one',
          inbox: inbox(),
          status: const SyncRefreshing(running: 1, queued: 0),
        ),
      ]),
      const HomeState.loading(),
    );
    final failed = homeState(InboxFilter.saved, [
      server('one', inbox: inbox(), status: offline),
    ]);
    expect(failed, isA<HomeFailed>());
    expect((failed as HomeFailed).detail, contains('one.example.test'));
  });

  test('a fetched empty list is ready and empty, not loading', () {
    final state = homeState(InboxFilter.saved, [
      server('one', inbox: inbox(known: true), status: const SyncIdle()),
    ]);
    expect(state, const HomeState.ready([], refreshing: false));
  });

  test('stored rows stay when a refresh fails, with a quiet notice', () {
    final one = homeState(InboxFilter.saved, [
      server(
        'one',
        inbox: inbox(saved: [item('p')]),
        status: offline,
      ),
    ]);
    expect(one, isA<HomeReady>());
    expect((one as HomeReady).notice, 'Offline · showing saved data');
    final two = homeState(InboxFilter.saved, [
      server(
        'one',
        inbox: inbox(saved: [item('p')]),
        status: offline,
      ),
      server('two', inbox: inbox(known: true), status: const SyncIdle()),
    ]);
    expect((two as HomeReady).notice, 'one offline · showing saved data');
  });

  test('one server still loading does not hide the other one\'s rows', () {
    final state = homeState(InboxFilter.saved, [
      server(
        'one',
        inbox: inbox(saved: [item('p')]),
        status: const SyncIdle(),
      ),
      server('two'),
    ]);
    expect((state as HomeReady).items.single.postId, 'p');
  });
}
