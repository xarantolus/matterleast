import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matterleast/api/json/calls.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/actions/calls_actions.dart';
import 'package:matterleast/domain/call_ui_rules.dart';
import 'package:matterleast/domain/calls.dart';
import 'package:matterleast/log.dart';

/// The calls running on one server and its Calls settings, kept in memory
/// from the plugin's events and its answers. Every answer replaces what it
/// describes; a failed one keeps what was there.
/// Where the media room of the user's own call reports mute and raised
/// hands.
abstract interface class CallRoomFeed {
  void apply(CallsEvent event);

  /// What the room says about [sessionId]; it wins over the plugin's own
  /// state until [clearMembers].
  void setMember(
    String channelId,
    String sessionId, {
    required bool muted,
    required int raisedAt,
  });
  void clearMembers(String channelId);

  /// Fetches the state of one channel again.
  Future<void> refreshChannel(String id);
}

class CallLive implements CallRoomFeed {
  CallLive({
    required this.actions,
    required Stream<bool> available,
    required this.ensureUsers,
    required this.channelTypeOf,
    required this.selfId,
    this.reactionFor = const Duration(seconds: 5),
    this.refreshEvery = const Duration(minutes: 20),
  }) {
    _availability = available.listen(_availabilityChanged);
  }

  final CallsActions actions;

  /// Fetches the people in calls so their names and pictures show.
  final Future<void> Function(Iterable<String> ids) ensureUsers;

  /// The type of a channel (`D`, `G`, …) from the database; null if unknown.
  final Future<String?> Function(String channelId) channelTypeOf;

  /// The signed-in user's id; null before it is known.
  final Future<String?> Function() selfId;

  /// How long a reaction shows.
  final Duration reactionFor;

  /// How often the settings and calls are fetched again while the plugin is
  /// there, as the official app refreshes its copy of the settings.
  final Duration refreshEvery;

  final state = ValueNotifier(const CallsState());

  /// The emoji each session reacted with, until it expires.
  final reactions = ValueNotifier(const <String, String>{});

  /// Calls that ring the user, by channel, that the user didn't join or
  /// dismiss; they exist from the live start of the call until it ends.
  final incoming = ValueNotifier(const <String, ActiveCall>{});
  final _reactionTimers = <String, Timer>{};

  /// The server's Calls settings; null until they arrived.
  final config = ValueNotifier<CallsConfig?>(null);

  late final StreamSubscription<bool> _availability;
  Timer? _refreshTimer;
  var _available = false;
  var _closed = false;
  var _changes = 0;
  Future<void>? _refreshing;
  final _channelsRefreshing = <String, Future<void>>{};

  void _availabilityChanged(bool available) {
    if (_closed || available == _available) return;
    _available = available;
    if (available) {
      unawaited(refresh());
      _refreshTimer = Timer.periodic(refreshEvery, (_) => unawaited(refresh()));
    } else {
      _refreshTimer?.cancel();
      state.value = const CallsState();
      config.value = null;
      incoming.value = const {};
    }
  }

  /// What the media room says about each session; the plugin does not
  /// track mute or hands for a LiveKit call.
  final _members = <String, Map<String, ({bool muted, int raisedAt})>>{};

  @override
  void setMember(
    String channelId,
    String sessionId, {
    required bool muted,
    required int raisedAt,
  }) {
    if (_closed) return;
    (_members[channelId] ??= {})[sessionId] = (
      muted: muted,
      raisedAt: raisedAt,
    );
    _publish(state.value);
  }

  @override
  void clearMembers(String channelId) => _members.remove(channelId);

  void _publish(CallsState next) {
    final merged = _withMembers(next);
    if (merged != state.value) state.value = merged;
  }

  CallsState _withMembers(CallsState next) {
    if (_members.isEmpty) return next;
    final calls = {...next.calls};
    for (final entry in _members.entries) {
      final call = calls[entry.key];
      if (call == null) continue;
      final sessions = {...call.sessions};
      for (final member in entry.value.entries) {
        final session = sessions[member.key];
        if (session == null) continue;
        sessions[member.key] = session.copyWith(
          muted: member.value.muted,
          raisedHand: member.value.raisedAt,
        );
      }
      calls[entry.key] = call.copyWith(sessions: sessions);
    }
    return next.copyWith(calls: calls);
  }

