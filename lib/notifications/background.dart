import 'dart:async';
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:matterleast/api/network_state.dart';
import 'package:matterleast/data/actions/conversation_actions.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/secure/token_store.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/app_servers.dart';
import 'package:matterleast/data/servers/server_manager.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/notifications/app_visibility.dart';
import 'package:matterleast/notifications/notification_check.dart';
import 'package:matterleast/notifications/notifier.dart';
import 'package:matterleast/notifications/notify_rules.dart';
import 'package:workmanager/workmanager.dart';

/// The app without its UI, for engines that run while it is closed: the
/// periodic check, notification actions and the stay-connected service.
class BackgroundApp {
  BackgroundApp._(this.db, this.manager, this.notifier, this.network);

  final AppDatabase db;
  final NetworkState network;
  final ServerManager manager;
  final Notifier notifier;

  static Future<BackgroundApp> open() async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    final notifier = Notifier();
    await notifier.init(onAction: onNoticeAction);
    final db = AppDatabase.open(shared: false);
    final network = NetworkState.device();
    final manager = appServerManager(
      db: db,
      tokens: TokenStore(),
      shared: false,
      onRead: (url, mark) => unawaited(clearOnRead(notifier, url, mark)),
      onWiped: notifier.clearServer,
      network: network,
    );
    return BackgroundApp._(db, manager, notifier, network);
  }

  /// Opens the app, runs [work] and closes it again, whatever happens.
  static Future<void> run(Future<void> Function(BackgroundApp app) work) async {
    final app = await open();
    try {
      await work(app);
    } on Object catch (e, stack) {
      Log.warn('notify', 'Background work failed', e);
      Log.warn('notify', stack.toString());
    } finally {
      await app.close();
    }
  }

  /// The URLs of the signed-in servers, with a label for each when there
  /// is more than one.
  Future<Map<String, String?>> signedIn() async {
    final servers = [
      for (final s in await db.allServers())
        if (s.lastActiveAt != null) s,
    ];
    return {
      for (final s in servers) s.url: servers.length > 1 ? s.displayName : null,
    };
  }

  /// Runs the notification check on every signed-in server. Not while the
  /// UI is on screen: it syncs and shows messages itself, and two
  /// connections writing the same database at once only get in each
  /// other's way.
  Future<void> checkAll({required bool refresh}) async {
    if (AppVisibility.visible) return;
    for (final MapEntry(key: url, value: label) in (await signedIn()).entries) {
      try {
        final session = await manager.session(url);
        await NotificationCheck(
          session,
          notifier,
          appVisible: () => AppVisibility.visible,
          serverName: label,
        ).run(refresh: refresh);
      } on Object catch (e) {
        Log.warn('notify', 'Checking a server failed', e);
      }
    }
  }

  Future<void> close() async {
    await manager.dispose();
    await network.close();
    await db.close();
  }
}

/// Removes the notification of what was just read.
Future<void> clearOnRead(Notifier notifier, String url, ReadMark mark) async {
  try {
    switch (mark) {
      case (channelId: final channelId?, rootId: _):
        await notifier.clear(url, ConversationKey(channelId));
      case (channelId: null, rootId: final rootId?) when rootId.isNotEmpty:
        await notifier.clearThread(url, rootId);
      case (channelId: null, rootId: _):
        for (final s in await notifier.shown(url)) {
          if (s.key.rootId.isNotEmpty) await notifier.clear(url, s.key);
        }
    }
  } on Object catch (e) {
    Log.warn('notify', 'Removing a notification failed', e);
  }
}

/// Reply and Mark as read, run in a background engine of their own.
@pragma('vm:entry-point')
Future<void> onNoticeAction(NotificationResponse response) async {
  final target = NoticeTarget.decode(response.payload);
  if (target == null) return;
  await BackgroundApp.run((app) async {
    final session = await app.manager.session(target.serverUrl);
    switch (response.actionId) {
      case NoticeActions.reply:
        final text = response.input?.trim() ?? '';
        if (text.isEmpty) return;
        await session.composer.send(
          target.channelId,
          rootId: target.rootId,
          message: text,
        );
        // The session may still be starting its outbox; this waits for
        // the post to be tried before the engine goes away.
        await session.outbox.start();
        await session.outbox.kick();
      case NoticeActions.read when target.rootId.isNotEmpty:
        final team = target.teamId.isNotEmpty
            ? target.teamId
            : await session.db.syncText(SyncKeys.currentTeamId);
        if (team == null) return;
        await ConversationActions(session).markThreadRead(team, target.rootId);
      case NoticeActions.read:
        await session.channels.markRead(target.channelId);
    }
  });
}

/// The periodic check: one unique work, kept across launches.
abstract final class PeriodicCheck {
  static const name = 'notification-check';

  static Future<void> schedule() async {
    await Workmanager().initialize(backgroundDispatcher);
    await Workmanager().registerPeriodicTask(
      name,
      name,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
      constraints: Constraints(networkType: NetworkType.connected),
    );
  }

  static Future<void> cancel() async {
    await Workmanager().initialize(backgroundDispatcher);
    await Workmanager().cancelByUniqueName(name);
  }
}

@pragma('vm:entry-point')
void backgroundDispatcher() {
  Workmanager().executeTask((task, input) async {
    // The stay-connected engine hears about new posts at once already.
    if (IsolateNameServer.lookupPortByName(AppVisibility.serviceName) != null) {
      return true;
    }
    await BackgroundApp.run((app) => app.checkAll(refresh: true));
    return true;
  });
}
