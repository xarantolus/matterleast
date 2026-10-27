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
    this.onContextMenu,
    this.trailing,
    super.key,
  });

  final String serverUrl;
  final ChannelItem item;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// A right click, at its global position.
  final ValueChanged<Offset>? onContextMenu;

  /// In place of the draft, muted and mention markers.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = item.muted ? tokens.muted : tokens.text;
    final tile = ListTile(
      dense: true,
      contentPadding: Spacing.row,
      minLeadingWidth: 28,
      // The row reads as one sentence, name first; the icon and markers
      // are in it as words.
      leading: ExcludeSemantics(
        child: _ChannelIcon(serverUrl: serverUrl, item: item, color: color),
      ),
      title: Semantics(
        label: channelRowLabel(item, markers: trailing == null),
        onLongPressHint: onLongPress == null ? null : 'channel options',
        child: ExcludeSemantics(
          child: Text(
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
        ),
      ),
      trailing: trailing ?? ExcludeSemantics(child: _Markers(item: item)),
      onTap: onTap,
      onLongPress: onLongPress,
    );
    final menu = onContextMenu;
    return menu == null
        ? tile
        : GestureDetector(
            onSecondaryTapUp: (d) => menu(d.globalPosition),
            child: tile,
          );
  }
}

/// Pure: a channel row in words: the name, what kind of channel or how
/// the other person is, then, with [markers], the draft, muted and unread
/// state.
String channelRowLabel(ChannelItem item, {bool markers = true}) => [
  item.title,
  switch (item.kind) {
    ChannelKind.public => null,
    ChannelKind.private => 'private channel',
    ChannelKind.archived => 'archived channel',
    ChannelKind.group => 'group message',
    ChannelKind.direct => presenceLabel(item.status).toLowerCase(),
  },
  if (markers) ...[
    if (item.hasDraft) 'draft',
    if (item.muted) 'muted',
    if (item.mentions == 1)
      '1 mention'
    else if (item.mentions > 1)
      '${item.mentions} mentions'
    else if (item.unread)
      'unread',
  ],
].nonNulls.join(', ');

class _Markers extends StatelessWidget {
  const _Markers({required this.item});

  final ChannelItem item;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final scheme = Theme.of(context).colorScheme;
    final markers = [
      if (item.hasDraft)
        Icon(Icons.edit_outlined, size: 16, color: tokens.muted),
      if (item.muted)
        Icon(Icons.notifications_off_outlined, size: 16, color: tokens.muted),
      if (item.mentions > 0)
        Badge.count(
          count: item.mentions,
          backgroundColor: item.muted ? tokens.muted : scheme.error,
          textColor: item.muted ? tokens.page : scheme.onError,
        )
      else if (item.unread)
        Badge(smallSize: 8, backgroundColor: tokens.unread),
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
