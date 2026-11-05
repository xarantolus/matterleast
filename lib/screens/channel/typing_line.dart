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
/// line, and a margin that is wider on a phone.
double conversationBottomGap(BuildContext context) =>
    typingLineHeight(context) + (isDesktop ? Spacing.xs : Spacing.lg);

/// Who is writing, drawn in the gap the message list keeps above the
/// composer, so it never covers a message or changes the layout. A bar
/// slides up out of the composer while someone types and back down after.
class TypingLine extends ConsumerStatefulWidget {
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
  ConsumerState<TypingLine> createState() => _TypingLineState();
}

class _TypingLineState extends ConsumerState<TypingLine> {
  // Kept while the bar slides away, so its words don't vanish first.
  String _last = '';

  @override
  Widget build(BuildContext context) {
    final provider = typingNamesProvider(
      widget.url,
      widget.channelId,
      widget.rootId,
    );
    ref.listen(provider, (_, next) {
      final text = typingText(next.value ?? const []);
      if (text != null && text != _last) setState(() => _last = text);
    });
    final shown = typingText(ref.watch(provider).value ?? const []) != null;
    final theme = Theme.of(context);
    final duration = motion(context, const Duration(milliseconds: 180));
    return IgnorePointer(
      child: ClipRect(
        child: AnimatedSlide(
          offset: shown ? Offset.zero : const Offset(0, 1),
          duration: duration,
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: shown ? 1 : 0,
            duration: duration,
            child: Container(
              height: typingLineHeight(context),
              padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(Spacing.sm),
                ),
              ),
              child: Text(
                _last,
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
