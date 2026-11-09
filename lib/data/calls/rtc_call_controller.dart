import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matterleast/api/network_state.dart';
import 'package:matterleast/data/calls/call_line.dart';
import 'package:matterleast/data/calls/call_peer.dart';
import 'package:matterleast/data/calls/call_platform.dart';
import 'package:matterleast/data/calls/call_session.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/call_connection.dart';
import 'package:matterleast/domain/call_controller.dart';
import 'package:matterleast/domain/call_rules.dart';
import 'package:matterleast/domain/sign_in_problems.dart';

/// The user's calls: one at a time, each a [CallSession].
class RtcCallController implements CallController {
  RtcCallController({
    required this.sessionOf,
    required this.platform,
    required this.createPeer,
    this.network,
    this.timings = const CallTimings(),
  });

  final Future<ServerSession> Function(String url) sessionOf;
  final CallPlatform platform;
  final CallPeerFactory createPeer;
  final NetworkState? network;
  final CallTimings timings;

  final _current = ValueNotifier<CallRef?>(null);
  final _connection = ValueNotifier(const CallConnection());
  CallSession? _session;
  var _starting = false;

  @override
  ValueListenable<CallRef?> get current => _current;

  @override
  ValueListenable<CallConnection> get connection => _connection;

  @override
  Future<void> join(String url, String channelId) => _begin(url, channelId);

  @override
  Future<void> start(
    String url,
    String channelId, {
    String? title,
    String? rootId,
  }) => _begin(url, channelId, title: title, threadId: rootId);

  Future<void> _begin(
    String url,
    String channelId, {
    String? title,
    String? threadId,
  }) async {
    if (_connection.value.active || _starting) return;
    _starting = true;
    try {
      final server = await sessionOf(url);
      final direct = await _isDirect(server, channelId);
      await _session?.dispose();
      final session = CallSession(
        channelId: channelId,
        direct: direct,
        title: title,
        threadId: threadId,
        timings: timings,
        platform: platform,
        createPeer: createPeer,
        openLine:
            ({required connectionId, required expected, required originalId}) =>
                CallSocket.open(
                  serverUrl: server.url,
                  token: server.token,
                  connectionId: connectionId,
                  expected: expected,
                  originalId: originalId,
                ),
        loadConfig: () async =>
            server.connection.calls.config.value ?? await server.calls.config(),
        loadTurn: server.calls.turnCredentials,
        refreshState: () =>
            unawaited(server.connection.calls.refreshChannel(channelId)),
        failureText: (error) => requestProblemText(error, hostOf(url)),
        networkChanges: network?.reports.where(hasNetwork).map((_) {}),
      );
      _session = session;
      session.connection.addListener(() => _forward(session, url, channelId));
      _current.value = (url: url, channelId: channelId);
      _forward(session, url, channelId);
      unawaited(session.start());
    } finally {
      _starting = false;
    }
  }

  Future<bool> _isDirect(ServerSession server, String channelId) async {
    final db = server.db;
    final row = await (db.select(
      db.channels,
    )..where((c) => c.id.equals(channelId))).getSingleOrNull();
    return row?.type == 'D';
  }

  void _forward(CallSession session, String url, String channelId) {
    if (session != _session) return;
    final state = session.connection.value.copyWith(
      url: url,
      channelId: channelId,
    );
    _connection.value = state;
    if (!state.active) _current.value = null;
  }

  @override
  Future<void> leave() async {
    final session = _session;
    if (session == null) return;
    if (_connection.value.active) {
      await session.leave();
    } else {
      _session = null;
      _connection.value = const CallConnection();
      await session.dispose();
    }
  }

  @override
  Future<void> setMuted({required bool muted}) =>
      _session?.setMuted(muted: muted) ?? Future.value();

  @override
  Future<void> setRoute(AudioRoute route) =>
      _session?.setRoute(route) ?? Future.value();

  Future<void> dispose() async {
    await _session?.dispose();
    _current.dispose();
    _connection.dispose();
  }
}
