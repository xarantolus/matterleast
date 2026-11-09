import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matterleast/api/json/calls.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/actions/calls_actions.dart';
import 'package:matterleast/domain/calls.dart';
import 'package:matterleast/log.dart';

/// The calls running on one server and its Calls settings, kept in memory
/// from the plugin's events and its answers. Every answer replaces what it
/// describes; a failed one keeps what was there.
class CallLive {
  CallLive({
    required this.actions,
    required Stream<bool> available,
    required this.ensureUsers,
  }) {
    _availability = available.listen(_availabilityChanged);
  }

  final CallsActions actions;

  /// Fetches the people in calls so their names and pictures show.
  final Future<void> Function(Iterable<String> ids) ensureUsers;

  final state = ValueNotifier(const CallsState());

  /// The server's Calls settings; null until they arrived.
  final config = ValueNotifier<CallsConfig?>(null);

  late final StreamSubscription<bool> _availability;
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
    } else {
      state.value = const CallsState();
      config.value = null;
    }
  }

  void apply(CallsEvent event) {
    if (_closed || !_available) return;
    if (event is! CallVoiceEvent) _changes++;
    final before = state.value;
    final after = applyCallEvent(before, event);
    if (!identical(before, after)) state.value = after;
    if (event is CallJoinedEvent &&
        !before.calls.containsKey(event.channelId)) {
      unawaited(refreshChannel(event.channelId));
    }
    if (event is CallJoinedEvent) unawaited(_people([event.userId]));
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
        state.value = callsStateOf(channels);
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
        state.value = state.value.copyWith(calls: calls, enabled: enabled);
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
    unawaited(_availability.cancel());
    state.dispose();
    config.dispose();
  }
}
