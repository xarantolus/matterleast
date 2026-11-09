import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:matterleast/api/calls/livekit_wire.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/calls/call_platform.dart';
import 'package:matterleast/data/calls/call_room.dart';
import 'package:matterleast/data/calls/call_run.dart';
import 'package:matterleast/data/live/call_live.dart';
import 'package:matterleast/domain/call_connection.dart';
import 'package:matterleast/domain/call_livekit_rules.dart';
import 'package:matterleast/domain/call_rules.dart';
import 'package:matterleast/log.dart';

/// One call whose media runs through a LiveKit room. The server gives us a
/// place with one request; who is muted, speaking or has a hand up comes
/// from the room, and the plugin's events keep arriving over the app's own
/// socket.
class LiveKitCallSession implements CallRun {
  LiveKitCallSession({
    required this.channelId,
    required this.direct,
    required this.room,
    required this.feed,
    required this.platform,
    required this.requestSession,
    required this.failureText,
    this.title,
    this.threadId,
    this.timings = const CallTimings(),
  });

  final String channelId;
  final bool direct;
  final CallRoom room;
  final CallRoomFeed feed;
  final CallPlatform platform;

  /// Asks the plugin for a place in the call.
  final Future<LiveKitSession> Function({String? title, String? threadId})
  requestSession;
  final String Function(Object error) failureText;
  final String? title;
  final String? threadId;
  final CallTimings timings;

  @override
  final connection = ValueNotifier(const CallConnection());

  final _subscriptions = <StreamSubscription<Object?>>[];
  var _finished = false;
  var _sessionId = '';
  var _botUserId = '';
  var _speaking = <String>{};
  AudioRoute? _pinned;

  void _set(CallConnection Function(CallConnection) edit) {
    final next = edit(connection.value);
    if (next != connection.value) connection.value = next;
  }

  @override
  Future<void> start() async {
    _set((c) => c.copyWith(phase: CallPhase.preparing));
    _subscriptions
      ..add(platform.hangUps.listen((_) => unawaited(leave())))
      ..add(platform.routesChanged.listen((_) => unawaited(_syncRoutes())))
      ..add(room.notes.listen(_onNote));
    var microphone = false;
    try {
      microphone = await platform.requestMicrophone();
    } on Object catch (e) {
      Log.warn('calls', 'Asking for the microphone failed', e);
    }
    if (_finished) return;
    _set((c) => c.copyWith(listenOnly: !microphone));
    final LiveKitSession session;
    try {
      session = await requestSession(title: title, threadId: threadId);
    } on Object catch (e) {
      _fail(CallFailure(CallFailureKind.server, failureText(e)));
      return;
    }
    if (_finished) return;
    if (!session.usable) {
      _fail(
        const CallFailure(
          CallFailureKind.server,
          'The server did not give a place in the call.',
        ),
      );
      return;
    }
    _sessionId = session.sessionId;
    _botUserId = session.botUserId;
    _set(
      (c) =>
          c.copyWith(phase: CallPhase.connecting, sessionId: session.sessionId),
    );
    try {
      await platform.startService(title: 'Call in progress', text: '');
    } on Object catch (e) {
      Log.warn('calls', 'Starting the call service failed', e);
    }
    if (_finished) return;
    try {
      await room
          .connect(session.url, session.token)
          .timeout(timings.roomConnectTimeout);
    } on TimeoutException {
      _fail(
        const CallFailure(
          CallFailureKind.timeout,
          "The call server didn't answer. Try again.",
        ),
      );
      return;
    } on Object catch (e) {
      Log.warn('calls', 'Joining the room failed: ${e.runtimeType}');
      _fail(
        const CallFailure(
          CallFailureKind.media,
          "Couldn't set up the audio connection to the call server.",
        ),
      );
      return;
    }
    if (_finished) return;
    if (microphone && !await _openMicrophone()) {
      _set((c) => c.copyWith(listenOnly: true));
    }
  }

  Future<bool> _openMicrophone() async {
    try {
      return await room.openMicrophone();
    } on Object catch (e) {
      Log.warn('calls', 'The microphone could not be opened', e);
      return false;
    }
  }

  void _onNote(RoomNote note) {
    if (_finished) return;
    switch (note) {
      case RoomEntered(:final members):
        _set((c) => c.copyWith(phase: CallPhase.connected));
        for (final member in members) {
          _enter(member);
        }
        unawaited(feed.refreshChannel(channelId));
        unawaited(_syncRoutes());
      case RoomReconnecting():
        _set((c) => c.copyWith(phase: CallPhase.reconnecting));
      case RoomReconnected():
        _set((c) => c.copyWith(phase: CallPhase.connected));
        unawaited(feed.refreshChannel(channelId));
      case RoomClosed(:final why):
        switch (why) {
          case RoomLeft.callEnded:
            unawaited(_finish(CallEnd.hostEnded));
          case RoomLeft.removed:
            unawaited(_finish(CallEnd.removed));
          case RoomLeft.other:
            _fail(
              const CallFailure(
                CallFailureKind.noConnection,
                'The connection to the call was lost and could not be '
                'restored. Check the connection and join again.',
              ),
            );
        }
      case MemberEntered(:final member):
        _enter(member);
      case MemberLeft(:final identity):
        final who = parseCallIdentity(identity);
        feed.apply(CallLeftEvent(channelId, sessionId: who.sessionId));
      case MemberMuted(:final identity, :final muted):
        _muted(parseCallIdentity(identity).sessionId, muted);
      case MemberHand(:final identity, :final raisedAt):
        final who = parseCallIdentity(identity);
        feed.setMember(
          channelId,
          who.sessionId,
          muted: _mutedBy[who.sessionId] ?? true,
          raisedAt: raisedAt,
        );
        _handsBy[who.sessionId] = raisedAt;
      case RoomSpeakers(:final identities):
        final now = {
          for (final id in identities) parseCallIdentity(id).sessionId,
        };
        final change = speakingChanges(_speaking, now);
        _speaking = now;
        for (final id in change.started) {
          feed.apply(CallVoiceEvent(channelId, sessionId: id, speaking: true));
        }
        for (final id in change.stopped) {
          feed.apply(CallVoiceEvent(channelId, sessionId: id, speaking: false));
        }
      case MemberReacted(:final identity, :final emoji):
        feed.apply(
          CallReactionEvent(
            channelId,
            sessionId: parseCallIdentity(identity).sessionId,
            emoji: emoji,
          ),
        );
      case RoomHost(:final hostId):
        feed.apply(CallHostEvent(channelId, hostId: hostId));
    }
  }

