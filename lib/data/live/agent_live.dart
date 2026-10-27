import 'dart:async';

import 'package:matterleast/api/json/agents.dart';
import 'package:matterleast/domain/agent_stream.dart';

/// A conversation of the Agents plugin as far as it is loaded.
class AgentConversationState {
  const AgentConversationState({this.conversation, this.loading = false});

  final AgentConversation? conversation;
  final bool loading;

  bool get failed => conversation == null && !loading;
}

/// Agent answers as they stream in, and the conversations they belong to.
/// Kept in memory for one server; the plugin stores the finished answer.
class AgentLive {
  AgentLive({required this.fetchConversation});

  final Future<AgentConversation> Function(String id) fetchConversation;

  final _streams = <String, AgentStream>{};
  final _conversations = <String, AgentConversationState>{};
  final _inFlight = <String, Future<void>>{};
  final _queued = <String, Future<void>>{};
  final _conversationOfPost = <String, String>{};
  final _changed = StreamController<String>.broadcast();
  var _closed = false;

  AgentStream? stream(String postId) => _streams[postId];

  /// Applies a plugin event. When an answer ends, its conversation is
  /// fetched again and the streamed copy goes once that has arrived, so
  /// nothing blinks or shows twice.
  void apply(AgentPostUpdate update) {
    final postId = update.postId;
    if (postId.isEmpty || _closed) return;
    final before = _streams[postId];
    final after = reduceAgentStream(before, update);
    if (!identical(before, after)) _setStream(postId, after);
    final conversationId = _conversationOfPost[postId];
    if (conversationId == null) return;
    if (update.control == 'end') {
      unawaited(_settle(postId, conversationId));
    } else if (after.resumed != (before?.resumed ?? 0)) {
      unawaited(refresh(conversationId));
    }
  }

  /// The server stored [message] in agent post [postId].
  void postEdited(String postId, String message) {
    if (_closed) return;
    _replace(postId, agentStreamAfterEdit(_streams[postId], message: message));
  }

  /// The socket is back after events may have been missed. A stream with
  /// streamed content keeps it until its conversation shows a newer answer,
  /// so one still running doesn't lose what it showed.
  void reconnected() {
    if (_closed) return;
    for (final postId in [..._streams.keys]) {
      final before = _streams[postId];
      _replace(postId, agentStreamAfterReconnect(before));
      final conversationId = _conversationOfPost[postId];
      if (_streams[postId] != null &&
          conversationId != null &&
          _conversations.containsKey(conversationId)) {
        unawaited(_settleAfterReconnect(postId, conversationId));
      }
    }
  }

  Future<void> _settleAfterReconnect(String postId, String id) async {
    final before = _conversations[id]?.conversation;
    final baseline = before == null ? -1 : anchorSequence(before, postId);
    await refresh(id);
    final after = _conversations[id]?.conversation;
    if (after != null &&
        anchorSequence(after, postId) > baseline &&
        !(_streams[postId]?.busy ?? false)) {
      clear(postId);
    }
  }

  void _replace(String postId, AgentStream? after) {
    if (identical(_streams[postId], after)) return;
    if (after == null) {
      clear(postId);
    } else {
      _setStream(postId, after);
    }
  }

  /// The user tapped Stop: late text is ignored from now.
  void stop(String postId) =>
      _setStream(postId, stopAgentStream(_streams[postId]));

  /// Forgets what streamed into [postId], before it is generated again.
  void clear(String postId) {
    if (_streams.remove(postId) != null) _emit(postId);
  }

  Future<void> _settle(
    String postId,
    String conversationId, {
    bool fetch = false,
  }) async {
    if (!fetch && !_conversations.containsKey(conversationId)) {
      // Nobody looked at it yet; the first look fetches it fresh.
      if (!(_streams[postId]?.busy ?? false)) clear(postId);
      return;
    }
    await refresh(conversationId);
    if (_conversations[conversationId]?.conversation != null &&
        !(_streams[postId]?.busy ?? false)) {
      clear(postId);
    }
  }

  /// Fetches [id] again; one request at a time per conversation. Asked
  /// while one runs, another follows it, since the server may have changed
  /// in between. A failed fetch keeps what was there.
  Future<void> refresh(String id) {
    final running = _inFlight[id];
    if (running != null) {
      return _queued[id] ??= running.then((_) {
        _queued.remove(id);
        return refresh(id);
      });
    }
    return _inFlight[id] = _fetch(id).whenComplete(() {
      _inFlight.remove(id);
    });
  }

  Future<void> _fetch(String id) async {
    final previous = _conversations[id]?.conversation;
    _setConversation(
      id,
      AgentConversationState(conversation: previous, loading: true),
    );
    try {
      final conversation = await fetchConversation(id);
      _setConversation(id, AgentConversationState(conversation: conversation));
    } on Object {
      _setConversation(id, AgentConversationState(conversation: previous));
    }
  }

  /// A conversation changed on the server; refreshed if it is loaded.
  void conversationUpdated(String id) {
    if (_conversations.containsKey(id)) unawaited(refresh(id));
  }

  /// The stream of [postId]: now, then each change.
  Stream<AgentStream?> watchStream(String postId) =>
      _watch(postId, () => _streams[postId]);

  /// Conversation [id] of post [postId], loaded on first watch.
  Stream<AgentConversationState> watchConversation(
    String id, {
    required String postId,
  }) {
    final known = _conversationOfPost[postId] == id;
    _conversationOfPost[postId] = id;
    final stream = _streams[postId];
    if (!known && stream != null && !stream.busy) {
      // The answer ended before its post was shown with a conversation.
      unawaited(_settle(postId, id, fetch: true));
    } else if (!_conversations.containsKey(id)) {
      unawaited(refresh(id));
    }
    return _watch(
      'c:$id',
      () => _conversations[id] ?? const AgentConversationState(loading: true),
    );
  }

  Stream<T> _watch<T>(String key, T Function() now) {
    StreamSubscription<String>? changes;
    late final StreamController<T> out;
    out = StreamController(
      onListen: () {
        changes = _changed.stream
            .where((k) => k == key)
            .listen((_) => out.add(now()));
        out.add(now());
      },
      onCancel: () async {
        await changes?.cancel();
        await out.close();
      },
    );
    return out.stream;
  }

  void _setStream(String postId, AgentStream stream) {
    _streams[postId] = stream;
    _emit(postId);
  }

  void _setConversation(String id, AgentConversationState state) {
    _conversations[id] = state;
    _emit('c:$id');
  }

  void _emit(String key) {
    if (!_closed) _changed.add(key);
  }

  void close() {
    _closed = true;
    _streams.clear();
    _conversations.clear();
    unawaited(_changed.close());
  }
}
