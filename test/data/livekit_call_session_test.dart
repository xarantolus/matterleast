import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/calls/livekit_wire.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/calls/call_room.dart';
import 'package:matterleast/data/calls/livekit_call_session.dart';
import 'package:matterleast/data/live/call_live.dart';
import 'package:matterleast/domain/call_connection.dart';
import 'package:matterleast/domain/call_livekit_rules.dart';

import '../support/fake_call.dart';

class FakeRoom implements CallRoom {
  final controller = StreamController<RoomNote>.broadcast(sync: true);
  final log = <String>[];
  var connected = Completer<void>();
  var microphoneOpens = true;
  var closed = false;

  @override
  Stream<RoomNote> get notes => controller.stream;

  @override
  Future<void> connect(String url, String token) {
    log.add('connect $url $token');
    return connected.future;
  }

  @override
  Future<bool> openMicrophone() async {
    log.add('microphone');
    return microphoneOpens;
  }

  @override
  Future<void> setMuted({required bool muted}) async => log.add('mute $muted');

  @override
  Future<void> setHand(int raisedAt) async =>
      log.add(raisedAt > 0 ? 'hand up' : 'hand down');

  @override
  Future<void> react(String name, String character, int timestamp) async =>
      log.add('react $name');

  @override
  Future<void> close() async {
    closed = true;
    await controller.close();
  }
}

class FakeFeed implements CallRoomFeed {
  final events = <CallsEvent>[];
  final members = <String, ({bool muted, int raisedAt})>{};
  var cleared = 0;
  var refreshes = 0;

  @override
  void apply(CallsEvent event) => events.add(event);

  @override
  void setMember(
    String channelId,
    String sessionId, {
    required bool muted,
    required int raisedAt,
  }) => members[sessionId] = (muted: muted, raisedAt: raisedAt);

  @override
  void clearMembers(String channelId) => cleared++;

  @override
  Future<void> refreshChannel(String id) async => refreshes++;
}

const _channel = 'ch000000000000000000000001';

class Harness {
  Harness({
    this.session = const LiveKitSession(
      sessionId: 's-me',
      token: 't',
      url: 'ws://media',
    ),
  }) {
    call = LiveKitCallSession(
      channelId: _channel,
      direct: false,
      room: room,
      feed: feed,
      platform: platform,
      requestSession: ({title, threadId}) async {
        if (refusal != null) throw refusal!;
        return session;
      },
      failureText: (e) => 'failed: $e',
    );
  }

  final LiveKitSession session;
  final room = FakeRoom();
  final feed = FakeFeed();
  final platform = FakeCallPlatform();
  Object? refusal;
  late final LiveKitCallSession call;

  CallConnection get state => call.connection.value;

  /// Joins and lets the room accept us with [others] in it.
  void join(void Function() flush, {List<RoomMember> others = const []}) {
    unawaited(call.start());
    flush();
    room.connected.complete();
    flush();
    room.controller.add(
      RoomEntered([
        (identity: 'me___s-me', muted: true, raisedAt: 0),
        ...others,
      ]),
    );
    flush();
  }

  void close() => unawaited(platform.close());
}

void run(void Function(FakeAsync async, Harness h) body) {
  fakeAsync((async) {
    final h = Harness();
    body(async, h);
    h.close();
  });
}

