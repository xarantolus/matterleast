import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/ui/tokens.dart';

/// A dense channel row: type icon or avatar, name (bold with a dot when
/// unread), and the draft, muted and mention markers.
class ChannelTile extends StatelessWidget {
  const ChannelTile({
    required this.item,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  final ChannelItem item;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = item.muted ? tokens.muted : tokens.text;
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.only(
        left: Spacing.lg,
        right: Spacing.md,
      ),
      minLeadingWidth: 28,
      leading: _ChannelIcon(item: item, color: color),
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
      trailing: _Markers(item: item),
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
        Badge.count(
          count: item.mentions,
          backgroundColor: item.muted ? tokens.muted : scheme.error,
          textColor: item.muted ? tokens.page : scheme.onError,
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
  const _ChannelIcon({required this.item, required this.color});

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
            CircleAvatar(
              radius: 14,
              backgroundColor: tokens.accentWash,
              child: Text(
                avatarInitials(item.title),
                // Fixed-size avatar; the name is next to it.
                textScaler: TextScaler.noScaling,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: tokens.accent,
                ),
              ),
            ),
            PositionedDirectional(
              end: 0,
              bottom: 0,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: switch (item.status) {
                    'online' => tokens.online,
                    'away' => tokens.away,
                    'dnd' => tokens.busy,
                    _ => tokens.divider,
                  },
                  border: Border.all(color: tokens.page, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      },
    );
  }
}
