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

/// Where to report custom emoji names the map above doesn't have yet.
@riverpod
Future<CustomEmojiResolver> customEmojiResolver(Ref ref, String url) async =>
    (await ref.watch(serverSessionProvider(url).future)).emoji;
