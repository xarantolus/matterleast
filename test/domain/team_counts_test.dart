import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/domain/rail.dart';

import 'channel_list_test.dart' show channel;

void main() {
  group('channelCounts', () {
    test('adds up unread messages of channels that are not muted', () {
      final counts = channelCounts([
        channel('a', total: 5, read: 3),
        channel('b', total: 4, read: 1, muted: true),
        channel('c', total: 2, read: 2),
      ], crt: false);
      expect(counts.messages, 2);
    });

    test('counts mentions of muted channels too, as the server does', () {
      final counts = channelCounts([
        channel('a', mentions: 1),
        channel('b', mentions: 2, muted: true),
      ], crt: false);
      expect(counts.mentions, 3);
    });

    test('leaves archived channels out', () {
      final counts = channelCounts([
        channel('a', total: 5, read: 1, mentions: 1, archived: true),
      ], crt: false);
      expect(counts, (messages: 0, mentions: 0));
    });

    test('counts only root posts with collapsed threads', () {
      final channels = [
        channel(
          'a',
          total: 6,
          read: 1,
          totalRoot: 3,
          readRoot: 2,
          mentions: 4,
          mentionsRoot: 1,
        ),
      ];
      expect(channelCounts(channels, crt: true), (messages: 1, mentions: 1));
      expect(channelCounts(channels, crt: false), (messages: 5, mentions: 4));
    });
  });

  group('staleTeams', () {
    const quiet = noTeamCounts;
    const busy = (messages: 1, mentions: 0, threads: 0, threadMentions: 0);

    test('names no team where the server and the store agree', () {
      final stale = staleTeams(
        server: {'a': busy, 'b': quiet},
        local: {'a': busy},
      );
      expect(stale.channels, isEmpty);
      expect(stale.threads, isEmpty);
    });

    test('names a team whose messages or mentions differ', () {
      final stale = staleTeams(
        server: {
          'a': quiet,
          'b': (messages: 0, mentions: 1, threads: 0, threadMentions: 0),
        },
        local: {'a': busy, 'b': quiet},
      );
      expect(stale.channels, {'a', 'b'});
      expect(stale.threads, isEmpty);
    });

    test('names a team whose unread threads or thread mentions differ', () {
      final stale = staleTeams(
        server: {
          'a': (messages: 0, mentions: 0, threads: 1, threadMentions: 0),
          'b': (messages: 0, mentions: 0, threads: 0, threadMentions: 2),
          'c': quiet,
        },
        local: {'a': quiet, 'b': quiet, 'c': quiet},
      );
      expect(stale.threads, {'a', 'b'});
      expect(stale.channels, isEmpty);
    });

    test('names a team whose channels were never fetched', () {
      final stale = staleTeams(
        server: {'a': quiet},
        local: const {},
        unsynced: {'a'},
      );
      expect(stale.channels, {'a'});
    });
  });
}
