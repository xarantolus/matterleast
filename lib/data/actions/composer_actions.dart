import 'dart:async';

import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/api/websocket/dialog.dart';
import 'package:matterleast/data/actions/drafts.dart';
import 'package:matterleast/data/actions/suggestions.dart';
import 'package:matterleast/data/dialog_clock.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/domain/autocomplete.dart';
import 'package:matterleast/domain/burn_on_read.dart';
import 'package:matterleast/domain/commands.dart';
import 'package:matterleast/domain/dialog_rules.dart';
import 'package:matterleast/domain/outbox.dart';
import 'package:matterleast/domain/typing.dart';

/// What the user writes: sending posts through the outbox, drafts,
/// suggestions, slash commands and changes to existing posts. Writes go
/// through the store; screens follow from the database.
class ComposerActions {
  ComposerActions(
    this.session, {
    DateTime Function()? clock,
    this.draftDelay = const Duration(milliseconds: 500),
  }) : _clock = clock ?? (() => DateTime.now().toUtc());

  final ServerSession session;
  final DateTime Function() _clock;
  final Duration draftDelay;

  ServerDatabase get _db => session.db;
  ServerStore get _store => session.store;

  DateTime? _lastQueuedAt;
  late final _drafts = DraftSaver(
    _store,
    delay: draftDelay,
    clock: _clock,
    onWritten: session.connection.drafts.changedSoon,
    onCleared: _synced,
  );

  void _synced(String channelId, String rootId) =>
      unawaited(session.connection.drafts.changed(channelId, rootId));
  late final _suggestions = SuggestionSource(
    server: session.api,
    store: _store,
    clock: _clock,
  );

  /// Joins the public channel when the user is not in it yet.
  Future<void> joinIfNeeded(String channelId) async {
    final mine = await (_db.select(
      _db.myChannels,
    )..where((m) => m.channelId.equals(channelId))).getSingleOrNull();
    if (mine == null) await session.channels.join(channelId);
  }

  /// Queues a post and returns its pending id. It shows in the conversation
  /// at once (dimmed while unsent) and the conversation's draft is cleared.
  /// [files] are already uploaded.
  Future<String> send(
    String channelId, {
    String rootId = '',
    required String message,
    List<api.FileInfo> files = const [],
    api.PostPriority? priority,
    bool burnOnRead = false,
  }) async {
    final me = await _db.syncText(SyncKeys.currentUserId);
    if (me == null) throw StateError('Not signed in');
    _drafts.cancel(channelId, rootId);
    final pendingPostId = pendingPostIdFor(me, _uniqueNow());
    await _store.queuePost(
      pendingPostId: pendingPostId,
      channelId: channelId,
      rootId: rootId,
      userId: me,
      message: message,
      createAt: await _nextAt(channelId),
      files: files,
      priority: rootId.isEmpty ? priority : null,
      type: burnOnRead ? burnOnReadType : '',
    );
    _synced(channelId, rootId);
    unawaited(session.outbox.kick());
    await _rememberEmoji(message);
    return pendingPostId;
  }

