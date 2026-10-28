import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/domain/typing.dart';
import 'package:matterleast/ui/motion.dart';
import 'package:matterleast/ui/tokens.dart';

/// The height of one line of [TypingLine], from its text and the text size.
double typingLineHeight(BuildContext context) {
  final style = Theme.of(context).textTheme.labelSmall;
  final line = (style?.fontSize ?? 11) * (style?.height ?? 1.4);
  return MediaQuery.textScalerOf(context).scale(line) + 2 * Spacing.xs;
}

/// The room the message list keeps under its newest message: the typing
/// line, and a margin that is wider on a phone, which asked for more air.
double conversationBottomGap(BuildContext context) =>
    typingLineHeight(context) + (isDesktop ? Spacing.xs : Spacing.xl);

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
        duration: motion(context, const Duration(milliseconds: 150)),
        child: SizedBox(
          height: typingLineHeight(context),
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
