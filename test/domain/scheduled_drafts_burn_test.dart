import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/dialog_clock.dart';
import 'package:matterleast/domain/burn_on_read.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/draft_sync.dart';
import 'package:matterleast/domain/scheduled_posts.dart';

void main() {
  group('schedule presets', () {
    // 2026-10-26 is a Monday.
    DateTime day(int d, [int h = 15]) => DateTime.utc(2026, 10, d, h);
    List<String> labels(DateTime now) => [
      for (final p in schedulePresets(
        dialogClock('Europe/Berlin', now),
        nine: '09:00',
      ))
        p.label,
    ];

    test('the choices follow the weekday as in the official app', () {
      expect(labels(day(26)), ['Tomorrow at 09:00', 'Next Monday at 09:00']);
      expect(labels(day(27)), ['Tomorrow at 09:00', 'Monday at 09:00']);
      expect(labels(day(30)), ['Monday at 09:00']);
      expect(labels(day(31)), ['Monday at 09:00']);
      expect(labels(DateTime.utc(2026, 11, 1, 15)), ['Tomorrow at 09:00']);
    });

    test('9:00 is in the chosen zone, across the change from summer time', () {
      // Saturday 24 Oct in Berlin (summer time); Monday 26 Oct is winter
      // time (UTC+1).
      final monday = schedulePresets(
        dialogClock('Europe/Berlin', DateTime.utc(2026, 10, 24, 12)),
        nine: '09:00',
      ).single;
      expect(monday.at, DateTime.utc(2026, 10, 26, 8));

      final tomorrow = schedulePresets(
        dialogClock('America/New_York', DateTime.utc(2026, 10, 27, 3)),
        nine: '09:00',
      ).first;
      // Still the 26th in New York; tomorrow 9:00 there is 13:00 UTC.
      expect(tomorrow.at, DateTime.utc(2026, 10, 27, 13));
    });

    test('a month end and the year end roll over', () {
      final newYear = schedulePresets(
        dialogClock('Europe/Berlin', DateTime.utc(2026, 12, 31, 12)),
        nine: '09:00',
      );
      expect(newYear.first.at, DateTime.utc(2027, 1, 1, 8));
    });
  });

  test('failed scheduled messages say why', () {
    expect(scheduleProblem(null), isNull);
    expect(scheduleProblem(''), isNull);
    expect(scheduleProblem('channel_archived'), 'The channel was archived');
    expect(scheduleProblem('no_channel_member'), contains('no longer'));
    expect(scheduleProblem('something_new'), "It wasn't sent");
  });

  test('the scheduled list puts failed messages first, then the soonest, '
      'and leaves out channels the user cannot see', () {
    final channels = <String, ChannelInput>{
      'c1': _channel('c1', 'Boats'),
      'c2': _channel('c2', 'Harbour'),
    };
    final items = buildScheduledList(
      [
        _scheduled('late', 'c1', DateTime.utc(2026, 11, 2)),
        _scheduled('soon', 'c2', DateTime.utc(2026, 10, 27)),
        _scheduled('failed', 'c1', DateTime.utc(2026, 12, 1), 'thread_deleted'),
        _scheduled('gone', 'c9', DateTime.utc(2026, 10, 27)),
      ],
      channels: channels,
      myId: 'me',
      people: const {},
    );
    expect([for (final i in items) i.id], ['failed', 'soon', 'late']);
    expect(items.first.problem, 'The thread was deleted');
    expect(items[1].title, '#Harbour');
    expect(scheduledCountLabel(0), isNull);
    expect(scheduledCountLabel(1), '1 scheduled message');
    expect(scheduledCountLabel(3), '3 scheduled messages');
  });

  group('draft sync plan', () {
    const a = (channelId: 'c1', rootId: '');
    const b = (channelId: 'c2', rootId: 'r1');
    final t1 = DateTime.utc(2026, 10, 26, 9);
    final t2 = DateTime.utc(2026, 10, 26, 10);

    List<String> plan({
      List<LocalDraftState> local = const [],
      Map<DraftKey, DateTime> server = const {},
      Map<DraftKey, DateTime> deleted = const {},
    }) => [
      for (final s in planDraftSync(
        local: local,
        server: server,
        deleted: deleted,
      ))
        '${s.runtimeType}:${s.key.channelId}',
    ];

    test('the newer copy wins', () {
      expect(
        plan(local: [(key: a, updatedAt: t1, syncedAt: t1)], server: {a: t2}),
        ['TakeServerDraft:c1'],
      );
      expect(
        plan(local: [(key: a, updatedAt: t2, syncedAt: t1)], server: {a: t1}),
        ['SendDraft:c1'],
      );
      expect(
        plan(local: [(key: a, updatedAt: t1, syncedAt: t1)], server: {a: t1}),
        isEmpty,
      );
    });

    test('drafts only one side has', () {
      expect(plan(server: {b: t1}), ['TakeServerDraft:c2']);
      expect(plan(local: [(key: a, updatedAt: t1, syncedAt: null)]), [
        'SendDraft:c1',
      ]);
      // The server had it and nothing changed here since: deleted elsewhere.
      expect(plan(local: [(key: a, updatedAt: t1, syncedAt: t1)]), [
        'DropDraft:c1',
      ]);
      // Changed here after the server last saw it: keep and send.
      expect(plan(local: [(key: a, updatedAt: t2, syncedAt: t1)]), [
        'SendDraft:c1',
      ]);
    });

    test('a draft deleted here while offline is deleted on the server, '
        'unless it changed there afterwards', () {
      expect(plan(server: {a: t1}, deleted: {a: t2}), ['DeleteServerDraft:c1']);
      expect(plan(server: {a: t2}, deleted: {a: t1}), ['TakeServerDraft:c1']);
    });

    test('events from the server', () {
      expect(serverDraftWins(t2, null), isTrue);
      expect(
        serverDraftWins(t1, (key: a, updatedAt: t2, syncedAt: t1)),
        isFalse,
      );
      expect(serverDeleteWins((key: a, updatedAt: t1, syncedAt: t1)), isTrue);
      expect(serverDeleteWins((key: a, updatedAt: t2, syncedAt: t1)), isFalse);
      expect(serverDeleteWins(null), isFalse);
    });
  });

  group('burn on read', () {
    final now = DateTime.utc(2026, 10, 26, 12);

    test('a message from someone else stays hidden until opened', () {
      expect(
        burnState(own: false, expireAt: null, maxExpireAt: null, now: now),
        isA<BurnUnrevealed>(),
      );
      final opened = burnState(
        own: false,
        expireAt: now.add(const Duration(minutes: 5)),
        maxExpireAt: now.add(const Duration(days: 7)),
        now: now,
      );
      expect((opened as BurnReadable).at, now.add(const Duration(minutes: 5)));
    });

    test('the sender reads it; it burns once every recipient read it', () {
      expect(
        (burnState(
          own: true,
          expireAt: null,
          maxExpireAt: null,
          now: now,
        ) as BurnReadable).at,
        isNull,
      );
      expect(
        burnState(
          own: true,
          expireAt: now.subtract(const Duration(seconds: 1)),
          maxExpireAt: null,
          now: now,
        ),
        isA<BurnExpired>(),
      );
    });

    test('everyone loses it at the maximum time to live', () {
      expect(
        burnState(own: false, expireAt: null, maxExpireAt: now, now: now),
        isA<BurnExpired>(),
      );
    });

    test('ends are read from the stored JSON, numbers or strings', () {
      final ends = burnEnds(
        '{"expire_at":"1793030843000"}',
        '{"expire_at":1793030000000}',
      );
      expect(ends.expireAt!.millisecondsSinceEpoch, 1793030000000);
      expect(ends.maxExpireAt!.millisecondsSinceEpoch, 1793030843000);
      expect(burnEnds(null, 'not json').expireAt, isNull);
    });

    test('countdowns and durations', () {
      expect(burnCountdown(const Duration(minutes: 9, seconds: 41)), '9:41');
      expect(burnCountdown(const Duration(hours: 1, minutes: 5)), '1:05:00');
      expect(burnCountdown(const Duration(days: 3, hours: 2)), '3 days');
      expect(burnCountdown(const Duration(seconds: -3)), '0:00');
      expect(burnDurationLabel(const Duration(minutes: 10)), '10 min');
      expect(burnDurationLabel(const Duration(hours: 1)), '1 h');
      expect(burnDurationLabel(const Duration(days: 7)), '7 days');
    });
  });
}

ChannelInput _channel(String id, String name) => (
  id: id,
  type: 'O',
  name: name.toLowerCase(),
  displayName: name,
  archived: false,
  createAt: null,
  lastPostAt: null,
  lastRootPostAt: null,
  totalMsgCount: 0,
  totalMsgCountRoot: 0,
  msgCount: 0,
  msgCountRoot: 0,
  mentionCount: 0,
  mentionCountRoot: 0,
  urgentMentionCount: 0,
  muted: false,
  lastViewedAt: null,
);

ScheduledInput _scheduled(
  String id,
  String channelId,
  DateTime at, [
  String? errorCode,
]) => (
  id: id,
  channelId: channelId,
  rootId: '',
  message: 'Message $id',
  files: 0,
  scheduledAt: at,
  errorCode: errorCode,
);