  /// Schedules the message for [at] instead of sending it, and clears the
  /// draft once the server took it.
  Future<void> schedule(
    String channelId, {
    String rootId = '',
    required String message,
    required DateTime at,
    List<api.FileInfo> files = const [],
    api.PostPriority? priority,
  }) async {
    await session.connection.scheduled.schedule(
      channelId: channelId,
      rootId: rootId,
      message: message,
      at: at,
      files: files,
      priority: rootId.isEmpty ? priority : null,
    );
    await clearDraft(channelId, rootId: rootId);
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

  /// Where a message made here goes until the server answers: right after
  /// the newest one in [channelId], by the server's times, so it doesn't
  /// move when it is confirmed. The device clock only for an empty channel.
  Future<DateTime> _nextAt(String channelId) async {
    final newest = await _db.newestPostAt(channelId: channelId, unsent: true);
    return newest?.add(const Duration(milliseconds: 1)) ?? _clock();
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

  /// What the server said when it refused to take the unsent post, if it
  /// said anything.
  Future<String?> sendFailure(String pendingPostId) async {
    final row = await (_db.select(
      _db.outbox,
    )..where((o) => o.pendingPostId.equals(pendingPostId))).getSingleOrNull();
    final reason = row?.lastError?.trim();
    return reason == null || reason.isEmpty ? null : reason;
  }

  /// Deletes an unsent post.
  Future<void> discard(String pendingPostId) =>
      _store.discardPost(pendingPostId);

  /// The conversation's draft, read once when it opens.
  Future<Draft?> loadDraft(String channelId, {String rootId = ''}) =>
      _drafts.load(channelId, rootId);

  /// The stored draft each time it changes.
  Stream<Draft?> draftChanges(String channelId, {String rootId = ''}) =>
      _drafts.changes(channelId, rootId);

  /// Saves the draft 500 ms after the last change; an empty one is deleted.
  void saveDraft(Draft draft) => _drafts.save(draft);

  Future<void> clearDraft(String channelId, {String rootId = ''}) =>
      _drafts.clear(channelId, rootId);

  /// Deletes a draft from the drafts list; [restoreDraft] with the answer
  /// undoes it.
  Future<DraftRow?> removeDraft(String channelId, {String rootId = ''}) async {
    await _drafts.flush();
    final row = await _store.draft(channelId, rootId);
    await _drafts.clear(channelId, rootId);
    return row;
  }

  Future<void> restoreDraft(DraftRow row) async {
    await _store.saveDraft(row.toCompanion(false));
    _synced(row.channelId, row.rootId);
  }

  /// Writes waiting drafts now and sends them to the server, e.g. when the
  /// app goes to the background.
  Future<void> flushDrafts() async {
    await _drafts.flush();
    session.connection.drafts.flushAll();
  }

  /// The user left a conversation: its draft goes to the server now.
  Future<void> leaveDraft(String channelId, {String rootId = ''}) async {
    await _drafts.flush();
    session.connection.drafts.flush(channelId, rootId);
  }

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
      session.connection.dialogs.expect(trigger);
    }
    final reply = response.text ?? '';
    if (response.responseType == 'ephemeral' &&
        (reply.isNotEmpty || response.attachments.isNotEmpty)) {
      final me = await _db.syncText(SyncKeys.currentUserId);
      final at = await _nextAt(channelId);
      await _store.applyEphemeralPost(
        api.Post.fromJson({
          'id': '$localEphemeralPrefix${_uniqueNow().millisecondsSinceEpoch}',
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

  final _typingSent = <(String, String), DateTime>{};

  /// The user changed the text: the channel (or thread) hears they are
  /// writing, at most once per the server's interval. Sent over the socket,
  /// as the official app does.
  Future<void> userTyping(String channelId, {String rootId = ''}) async {
    final features = await _db.features();
    final channel = await (_db.select(
      _db.channels,
    )..where((c) => c.id.equals(channelId))).getSingleOrNull();
    final key = (channelId, rootId);
    final now = _clock();
    final send = shouldSendTyping(
      now: now,
      lastSent: _typingSent[key],
      interval: features.typingInterval,
      enabled: features.typing,
      memberCount: channel?.memberCount,
      maxNotificationsPerChannel: features.maxNotificationsPerChannel,
    );
    if (send && session.connection.socket.sendTyping(channelId, rootId)) {
      _typingSent[key] = now;
    }
  }

  /// Sends a dialog's answers, or tells the integration it was cancelled
  /// when it asked to know. Fields are checked here first; the
  /// integration's own complaints come back the same way.
  Future<DialogOutcome> submitDialog(
    OpenDialog dialog, {
    required String channelId,
    String teamId = '',
    Map<String, Object?> values = const {},
    bool cancelled = false,
  }) async {
    if (cancelled && !(dialog.dialog.notifyOnCancel ?? false)) {
      return const DialogSubmitted();
    }
    if (!cancelled) {
      final errors = dialogErrors(
        dialog.dialog,
        values,
        clockFor: clockForElement,
      );
      if (errors.isNotEmpty) return DialogRejected(fieldErrors: errors);
    }
    final answer = await session.api.call(
      () => session.api.client.integrationActions.submitInteractiveDialog(
        body: api.ApiV4ActionsDialogsSubmitRequestBody(
          url: dialog.url ?? '',
          channelId: channelId,
          teamId: teamId.isEmpty ? null : teamId,
          callbackId: dialog.dialog.callbackId,
          state: dialog.dialog.state,
          cancelled: cancelled,
          submission: cancelled
              ? const {}
              : dialogSubmission(dialog.dialog, values),
        ),
      ),
    );
    final fieldErrors = answer.errors ?? const <String, String>{};
    final error = answer.error ?? '';
    if (fieldErrors.isEmpty && error.isEmpty) return const DialogSubmitted();
    return DialogRejected(
      error: error.isEmpty ? null : error,
      fieldErrors: fieldErrors,
    );
  }

  /// Presses a dialog's action button; the integration answers by opening
  /// another dialog, which shows because its trigger is expected here.
  Future<void> pressDialogButton(
    DialogActionButton button, {
    required String channelId,
    String teamId = '',
  }) async {
    final answer = await session.api.call(
      () => session.api.client.integrationActions.executeDialogAction(
        body: api.ApiV4ActionsDialogsExecuteRequestBody(
          url: button.url,
          channelId: channelId,
          teamId: teamId.isEmpty ? null : teamId,
          context: button.context.isEmpty ? null : button.context,
        ),
      ),
    );
    final trigger = answer.triggerId;
    if (trigger != null && trigger.isNotEmpty) {
      session.connection.dialogs.expect(trigger);
    }
  }

  /// Asks the integration for [dialog] again from its `source_url`, with
  /// what was entered so far. Null when it sent no form.
  Future<DialogForm?> refreshDialog(
    OpenDialog dialog, {
    required String channelId,
    String teamId = '',
    Map<String, Object?> values = const {},
  }) async {
    final form = dialog.dialog;
    final response = await session.api.call(
      () => session.api.dio.post<Object?>(
        '/api/v4/actions/dialogs/submit',
        data: DialogRefreshBody(
          url: form.sourceUrl ?? '',
          channelId: channelId,
          teamId: teamId.isEmpty ? null : teamId,
          callbackId: form.callbackId,
          state: form.state,
          submission: dialogSubmission(form, values),
        ).toJson(),
      ),
    );
    final json = response.data;
    return json is Map<String, Object?>
        ? DialogRefreshAnswer.fromJson(json).form
        : null;
  }
}

sealed class DialogOutcome {
  const DialogOutcome();
}

final class DialogSubmitted extends DialogOutcome {
  const DialogSubmitted();
}

/// The dialog stays open showing [error] and the [fieldErrors] by element
/// name.
final class DialogRejected extends DialogOutcome {
  const DialogRejected({this.error, this.fieldErrors = const {}});
  final String? error;
  final Map<String, String> fieldErrors;
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
