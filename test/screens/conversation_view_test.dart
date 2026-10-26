import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/channel/conversation_view.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

void main() {
  late FakeServer server;
  late ServerSession session;
  late Completer<void> olderAsked;
  late Completer<void> answerOlder;

  final start = DateTime.utc(2026, 10, 26, 8);
  Map<String, Object?> post(int i) => {
    'id': 'n$i',
    'channel_id': channelId,
    'user_id': 'someone',
    'create_at': start.add(Duration(minutes: i)).millisecondsSinceEpoch,
    'message': 'message $i',
  };

  Future<void> open(WidgetTester tester) async {
    HttpOverrides.global = null;
    olderAsked = Completer();
    answerOlder = Completer();
    (server, session) = (await tester.runAsync(() async {
      final server = await FakeServer.start();
      final session = await testSession(server);
      await session.store.applyChannelPage(
        channelId: channelId,
        page: api.PostList.fromJson({
          'order': [for (var i = 59; i >= 0; i--) 'n$i'],
          'posts': {for (var i = 0; i < 60; i++) 'n$i': post(i)},
        }),
        kind: PageKind.page,
        requested: 60,
      );
      server.handle = (r) async {
        if (r.path == '/api/v4/channels/$channelId/posts') {
          if (r.raw.uri.queryParameters.containsKey('before')) {
            if (!olderAsked.isCompleted) olderAsked.complete();
            await answerOlder.future;
            return error(500, 'app.post.get_posts.app_error');
          }
          return ok({'order': <String>[], 'posts': <String, Object?>{}});
        }
        if (r.path == '/api/v4/users/ids') return ok(<Object?>[]);
        return ok(<String, Object?>{});
      };
      return (server, session);
    }))!;
    final url = server.url.toString();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serverSessionProvider(url).overrideWith((ref) async => session),
          serverImageCachesProvider(url)
              .overrideWith((ref) => Completer<ServerImageCaches>().future),
        ],
        child: MaterialApp(
          theme: MatterleastApp.lightTheme,
          home: Scaffold(
            body: ConversationView(
              url: url,
              conversation: conversationProvider(url, channelId),
              startText: 'This is the start of Boats.',
            ),
          ),
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    await tester.runAsync(() async {
      await closeTestSession(session);
      await server.close();
    });
  }

  testWidgets('a failed older page leaves the reader where they were', (
    tester,
  ) async {
    await open(tester);
    expect(find.text('message 59'), findsOneWidget);

    while (!olderAsked.isCompleted) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 400));
      await settle(tester);
    }
    final reading = find.text('message ${topVisible(tester)}');
    final before = tester.getTopLeft(reading).dy;

    answerOlder.complete();
    await settle(tester);

    expect(tester.getTopLeft(reading).dy, closeTo(before, 0.5));
    expect(find.text('message 59'), findsNothing);

    final notice = find.textContaining("Couldn't load older messages");
    for (var i = 0; i < 10 && notice.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 400));
      for (var j = 0; j < 5; j++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    }
    expect(notice, findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    await close(tester);
  });
}

/// The number of the topmost message on screen.
int topVisible(WidgetTester tester) {
  final shown = [
    for (var i = 0; i < 60; i++)
      if (find.text('message $i').evaluate().isNotEmpty &&
          tester.getTopLeft(find.text('message $i')).dy >= 0)
        i,
  ];
  return shown.reduce(
    (a, b) =>
        tester.getTopLeft(find.text('message $a')).dy <=
            tester.getTopLeft(find.text('message $b')).dy
        ? a
        : b,
  );
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 10; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 100));
  }
}
