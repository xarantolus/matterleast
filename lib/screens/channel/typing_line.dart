import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/domain/typing.dart';
import 'package:matterleast/ui/tokens.dart';

/// Who is writing, drawn in the gap the message list keeps above the
/// composer, so it never covers a message or changes the layout.
class TypingLine extends ConsumerWidget {
  const TypingLine({
    super.key,
    required this.url,
    required this.channelId,
    this.rootId = '',
  });

  final String url;
  final String channelId;
  final String rootId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final names = ref.watch(typingNamesProvider(url, channelId, rootId)).value;
    final text = typingText(names ?? const []);
    final theme = Theme.of(context);
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: text == null ? 0 : 1,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 150),
        child: SizedBox(
          height: Spacing.xl,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                text ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
