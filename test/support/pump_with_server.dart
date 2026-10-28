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
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/data/servers/server_session.dart';

import 'fake_server.dart';
import 'memory_database.dart';
import 'test_session.dart';

/// A fake server and a seeded session behind a widget under test.
class ServerHarness {
  ServerHarness(this.server, this.session);

  final FakeServer server;
  final ServerSession session;

  String get url => server.url.toString();

  /// Lets the server and database, which answer on the real clock, and the
  /// widgets' timers, on the fake one, run for a while.
  Future<void> settle(WidgetTester tester, {int rounds = 15}) async {
    for (var i = 0; i < rounds; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  /// Unmounts the widget and closes the server and session. Call it last in
  /// the test body: pending timers are checked before tear-downs run.
  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    await tester.runAsync(() async {
      await closeTestSession(session);
      await server.close();
    });
  }
}

/// Starts [handle] as the server, opens a [testSession] on it, runs [seed]
/// on that session, and pumps [home] inside providers that serve it (plus
/// [overrides], which know the server's url), with image caches left pending. [size] and [platform] are reset afterwards.
Future<ServerHarness> pumpWithServer(
  WidgetTester tester, {
  required Widget Function(String url) home,
  FutureOr<Reply?> Function(SeenRequest request)? handle,
  Future<void> Function(ServerSession session)? seed,
  List<Override> Function(String url)? overrides,
  Size? size,
  TargetPlatform? platform,
  bool settle = true,
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
    return ServerHarness(server, session);
  }))!;
  final url = harness.url;
  final appDb = memoryAppDatabase();
  addTearDown(appDb.close);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(appDb),
        serverSessionProvider(url).overrideWith((ref) async => harness.session),
        serverImageCachesProvider(url)
            .overrideWith((ref) => Completer<ServerImageCaches>().future),
        ...?overrides?.call(url),
      ],
      child: MaterialApp(theme: MatterleastApp.lightTheme, home: home(url)),
    ),
  );
  if (settle) await harness.settle(tester);
  return harness;
}
