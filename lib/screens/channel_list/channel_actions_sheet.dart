import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/data/actions/channel_actions.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/channel_info/channel_info_screen.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/sheet_header.dart';
import 'package:matterleast/ui/slide_route.dart';

/// The long-press sheet of a channel row; on desktop a popup next to
/// [anchor] (global), where it was right-clicked.
Future<void> showChannelActions(
  BuildContext context, {
  required String url,
  required String teamId,
  required ChannelItem item,
  Rect? anchor,
}) => showAppSheet<void>(
  context: context,
  showDragHandle: true,
  anchor: anchor,
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
        Object e,
      ) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              '$failure ${requestProblemText(e, Uri.parse(url).host)}',
            ),
          ),
        );
      });
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetHeader(item.title),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Channel info'),
            onTap: () {
              final navigator = Navigator.of(context);
              navigator.pop();
              unawaited(
                navigator.push(
                  SlideRoute<void>(
                    builder: (_) =>
                        ChannelInfoScreen(url: url, channelId: item.id),
                  ),
                ),
              );
            },
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
          if (conversation)
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(
                item.kind == ChannelKind.direct
                    ? 'Close direct message'
                    : 'Close group message',
              ),
              onTap: () => run(
                "Couldn't close ${item.title}.",
                (actions) => actions.closeConversation(item.id),
              ),
            ),
          if (!conversation)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Leave channel'),
              onTap: () async {
                final navigator = Navigator.of(context);
                final leave = await confirmLeave(
                  context,
                  item.title,
                  private: item.kind == ChannelKind.private,
                );
                if (!leave) {
                  navigator.pop();
                  return;
                }
                if (!context.mounted) return;
                run("Couldn't leave ${item.title}.", (actions) async {
                  await actions.leave(item.id);
                  closeChannel(navigator, url: url, channelId: item.id);
                });
              },
            ),
        ],
      ),
    );
  }
}
