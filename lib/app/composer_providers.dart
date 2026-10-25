import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:matterleast/api/websocket/dialog.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/composer_actions.dart';
import 'package:matterleast/data/outbox/outbox_sender.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'composer_providers.g.dart';

/// Kept while the app runs, like the session it wraps, so a draft save
/// outlives the screen that started it. Waiting drafts are written when the
/// app is hidden.
@Riverpod(keepAlive: true)
Future<ComposerActions> composerActions(Ref ref, String url) async {
  final actions = ComposerActions(
    await ref.watch(serverSessionProvider(url).future),
  );
  final lifecycle = AppLifecycleListener(
    onHide: () => unawaited(actions.flushDrafts()),
  );
  ref.onDispose(() {
    lifecycle.dispose();
    unawaited(actions.dispose().catchError((Object _) {}));
  });
  return actions;
}

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
  final db = session.db;
  yield* session.connection.typing.watch(channelId, rootId: rootId).asyncMap((
    ids,
  ) async {
    if (ids.isEmpty) return const <String>[];
    final format = await db.nameFormat();
    final users = {
      for (final u in await (db.select(
        db.users,
      )..where((u) => u.id.isIn(ids))).get())
        u.id: u,
    };
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
  });
}

/// Dialogs integrations open in answer to this device's commands, to show
/// as they come.
@riverpod
Stream<OpenDialog> openDialogs(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* session.connection.dialogs.dialogs;
}
