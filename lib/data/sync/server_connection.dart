import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/json/agents.dart';
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/api/websocket/server_socket.dart';
import 'package:matterleast/api/websocket/socket_rules.dart';
import 'package:matterleast/data/live/agent_live.dart';
import 'package:matterleast/data/live/dialogs.dart';
import 'package:matterleast/data/live/typing.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/sync/draft_sync.dart';
import 'package:matterleast/data/sync/entry_sync.dart';
import 'package:matterleast/data/sync/event_applier.dart';
import 'package:matterleast/data/sync/inbox_sync.dart';
import 'package:matterleast/data/sync/presence.dart';
import 'package:matterleast/data/sync/scheduled_sync.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/data/users/user_loader.dart';
import 'package:matterleast/domain/agent_stream.dart';

/// Keeps one server's database current while the app is in the foreground:
/// the WebSocket, the entry sync it triggers and presence polling. It goes
/// quiet 15 s after the app goes to the background. When the device's
/// network comes back, or the server answers again after it didn't, it
/// reconnects and refreshes at once.
class ServerConnection {
  ServerConnection({
    required Uri url,
    required this.server,
    required this.store,
    required this.runner,
    required this.users,
    required String? Function() token,
    Duration pingInterval = const Duration(seconds: 30),
    Duration Function(int failCount) retryDelayOf = jitteredRetryDelay,
    this.catchUpLimit = const Duration(seconds: 20),
    this.online,
  }) {
    drafts = DraftSync(server: server, store: store);
    scheduled = ScheduledSync(server: server, store: store);
    entry = EntrySync(
      server: server,
      store: store,
      runner: runner,
      users: users,
      drafts: drafts,
      scheduled: scheduled,
    );
    inbox = InboxSync(
      server: server,
      store: store,
      runner: runner,
      users: users,
    );
    events = EventApplier(
      server: server,
      store: store,
      runner: runner,
      users: users,
      entry: entry,
      inbox: inbox,
      typing: typing,
      dialogs: dialogs,
      drafts: drafts,
      scheduled: scheduled,
      onNotice: (message) {
        if (!_notices.isClosed) _notices.add(message);
      },
    );
    presence = PresencePoller(
      server: server,
      store: store,
      runner: runner,
      live: live,
    );
    socket = ServerSocket(
      serverUrl: url,
      token: token,
      pingInterval: pingInterval,
      retryDelayOf: retryDelayOf,
      onEvent: receive,
      online: online,
      reachable: server.reach.reachable,
      probe: server.reach.probe,
      onResync: () {
        agents.reconnected();
        _resyncing = true;
        refreshAll();
      },
      onClosed: (failCount) {
        // REST may work where the socket doesn't; try once per outage,
        // without the progress bar, since it may only wait for a timeout.
        if (failCount == 1) refreshAll(quiet: true);
      },
    );
    online?.addListener(_networkChanged);
    server.reach.reachable.addListener(_reachChanged);
    socket.state.addListener(_updateLive);
    server.reach.reachable.addListener(_updateLive);
  }

  /// False while the device has no network.
  final ValueListenable<bool>? online;

  final ServerApi server;
  final ServerStore store;
  final SyncRunner runner;
  final UserLoader users;
  late final DraftSync drafts;
  late final ScheduledSync scheduled;
  late final EntrySync entry;
  late final InboxSync inbox;
  late final EventApplier events;
  final typing = TypingTracker();
  final dialogs = DialogInbox();
  late final agents = AgentLive(
    fetchConversation: (id) async {
      final json = await server.getJsonObject(
        '/plugins/mattermost-ai/conversations/${Uri.encodeComponent(id)}',
      );
      if (json == null) throw const FormatException('not a conversation');
      return AgentConversation.fromJson(json);
    },
  );
  late final PresencePoller presence;
  late final ServerSocket socket;

  static const backgroundGrace = Duration(seconds: 15);

  /// How long coming back may show as catching up; what is still missing
  /// after that is fetched without the bar.
  final Duration catchUpLimit;
  Timer? _catchUpTimer;

  final _live = ValueNotifier(false);

  /// Whether the server is live: its socket is connected and it answers.
  /// Presence, typing and streaming are only true while it is; when it
  /// stops being live they clear, and they come back only from fresh data.
  ValueListenable<bool> get live => _live;

  final _catchingUp = ValueNotifier(false);

  /// The app came back and the socket is connecting again, or what it may
  /// have missed meanwhile is being fetched; false while the server is
  /// known not to answer, so nothing shows as loading for a timeout.
  ValueListenable<bool> get catchingUp => _catchingUp;
  var _resyncing = false;

