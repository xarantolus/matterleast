import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/emoji_providers.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/screens/you/profile_providers.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/tokens.dart';

/// A tapped emoji, large, with its name.
Future<void> showEmojiCard(
  BuildContext context, {
  required String name,
  required String? serverUrl,
}) => showAppSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (_) => EmojiCard(name: name, serverUrl: serverUrl),
);

class EmojiCard extends ConsumerWidget {
  const EmojiCard({required this.name, required this.serverUrl, super.key});

  final String name;
  final String? serverUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final url = serverUrl;
    final custom = unicodeForName(name) == null;
    final creatorId = custom && url != null
        ? ref.watch(customEmojiCreatorProvider(url, name)).value
        : null;
    final creator = creatorId == null || creatorId.isEmpty
        ? null
        : ref.watch(userProfileProvider(url!, creatorId)).value;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          0,
          Spacing.lg,
          Spacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(
              child: Center(
                child: EmojiGlyph(name: name, size: 96, serverUrl: url),
              ),
            ),
            const SizedBox(height: Spacing.md),
            Text(
              ':$name:',
              style: text.headlineSmall,
              textAlign: TextAlign.center,
            ),
            if (custom)
              Text(
                creator == null
                    ? 'Custom emoji'
                    : 'Custom emoji · added by ${creator.name}',
                style: text.bodyMedium?.copyWith(color: context.tokens.muted),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}
