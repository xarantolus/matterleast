import 'dart:async';
import 'dart:typed_data';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/calls/call_signals.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/calls/call_line.dart';
import 'package:matterleast/data/calls/call_peer.dart';
import 'package:matterleast/domain/call_connection.dart';

import '../support/fake_call.dart';

void run(
  void Function(FakeAsync async, CallHarness h) body, {
  bool dcSignaling = false,
  bool direct = true,
}) {
  fakeAsync((async) {
    final h = CallHarness(dcSignaling: dcSignaling, direct: direct);
    body(async, h);
    h.close();
  });
}

void main() {
  group('joining', () {
    test('sends join first and the offer only after the server accepted', () {
      run((async, h) {
        unawaited(h.session.start());
        async.flushMicrotasks();
        expect(h.state.phase, CallPhase.preparing);
        expect(h.lines, hasLength(1));
        h.line.emit(const LineHello('conn1'));
        async.flushMicrotasks();
        expect(h.line.actions, ['join']);
        expect(h.line.sent.single.data?['channelID'], CallHarness.channel);
        expect(h.state.phase, CallPhase.joining);
        expect(h.state.sessionId, 'conn1');
        expect(h.peer.offers, isEmpty);
        expect(h.line.sdp, isEmpty);

        h.line.emit(const LineJoined());
        async.flushMicrotasks();
        expect(h.peer.offers, hasLength(1));
        expect(h.line.sdp, hasLength(1));
        expect(h.state.phase, CallPhase.connecting);
      });
    });

    test('has the peer, with the microphone, ready before it joins', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        expect(
          h.log.indexOf('peer:start'),
          lessThan(h.log.indexOf('line:join')),
        );
        expect(h.peer.microphone, isTrue);
        expect(h.platform.serviceRunning, isTrue);
      });
    });

    test('is connected once the answer is applied and the media is up', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        expect(h.peer.remoteAnswers, ['server-answer']);
        expect(h.state.phase, CallPhase.connected);
      });
    });

    test('asks again when the first offer gets no answer', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        async.elapse(const Duration(seconds: 3));
        expect(h.peer.offers.length, 2);
        expect(h.line.sdp.length, 2);
      });
    });

    test('says what the server said when it refuses the join', () {
      run((async, h) {
        unawaited(h.session.start());
        async.flushMicrotasks();
        h.line.emit(const LineHello('conn1'));
        h.line.emit(const LineError('cannot join call in archived channel'));
        async.flushMicrotasks();
        expect(h.state.phase, CallPhase.failed);
        expect(
          h.state.failure?.message,
          'cannot join call in archived channel',
        );
        expect(h.peer.closed, isTrue);
        expect(h.platform.serviceRunning, isFalse);
      });
    });

    test('retries a socket that does not open, within the budget', () {
      run((async, h) {
        h.failOpens = 2;
        unawaited(h.session.start());
        async.elapse(const Duration(seconds: 2));
        expect(h.opens.length, 3);
        expect(h.lines, hasLength(1));
      });
    });

    test('gives a socket that stalls only so long to open', () {
      run((async, h) {
        h.stallOpens = 1;
        h.session.start();
        async.elapse(const Duration(seconds: 4));
        expect(h.opens, hasLength(2));
        expect(h.lines, hasLength(1));
      });
    });

    test('fails when the socket never opens', () {
      run((async, h) {
        h.failOpens = 100;
        unawaited(h.session.start());
        async.elapse(const Duration(seconds: 9));
        expect(h.state.phase, CallPhase.failed);
        expect(h.state.failure?.kind, CallFailureKind.noConnection);
      });
    });

    test('fails when the server never accepts the join', () {
      run((async, h) {
        unawaited(h.session.start());
        async.flushMicrotasks();
        h.line.emit(const LineHello('conn1'));
        async.elapse(const Duration(seconds: 9));
        expect(h.state.failure?.kind, CallFailureKind.timeout);
      });
    });

    test('names the media port when ICE never connects', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.line.emit(
          LineSignal(
            '{"type":"candidate","candidate":{"candidate":'
            '"candidate:1 1 udp 2130706431 10.0.0.9 8445 typ host"}}',
          ),
        );
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 16));
        expect(h.state.failure?.kind, CallFailureKind.media);
        expect(h.state.failure?.message, contains('UDP 8445'));
      });
    });

    test('falls back to listening when the microphone can not be opened', () {
      fakeAsync((async) {
        final h = CallHarness(micFails: true);
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        expect(h.peers, hasLength(2));
        expect(h.peers.first.closed, isTrue);
        expect(h.peer.microphone, isFalse);
        expect(h.state.listenOnly, isTrue);
        expect(h.state.phase, CallPhase.connected);
        h.close();
      });
    });
  });

  group('without the microphone', () {
    test('joins listen-only, muted, and stays muted', () {
      run((async, h) {
        h.platform.microphone = false;
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        expect(h.peer.microphone, isFalse);
        expect(h.state.listenOnly, isTrue);
        unawaited(h.session.setMuted(muted: false));
        async.flushMicrotasks();
        expect(h.line.actions, isNot(contains('unmute')));
        expect(h.state.muted, isTrue);
      });
    });
  });

  group('muting', () {
    test('unmute is sent only after the audio is switched on', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        unawaited(h.session.setMuted(muted: false));
        async.flushMicrotasks();
        expect(h.line.actions, isNot(contains('unmute')));
        h.connect(async.flushMicrotasks);
        expect(h.log.skipWhile((e) => e != 'peer:sending:true').toList(), [
          'peer:sending:true',
          'line:unmute',
        ]);
        expect(h.state.muted, isFalse);
      });
    });

    test('mute tells the server first, then silences the audio', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        unawaited(h.session.setMuted(muted: false));
        async.flushMicrotasks();
        h.log.clear();
        unawaited(h.session.setMuted(muted: true));
        async.flushMicrotasks();
        expect(h.log, ['line:mute', 'peer:sending:false']);
      });
    });

    test('never renegotiates', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        final offers = h.peer.offers.length;
        unawaited(h.session.setMuted(muted: false));
        unawaited(h.session.setMuted(muted: true));
        async.flushMicrotasks();
        expect(h.peer.offers.length, offers);
      });
    });

    test('a host mute mutes us', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        unawaited(h.session.setMuted(muted: false));
        async.flushMicrotasks();
        h.line.emit(
          LineCall(CallHostMuteEvent(CallHarness.channel, sessionId: 'conn1')),
        );
        async.flushMicrotasks();
        expect(h.state.muted, isTrue);
        expect(h.line.actions.last, 'mute');
      });
    });
  });

  group('the calls socket dropping', () {
    test('reconnects with the old ids, once, and asks for the state', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        final first = h.line;
        first.drop();
        async.flushMicrotasks();
        expect(h.state.phase, CallPhase.reconnecting);
        async.elapse(const Duration(milliseconds: 600));
        expect(h.lines, hasLength(2));
        expect(h.opens.last.connectionId, 'conn1');
        expect(h.opens.last.originalId, 'conn1');
        h.line.emit(const LineHello('conn2'));
        h.line.emit(const LineHello('conn2'));
        async.flushMicrotasks();
        expect(h.line.reconnects, hasLength(1));
        expect(h.line.reconnects.single, {
          'channelId': CallHarness.channel,
          'originalId': 'conn1',
          'previousId': 'conn1',
        });
        expect(h.refreshes, 1);
        expect(h.state.phase, CallPhase.connected);
      });
    });

    test(
      'does not wait for a hello from a socket that resumes the old one',
      () {
        run((async, h) {
          h.join(async.flushMicrotasks);
          h.connect(async.flushMicrotasks);
          h.line.drop();
          async.elapse(const Duration(milliseconds: 600));
          expect(h.lines, hasLength(2));
          expect(h.line.reconnects, hasLength(1));
          expect(h.refreshes, 1);
          expect(h.state.phase, CallPhase.connected);
        });
      },
    );

    test('is over when the server refuses the reconnect', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        h.line.drop();
        async.elapse(const Duration(milliseconds: 600));
        h.line.emit(const LineHello('conn2'));
        h.line.emit(const LineError('session not found in call state'));
        async.flushMicrotasks();
        expect(h.state.phase, CallPhase.failed);
        expect(h.state.failure?.message, contains('dropped you'));
        expect(h.peer.closed, isTrue);
      });
    });

    test('gives up after the budget, before the server drops the session', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        h.failOpens = 100;
        h.line.drop();
        async.elapse(const Duration(seconds: 8));
        expect(h.state.phase, CallPhase.failed);
        expect(h.state.failure?.kind, CallFailureKind.noConnection);
      });
    });

    test('tries again after a socket that does not open', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        h.failOpens = 2;
        h.line.drop();
        async.elapse(const Duration(seconds: 3));
        expect(h.lines, hasLength(2));
        expect(h.state.phase, isNot(CallPhase.failed));
      });
    });
  });

  group('restarting ICE', () {
    void answerNextOffer(FakeAsync async, CallHarness h) {
      h.line.emit(
        LineSignal(sessionDescriptionJson('answer', 'restart-answer')),
      );
      async.flushMicrotasks();
    }

    test('takes the lock, offers with new credentials, then unlocks', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        h.peer.link(PeerLink.disconnected);
        async.flushMicrotasks();
        expect(h.state.phase, CallPhase.restartingIce);
        expect(h.peer.data.whereType<DcLockRequest>(), hasLength(1));
        expect(h.peer.offers.where((o) => o.iceRestart), isEmpty);

        h.peer.emit(PeerChannelMessage(Uint8List.fromList([0xcc, 7, 0xc3])));
        async.flushMicrotasks();
        expect(h.peer.offers.last.iceRestart, isTrue);
        answerNextOffer(async, h);
        expect(h.peer.remoteAnswers.last, 'restart-answer');
        expect(h.peer.data.whereType<DcUnlock>(), hasLength(1));
        h.peer.link(PeerLink.connected);
        async.flushMicrotasks();
        expect(h.state.phase, CallPhase.connected);
      });
    });

    test('goes without the lock when the data channel does not answer', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        final before = h.peer.offers.length;
        h.peer.link(PeerLink.disconnected);
        async.elapse(const Duration(milliseconds: 900));
        expect(h.peer.offers.length, before);
        async.elapse(const Duration(milliseconds: 200));
        expect(h.peer.offers.length, before + 1);
        expect(h.peer.offers.last.iceRestart, isTrue);
        answerNextOffer(async, h);
        expect(h.peer.remoteAnswers.last, 'restart-answer');
        expect(h.peer.data.whereType<DcUnlock>(), isEmpty);
      });
    });

    test('hands back a lock the server grants after the wait is over', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        h.peer.link(PeerLink.disconnected);
        async.elapse(const Duration(seconds: 1, milliseconds: 100));
        expect(h.peer.data.whereType<DcUnlock>(), isEmpty);
        h.peer.emit(PeerChannelMessage(Uint8List.fromList([0xcc, 7, 0xc3])));
        async.flushMicrotasks();
        expect(h.peer.data.whereType<DcUnlock>(), hasLength(1));
      });
    });

    test('lets a restart bring the path back before another starts', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        h.peer.link(PeerLink.disconnected);
        async.elapse(const Duration(seconds: 1, milliseconds: 100));
        answerNextOffer(async, h);
        final offers = h.peer.offers.length;
        // Three silent seconds would count as lost pongs.
        async.elapse(const Duration(seconds: 4));
        expect(h.peer.offers.length, offers);
        async.elapse(const Duration(seconds: 4));
        expect(h.peer.offers.length, offers + 1);
      });
    });

    test('a network change while the socket is down rebuilds the path', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        h.line.drop();
        async.flushMicrotasks();
        h.network.add(null);
        async.elapse(const Duration(milliseconds: 1600));
        h.line.emit(const LineHello('conn2'));
        async.elapse(const Duration(milliseconds: 100));
        expect(h.peer.data.whereType<DcLockRequest>(), hasLength(1));
      });
    });

    test('sends the offer over the data channel when the server wants it', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        final socketOffers = h.line.sdp.length;
        h.peer.link(PeerLink.disconnected);
        async.flushMicrotasks();
        h.peer.emit(PeerChannelMessage(Uint8List.fromList([0xcc, 7, 0xc3])));
        async.flushMicrotasks();
        expect(h.peer.data.whereType<DcSdp>(), hasLength(1));
        expect(h.line.sdp.length, socketOffers);
      }, dcSignaling: true);
    });

    test('is not started twice while one runs', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        h.peer.link(PeerLink.disconnected);
        h.peer.link(PeerLink.disconnected);
        async.flushMicrotasks();
        expect(h.peer.data.whereType<DcLockRequest>(), hasLength(1));
      });
    });

    test('three missed pongs start one', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        async.elapse(const Duration(seconds: 2));
        expect(h.peer.data.whereType<DcLockRequest>(), isEmpty);
        async.elapse(const Duration(seconds: 2));
        expect(h.peer.data.whereType<DcLockRequest>(), isNotEmpty);
        expect(h.peer.data.whereType<DcPing>(), isNotEmpty);
      });
    });

    test('answered pings keep the path as it is', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        for (var i = 0; i < 10; i++) {
          async.elapse(const Duration(seconds: 1));
          h.peer.emit(PeerChannelMessage(Uint8List.fromList([0xcc, 2])));
        }
        expect(h.peer.data.whereType<DcLockRequest>(), isEmpty);
        expect(h.state.phase, CallPhase.connected);
      });
    });

    test('a network change reconnects the socket and rebuilds the path', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        final first = h.line..alive = false;
        h.network.add(null);
        async.elapse(const Duration(milliseconds: 3600));
        expect(first.closed, isTrue);
        expect(h.lines, hasLength(2));
        h.line.emit(const LineHello('conn2'));
        async.flushMicrotasks();
        expect(h.line.reconnects, hasLength(1));
        expect(h.peer.data.whereType<DcLockRequest>(), hasLength(1));
      });
    });

    test('a network change keeps a socket that still answers', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        final first = h.line;
        h.network.add(null);
        async.elapse(const Duration(milliseconds: 1200));
        expect(first.closed, isFalse);
        expect(h.lines, hasLength(1));
        expect(h.peer.data.whereType<DcLockRequest>(), hasLength(1));
      });
    });

    test('a burst of network reports is one change', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        h.network.add(null);
        async.elapse(const Duration(milliseconds: 500));
        h.network.add(null);
        async.elapse(const Duration(milliseconds: 500));
        h.network.add(null);
        async.elapse(const Duration(milliseconds: 1800));
        expect(h.peer.data.whereType<DcLockRequest>(), hasLength(1));
      });
    });

    test('ends the call when restarts do not bring the path back', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        h.peer.link(PeerLink.failed);
        async.elapse(const Duration(seconds: 90));
        expect(h.state.phase, CallPhase.failed);
        expect(h.state.failure?.kind, CallFailureKind.media);
        expect(h.peer.closed, isTrue);
      });
    });
  });

  group('the call ending', () {
    test('leave says so to the server and tears everything down', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        unawaited(h.session.leave());
        async.flushMicrotasks();
        expect(h.line.actions.last, 'leave');
        expect(h.line.closed, isTrue);
        expect(h.peer.closed, isTrue);
        expect(h.platform.serviceRunning, isFalse);
        expect(h.state.phase, CallPhase.ended);
        expect(h.state.endedBy, CallEnd.left);
      });
    });

    test('the notification action leaves', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        h.platform.hangUp.add(null);
        async.flushMicrotasks();
        expect(h.state.endedBy, CallEnd.left);
      });
    });

    test('being removed by the host ends it', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        h.line.emit(
          LineCall(
            CallHostRemovedEvent(CallHarness.channel, sessionId: 'someone'),
          ),
        );
        async.flushMicrotasks();
        expect(h.state.phase, CallPhase.connected);
        h.line.emit(
          LineCall(
            CallHostRemovedEvent(CallHarness.channel, sessionId: 'conn1'),
          ),
        );
        async.flushMicrotasks();
        expect(h.state.endedBy, CallEnd.removed);
      });
    });

    test('the host ending the call ends it', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        h.line.emit(LineCall(CallEndedEvent(CallHarness.channel)));
        async.flushMicrotasks();
        expect(h.state.endedBy, CallEnd.ended);
      });
    });
  });

  group('the audio route', () {
    test('is the earpiece in a direct message, until the user picks', () {
      run((async, h) {
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        expect(h.state.route, AudioRoute.earpiece);
        expect(h.platform.appliedRoutes, [AudioRoute.earpiece]);
        unawaited(h.session.setRoute(AudioRoute.speaker));
        async.flushMicrotasks();
        expect(h.state.route, AudioRoute.speaker);
      });
    });

    test('is the speaker elsewhere, and a pick goes when its device goes', () {
      run((async, h) {
        h.platform.routeList = [
          AudioRoute.earpiece,
          AudioRoute.speaker,
          AudioRoute.bluetooth,
        ];
        h.join(async.flushMicrotasks);
        h.connect(async.flushMicrotasks);
        expect(h.state.route, AudioRoute.bluetooth);
        unawaited(h.session.setRoute(AudioRoute.bluetooth));
        async.flushMicrotasks();
        h.platform.routeList = [AudioRoute.earpiece, AudioRoute.speaker];
        h.platform.routesChange.add(null);
        async.flushMicrotasks();
        expect(h.state.route, AudioRoute.speaker);
      }, direct: false);
    });
  });
}
