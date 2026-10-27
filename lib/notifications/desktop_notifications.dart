import 'dart:async';

import 'package:matterleast/app/desktop/desktop_shell.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/servers/server_manager.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/notifications/live_notifications.dart';
import 'package:matterleast/notifications/notification_check.dart';
import 'package:matterleast/notifications/notifier.dart';
import 'package:matterleast/notifications/notify_rules.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'desktop_notifications.g.dart';

@Riverpod(keepAlive: true)
DesktopNotifications desktopNotifications(Ref ref) {
  final routes = ref.watch(conversationRoutesProvider);
  final engine = DesktopNotifications(
    ref.watch(serverManagerProvider),
    ref.watch(notifierProvider),
    inView: (url, key) => conversationInView(
      url,
      key,
      focused: appInFront(),
      open: Panes.openNow(
        routes: [for (final r in routes.live) r.target],
        panes: ref.read(openPanesProvider),
      ),
    ),
  );
  ref.onDispose(() => unawaited(engine.dispose()));
  return engine;
}

/// Toasts on desktop, from the window's own live connections while the app
/// runs (open, minimised or in the tray), for every signed-in server.
class DesktopNotifications {
  DesktopNotifications(this._manager, this._notifier, {required this.inView}) {
    _changes = _manager.changed.listen((url) {
      // A new sign-in replaced the session; its check follows it.
      _serial(() async {
        if (_attached.containsKey(url)) await _attach(url, _labels[url]);
      });
    });
  }

  final ServerManager _manager;
  final Notifier _notifier;

  /// Whether the user looks at that conversation of that server now.
  final bool Function(String url, ConversationKey key) inView;

  final _attached = <String, LiveNotifications>{};
  final _labels = <String, String?>{};
  late final StreamSubscription<String> _changes;
  var _busy = Future<void>.value();

  void _serial(Future<void> Function() step) {
    _busy = _busy.then((_) => step()).catchError((Object e) {
      Log.warn('notify', 'Following the servers for toasts failed', e);
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
    await markSeen(session.db, DateTime.now().toUtc());
    final check = NotificationCheck(
      session,
      _notifier,
      shownNow: (key) => inView(url, key),
      serverName: label,
    );
    _labels[url] = label;
    _attached[url] = LiveNotifications(
      applied: session.connection.applied,
      caughtUp: session.connection.caughtUp,
      check: () => check.run(refresh: false),
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
