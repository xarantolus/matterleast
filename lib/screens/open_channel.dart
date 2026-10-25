import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/channel/channel_screen.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/thread/thread_screen.dart';
import 'package:matterleast/ui/conversation_route.dart';

/// Opens a channel the user is in: its server and team in the rail, then
/// the conversation, at [highlightPostId] when given. A reply under
/// collapsed threads opens its thread instead ([rootId]).
Future<void> openChannel(
  NavigatorState navigator,
  WidgetRef ref, {
  required String url,
  required String channelId,
  required String title,
  String? teamId,
  String? highlightPostId,
  String? rootId,
}) async {
  final picked = ref.read(railSelectionProvider);
  final team = (teamId?.isNotEmpty ?? false)
      ? teamId
      : (picked?.url == url ? picked?.teamId : null);
  ref
      .read(railSelectionProvider.notifier)
      .select(RailTarget(url: url, teamId: team));
  final actions = await ref.read(channelActionsProvider(url).future);
  unawaited(actions.open(channelId, teamId: team));
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
