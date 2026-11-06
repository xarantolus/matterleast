import 'dart:async';

import 'package:matterleast/app/desktop/desktop_shell.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/servers/server_manager.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/notifications/live_notifications.dart';
import 'package:matterleast/notifications/notice_banner.dart';
import 'package:matterleast/notifications/notification_check.dart';
import 'package:matterleast/notifications/notifier.dart';
import 'package:matterleast/notifications/notify_rules.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'in_app_notifications.g.dart';

/// Where a notice goes right now: for the conversation [key] of [url], or
/// with a null [key] for any conversation the user doesn't look at.
typedef NoticeRouter = NoticeRoute Function(String url, ConversationKey? key);

@Riverpod(keepAlive: true)
NoticeRouter noticeRouter(Ref ref) {
  final routes = ref.watch(conversationRoutesProvider);
  return (url, key) => noticeRoute(
    inView:
        key != null &&
        conversationInView(
          url,
          key,
          focused: appInFront(),
          open: Panes.openNow(
            routes: [for (final r in routes.live) r.target],
            panes: ref.read(openPanesProvider),
          ),
        ),
    inFront: appInFront(),
    covered: appCovered(),
    desktop: isDesktop,
  );
}

@Riverpod(keepAlive: true)
InAppNotifications inAppNotifications(Ref ref) {
  final engine = InAppNotifications(
    ref.watch(serverManagerProvider),
    ref.watch(notifierProvider),
    route: ref.watch(noticeRouterProvider),
    banner: ref.watch(noticeBannersProvider.notifier).show,
  );
  ref.onDispose(() => unawaited(engine.dispose()));
  return engine;
}

/// The notification check of a server as the UI isolate runs it: a notice
/// for a conversation the user sees is dropped, one while the app is in
/// front becomes a banner, and one while the app is covered, or a desktop
/// window is not in front, a toast.
NotificationCheck inAppCheck(
  ServerSession session,
  Notifier notifier, {
  required NoticeRouter route,
  required void Function(ConversationNotice notice) banner,
  String? serverName,
}) {
  final url = session.url.toString();
  return NotificationCheck(
    session,
    notifier,
    shownNow: (key) => route(url, key) == NoticeRoute.none,
    deliver: (notice) async {
      switch (route(url, notice.key)) {
        case NoticeRoute.banner:
          banner(notice);
        case NoticeRoute.toast:
          await notifier.show(notice);
        case NoticeRoute.none:
          break;
      }
    },
    serverName: serverName,
  );
}

/// Banners and toasts from the window's own live connections while the app
/// runs (on a desktop open, minimised or in the tray), for every signed-in
/// server. A phone that is not in front checks nothing here: its background
/// engines own the notifications and the cursor then.
class InAppNotifications {
  InAppNotifications(
    this._manager,
    this._notifier, {
    required this.route,
    required this.banner,
  }) {
    _changes = _manager.changed.listen((url) {
      // A new sign-in replaced the session; its check follows it.
      _serial(() async {
        if (_attached.containsKey(url)) await _attach(url, _labels[url]);
      });
    });
  }

  final ServerManager _manager;
  final Notifier _notifier;
  final NoticeRouter route;
  final void Function(ConversationNotice notice) banner;

  final _attached = <String, LiveNotifications>{};
  final _labels = <String, String?>{};
  late final StreamSubscription<String> _changes;
  var _busy = Future<void>.value();

  void _serial(Future<void> Function() step) {
    _busy = _busy.then((_) => step()).catchError((Object e) {
      Log.warn('notify', 'Following the servers for notices failed', e);
    });
  }

  /// Follows the signed-in servers, labelled by name when there are
  /// several, as on Android.
  Future<void> follow(List<ServerEntry> servers) {
    final signedIn = [
      for (final s in servers)
        if (s.signedIn) s,
    ];
    final labels = {
      for (final s in signedIn)
        s.url: signedIn.length > 1 ? s.displayName : null,
    };
    _serial(() async {
      for (final url in _attached.keys.toList()) {
        if (!labels.containsKey(url)) await _detach(url);
      }
      for (final MapEntry(key: url, value: label) in labels.entries) {
        if (_attached.containsKey(url) && _labels[url] == label) continue;
        await _attach(url, label);
      }
    });
    return _busy;
  }

  Future<void> _attach(String url, String? label) async {
    await _detach(url);
    final session = await _manager.session(url);
    // The window shows what came before; only what arrives from now on
    // can be news.
    await markSeen(session.db);
    final check = inAppCheck(
      session,
      _notifier,
      route: route,
      banner: banner,
      serverName: label,
    );
    _labels[url] = label;
    _attached[url] = LiveNotifications(
      applied: session.connection.applied,
      caughtUp: session.connection.caughtUp,
      check: ({required afterGap}) async {
        if (route(url, null) == NoticeRoute.none) return;
        await check.run(refresh: false, fetch: afterGap);
      },
    )..start();
  }

  Future<void> _detach(String url) async {
    _labels.remove(url);
    await _attached.remove(url)?.stop();
  }

  Future<void> dispose() async {
    await _changes.cancel();
    for (final url in _attached.keys.toList()) {
      await _detach(url);
    }
  }
}