void main() {
  test('joining asks the server, enters the room and opens the microphone', () {
    run((async, h) {
      h.join(async.flushMicrotasks);
      expect(h.room.log, ['connect ws://media t', 'microphone']);
      expect(h.state.phase, CallPhase.connected);
      expect(h.state.sessionId, 's-me');
      expect(h.state.listenOnly, isFalse);
      expect(h.platform.serviceRunning, isTrue);
    });
  });

  test('the server refusing shows what it said and nothing connects', () {
    run((async, h) {
      h.refusal = StateError('no calls here');
      unawaited(h.call.start());
      async.flushMicrotasks();
      expect(h.state.phase, CallPhase.failed);
      expect(h.state.failure?.kind, CallFailureKind.server);
      expect(h.state.failure?.message, contains('no calls here'));
      expect(h.room.log, isEmpty);
    });
  });

  test('a room that never answers fails with a timeout', () {
    run((async, h) {
      unawaited(h.call.start());
      async.elapse(const Duration(seconds: 31));
      expect(h.state.phase, CallPhase.failed);
      expect(h.state.failure?.kind, CallFailureKind.timeout);
      expect(h.room.closed, isTrue);
      expect(h.platform.serviceRunning, isFalse);
    });
  });

  test('a refused microphone joins listening only', () {
    run((async, h) {
      h.platform.microphone = false;
      h.join(async.flushMicrotasks);
      expect(h.state.listenOnly, isTrue);
      expect(h.room.log, isNot(contains('microphone')));
      unawaited(h.call.setMuted(muted: false));
      async.flushMicrotasks();
      expect(h.state.muted, isTrue);
    });
  });

  test('who is muted, speaking or reacting comes from the room', () {
    run((async, h) {
      h.join(
        async.flushMicrotasks,
        others: [(identity: 'bob___s-bob', muted: true, raisedAt: 0)],
      );
      expect(
        h.feed.events,
        contains(isA<CallJoinedEvent>().having((e) => e.userId, 'user', 'bob')),
      );
      h.room.controller
        ..add(const MemberMuted('bob___s-bob', muted: false))
        ..add(const MemberHand('bob___s-bob', 42))
        ..add(const RoomSpeakers({'bob___s-bob'}))
        ..add(const MemberReacted('bob___s-bob', 'tada'))
        ..add(const RoomSpeakers({}));
      expect(h.feed.members['s-bob'], (muted: false, raisedAt: 42));
      expect(h.feed.events.whereType<CallVoiceEvent>().map((e) => e.speaking), [
        true,
        false,
      ]);
      expect(h.feed.events.whereType<CallReactionEvent>().single.emoji, 'tada');
    });
  });

  test('the recording bot is not a person in the call', () {
    fakeAsync((async) {
      final h = Harness(
        session: const LiveKitSession(
          sessionId: 's-me',
          token: 't',
          url: 'ws://media',
          botUserId: 'robot',
        ),
      );
      h.join(
        async.flushMicrotasks,
        others: [(identity: 'robot___s-bot', muted: false, raisedAt: 0)],
      );
      expect(h.feed.events.whereType<CallJoinedEvent>().map((e) => e.userId), [
        'me',
      ]);
      expect(h.feed.members.keys, isNot(contains('s-bot')));
      h.close();
    });
  });

  test('the host muting us shows as muted, and unmuting follows the room', () {
    run((async, h) {
      h.join(async.flushMicrotasks);
      unawaited(h.call.setMuted(muted: false));
      async.flushMicrotasks();
      expect(h.room.log.last, 'mute false');
      expect(h.state.muted, isFalse);
      h.room.controller.add(const MemberMuted('me___s-me', muted: true));
      expect(h.state.muted, isTrue);
    });
  });

  test('hand and reaction go to the room and our own reaction shows', () {
    run((async, h) {
      h.join(async.flushMicrotasks);
      unawaited(h.call.setHandRaised(raised: true));
      unawaited(h.call.react('tada', '🎉'));
      async.flushMicrotasks();
      expect(h.room.log, containsAll(['hand up', 'react tada']));
      expect(
        h.feed.events.whereType<CallReactionEvent>().single.sessionId,
        's-me',
      );
    });
  });

  test('a dropped room reconnects by itself and the call goes on', () {
    run((async, h) {
      h.join(async.flushMicrotasks);
      h.room.controller.add(const RoomReconnecting());
      expect(h.state.phase, CallPhase.reconnecting);
      h.room.controller.add(const RoomReconnected());
      expect(h.state.phase, CallPhase.connected);
      expect(h.feed.refreshes, greaterThan(1));
    });
  });

  test('the room ending, removing us or breaking says why', () {
    for (final (why, end, phase) in [
      (RoomLeft.callEnded, CallEnd.ended, CallPhase.ended),
      (RoomLeft.removed, CallEnd.removed, CallPhase.ended),
      (RoomLeft.other, null, CallPhase.failed),
    ]) {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.room.controller.add(RoomClosed(why));
        async.flushMicrotasks();
        expect(h.state.phase, phase);
        expect(h.state.endedBy, end);
        expect(h.room.closed, isTrue);
        expect(h.feed.cleared, 1);
      });
    }
  });

  test('leaving closes the room and stops the service', () {
    run((async, h) {
      h.join(async.flushMicrotasks);
      unawaited(h.call.leave());
      async.flushMicrotasks();
      expect(h.state.endedBy, CallEnd.left);
      expect(h.room.closed, isTrue);
      expect(h.platform.serviceRunning, isFalse);
    });
  });
}
