import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/channel/channel_screen.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/thread/thread_screen.dart';
import 'package:matterleast/ui/conversation_route.dart';

/// Opens a conversation the user is in, the one way every screen does it:
/// its server and team in the rail, then the channel, or the thread of
/// [rootId], at [highlightPostId] when given. Opening a channel (not a
/// thread) remembers it as the team's last one and marks it viewed.
Future<void> openConversation(
  NavigatorState navigator, {
  required String url,
  required String channelId,
  required String title,
  String? teamId,
  String? rootId,
  String? highlightPostId,
}) async {
  if (!navigator.mounted) return;
  final container = ProviderScope.containerOf(navigator.context, listen: false);
  final picked = container.read(railSelectionProvider);
  final team = (teamId?.isNotEmpty ?? false)
      ? teamId
      : (picked?.url == url ? picked?.teamId : null);
  container
      .read(railSelectionProvider.notifier)
      .select(RailTarget(url: url, teamId: team));
  if (rootId == null) {
    final actions = container.read(channelActionsProvider(url).future);
    unawaited(actions.then((a) => a.open(channelId, teamId: team)));
  }
  await navigator.push(
    ConversationRoute<void>(
      builder: (_) => rootId != null
          ? ThreadScreen(
              url: url,
              channelId: channelId,
              rootId: rootId,
              channelName: title,
              highlightPostId: highlightPostId,
            )
          : ChannelScreen(
              url: url,
              channelId: channelId,
              title: title,
              highlightPostId: highlightPostId,
            ),
    ),
  );
}

/// Asks before joining a channel; nothing is joined silently.
Future<bool> confirmJoin(BuildContext context, String name) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Join $name?'),
        content: const Text(
          'You will see its messages and be able to post. You can leave it '
          'again from the channel list.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Join'),
          ),
        ],
      ),
    ) ??
    false;
