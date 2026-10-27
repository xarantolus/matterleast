import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart' show WidgetRef;
import 'package:matterleast/api/network_state.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/data/secure/token_store.dart';
import 'package:matterleast/data/servers/app_servers.dart';
import 'package:matterleast/data/servers/browser_auth_session.dart';
import 'package:matterleast/data/servers/entries.dart';
import 'package:matterleast/data/servers/server_manager.dart';
import 'package:matterleast/data/servers/server_probe.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/servers/sign_in.dart';
import 'package:matterleast/domain/message_text_size.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/notifications/background.dart';
import 'package:matterleast/notifications/notification_check.dart';
import 'package:matterleast/notifications/notifier.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:url_launcher/url_launcher.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
AppDatabase appDatabase(Ref ref) {
  final db = AppDatabase.open();
  ref.onDispose(db.close);
  return db;
}

@Riverpod(keepAlive: true)
SettingsStore settingsStore(Ref ref) =>
    SettingsStore(ref.watch(appDatabaseProvider));

/// The rail item shown when the app was last used, read once at launch.
@Riverpod(keepAlive: true)
Future<RailTarget?> savedRailTarget(Ref ref) =>
    ref.watch(settingsStoreProvider).read(Settings.lastRailTarget);

@Riverpod(keepAlive: true)
TokenStore tokenStore(Ref ref) => TokenStore();

/// Whether the token storage stopped answering (a locked or missing
/// keyring), as it changes.
@riverpod
Stream<bool> keyringUnavailable(Ref ref) async* {
  final tokens = ref.watch(tokenStoreProvider);
  yield tokens.unavailable;
  yield* tokens.unavailableChanges;
}

@Riverpod(keepAlive: true)
NetworkState networkState(Ref ref) {
  final network = NetworkState.device();
  ref.onDispose(network.close);
  return network;
}

/// True while the device has no network, so nothing shows as loading.
@Riverpod(keepAlive: true)
bool offline(Ref ref) {
  final online = ref.watch(networkStateProvider).online;
  online.addListener(ref.invalidateSelf);
  ref.onDispose(() => online.removeListener(ref.invalidateSelf));
  return !online.value;
}

@Riverpod(keepAlive: true)
ServerManager serverManager(Ref ref) {
  final notifier = ref.watch(notifierProvider);
  final manager = appServerManager(
    db: ref.watch(appDatabaseProvider),
    tokens: ref.watch(tokenStoreProvider),
    onRead: (url, mark) => unawaited(clearOnRead(notifier, url, mark)),
    onWiped: notifier.clearServer,
    // What the app showed until now never comes back as a notification.
    onHidden: (session) => markSeen(session.db, DateTime.now().toUtc()),
    network: ref.watch(networkStateProvider),
  );
  ref.onDispose(manager.dispose);
  return manager;
}

/// Message notifications of this isolate; [Notifier.init] runs at launch.
@Riverpod(keepAlive: true)
Notifier notifier(Ref ref) => Notifier();

@riverpod
ServerProbe serverProbe(Ref ref) => ServerProbe();

/// The desktop SSO sign-in waiting for the browser; callback links that
/// reach the app go to it.
@Riverpod(keepAlive: true)
BrowserAuthSession browserAuthSession(Ref ref) => BrowserAuthSession(
  launch: (url) => launchUrl(url, mode: LaunchMode.externalApplication),
);

@riverpod
SignIn signIn(Ref ref) => SignIn(
  openAuthSession: isDesktop
      ? ref.watch(browserAuthSessionProvider).open
      : null,
);

/// Every added server, signed in or not, in rail order.
@riverpod
Stream<List<ServerEntry>> servers(Ref ref) => ref
    .watch(appDatabaseProvider)
    .watchServers()
    .map((rows) => [for (final row in rows) serverEntryOf(row)]);

@Riverpod(keepAlive: true)
Future<ServerSession> serverSession(Ref ref, String url) {
  final manager = ref.watch(serverManagerProvider);
  final changes = manager.changed
      .where((changedUrl) => changedUrl == url)
      .listen((_) => ref.invalidateSelf());
  ref.onDispose(changes.cancel);
  return manager.session(url);
}

/// The signed-in user of one server, from its database.
@riverpod
Stream<Me?> currentUser(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* session.db.watchMe().map((row) => row == null ? null : meOf(row));
}

/// What one server offers, as it changes.
@riverpod
Stream<ServerFeatures> features(Ref ref, String url) async* {
  final session = await ref.watch(serverSessionProvider(url).future);
  yield* session.db.watchFeatures();
}

/// Servers that ended their session, as they happen.
@riverpod
Stream<ServerEntry> sessionEnded(Ref ref) =>
    ref.watch(serverManagerProvider).sessionEnded.map(serverEntryOf);

/// The GitHub repository whose releases the desktop update check reads.
/// CI passes the repository it builds in, so a fork checks its own.
const releaseRepo = String.fromEnvironment(
  'RELEASE_REPO',
  defaultValue: 'xarantolus/matterleast',
);

/// The running version alone, such as `0.11.1`.
@Riverpod(keepAlive: true)
Future<String> runningVersion(Ref ref) async =>
    (await PackageInfo.fromPlatform()).version;

/// The app's version as people read it, such as `0.1.0 (1)`.
@Riverpod(keepAlive: true)
Future<String> appVersion(Ref ref) async {
  final info = await PackageInfo.fromPlatform();
  return '${info.version} (${info.buildNumber})';
}

/// The clock the user picked; null follows the phone.
@Riverpod(keepAlive: true)
Stream<bool?> use24HourClock(Ref ref) =>
    ref.watch(settingsStoreProvider).watch(Settings.use24HourClock);

@Riverpod(keepAlive: true)
Stream<MessageTextSize> messageTextSize(Ref ref) =>
    ref.watch(settingsStoreProvider).watch(Settings.messageTextSize);

@Riverpod(keepAlive: true)
Stream<bool> wrapCode(Ref ref) =>
    ref.watch(settingsStoreProvider).watch(Settings.wrapCode);

@riverpod
Stream<bool> closeToTray(Ref ref) =>
    ref.watch(settingsStoreProvider).watch(Settings.closeToTray);

/// Reads [provider] (a `.future`) once from outside a build, held until it
/// answers: an auto-disposed provider nothing else listens to would be
/// disposed before then.
Future<T> readOnce<T>(
  WidgetRef ref,
  ProviderListenable<Future<T>> provider,
) async {
  final held = ref.listenManual(provider, (_, _) {});
  try {
    return await held.read();
  } finally {
    held.close();
  }
}
