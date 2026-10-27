import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/notifications/app_visibility.dart';
import 'package:matterleast/notifications/background.dart';
import 'package:matterleast/notifications/notifier.dart';
import 'package:matterleast/notifications/stay_connected.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/search/search_providers.dart';

/// Sets up notifications in the UI isolate: taps open their conversation,
/// the app counts as on screen, and the stay-connected service comes back
/// when it is switched on. True when a notification launched the app.
Future<bool> startNotifications(WidgetRef ref, NavigatorState navigator) async {
  AppVisibility.set(visible: true);
  final notifier = ref.read(notifierProvider);
  try {
    await notifier.init(
      onTap: (response) {
        final target = NoticeTarget.decode(response.payload);
        if (target != null) unawaited(openNotice(navigator, ref, target));
      },
      onAction: onNoticeAction,
    );
    final launch = await notifier.launchTarget();
    if (launch != null) await openNotice(navigator, ref, launch);
    await StayConnected.resume();
    return launch != null;
  } on Object catch (e) {
    Log.warn('notify', 'Setting up notifications failed', e);
    return false;
  }
}

/// The periodic check runs while any server is signed in.
Future<void> followSignedIn(List<ServerEntry> servers) async {
  try {
    if (servers.any((s) => s.signedIn)) {
      await PeriodicCheck.schedule();
    } else {
      await PeriodicCheck.cancel();
      await StayConnected.disable();
    }
  } on Object catch (e) {
    Log.warn('notify', 'Scheduling the notification check failed', e);
  }
}

/// Opens the conversation a notification is about, at its newest message.
Future<void> openNotice(
  NavigatorState navigator,
  WidgetRef ref,
  NoticeTarget target,
) async {
  final servers = await readOnce(ref, serversProvider.future);
  if (!servers.any((s) => s.signedIn && s.url == target.serverUrl)) return;
  final items = await readOnce(
    ref,
    switchItemsProvider(target.serverUrl).future,
  );
  final channel = items.where((i) => i.id == target.channelId).firstOrNull;
  if (channel == null || !navigator.mounted) return;
  navigator.popUntil((route) => route.isFirst);
  await openConversation(
    navigator,
    url: target.serverUrl,
    channelId: channel.id,
    title: channel.title,
    teamId: channel.teamId,
    rootId: target.rootId.isEmpty ? null : target.rootId,
    highlightPostId: target.postId,
  );
}

/// Once after the first sign-in: says what notifications do, then lets
/// Android ask. Later changes go through the settings.
Future<void> askForNotificationsOnce(
  BuildContext context,
  WidgetRef ref,
) async {
  final settings = ref.read(settingsStoreProvider);
  if (await settings.read(Settings.notificationsAsked)) return;
  final notifier = ref.read(notifierProvider);
  if (await notifier.permitted()) {
    await settings.write(Settings.notificationsAsked, true);
    return;
  }
  if (!context.mounted) return;
  final wanted = await showDialog<bool>(
    context: context,
    builder: (context) => const _NotificationsDialog(),
  );
  await settings.write(Settings.notificationsAsked, true);
  if (wanted ?? false) await notifier.requestPermission();
}

class _NotificationsDialog extends StatelessWidget {
  const _NotificationsDialog();

  @override
  Widget build(BuildContext context) => AlertDialog(
    icon: const Icon(Icons.notifications_outlined),
    title: const Text('Get notified about new messages?'),
    content: const Text(
      'While Matterleast is closed it looks for direct messages, mentions '
      'and replies about every 15 minutes, as your notification settings on '
      'each server say. For notifications right away, turn on Stay '
      'connected in Settings › Notifications.',
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, false),
        child: const Text('Not now'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, true),
        child: const Text('Continue'),
      ),
    ],
  );
}
