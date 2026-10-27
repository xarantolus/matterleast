import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
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
  late int olderAsks;

  /// What the next older page holds; a server error when null.
  List<int>? olderPage;

  final start = DateTime.utc(2026, 10, 26, 8);
  const linkRow = 50;
  const link = 'https://example.test/tide';
  Map<String, Object?> post(int i) => {
    'id': 'n$i',
    'channel_id': channelId,
    'user_id': 'someone',
    'create_at': start.add(Duration(minutes: i)).millisecondsSinceEpoch,
    'message': i == linkRow ? 'tide table at $link' : 'message $i',
  };

  Future<void> open(WidgetTester tester) async {
    HttpOverrides.global = null;
    olderAsked = Completer();
    answerOlder = Completer();
    olderAsks = 0;
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
            olderAsks++;
            if (!olderAsked.isCompleted) olderAsked.complete();
            await answerOlder.future;
            final page = olderPage;
            if (page == null) return error(500, 'app.post.get_posts.app_error');
            olderPage = null;
            return ok({
              'order': [for (final i in page) 'n$i'],
              'posts': {for (final i in page) 'n$i': post(i)},
            });
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
          serversProvider.overrideWith((ref) => Stream.value(const [])),
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

  testWidgets('an older page at the top leaves the reader where they were', (
    tester,
  ) async {
    olderPage = [for (var i = -1; i >= -60; i--) i];
    await open(tester);
    while (!olderAsked.isCompleted) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 400));
      await settle(tester);
    }
    // Up to the oldest message, as a reader waiting for more would be.
    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, 800),
      3000,
    );
    await settle(tester);
    final shown = [
      for (var i = 0; i < 60; i++)
        if (find.text('message $i').evaluate().isNotEmpty) i,
    ];
    expect(shown, contains(0));
    final before = {
      for (final i in shown) i: tester.getTopLeft(find.text('message $i')).dy,
    };

    answerOlder.complete();
    await settle(tester);

    // The oldest message lost its name and avatar to the ones above it.
    for (final i in shown.where((i) => i > 0)) {
      expect(
        tester.getTopLeft(find.text('message $i')).dy,
        closeTo(before[i]!, 0.5),
        reason: 'message $i',
      );
    }
    expect(olderAsks, 1);
    await close(tester);
  });

  testWidgets('a conversation meets the tap target, label and contrast '
      'guidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    await open(tester);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    semantics.dispose();
    await close(tester);
  });

  testWidgets('a list at rest asks for no frames', (tester) async {
    await open(tester);
    expect(find.text('message 59'), findsOneWidget);
    expect(tester.binding.hasScheduledFrame, isFalse);
    await close(tester);
  });

  testWidgets('the start of the channel takes the place of the spinner', (
    tester,
  ) async {
    olderPage = [];
    await open(tester);
    while (!olderAsked.isCompleted) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 400));
      await settle(tester);
    }
    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, 800),
      3000,
    );
    await settle(tester);
    final spinner = find.bySemanticsLabel('Loading older messages');
    expect(tester.getTopLeft(spinner).dy, greaterThanOrEqualTo(0));
    final oldest = tester.getTopLeft(find.text('message 0')).dy;

    answerOlder.complete();
    await settle(tester);

    expect(find.text('This is the start of Boats.'), findsOneWidget);
    expect(tester.getTopLeft(find.text('message 0')).dy, closeTo(oldest, 0.5));
    // Still at the top: nothing of the start text is hidden above.
    await tester.fling(
      find.byType(Scrollable).first,
      const Offset(0, 300),
      3000,
    );
    await settle(tester);
    expect(tester.getTopLeft(find.text('message 0')).dy, closeTo(oldest, 0.5));
    await close(tester);
  });

  testWidgets('tapping a link in a message opens it and moves nothing', (
    tester,
  ) async {
    final launched = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/url_launcher'),
      (call) async {
        if (call.method == 'canLaunch') return true;
        launched.add((call.arguments as Map)['url'] as String);
        return true;
      },
    );
    await open(tester);
    answerOlder.complete();
    final linkText = find.textContaining('tide table');
    for (var i = 0; i < 10 && linkText.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 300));
      await settle(tester);
    }
    await tester.drag(find.byType(Scrollable).first, const Offset(0, 150));
    await settle(tester);
    final rows = [
      for (var i = 0; i < 60; i++)
        if (find.text('message $i').evaluate().isNotEmpty) i,
    ];
    final before = {
      for (final i in rows) i: tester.getTopLeft(find.text('message $i')).dy,
    };

    await tester.tapOnText(find.textRange.ofSubstring(link));
    await settle(tester);

    expect(launched, [link]);
    for (final i in rows) {
      expect(
        tester.getTopLeft(find.text('message $i')).dy,
        closeTo(before[i]!, 0.5),
        reason: 'message $i',
      );
    }
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
