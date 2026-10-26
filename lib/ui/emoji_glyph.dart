import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/emoji_providers.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/ui/custom_emoji_image.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';

/// One emoji by its short name in a fixed square of [size]: the system
/// glyph for a standard emoji, otherwise the server's custom emoji, looked
/// up when it isn't stored yet. The square stays empty while the lookup
/// runs; a name the server doesn't know shows as `:name:`.
///
/// The server is [serverUrl], or the one of the surrounding message list.
class EmojiGlyph extends ConsumerWidget {
  const EmojiGlyph({
    required this.name,
    required this.size,
    this.serverUrl,
    super.key,
  });

  final String name;
  final double size;
  final String? serverUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unicode = unicodeForName(name);
    if (unicode != null) {
      return SizedBox.square(
        dimension: size,
        child: FittedBox(
          child: Text(
            unicode,
            textScaler: TextScaler.noScaling,
            style: TextStyle(fontSize: size, height: 1),
          ),
        ),
      );
    }
    final url =
        serverUrl ?? PostEnvironment.maybeOf(context)?.server.toString();
    final literal = Text(':$name:', maxLines: 1);
    if (url == null) return literal;
    final known = ref.watch(
      customEmojiProvider(url)
          .select((a) => (loaded: a.hasValue, id: a.value?[name])),
    );
    if (known.id case final id?) {
      return SizedBox.square(
        dimension: size,
        child: CustomEmojiImage(
          serverUrl: url,
          emojiId: id,
          size: size,
          fallback: const SizedBox.shrink(),
        ),
      );
    }
    final missing = ref.watch(
      customEmojiMissingProvider(url)
          .select((a) => a.value?.contains(name) ?? false),
    );
    if (missing) return literal;
    if (known.loaded) {
      ref.watch(customEmojiResolverProvider(url)).value?.want([name]);
    }
    return SizedBox.square(dimension: size);
  }
}
