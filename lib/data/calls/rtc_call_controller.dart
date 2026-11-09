import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matterleast/api/network_state.dart';
import 'package:matterleast/data/calls/call_line.dart';
import 'package:matterleast/data/calls/call_peer.dart';
import 'package:matterleast/data/calls/call_platform.dart';
import 'package:matterleast/data/calls/call_room.dart';
import 'package:matterleast/data/calls/call_run.dart';
import 'package:matterleast/data/calls/call_session.dart';
import 'package:matterleast/data/calls/livekit_call_session.dart';
import 'package:matterleast/data/calls/livekit_room.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/call_connection.dart';
import 'package:matterleast/domain/call_controller.dart';
import 'package:matterleast/domain/call_livekit_rules.dart';
import 'package:matterleast/domain/call_rules.dart';
import 'package:matterleast/domain/sign_in_problems.dart';

/// The user's calls: one at a time, each a [CallRun]: over LiveKit where
/// the plugin says so, else the classic [CallSession].
class RtcCallController implements CallController {
  RtcCallController({
    required this.sessionOf,
    required this.platform,
    required this.createPeer,
    this.network,
    this.lineOpener,
    this.createRoom = LiveKitCallRoom.new,
    this.timings = const CallTimings(),
  });

  final Future<ServerSession> Function(String url) sessionOf;
  final CallPlatform platform;
  final CallPeerFactory createPeer;

  /// Makes the media room of a LiveKit call.
  final CallRoom Function() createRoom;
  final NetworkState? network;

  /// Opens the calls socket of a server; the real one unless a test says.
  final CallLineOpener Function(ServerSession server)? lineOpener;
  final CallTimings timings;

  final _current = ValueNotifier<CallRef?>(null);
  final _connection = ValueNotifier(const CallConnection());
  CallRun? _session;
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
      final CallRun session;
      if (await _usesLiveKit(server)) {
        session = LiveKitCallSession(
          channelId: channelId,
          direct: direct,
          title: title,
          threadId: threadId,
          timings: timings,
          platform: platform,
          room: createRoom(),
          feed: server.connection.calls,
          requestSession: ({title, threadId}) => server.calls.liveKitSession(
            channelId,
            title: title,
            threadId: threadId,
          ),
          failureText: (error) => requestProblemText(error, hostOf(url)),
        );
      } else {
        session = _classic(server, url, channelId, direct, title, threadId);
      }
      _session = session;
      session.connection.addListener(() => _forward(session, url, channelId));
      unawaited(session.start());
      _forward(session, url, channelId);
    } finally {
      _starting = false;
    }
  }

  Future<bool> _usesLiveKit(ServerSession server) async {
    try {
      return callsUseLiveKit(await server.calls.version());
    } on Object {
      return false;
    }
  }

  CallSession _classic(
    ServerSession server,
    String url,
    String channelId,
    bool direct,
    String? title,
    String? threadId,
  ) => CallSession(
    channelId: channelId,
    direct: direct,
    title: title,
    threadId: threadId,
    timings: timings,
    platform: platform,
    createPeer: createPeer,
    openLine:
        lineOpener?.call(server) ??
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

  Future<bool> _isDirect(ServerSession server, String channelId) async {
    final db = server.db;
    final row = await (db.select(
      db.channels,
    )..where((c) => c.id.equals(channelId))).getSingleOrNull();
    return row?.type == 'D';
  }

  void _forward(CallRun session, String url, String channelId) {
    if (session != _session) return;
    final state = session.connection.value.copyWith(
      url: url,
      channelId: channelId,
    );
    _connection.value = state;
    _current.value = state.active ? (url: url, channelId: channelId) : null;
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

  @override
  Future<void> setDevice({required bool input, required String id}) =>
      _session?.setDevice(input: input, id: id) ?? Future.value();

  @override
  Future<void> setHandRaised({required bool raised}) =>
      _session?.setHandRaised(raised: raised) ?? Future.value();

  @override
  Future<void> react(String name, String character) =>
      _session?.react(name, character) ?? Future.value();

  Future<void> dispose() async {
    await _session?.dispose();
    _current.dispose();
    _connection.dispose();
  }
}
