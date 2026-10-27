import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/json/agents.dart';
import 'package:matterleast/api/server_api.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/api/websocket/server_socket.dart';
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
/// network comes back it reconnects and refreshes at once.
class ServerConnection {
  ServerConnection({
    required Uri url,
    required this.server,
    required this.store,
    required this.runner,
    required this.users,
    required String? Function() token,
    Duration pingInterval = const Duration(seconds: 30),
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
    presence = PresencePoller(server: server, store: store, runner: runner);
    socket = ServerSocket(
      serverUrl: url,
      token: token,
      pingInterval: pingInterval,
      onEvent: receive,
      online: online,
      onResync: () {
        agents.reconnected();
        refreshAll();
      },
      onClosed: (failCount) {
        // REST may work where the socket doesn't; try once per outage,
        // without the progress bar, since it may only wait for a timeout.
        if (failCount == 1) refreshAll(quiet: true);
      },
    );
    online?.addListener(_networkChanged);
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
      socket.start();
      presence.start();
    });
  }

  void background() {
    _startTimer?.cancel();
    _stopTimer?.cancel();
    _stopTimer = Timer(backgroundGrace, () => unawaited(_stop()));
  }

  /// One event from the socket, in the order it arrived.
  void receive(ServerEvent event) {
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
          if (!_caughtUp.isClosed) _caughtUp.add(null);
          return inbox.refresh(force: true, quiet: quiet);
        })
        .catchError((Object _) {}),
  );

  void _networkChanged() {
    if (_active && online!.value) refreshAll();
  }

  Future<void> _stop() async {
    _active = false;
    presence.stop();
    await socket.stop();
  }

  Future<void> close() async {
    online?.removeListener(_networkChanged);
    _startTimer?.cancel();
    _stopTimer?.cancel();
    await _stop();
    await socket.dispose();
    await drafts.close();
    typing.close();
    dialogs.close();
    agents.close();
    await _caughtUp.close();
    await _notices.close();
    await _applied.close();
  }
}
