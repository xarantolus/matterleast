import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/channel/channel_screen.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/thread/thread_screen.dart';

/// Opens what a preview row points at: its server and team in the rail,
/// then the conversation at the message, or the thread.
Future<void> openInboxItem(
  BuildContext context,
  WidgetRef ref,
  InboxItem item,
) async {
  final navigator = Navigator.of(context);
  ref
      .read(railSelectionProvider.notifier)
      .select(RailTarget(url: item.serverUrl, teamId: item.teamId));
  if (item.kind != InboxKind.thread) {
    final actions = await ref.read(
      channelActionsProvider(item.serverUrl).future,
    );
    unawaited(actions.open(item.channelId, teamId: item.teamId));
  }
  final rootId = item.rootId;
  await navigator.push(
    MaterialPageRoute<void>(
      builder: (_) => item.kind == InboxKind.thread && rootId != null
          ? ThreadScreen(
              url: item.serverUrl,
              channelId: item.channelId,
              rootId: rootId,
              channelName: item.place ?? item.title,
            )
          : ChannelScreen(
              url: item.serverUrl,
              channelId: item.channelId,
              title: item.place ?? item.title,
              highlightPostId: item.postId,
            ),
    ),
  );
}
