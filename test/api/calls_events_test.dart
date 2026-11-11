import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/websocket/server_events.dart';

ServerEvent decode(
  String event,
  Map<String, Object?> data, {
  String channel = 'ch1',
}) => decodeEvent(
  SocketFrame.fromJson({
    'event': 'custom_com.mattermost.calls_$event',
    'data': data,
    'broadcast': {'channel_id': channel},
  }),
);

void main() {
  test('a call starts', () {
    final event = decode('call_start', {
      'id': 'call1',
      'channelID': 'ch1',
      'start_at': 1700000000000,
      'thread_id': 'post1',
      'post_id': 'post1',
      'owner_id': 'ann',
      'host_id': 'ann',
    });
    expect(event, isA<CallStartedEvent>());
    event as CallStartedEvent;
    expect(event.channelId, 'ch1');
    expect(event.postId, 'post1');
    expect(event.startAt, DateTime.utc(2023, 11, 14, 22, 13, 20));
  });

  test('people join, leave, mute and raise a hand', () {
    final joined = decode('user_joined', {
      'user_id': 'ann',
      'session_id': 's1',
    }) as CallJoinedEvent;
    expect((joined.userId, joined.sessionId), ('ann', 's1'));
    expect(
      decode('user_left', {'user_id': 'ann', 'session_id': 's1'}),
      isA<CallLeftEvent>(),
    );
    expect(
      (decode('user_muted', {'session_id': 's1'}) as CallMutedEvent).muted,
      isTrue,
    );
    expect(
      (decode('user_unmuted', {'session_id': 's1'}) as CallMutedEvent).muted,
      isFalse,
    );
    expect(
      (decode('user_raise_hand', {
        'session_id': 's1',
        'raised_hand': 99,
      }) as CallHandEvent).raisedAt,
      99,
    );
    expect(
      (decode('user_unraise_hand', {
        'session_id': 's1',
        'raised_hand': 0,
      }) as CallHandEvent).raisedAt,
      0,
    );
  });

  test('the host changes', () {
    final event = decode('call_host_changed', {
      'hostID': 'bob',
      'call_id': 'call1',
    }) as CallHostEvent;
    expect(event.hostId, 'bob');
  });

  test('a call state holds the call as JSON in a string', () {
    final event = decode('call_state', {
      'channel_id': 'ch1',
      'call': jsonEncode({
        'id': 'call1',
        'start_at': 1700000000000,
        'sessions': [
          {
            'session_id': 's1',
            'user_id': 'ann',
            'unmuted': true,
            'raised_hand': 0,
          },
          'garbage',
        ],
        'owner_id': 'ann',
      }),
    }) as CallStateEvent;
    expect(event.call.id, 'call1');
    expect(event.call.sessions.single.userId, 'ann');
  });

  test('a call state that is not JSON is an unknown event', () {
    expect(
      decode('call_state', {'channel_id': 'ch1', 'call': '{broken'}),
      isA<UnknownEvent>(),
    );
  });

  test('a frame without a session or channel is unknown', () {
    expect(decode('user_joined', {'user_id': 'ann'}), isA<UnknownEvent>());
    expect(
      decode('user_muted', {'session_id': 's1'}, channel: ''),
      isA<UnknownEvent>(),
    );
  });

  test('calls are switched on and off in a channel', () {
    expect(
      (decode('channel_enable_voice', {}) as CallsEnabledEvent).enabled,
      isTrue,
    );
    expect(
      (decode('channel_disable_voice', {}) as CallsEnabledEvent).enabled,
      isFalse,
    );
  });

  test('the host acts on a session', () {
    final mute = decode('host_mute', {
      'channel_id': 'ch1',
      'session_id': 's1',
    }, channel: '') as CallHostMuteEvent;
    expect((mute.channelId, mute.sessionId), ('ch1', 's1'));
    expect(
      decode('host_lower_hand', {'channel_id': 'ch1', 'session_id': 's1'}),
      isA<CallHostLowerHandEvent>(),
    );
    final removed = decode('host_removed', {
      'channel_id': 'ch1',
      'session_id': 's1',
      'user_id': 'ann',
    }) as CallHostRemovedEvent;
    expect(removed.sessionId, 's1');
  });

  test('events we do not read stay unknown', () {
    expect(decode('call_job_state', {}), isA<UnknownEvent>());
  });
}
