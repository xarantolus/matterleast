// Usage: `final h = await pumpWithServer(tester, handle: (r) => ok({}),
// home: (url) => MyScreen(url: url));` then `h.settle(tester)`, `h.server`
// and `h.session`; end the test with `await h.close(tester)`.
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/file_providers.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/files/file_downloads.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/screens/root/open_panes.dart';

import 'fake_server.dart';
import 'memory_database.dart';
import 'settle.dart';
import 'test_session.dart';

/// A fake server and a seeded session behind a widget under test.
class ServerHarness {
  ServerHarness(this.server, this.session, {this.platform});

  /// Reset when the harness closes, before the test's checks.
  final TargetPlatform? platform;

  final FakeServer server;
  final ServerSession session;

  String get url => server.url.toString();

  /// Pumps until the app is idle, once [until] holds; see [settleApp].
  Future<void> settle(WidgetTester tester, {bool Function()? until}) =>
      settleApp(tester, servers: [server], until: until);

  /// Unmounts the widget and closes the server and session. Call it last in
  /// the test body: pending timers are checked before tear-downs run.
  Future<void> close(WidgetTester tester) async {
    if (platform != null) debugDefaultTargetPlatformOverride = null;
    await tester.pumpWidget(const SizedBox());
    // Closing the database in the same frame as the unmount hangs.
    await settle(tester);
    await tester.runAsync(() async {
      await closeTestSession(session);
      await server.close();
    });
  }
}

/// Starts [handle] as the server, opens a [testSession] on it, runs [seed]
/// on that session, and pumps [home] inside providers that serve it (plus
/// [overrides], which know the server's url), with image caches and file
/// [downloads] left pending unless given; [appDatabase] replaces the empty
/// app database. [size] and [platform] are reset afterwards. With
/// [trackRoutes] the navigator reports its conversations, as in the app;
/// [builder] wraps the navigator.
Future<ServerHarness> pumpWithServer(
  WidgetTester tester, {
  required Widget Function(String url) home,
  FutureOr<Reply?> Function(SeenRequest request)? handle,
  Future<void> Function(ServerSession session)? seed,
  List<Override> Function(String url)? overrides,
  FileDownloads? downloads,
  AppDatabase? appDatabase,
  Size? size,
  TargetPlatform? platform,
  bool settle = true,
  bool trackRoutes = false,
  TransitionBuilder? builder,
}) async {
  HttpOverrides.global = null;
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }
  if (platform != null) {
    debugDefaultTargetPlatformOverride = platform;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
  }
  final harness = (await tester.runAsync(() async {
    final server = await FakeServer.start();
    server.handle = handle ?? (_) => ok(const <String, Object?>{});
    final session = await testSession(server);
    await seed?.call(session);
    return ServerHarness(server, session, platform: platform);
  }))!;
  final url = harness.url;
  final appDb = appDatabase ?? memoryAppDatabase();
  if (appDatabase == null) addTearDown(appDb.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(appDb),
        serverSessionProvider(url).overrideWith((ref) async => harness.session),
        serverImageCachesProvider(url)
            .overrideWith((ref) => Completer<ServerImageCaches>().future),
        fileDownloadsProvider(url).overrideWith(
          (ref) => downloads == null
              ? Completer<FileDownloads>().future
              : Future.value(downloads),
        ),
        ...?overrides?.call(url),
      ],
      child: Consumer(
        builder: (context, ref, _) => MaterialApp(
          theme: MatterleastApp.lightTheme,
          navigatorObservers: [
            if (trackRoutes) ref.watch(conversationRoutesProvider),
          ],
          builder: builder,
          home: home(url),
        ),
      ),
    ),
  );
  if (settle) await harness.settle(tester);
  return harness;
}
