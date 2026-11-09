import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/json/calls.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/domain/calls.dart';

const _channel = 'ch1';

CallsState _started([CallsState? state]) => applyCallEvent(
  state ?? const CallsState(),
  const CallStartedEvent(_channel, id: 'call1', postId: 'post1'),
);

CallsState _joined(CallsState state, String session, String user) =>
    applyCallEvent(
      state,
      CallJoinedEvent(_channel, sessionId: session, userId: user),
    );

void main() {
  group('events', () {
    test('people join, speak, mute and leave', () {
      var state = _joined(_started(), 's1', 'ann');
      state = _joined(state, 's2', 'bob');
      expect(state.calls[_channel]!.participantUserIds, ['ann', 'bob']);
      expect(state.calls[_channel]!.sessions['s1']!.muted, isTrue);

      state = applyCallEvent(
        state,
        const CallMutedEvent(_channel, sessionId: 's1', muted: false),
      );
      state = applyCallEvent(
        state,
        const CallVoiceEvent(_channel, sessionId: 's1', speaking: true),
      );
      state = applyCallEvent(
        state,
        const CallHandEvent(_channel, sessionId: 's2', raisedAt: 5),
      );
      final s1 = state.calls[_channel]!.sessions['s1']!;
      expect(s1.muted, isFalse);
      expect(s1.speaking, isTrue);
      expect(state.calls[_channel]!.sessions['s2']!.raisedHand, 5);

      state = applyCallEvent(
        state,
        const CallLeftEvent(_channel, sessionId: 's1'),
      );
      expect(state.calls[_channel]!.participantUserIds, ['bob']);
    });

    test('one person on two devices counts once', () {
      var state = _joined(_started(), 's1', 'ann');
      state = _joined(state, 's2', 'ann');
      expect(state.calls[_channel]!.sessions, hasLength(2));
      expect(state.calls[_channel]!.participantUserIds, ['ann']);
    });

    test('joining twice with one session changes nothing', () {
      final once = _joined(_started(), 's1', 'ann');
      expect(identical(_joined(once, 's1', 'ann'), once), isTrue);
    });

    test('the host changes and the call ends', () {
      var state = applyCallEvent(
        _started(),
        const CallHostEvent(_channel, hostId: 'bob'),
      );
      expect(state.calls[_channel]!.hostId, 'bob');
      state = applyCallEvent(state, const CallEndedEvent(_channel));
      expect(state.calls, isEmpty);
    });

    test('a repeated start keeps the people already known', () {
      final state = _started(_joined(_started(), 's1', 'ann'));
      expect(state.calls[_channel]!.participantUserIds, ['ann']);
    });

    test('a snapshot replaces the call wholesale', () {
      var state = _joined(_started(), 's1', 'ann');
      state = applyCallEvent(
        state,
        CallStateEvent(
          _channel,
          CallSnapshot.fromJson({
            'id': 'call1',
            'sessions': [
              {'session_id': 'x', 'user_id': 'cy', 'unmuted': true},
            ],
          }),
        ),
      );
      expect(state.calls[_channel]!.participantUserIds, ['cy']);
      expect(state.calls[_channel]!.sessions['x']!.muted, isFalse);
    });

    test('events about a call we do not know change nothing', () {
      const empty = CallsState();
      expect(_joined(empty, 's1', 'ann'), empty);
      expect(
        applyCallEvent(
          empty,
          const CallMutedEvent(_channel, sessionId: 's1', muted: false),
        ),
        empty,
      );
    });

    test('screen sharing follows the session that shares', () {
      var state = _joined(_started(), 's1', 'ann');
      state = applyCallEvent(
        state,
        const CallScreenEvent(_channel, sessionId: 's1', sharing: true),
      );
      expect(state.calls[_channel]!.screenSharingSessionId, 's1');
      state = applyCallEvent(
        state,
        const CallLeftEvent(_channel, sessionId: 's1'),
      );
      expect(state.calls[_channel]!.screenSharingSessionId, '');
    });

    test('switching calls on and off is kept per channel', () {
      final state = applyCallEvent(
        const CallsState(),
        const CallsEnabledEvent(_channel, enabled: false),
      );
      expect(state.enabled, {_channel: false});
    });
  });

  group('where calls are offered', () {
    CallsConfig config({bool defaultEnabled = true, bool? groups}) =>
        CallsConfig(defaultEnabled: defaultEnabled, groupCallsAllowed: groups);

    CallAction action({
      CallsConfig? config,
      String type = 'D',
      bool? explicit,
      bool live = false,
      bool admin = false,
    }) => callAction(
      config: config,
      channelType: type,
      explicit: explicit,
      live: live,
      admin: admin,
    );

    test('nothing before the settings arrived', () {
      expect(action(), CallAction.none);
    });

    test('a channel with calls switched off offers nothing, even live', () {
      expect(
        action(config: config(), explicit: false, live: true),
        CallAction.none,
      );
    });

    test('a live call is joined, otherwise started', () {
      expect(action(config: config(), live: true), CallAction.join);
      expect(action(config: config()), CallAction.start);
    });

    test('without the default only admins start, unless switched on', () {
      final off = config(defaultEnabled: false);
      expect(action(config: off), CallAction.none);
      expect(action(config: off, admin: true), CallAction.start);
      expect(action(config: off, explicit: true), CallAction.start);
      expect(action(config: off, live: true), CallAction.join);
    });

    test('group calls can be forbidden, direct ones not', () {
      final noGroups = config(groups: false);
      expect(action(config: noGroups, type: 'O'), CallAction.none);
      expect(action(config: noGroups, type: 'G', live: true), CallAction.none);
      expect(action(config: noGroups, type: 'D'), CallAction.start);
      expect(action(config: config(), type: 'G'), CallAction.start);
    });
  });

  group('call post card', () {
    CallCardState card({
      DateTime? endAt,
      String status = '',
      int people = 0,
      bool exists = true,
    }) => callCardState(
      endAt: endAt,
      status: status,
      people: people,
      callExists: exists,
    );
    final end = DateTime.utc(2026, 11, 1);

    test('a running call is active', () {
      expect(card(people: 3), CallCardState.active);
    });

    test('a ringing direct message call turns active with a second person', () {
      expect(card(status: 'calling', people: 1), CallCardState.calling);
      expect(card(status: 'calling', people: 2), CallCardState.active);
    });

    test('a call gone before its post says so just ended', () {
      expect(
        card(status: 'calling', people: 1, exists: false),
        CallCardState.ended,
      );
    });

    test('an ended post says how it ended', () {
      expect(card(endAt: end), CallCardState.ended);
      expect(card(endAt: end, status: 'no_answer'), CallCardState.noAnswer);
      expect(
        card(endAt: end, status: 'canceled_by_caller'),
        CallCardState.canceled,
      );
      expect(card(endAt: end, status: 'declined'), CallCardState.declined);
      expect(card(endAt: end, status: 'ended'), CallCardState.ended);
    });
  });

  test('a call length reads in words', () {
    expect(callDurationLabel(const Duration(seconds: 20)), 'a few seconds');
    expect(callDurationLabel(const Duration(seconds: 60)), 'a minute');
    expect(
      callDurationLabel(const Duration(minutes: 1, seconds: 59)),
      '2 minutes',
    );
    expect(callDurationLabel(const Duration(minutes: 5)), '5 minutes');
    expect(callDurationLabel(const Duration(minutes: 60)), 'an hour');
    expect(callDurationLabel(const Duration(hours: 3)), '3 hours');
    expect(callDurationLabel(const Duration(hours: 30)), 'a day');
    expect(callDurationLabel(const Duration(days: 3)), '3 days');
  });
}
