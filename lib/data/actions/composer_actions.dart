import 'dart:async';

import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/actions/drafts.dart';
import 'package:matterleast/data/actions/suggestions.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/domain/autocomplete.dart';
import 'package:matterleast/domain/commands.dart';
import 'package:matterleast/domain/outbox.dart';

/// What the user writes: sending posts through the outbox, drafts,
/// suggestions, slash commands and changes to existing posts. Writes go
/// through the store; screens follow from the database.
class ComposerActions {
  ComposerActions(this.session, {DateTime Function()? clock})
    : _clock = clock ?? (() => DateTime.now().toUtc());

  final ServerSession session;
  final DateTime Function() _clock;

  ServerDatabase get _db => session.db;
  ServerStore get _store => session.store;

  DateTime? _lastQueuedAt;
  late final _drafts = DraftSaver(_store, clock: _clock);
  late final _suggestions = SuggestionSource(
    server: session.api,
    store: _store,
    clock: _clock,
  );

  /// Queues a post and returns its pending id. It shows in the conversation
  /// at once (dimmed while unsent) and the conversation's draft is cleared.
  /// [files] are already uploaded.
  Future<String> send(
    String channelId, {
    String rootId = '',
    required String message,
    List<api.FileInfo> files = const [],
    api.PostPriority? priority,
  }) async {
    final me = await _db.syncText(SyncKeys.currentUserId);
    if (me == null) throw StateError('Not signed in');
    _drafts.cancel(channelId, rootId);
    final at = _uniqueNow();
    final pendingPostId = pendingPostIdFor(me, at);
    await _store.queuePost(
      pendingPostId: pendingPostId,
      channelId: channelId,
      rootId: rootId,
      userId: me,
      message: message,
      createAt: at,
      files: files,
      priority: rootId.isEmpty ? priority : null,
    );
    unawaited(session.outbox.kick());
    await _rememberEmoji(message);
    return pendingPostId;
  }

  /// Emoji written as `:name:` count as recently used, as in the official
  /// app.
  Future<void> _rememberEmoji(String message) async {
    final names = [for (final m in _emojiCode.allMatches(message)) m[1]!];
    if (names.isEmpty) return;
    final custom = {
      for (final e in await (_db.select(
        _db.customEmoji,
      )..where((e) => e.name.isIn(names))).get())
        e.name,
    };
    final used = [
      for (final name in names)
        if (isKnownEmoji(name) || custom.contains(name)) name,
    ];
    if (used.isNotEmpty) await _store.addRecentEmoji(used);
  }

  /// Two posts queued in the same millisecond would share a pending id.
  DateTime _uniqueNow() {
    var at = _clock();
    final last = _lastQueuedAt;
    if (last != null && !at.isAfter(last)) {
      at = last.add(const Duration(milliseconds: 1));
    }
    return _lastQueuedAt = at;
  }

  /// Sends a failed post again, keeping its place in the conversation.
  Future<void> retry(String pendingPostId) async {
    if (await _store.requeuePost(pendingPostId)) {
      unawaited(session.outbox.kick());
    }
  }

  /// Deletes an unsent post.
  Future<void> discard(String pendingPostId) =>
      _store.discardPost(pendingPostId);

  /// The conversation's draft, read once when it opens.
  Future<Draft?> loadDraft(String channelId, {String rootId = ''}) =>
      _drafts.load(channelId, rootId);

  /// Saves the draft 500 ms after the last change; an empty one is deleted.
  void saveDraft(Draft draft) => _drafts.save(draft);

  Future<void> clearDraft(String channelId, {String rootId = ''}) =>
      _drafts.clear(channelId, rootId);

  /// Writes waiting drafts now, e.g. when the app goes to the background.
  Future<void> flushDrafts() => _drafts.flush();

  Future<void> dispose() => _drafts.dispose();

  /// Suggestions for the word at [cursor] (`@`, `~`, `:`, `/`): what is
  /// stored first, then merged with the server's answer. Empty when the
  /// cursor isn't in such a word.
  Stream<List<Suggestion>> suggestions({
    required String channelId,
    required String teamId,
    String rootId = '',
    required String text,
    required int cursor,
  }) => _suggestions.suggest(
    text: text,
    cursor: cursor,
    channelId: channelId,
    teamId: teamId,
    rootId: rootId,
  );

  /// Runs a slash command. A reply only the user sees shows as an ephemeral
  /// message; one for everyone arrives as an ordinary post. Server errors
  /// are thrown as [ApiError]s, whose message says what went wrong.
  Future<CommandOutcome> executeCommand(
    String channelId, {
    required String teamId,
    String rootId = '',
    required String text,
  }) async {
    final response = await session.api.call(
      () => session.api.client.commands.executeCommand(
        body: api.ApiV4CommandsExecuteRequestBody(
          channelId: channelId,
          command: normalizeCommand(text),
          teamId: teamId.isEmpty ? null : teamId,
          rootId: rootId.isEmpty ? null : rootId,
          parentId: rootId.isEmpty ? null : rootId,
        ),
      ),
    );
    if (response.triggerId case final trigger? when trigger.isNotEmpty) {
      session.dialogTriggerId = trigger;
    }
    final reply = response.text ?? '';
    if (response.responseType == 'ephemeral' &&
        (reply.isNotEmpty || response.attachments.isNotEmpty)) {
      final me = await _db.syncText(SyncKeys.currentUserId);
      final at = _uniqueNow();
      await _store.applyEphemeralPost(
        api.Post.fromJson({
          'id': '$localEphemeralPrefix${at.millisecondsSinceEpoch}',
          'channel_id': response.channelId?.isNotEmpty ?? false
              ? response.channelId
              : channelId,
          'root_id': rootId,
          'user_id': me ?? '',
          'create_at': at.millisecondsSinceEpoch,
          'type': ephemeralType,
          'message': reply,
          'props': {
            ...?response.props,
            if (response.attachments.isNotEmpty)
              'attachments': [for (final a in response.attachments) a.toJson()],
          },
        }),
      );
    }
    if (response.gotoLocation case final location? when location.isNotEmpty) {
      return CommandGoto(location);
    }
    return const CommandDone();
  }

  /// Hides an ephemeral message.
  Future<void> dismissEphemeral(String postId) =>
      _store.dismissEphemeral(postId);
}

/// What the screen does after a slash command ran.
sealed class CommandOutcome {
  const CommandOutcome();
}

final class CommandDone extends CommandOutcome {
  const CommandDone();
}

/// The command asks to open [location]: a link on this server (a channel,
/// a permalink) or anywhere else.
final class CommandGoto extends CommandOutcome {
  const CommandGoto(this.location);
  final String location;
}

final _emojiCode = RegExp(r':([a-z0-9_+-]+):');
