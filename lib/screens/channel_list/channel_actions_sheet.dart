import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/data/actions/channel_actions.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/screens/root/root_providers.dart';

/// The long-press sheet of a channel row.
Future<void> showChannelActions(
  BuildContext context, {
  required String url,
  required String teamId,
  required ChannelItem item,
}) => showModalBottomSheet<void>(
  context: context,
  showDragHandle: true,
  builder: (_) => _ChannelActionsSheet(url: url, teamId: teamId, item: item),
);

class _ChannelActionsSheet extends ConsumerWidget {
  const _ChannelActionsSheet({
    required this.url,
    required this.teamId,
    required this.item,
  });

  final String url;
  final String teamId;
  final ChannelItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversation =
        item.kind == ChannelKind.direct || item.kind == ChannelKind.group;
    void run(String failure, Future<void> Function(ChannelActions) action) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      ref.read(channelActionsProvider(url).future).then(action).catchError((
        Object _,
      ) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('$failure Check the connection and try again.'),
          ),
        );
      });
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Text(
              item.title,
              style: Theme.of(context).textTheme.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ListTile(
            leading: const Icon(Icons.mark_chat_read_outlined),
            title: const Text('Mark as read'),
            enabled: item.unread || item.mentions > 0,
            onTap: () => run(
              "Couldn't mark ${item.title} as read.",
              (actions) => actions.view(item.id),
            ),
          ),
          ListTile(
            leading: Icon(item.favorite ? Icons.star : Icons.star_border),
            title: Text(item.favorite ? 'Remove from favourites' : 'Favourite'),
            onTap: () => run(
              "Couldn't change favourites.",
              (actions) => actions.setFavorite(
                teamId,
                item.id,
                favorite: !item.favorite,
              ),
            ),
          ),
          ListTile(
            leading: Icon(
              item.muted
                  ? Icons.notifications_outlined
                  : Icons.notifications_off_outlined,
            ),
            title: Text(item.muted ? 'Unmute' : 'Mute'),
            onTap: () => run(
              "Couldn't ${item.muted ? 'unmute' : 'mute'} ${item.title}.",
              (actions) => actions.setMuted(item.id, muted: !item.muted),
            ),
          ),
          if (!conversation)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Leave channel'),
              onTap: () async {
                final navigator = Navigator.of(context);
                final leave = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Leave ${item.title}?'),
                    content: Text(
                      item.kind == ChannelKind.private
                          ? "It's private, so you'll need an invite to come back."
                          : 'You can join it again from Browse channels.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Leave'),
                      ),
                    ],
                  ),
                );
                if (leave != true) {
                  navigator.pop();
                  return;
                }
                if (!context.mounted) return;
                run(
                  "Couldn't leave ${item.title}.",
                  (actions) => actions.leave(item.id),
                );
              },
            ),
        ],
      ),
    );
  }
}
