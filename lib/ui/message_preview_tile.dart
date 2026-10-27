import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/today_provider.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/ui/initials_badge.dart';
import 'package:matterleast/ui/presence_dot.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/user_avatar.dart';

/// One message preview: who, where, one line of the message, when, and how
/// much is new.
class MessagePreviewTile extends ConsumerWidget {
  const MessagePreviewTile({
    required this.item,
    required this.onTap,
    this.serverName,
    super.key,
  });

  final InboxItem item;
  final VoidCallback onTap;

  /// Shown on the row when more than one server is signed in.
  final String? serverName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(todayProvider);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    final strong = item.unread ? FontWeight.w700 : FontWeight.w500;
    final detail = [?item.place, ?item.team, ?serverName].join(' · ');
    final when = shortWhen(
      item.time,
      today,
      use24: MediaQuery.alwaysUse24HourFormatOf(context),
    );
    // At large text sizes the time leaves the title line, which would
    // otherwise have room for a few letters only.
    final large = MediaQuery.textScalerOf(context).scale(10) > 15;
    final marker = _marker(context, item);
    return ListTile(
      contentPadding: Spacing.row,
      onTap: onTap,
      // Pictures are decoration here; presence is read after the name.
      leading: ExcludeSemantics(
        child: Stack(
          children: [
            if (item.avatarUserId case final userId?)
              UserAvatar(
                serverUrl: item.serverUrl,
                userId: userId,
                name: item.avatarName,
                lastPictureUpdate: item.avatarPictureUpdate,
              )
            else
              InitialsBadge(name: item.avatarName, round: true),
            if (item.kind == InboxKind.direct)
              PositionedDirectional(
                end: 0,
                bottom: 0,
                child: PresenceDot(status: item.status, size: 12),
              ),
          ],
        ),
      ),
      title: Row(
        children: [
          Expanded(
            // The detail comes last, so it is what the ellipsis cuts.
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: item.title,
                    style: TextStyle(fontWeight: strong),
                  ),
                  if (detail.isNotEmpty)
                    TextSpan(
                      text: ' · $detail',
                      style: TextStyle(
                        color: tokens.muted,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.kind == InboxKind.direct)
            Semantics(label: presenceLabel(item.status).toLowerCase()),
          if (!large) ...[
            const SizedBox(width: Spacing.sm),
            Text(when, style: text.bodySmall?.copyWith(color: tokens.muted)),
          ],
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // At large sizes the time takes a line of its own, so the
          // message keeps two lines instead of a few letters after it.
          if (large) Text(when, style: TextStyle(color: tokens.muted)),
          Text.rich(
            TextSpan(
              children: [
                if (item.author case final author?)
                  TextSpan(
                    text: '$author: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                TextSpan(text: item.preview),
              ],
            ),
            maxLines: large ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: item.unread ? tokens.text : tokens.muted),
          ),
        ],
      ),
      trailing: marker,
    );
  }
}

/// The new-message count or unread dot, or null so that rows without one
/// keep no empty slot at the end.
Widget? _marker(BuildContext context, InboxItem item) {
  if (item.count > 0) {
    final label = item.kind == InboxKind.thread
        ? '${item.count} new ${item.count == 1 ? 'reply' : 'replies'}'
        : '${item.count} unread';
    return Semantics(
      label: label,
      child: ExcludeSemantics(child: Badge.count(count: item.count)),
    );
  }
  if (item.unread) {
    return Semantics(
      label: 'Unread',
      child: Badge(smallSize: 10, backgroundColor: context.tokens.unread),
    );
  }
  return null;
}
