import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/today_provider.dart';
import 'package:matterleast/domain/inbox.dart';
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
    final labels = [?serverName, ?item.place];
    return ListTile(
      onTap: onTap,
      leading: Stack(
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
      title: Row(
        children: [
          Expanded(
            child: Text(
              item.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: strong),
            ),
          ),
          const SizedBox(width: Spacing.sm),
          Text(
            _timeLabel(context, item.time, today),
            style: text.bodySmall?.copyWith(color: tokens.muted),
          ),
        ],
      ),
      subtitle: Text.rich(
        TextSpan(
          children: [
            if (labels.isNotEmpty)
              TextSpan(
                text: '${labels.join(' · ')} · ',
                style: TextStyle(color: tokens.accent),
              ),
            if (item.author case final author?)
              TextSpan(
                text: '$author: ',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            TextSpan(text: item.preview),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: item.unread ? tokens.text : tokens.muted),
      ),
      trailing: _Marker(item: item),
    );
  }
}

String _timeLabel(BuildContext context, DateTime time, DateTime today) {
  final local = time.toLocal();
  final strings = MaterialLocalizations.of(context);
  if (local.year == today.year &&
      local.month == today.month &&
      local.day == today.day) {
    return strings.formatTimeOfDay(
      TimeOfDay.fromDateTime(local),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
  }
  return local.year == today.year
      ? strings.formatShortMonthDay(local)
      : strings.formatShortDate(local);
}

class _Marker extends StatelessWidget {
  const _Marker({required this.item});

  final InboxItem item;

  @override
  Widget build(BuildContext context) {
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
    return const SizedBox.shrink();
  }
}
