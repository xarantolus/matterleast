import 'dart:async';

import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/emoji/custom_emoji.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'emoji_providers.g.dart';

/// A server's known custom emoji, name → id.
@riverpod
Stream<Map<String, String>> customEmoji(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* watchCustomEmoji(session.store);
}

/// Who added the custom emoji [name] on [url], fetched when no stored
/// message brought that person in.
@riverpod
Stream<String?> customEmojiCreator(Ref ref, String url, String name) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* watchEmojiCreator(session.store, name).map((id) {
    if (id != null && id.isNotEmpty) {
      unawaited(session.users.ensure([id]).catchError((Object _) {}));
    }
    return id;
  });
}

/// Names the server has no custom emoji for, as far as asked.
@riverpod
Stream<Set<String>> customEmojiMissing(Ref ref, String url) async* {
  final resolver = await ref.watch(customEmojiResolverProvider(url).future);
  yield resolver.missing;
  yield* resolver.missingChanges;
}

/// Where to report custom emoji names the map above doesn't have yet.
@riverpod
Future<CustomEmojiResolver> customEmojiResolver(Ref ref, String url) async =>
    (await ref.watch(serverSessionProvider(url).future)).emoji;

/// Every custom emoji of the server, stored for the picker.
@riverpod
Future<void> customEmojiCatalog(Ref ref, String url) async {
  final resolver = await ref.watch(customEmojiResolverProvider(url).future);
  await resolver.loadAll();
}
