import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/composer_actions.dart';
import 'package:matterleast/data/outbox/outbox_sender.dart';
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
