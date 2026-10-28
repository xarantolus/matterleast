import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/live_providers.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/today_provider.dart';
import 'package:matterleast/domain/user_profile.dart';
import 'package:matterleast/ui/emoji_glyph.dart';

/// The emoji of [userId]'s custom status on the server at [serverUrl], for
/// beside their name; see [CustomStatusGlyph].
class CustomStatusEmoji extends ConsumerWidget {
  const CustomStatusEmoji({
    required this.serverUrl,
    required this.userId,
    this.size = 16,
    this.padding = const EdgeInsetsDirectional.only(start: 4),
    super.key,
  });

  final String serverUrl;
  final String userId;
  final double size;
  final EdgeInsetsDirectional padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(activeCustomStatusProvider(serverUrl, userId));
    if (status == null) return const SizedBox.shrink();
    return CustomStatusGlyph(
      serverUrl: serverUrl,
      status: status,
      size: size,
      padding: padding,
    );
  }
}

/// A custom status's emoji in a square of [size] (a custom emoji fills it
/// once loaded, so nothing beside it moves). Nothing without an emoji or
/// once the status expires by the clock. On a desktop, hovering shows the
/// status text and when it clears.
class CustomStatusGlyph extends ConsumerWidget {
  const CustomStatusGlyph({
    required this.serverUrl,
    required this.status,
    this.size = 16,
    this.padding = const EdgeInsetsDirectional.only(start: 4),
    super.key,
  });

  final String serverUrl;
  final CustomStatus status;
  final double size;

  /// Space around the emoji, only when there is one.
  final EdgeInsetsDirectional padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (status.emoji.isEmpty || !ref.watch(customStatusHoldsProvider(status))) {
      return const SizedBox.shrink();
    }
    final glyph = Padding(
      padding: padding,
      child: ExcludeSemantics(
        child: EmojiGlyph(name: status.emoji, size: size, serverUrl: serverUrl),
      ),
    );
    if (!isDesktop) return glyph;
    // "Tomorrow" in the tooltip turns into today at midnight.
    ref.watch(todayProvider);
    final message = customStatusTooltip(
      status,
      ref.read(wallClockProvider)(),
      use24: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    if (message.isEmpty) return glyph;
    return Tooltip(message: message, child: glyph);
  }
}
