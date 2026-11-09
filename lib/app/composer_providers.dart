import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:matterleast/api/websocket/dialog.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/composer_actions.dart';
import 'package:matterleast/data/actions/post_actions.dart';
import 'package:matterleast/data/outbox/outbox_sender.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'composer_providers.g.dart';

/// Kept while the app runs, like the session it wraps, so a draft save
/// outlives the screen that started it. Waiting drafts are written when the
/// app is hidden.
@Riverpod(keepAlive: true)
Future<ComposerActions> composerActions(Ref ref, String url) async {
  final actions = (await ref.watch(serverSessionProvider(url).future)).composer;
  final lifecycle = AppLifecycleListener(
    onHide: () => unawaited(actions.flushDrafts()),
    onInactive: () => unawaited(actions.flushDrafts()),
  );
  ref.onDispose(lifecycle.dispose);
  return actions;
}

/// Why an unsent post failed, in the server's words; null when it said
/// nothing.
@riverpod
Future<String?> sendFailure(Ref ref, String url, String pendingPostId) async =>
    (await ref.watch(composerActionsProvider(url).future))
        .sendFailure(pendingPostId);

/// Posts the server refused for good, as they happen, to tell the user.
@riverpod
Stream<PostRejected> rejectedPosts(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* session.outbox.rejected;
}

/// The names of the people writing in a channel (empty [rootId]) or thread,
/// first to start first.
@riverpod
Stream<List<String>> typingNames(
  Ref ref,
  String url,
  String channelId,
  String rootId,
) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  final ids = await ref.watch(typingIdsProvider(url, channelId, rootId).future);
  if (ids.isEmpty) {
    yield const <String>[];
    return;
  }
  final db = session.db;
  final format = await db.nameFormat();
  // Watched, so someone not stored yet is named once they arrive.
  yield* (db.select(db.users)..where((u) => u.id.isIn(ids)))
      .watch()
      .map((rows) {
        final users = {for (final u in rows) u.id: u};
        return [
          for (final id in ids)
            if (users[id] case final u?)
              personName((
                username: u.username,
                firstName: u.firstName,
                lastName: u.lastName,
                nickname: u.nickname,
                status: u.status,
              ), format)
            else
              'Someone',
        ];
      })
      .distinct(listEquals);
}

/// The ids of the people writing in a channel or thread, first to start
/// first.
@riverpod
Stream<List<String>> typingIds(
  Ref ref,
  String url,
  String channelId,
  String rootId,
) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* session.connection.typing.watch(channelId, rootId: rootId);
}

/// Dialogs integrations open in answer to this device's commands, to show
/// as they come.
@riverpod
Stream<OpenDialog> openDialogs(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* session.connection.dialogs.dialogs;
}

/// What the message menu does to a post.
@Riverpod(keepAlive: true)
Future<PostActions> postActions(Ref ref, String url) async =>
    (await ref.watch(serverSessionProvider(url).future)).posts;
