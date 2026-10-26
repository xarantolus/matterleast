import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/ui/presence_dot.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/user_avatar.dart';

/// A dense channel row: type icon or avatar, name (bold with a dot when
/// unread), and the draft, muted and mention markers.
class ChannelTile extends StatelessWidget {
  const ChannelTile({
    required this.serverUrl,
    required this.item,
    this.onTap,
    this.onLongPress,
    this.trailing,
    super.key,
  });

  final String serverUrl;
  final ChannelItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// In place of the draft, muted and mention markers.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = item.muted ? tokens.muted : tokens.text;
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(
        left: Spacing.lg,
        right: Spacing.md,
      ),
      minLeadingWidth: 28,
      leading: _ChannelIcon(serverUrl: serverUrl, item: item, color: color),
      title: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 15,
          color: color,
          fontWeight: item.unread || item.mentions > 0
              ? FontWeight.w700
              : FontWeight.w400,
        ),
      ),
      trailing: trailing ?? _Markers(item: item),
      onTap: onTap,
      onLongPress: onLongPress,
    );
  }
}

class _Markers extends StatelessWidget {
  const _Markers({required this.item});

  final ChannelItem item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final markers = [
      if (item.hasDraft)
        Icon(
          Icons.edit_outlined,
          size: 16,
          color: tokens.muted,
          semanticLabel: 'Draft',
        ),
      if (item.muted)
        Icon(
          Icons.notifications_off_outlined,
          size: 16,
          color: tokens.muted,
          semanticLabel: 'Muted',
        ),
      if (item.mentions > 0)
        Semantics(
          label: item.mentions == 1 ? '1 mention' : '${item.mentions} mentions',
          child: ExcludeSemantics(
            child: Badge.count(
              count: item.mentions,
              backgroundColor: item.muted ? tokens.muted : scheme.error,
              textColor: item.muted ? tokens.page : scheme.onError,
            ),
          ),
        )
      else if (item.unread)
        Semantics(
          label: 'Unread',
          child: Badge(smallSize: 8, backgroundColor: tokens.unread),
        ),
    ];
    if (markers.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: Spacing.sm,
      children: markers,
    );
  }
}

class _ChannelIcon extends StatelessWidget {
  const _ChannelIcon({
    required this.serverUrl,
    required this.item,
    required this.color,
  });

  final String serverUrl;
  final ChannelItem item;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return SizedBox(
      width: 28,
      height: 28,
      child: switch (item.kind) {
        ChannelKind.public => Icon(Icons.tag, size: 20, color: color),
        ChannelKind.private => Icon(Icons.lock_outline, size: 20, color: color),
        ChannelKind.archived => Icon(
          Icons.archive_outlined,
          size: 20,
          color: color,
        ),
        ChannelKind.group => CircleAvatar(
          radius: 14,
          backgroundColor: tokens.accentWash,
          child: Text(
            '${item.others ?? 0}',
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: tokens.accent,
            ),
          ),
        ),
        ChannelKind.direct => Stack(
          children: [
            UserAvatar(
              serverUrl: serverUrl,
              userId: item.userId ?? '',
              name: avatarName(item.title),
              lastPictureUpdate: item.pictureUpdate,
              size: 28,
            ),
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: PresenceDot(status: item.status),
            ),
          ],
        ),
      },
    );
  }
}
