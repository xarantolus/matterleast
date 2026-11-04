import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/screens/channel/message_environment.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/ui/clickable.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/motion.dart';
import 'package:matterleast/ui/tokens.dart';

/// A channel's header under the app bar: one line with working links,
/// the whole text after a tap. Takes no room when there is none.
class HeaderStrip extends ConsumerStatefulWidget {
  const HeaderStrip({required this.url, required this.channelId, super.key});

  final String url;
  final String channelId;

  @override
  ConsumerState<HeaderStrip> createState() => _HeaderStripState();
}

class _HeaderStripState extends ConsumerState<HeaderStrip> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final info = ref
        .watch(channelInfoProvider(widget.url, widget.channelId))
        .value;
    final header = info?.header.trim() ?? '';
    if (info == null || header.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall!.copyWith(
      color: context.tokens.muted,
    );
    final key = 'header:${info.id}:${header.hashCode}';
    Widget text = MessageEnvironment(
      url: widget.url,
      teamId: info.teamId,
      child: _open
          ? PostBody(
              postId: key,
              message: header,
              collapsible: false,
              style: style,
            )
          : DefaultTextStyle.merge(
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              child: PostBody(
                postId: '$key:line',
                message: header.replaceAll(RegExp(r'\s*\n\s*'), ' '),
                collapsible: false,
                style: style,
              ),
            ),
    );
    text = GestureDetector(
      onTap: () => setState(() => _open = !_open),
      child: Clickable(child: text),
    );
    if (isDesktop) {
      text = Tooltip(
        message: _open ? 'Show less' : 'Show the whole header',
        child: text,
      );
    }
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: SizedBox(
        width: double.infinity,
        child: AnimatedSize(
          alignment: Alignment.topCenter,
          duration: motion(context, const Duration(milliseconds: 200)),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.xs,
            ),
            child: text,
          ),
        ),
      ),
    );
  }
}
