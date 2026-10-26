import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/views/conversation_views.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'thread_providers.g.dart';

/// Whether the user follows the thread; null without collapsed threads,
/// where there is nothing to follow.
@riverpod
Stream<bool?> threadFollowing(Ref ref, String url, String rootId) async* {
  final db = (await ref.watch(serverSessionProvider(url).future)).db;
  yield* ConversationViews(db).threadFollowing(rootId);
}
