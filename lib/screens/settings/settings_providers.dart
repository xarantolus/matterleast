import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/settings_actions.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/data/images/cache_usage.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/views/settings_views.dart';
import 'package:matterleast/domain/notify_props.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/server_theme.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_providers.g.dart';

/// The server whose account settings are shown: the one picked in the
/// rail, else the one used last.
@riverpod
ServerEntry? settingsServer(Ref ref) {
  final servers = ref.watch(serversProvider).value ?? const <ServerEntry>[];
  final signedIn = [
    for (final s in servers)
      if (s.signedIn) s,
  ];
  if (signedIn.isEmpty) return null;
  final picked = ref.watch(railSelectionProvider)?.url;
  return signedIn.where((s) => s.url == picked).firstOrNull ??
      signedIn.reduce(
        (a, b) => b.lastActiveAt!.isAfter(a.lastActiveAt!) ? b : a,
      );
}

@riverpod
Future<SettingsActions> settingsActions(Ref ref, String url) async =>
    (await ref.watch(serverSessionProvider(url).future)).settings;

/// The account's notification settings as stored; empty until the first
/// sign-in data arrived.
@riverpod
Stream<NotifyProps> notifySettings(Ref ref, String url) async* {
  final db = (await ref.watch(serverSessionProvider(url).future)).db;
  yield* SettingsViews(db).notifyProps();
}

/// Fetched when the notification settings open, so they show every key.
@Riverpod(retry: noRetry)
Future<void> notifySettingsRefresh(Ref ref, String url) async =>
    (await ref.watch(settingsActionsProvider(url).future)).refreshNotifyProps();

@riverpod
Stream<DisplayPrefs> displayPrefs(Ref ref, String url) async* {
  final db = (await ref.watch(serverSessionProvider(url).future)).db;
  yield* SettingsViews(db).displayPrefs();
}

@riverpod
Stream<ThemeSource> themeMode(Ref ref, String url) =>
    ref.watch(appDatabaseProvider).watchThemeMode(url);

@riverpod
Stream<int> mediaCacheBudget(Ref ref) =>
    ref.watch(settingsStoreProvider).watch(Settings.mediaCacheBytes);

@riverpod
Stream<int> filesCacheBudget(Ref ref) =>
    ref.watch(settingsStoreProvider).watch(Settings.filesCacheBytes);

/// Bytes of each cache kind across every signed-in server.
@riverpod
class CacheUsage extends _$CacheUsage {
  var _sessions = const <ServerSession>[];

  @override
  Future<Map<CacheKind, int>> build() async {
    final servers = await ref.watch(serversProvider.future);
    _sessions = [
      for (final server in servers.where((s) => s.signedIn))
        await ref.watch(serverSessionProvider(server.url).future),
    ];
    final totals = {for (final kind in CacheKind.values) kind: 0};
    for (final session in _sessions) {
      for (final kind in CacheKind.values) {
        totals[kind] = totals[kind]! + await cacheBytes(session.images, kind);
      }
    }
    return totals;
  }

  Future<void> clear(CacheKind kind) async {
    for (final session in _sessions) {
      await kind.of(session.images).emptyCache();
    }
    ref.invalidateSelf();
  }
}