  final _mutedBy = <String, bool>{};
  final _handsBy = <String, int>{};

  void _enter(RoomMember member) {
    final who = parseCallIdentity(member.identity);
    if (_botUserId.isNotEmpty && who.userId == _botUserId) return;
    if (who.userId.isNotEmpty) {
      feed.apply(
        CallJoinedEvent(
          channelId,
          sessionId: who.sessionId,
          userId: who.userId,
        ),
      );
    }
    _mutedBy[who.sessionId] = member.muted;
    _handsBy[who.sessionId] = member.raisedAt;
    feed.setMember(
      channelId,
      who.sessionId,
      muted: member.muted,
      raisedAt: member.raisedAt,
    );
    if (who.sessionId == _sessionId) _syncOwnMute(member.muted);
  }

  void _muted(String sessionId, bool muted) {
    _mutedBy[sessionId] = muted;
    feed.setMember(
      channelId,
      sessionId,
      muted: muted,
      raisedAt: _handsBy[sessionId] ?? 0,
    );
    if (sessionId == _sessionId) _syncOwnMute(muted);
  }

  /// The room is the truth for our own microphone too: the host may have
  /// muted it.
  void _syncOwnMute(bool muted) {
    if (connection.value.listenOnly) return;
    _set((c) => c.copyWith(muted: muted));
  }

  @override
  Future<void> setMuted({required bool muted}) async {
    if (_finished || connection.value.listenOnly) return;
    _set((c) => c.copyWith(muted: muted));
    try {
      await room.setMuted(muted: muted);
    } on Object catch (e) {
      Log.warn('calls', 'Changing the mute state failed: ${e.runtimeType}');
    }
  }

  @override
  Future<void> setHandRaised({required bool raised}) async {
    if (_finished) return;
    try {
      // The room has no clock of its own for a raised hand; the value only
      // orders the hands among themselves.
      await room.setHand(raised ? clock.now().millisecondsSinceEpoch : 0);
    } on Object catch (e) {
      Log.warn('calls', 'Changing the hand failed: ${e.runtimeType}');
    }
  }

  @override
  Future<void> react(String name, String character) async {
    if (_finished) return;
    // The room does not send our own reaction back to us.
    feed.apply(
      CallReactionEvent(channelId, sessionId: _sessionId, emoji: name),
    );
    try {
      await room.react(name, character, clock.now().millisecondsSinceEpoch);
    } on Object catch (e) {
      Log.warn('calls', 'Sending the reaction failed: ${e.runtimeType}');
    }
  }

  @override
  Future<void> setRoute(AudioRoute route) async {
    if (_finished) return;
    _pinned = route;
    await _syncRoutes();
  }

  Future<void> _syncRoutes() async {
    if (_finished || connection.value.phase != CallPhase.connected) return;
    final routes = await platform.routes();
    if (_finished) return;
    _pinned = keepPin(_pinned, routes);
    final chosen = chooseRoute(
      available: routes,
      pinned: _pinned,
      direct: direct,
    );
    final previous = connection.value.route;
    _set((c) => c.copyWith(routes: routes, route: chosen));
    if (chosen != null && chosen != previous) await platform.setRoute(chosen);
  }

  @override
  Future<void> leave() async {
    if (_finished) return;
    await _finish(CallEnd.left);
  }

  Future<void> _finish(CallEnd reason) => _close(
    (c) => c.copyWith(phase: CallPhase.ended, endedBy: reason, failure: null),
  );

  void _fail(CallFailure failure) {
    unawaited(
      _close((c) => c.copyWith(phase: CallPhase.failed, failure: failure)),
    );
  }

  Future<void> _close(CallConnection Function(CallConnection) end) async {
    if (_finished) return;
    _finished = true;
    for (final s in _subscriptions) {
      unawaited(s.cancel());
    }
    _subscriptions.clear();
    feed.clearMembers(channelId);
    _set(end);
    await _quietly(room.close);
    await _quietly(platform.stopService);
  }

  Future<void> _quietly(Future<void> Function() action) async {
    try {
      await action();
    } on Object catch (_) {}
  }

  @override
  Future<void> dispose() async {
    await _close((c) => c.copyWith(phase: CallPhase.ended));
    connection.dispose();
  }
}