  @override
  void apply(CallsEvent event) {
    if (_closed || !_available) return;
    if (event is! CallVoiceEvent) _changes++;
    final before = state.value;
    final after = applyCallEvent(before, event);
    if (!identical(before, after)) _publish(after);
    if (event is CallJoinedEvent &&
        !before.calls.containsKey(event.channelId)) {
      unawaited(refreshChannel(event.channelId));
    }
    if (event is CallJoinedEvent) unawaited(_people([event.userId]));
    switch (event) {
      case CallReactionEvent():
        _react(event.sessionId, event.emoji);
      case CallStartedEvent():
        unawaited(_ring(event));
      case CallEndedEvent() || CallNoticeDismissedEvent():
        dismiss(event.channelId);
      case CallJoinedEvent():
        unawaited(_joined(event));
      default:
    }
  }

  void _react(String sessionId, String emoji) {
    reactions.value = {...reactions.value, sessionId: emoji};
    _reactionTimers[sessionId]?.cancel();
    _reactionTimers[sessionId] = Timer(reactionFor, () {
      _reactionTimers.remove(sessionId);
      reactions.value = {
        for (final e in reactions.value.entries)
          if (e.key != sessionId) e.key: e.value,
      };
    });
  }

  Future<void> _ring(CallStartedEvent event) async {
    try {
      final rings = callRings(
        config: config.value,
        channelType: await channelTypeOf(event.channelId),
        ownerId: event.ownerId,
        selfId: await selfId(),
      );
      if (_closed || !rings) return;
      final call = state.value.calls[event.channelId];
      if (call == null || call.id != event.id) return;
      incoming.value = {...incoming.value, event.channelId: call};
    } on Object catch (e) {
      Log.warn('calls', 'ring check failed: ${e.runtimeType}');
    }
  }

  Future<void> _joined(CallJoinedEvent event) async {
    if (event.userId == await selfId()) dismiss(event.channelId);
  }

  /// Stops offering the call in [channelId] as incoming.
  void dismiss(String channelId) {
    if (!incoming.value.containsKey(channelId)) return;
    incoming.value = {
      for (final e in incoming.value.entries)
        if (e.key != channelId) e.key: e.value,
    };
  }

  /// The socket is back after events may have been missed.
  void reconnected() {
    if (_available) unawaited(refresh());
  }

  /// Fetches the settings and every channel's state again, one request at
  /// a time; asked while one runs, it waits for that one's answer.
  Future<void> refresh() => _refreshing ??= _refresh().whenComplete(() {
    _refreshing = null;
  });

  Future<void> _refresh() async {
    try {
      config.value = await actions.config() ?? config.value;
    } on Object catch (e) {
      Log.warn('calls', 'settings failed: ${e.runtimeType}');
    }
    try {
      // Events that came in while the answer was on its way may be newer
      // than it; ask again, a few times at most.
      for (var round = 0; round < 3; round++) {
        final seen = _changes;
        final channels = await actions.channels();
        if (_closed || channels == null) return;
        if (seen != _changes && round < 2) continue;
        _publish(callsStateOf(channels));
        unawaited(
          _people({
            for (final call in state.value.calls.values)
              ...call.participantUserIds,
          }),
        );
        return;
      }
    } on Object catch (e) {
      Log.warn('calls', 'refresh failed: ${e.runtimeType}');
    }
  }

  /// Fetches the state of one channel again, such as one that gained a
  /// person we know no call for.
  @override
  Future<void> refreshChannel(String id) =>
      _channelsRefreshing[id] ??= _refreshChannel(id).whenComplete(() {
        _channelsRefreshing.remove(id);
      });

  Future<void> _refreshChannel(String id) async {
    try {
      for (var round = 0; round < 3; round++) {
        final seen = _changes;
        final channel = await actions.channel(id);
        if (_closed || channel == null) return;
        if (seen != _changes && round < 2) continue;
        final calls = {...state.value.calls};
        final enabled = {...state.value.enabled};
        if (channel.call case final call?) {
          calls[id] = callOf(call);
        } else {
          calls.remove(id);
        }
        if (channel.enabled case final value?) enabled[id] = value;
        _publish(state.value.copyWith(calls: calls, enabled: enabled));
        unawaited(_people(calls[id]?.participantUserIds ?? const []));
        return;
      }
    } on Object catch (e) {
      Log.warn('calls', 'channel refresh failed: ${e.runtimeType}');
    }
  }

  Future<void> _people(Iterable<String> ids) async {
    try {
      await ensureUsers(ids);
    } on Object catch (e) {
      Log.warn('calls', 'people lookup failed: ${e.runtimeType}');
    }
  }

  void close() {
    _closed = true;
    _refreshTimer?.cancel();
    unawaited(_availability.cancel());
    for (final t in _reactionTimers.values) {
      t.cancel();
    }
    state.dispose();
    config.dispose();
    reactions.dispose();
    incoming.dispose();
  }
}
