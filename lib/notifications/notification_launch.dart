import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/desktop/desktop_shell.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/data/servers/server_manager.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/notifications/app_visibility.dart';
import 'package:matterleast/notifications/background.dart';
import 'package:matterleast/notifications/notifier.dart';
import 'package:matterleast/notifications/stay_connected.dart';
import 'package:matterleast/screens/channel/link_opener.dart';
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
      onTap: (response) => unawaited(_onNotice(navigator, ref, response)),
      onAction: onNoticeAction,
    );
    final launch = await notifier.launchResponse();
    final opened = launch != null && await _onNotice(navigator, ref, launch);
    await StayConnected.resume();
    return opened;
  } on Object catch (e) {
    Log.warn('notify', 'Setting up notifications failed', e);
    return false;
  }
}

/// A tap on a notification opens its conversation. Desktop toast buttons
/// arrive here too, in the window's own isolate, so they act through its
/// sessions; a second database there would fight the window's. True when
/// a conversation is being opened.
Future<bool> _onNotice(
  NavigatorState navigator,
  WidgetRef ref,
  NotificationResponse response,
) async {
  if (noticeActionOf(response) case final action?) {
    try {
      final session = await ref
          .read(serverManagerProvider)
          .session(action.target.serverUrl);
      await runNoticeAction(session, action);
    } on Object catch (e) {
      Log.warn('notify', 'A notification action failed', e);
    }
    return false;
  }
  final target = NoticeTarget.decode(response.payload);
  if (target == null) return false;
  // A toast may be clicked while the window is in the tray.
  if (isDesktop) unawaited(DesktopShell.open());
  await openNotice(navigator, ref, target);
  return true;
}

/// The app left the screen. On a phone the connections go quiet a little
/// later and the background engines take over; on a desktop they stay up
/// while the process runs, minimised or in the tray, for the toasts.
Future<void> appHidden(ServerManager manager) async {
  AppVisibility.set(visible: false);
  if (!isDesktop) await manager.setForeground(false);
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
/// A channel not stored yet, such as a new direct message, is looked up on
/// the server by that message.
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
  if (!navigator.mounted) return;
  if (channel == null) {
    if (target.postId.isEmpty) return;
    await openPost(
      navigator,
      target.serverUrl,
      target.postId,
      fromOutside: true,
    );
    return;
  }
  await openConversation(
    navigator,
    url: target.serverUrl,
    channelId: channel.id,
    title: channel.title,
    teamId: channel.teamId,
    rootId: target.rootId.isEmpty ? null : target.rootId,
    highlightPostId: target.postId,
    fromOutside: true,
  );
}

/// Once after the first sign-in: says what notifications do, then lets
/// Android ask. Later changes go through the settings. Desktops don't ask.
Future<void> askForNotificationsOnce(
  BuildContext context,
  WidgetRef ref,
) async {
  if (isDesktop) return;
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