  void _setCatchingUp({required bool value}) {
    _catchUpTimer?.cancel();
    _catchUpTimer = value
        ? Timer(catchUpLimit, () => _catchingUp.value = false)
        : null;
    _catchingUp.value = value;
  }

  void _updateLive() {
    final socketState = socket.state.value;
    final live =
        socketState == SocketState.connected && server.reach.reachable.value;
    if (socketState == SocketState.disconnected ||
        !server.reach.reachable.value) {
      _setCatchingUp(value: false);
    }
    if (live == _live.value) return;
    _live.value = live;
    if (live) {
      presence.refresh();
    } else {
      presence.forget();
      typing.clear();
    }
  }

  Timer? _startTimer;
  Timer? _stopTimer;
  var _active = false;

  ValueListenable<SocketState> get state => socket.state;

  /// Connects after [delay] (other servers are staggered behind the one the
  /// user looks at).
  void foreground({Duration delay = Duration.zero}) {
    _stopTimer?.cancel();
    if (_active) return;
    _startTimer?.cancel();
    _startTimer = Timer(delay, () {
      _active = true;
      _setCatchingUp(
        value:
            socket.state.value != SocketState.connected &&
            (online?.value ?? true) &&
            server.reach.reachable.value,
      );
      socket.start();
      presence.start();
    });
  }

  void background() {
    _setCatchingUp(value: false);
    _startTimer?.cancel();
    _stopTimer?.cancel();
    _stopTimer = Timer(backgroundGrace, () => unawaited(_stop()));
  }

  /// One event from the socket, in the order it arrived.
  void receive(ServerEvent event) {
    // The first event after connecting: replayed events follow at once,
    // and anything lost is fetched by the refresh it started.
    if (!_resyncing) _setCatchingUp(value: false);
    switch (event) {
      // Streamed answers live in memory only; they skip the queue so text
      // keeps flowing while the database is busy.
      case AgentPostEvent(:final update):
        agents.apply(update);
        return;
      case AgentConversationEvent(:final conversationId):
        agents.conversationUpdated(conversationId);
        return;
      default:
    }
    unawaited(
      events.add(event).then((_) {
        // After the edit is stored, so the post's own text is there to show.
        if (event
            case PostEditedEvent(
              post: api.Post(:final id?, :final type?, :final message),
            )
            when agentPostTypes.contains(type)) {
          agents.postEdited(id, message ?? '');
        }
        if (event case StatusChangedEvent(:final userId?)) {
          presence.confirm([userId]);
        }
        if (!_applied.isClosed) _applied.add(event);
      }),
    );
  }

  final _caughtUp = StreamController<void>.broadcast();
  final _notices = StreamController<String>.broadcast();

  /// Messages from the server or a plugin to show the user, such as a
  /// refused download.
  Stream<String> get notices => _notices.stream;
  final _applied = StreamController<ServerEvent>.broadcast();

  /// Events once they are in the database.
  Stream<ServerEvent> get applied => _applied.stream;

  /// Fires once the entry data is current again after events may have been
  /// missed; open conversations then fetch what they lack.
  Stream<void> get caughtUp => _caughtUp.stream;

  /// Events may have been missed: the entry data first, then Home's lists,
  /// which only a fresh fetch brings up to date, and open conversations.
  /// [quiet]: failures report, but nothing shows as refreshing.
  void refreshAll({bool quiet = false}) => unawaited(
    entry
        .run(quiet: quiet)
        .then((_) {
          _caughtUpNow();
          // Direct messages it stored may name people not polled yet.
          presence.refresh();
          if (!_caughtUp.isClosed) _caughtUp.add(null);
          return inbox.refresh(force: true, quiet: quiet);
        })
        .catchError((Object _) => _caughtUpNow()),
  );

  /// Open conversations take over showing their own catch-up from here.
  void _caughtUpNow() {
    if (!_resyncing) return;
    _resyncing = false;
    _setCatchingUp(value: false);
  }

  void _networkChanged() {
    if (_active && online!.value) refreshAll();
  }

  void _reachChanged() {
    if (_active && server.reach.reachable.value) refreshAll();
  }

  Future<void> _stop() async {
    _active = false;
    presence.stop();
    await socket.stop();
  }

  Future<void> close() async {
    online?.removeListener(_networkChanged);
    server.reach.reachable.removeListener(_reachChanged);
    socket.state.removeListener(_updateLive);
    server.reach.reachable.removeListener(_updateLive);
    _startTimer?.cancel();
    _stopTimer?.cancel();
    _catchUpTimer?.cancel();
    await _stop();
    await socket.dispose();
    await drafts.close();
    typing.close();
    dialogs.close();
    agents.close();
    presence.dispose();
    _live.dispose();
    _catchingUp.dispose();
    await _caughtUp.close();
    await _notices.close();
    await _applied.close();
  }
}
