import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/keyboard_shortcuts.dart';
import 'package:matterleast/app/permission_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/data/views/conversation_views.dart';
import 'package:matterleast/screens/channel/composer.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/channel/conversation_view.dart';
import 'package:matterleast/screens/channel/message_hover.dart';
import 'package:matterleast/screens/you/user_profile_sheet.dart';
import 'package:matterleast/ui/post_tile.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';
import '../support/tooltips.dart';

void main() {
  late FakeServer server;
  late ServerSession session;
  late Completer<void> olderAsked;
  late Completer<void> answerOlder;
  late int olderAsks;
  final opened = <String>[];

  /// What the next older page holds; a server error when null.
  List<int>? olderPage;

  final start = DateTime.utc(2026, 10, 26, 8);
  const linkRow = 50;
  const codeRow = 53;
  const mentionRow = 52;
  const systemRow = 51;
  const reactedRow = 58;
  var longRow = 60;
  final long = [for (var i = 1; i <= 60; i++) 'line $i'].join('\n\n');
  const code = 'ebb `low water` chart\n\n```\nhigh water\n```\n\nmessage end';
  const link = 'https://example.test/tide';
  Map<String, Object?> post(int i) => {
    'id': 'n$i',
    'channel_id': channelId,
    'user_id': 'someone',
    if (i == reactedRow)
      'metadata': {
        'reactions': [
          {
            'user_id': 'bobid',
            'post_id': 'n$i',
            'emoji_name': 'tada',
            'create_at': 1,
          },
        ],
      },
    if (i == systemRow) ...{
      'type': 'system_add_to_channel',
      'props': {'username': 'wren', 'addedUsername': 'bob'},
    },
    'create_at': start.add(Duration(minutes: i)).millisecondsSinceEpoch,
    'message': i == longRow
        ? long
        : switch (i) {
            linkRow => 'tide table at $link',
            codeRow => code,
            mentionRow => 'please ask @bob about it',
            systemRow => '@wren added @bob to the channel.',
            _ => 'message $i',
          },
  };

  Future<void> open(
    WidgetTester tester, {
    int count = 60,
    VoidCallback? onReplyToNewest,
    bool threads = true,
  }) async {
    HttpOverrides.global = null;
    olderAsked = Completer();
    answerOlder = Completer();
    olderAsks = 0;
    opened.clear();
    (server, session) = (await tester.runAsync(() async {
      final server = await FakeServer.start();
      final session = await testSession(server);
      await session.store.applyUsers([
        api.User.fromJson({'id': 'bobid', 'username': 'bob'}),
      ]);
      await session.store.applyChannelPage(
        channelId: channelId,
        page: api.PostList.fromJson({
          'order': [for (var i = count - 1; i >= 0; i--) 'n$i'],
          'posts': {for (var i = 0; i < count; i++) 'n$i': post(i)},
        }),
        kind: PageKind.page,
        requested: count,
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
          channelRightsProvider(url, channelId).overrideWith(
            (ref) => Stream.value((
              block: null,
              react: true,
              editOwn: true,
              editOthers: false,
              deleteOwn: true,
              deleteOthers: false,
              channelMentions: true,
              groupMentions: true,
            )),
          ),
          serverImageCachesProvider(url)
              .overrideWith((ref) => Completer<ServerImageCaches>().future),
        ],
        child: MaterialApp(
          theme: MatterleastApp.lightTheme,
          builder: onReplyToNewest == null
              ? null
              : (_, child) => AppShortcuts(child: child!),
          home: Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: ConversationView(
                    url: url,
                    conversation: conversationProvider(url, channelId),
                    startText: 'This is the start of Boats.',
                    onOpenThread: threads
                        ? (post, {reply = false}) => opened.add(post.id)
                        : null,
                  ),
                ),
                if (onReplyToNewest != null)
                  Composer(
                    url: url,
                    channelId: channelId,
                    teamId: 'team1',
                    hint: 'Write',
                    onReplyToNewest: onReplyToNewest,
                  ),
              ],
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

  testWidgets('closing a conversation saves where the reader was', (
    tester,
  ) async {
    await open(tester, count: 200);
    for (var i = 0; i < 4; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 400));
      await settle(tester);
    }
    expect(find.text('message 199'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    final facts = await tester.runAsync(
      () => ConversationViews(session.db).openFacts(channelId),
    );
    expect(facts!.saved, isNotNull, reason: 'the place is saved on close');
    await close(tester);
  });

  testWidgets('what the reader sends far up in a long conversation shows, '
      'and so does what comes after it', (tester) async {
    await open(tester, count: 200);
    for (var i = 0; i < 6; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 400));
      await settle(tester);
    }
    expect(find.text('message 199'), findsNothing);

    Future<void> arrive(String id, String message, int minute) =>
        tester.runAsync(
          () => session.store.queuePost(
            pendingPostId: id,
            channelId: channelId,
            rootId: '',
            userId: 'me',
            message: message,
            createAt: start.add(Duration(minutes: minute)),
          ),
        );
    final list = tester.getRect(find.byType(Scrollable).first);
    await arrive('p1', 'my reply', 300);
    await settle(tester);
    expect(find.text('my reply'), findsOneWidget);
    expect(
      tester.getBottomLeft(find.text('my reply')).dy,
      lessThan(list.bottom),
    );

    await arrive('p2', 'the next answer', 301);
    await settle(tester);
    expect(find.text('the next answer'), findsOneWidget);
    expect(
      tester.getBottomLeft(find.text('the next answer')).dy,
      lessThan(list.bottom),
    );
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

  for (final short in [false, true]) {
    testWidgets(
      'at the bottom, Show more opens the newest message downwards '
      'from where its top is${short ? ', in a short channel' : ''}',
      (tester) async {
        longRow = short ? 1 : 60;
        addTearDown(() => longRow = 60);
        await open(tester, count: short ? 2 : 61);
        olderPage = const [];
        answerOlder.complete();
        await settle(tester);
        double top() => tester.getTopLeft(find.text('line 1')).dy;
        final before = top();
        expect(find.text('Show more'), findsOneWidget);

        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(
          location: tester.getCenter(find.text('Show more')),
        );
        addTearDown(mouse.removePointer);
        await tester.pump(const Duration(milliseconds: 300));
        await mouse.down(tester.getCenter(find.text('Show more')));
        await tester.pump(const Duration(milliseconds: 50));
        await mouse.up();
        for (var i = 0; i < 15; i++) {
          await tester.pump(const Duration(milliseconds: 20));
          expect(top(), closeTo(before, 0.5), reason: 'frame $i');
        }
        await settle(tester);
        expect(top(), closeTo(before, 0.5));
        await close(tester);
      },
      variant: TargetPlatformVariant(const {
        TargetPlatform.android,
        TargetPlatform.linux,
      }),
    );
  }

  Future<void> tapMention(WidgetTester tester, String text, String name) async {
    await open(tester);
    answerOlder.complete();
    final row = find.textContaining(text, findRichText: true);
    for (var i = 0; i < 10 && row.evaluate().isEmpty; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, 300));
      await settle(tester);
    }
    final range = find.textRange.ofSubstring('@$name').evaluate().first;
    final box = range.renderObject
        .getBoxesForSelection(
          TextSelection(
            baseOffset: range.textRange.start,
            extentOffset: range.textRange.end,
          ),
        )
        .first;
    final at = range.renderObject.localToGlobal(box.toRect().center);
    final mouse = defaultTargetPlatform == TargetPlatform.android
        ? null
        : await tester.createGesture(kind: PointerDeviceKind.mouse);
    if (mouse == null) {
      await tester.tapAt(at);
    } else {
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(at);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await mouse.down(at);
      await tester.pump(const Duration(milliseconds: 80));
      await mouse.up();
    }
    await settle(tester);
  }

  for (final (label, text) in [
    ('a message', 'please ask'),
    ('a system message', 'added'),
  ]) {
    testWidgets(
      'tapping @bob in $label opens his profile, not the thread',
      (tester) async {
        await tapMention(tester, text, 'bob');
        expect(find.byType(UserProfileSheet), findsOneWidget);
        expect(opened, isEmpty);
        await close(tester);
      },
      variant: TargetPlatformVariant(const {
        TargetPlatform.android,
        TargetPlatform.linux,
      }),
    );
  }

  for (final variant in [TargetPlatform.android, TargetPlatform.linux]) {
    Future<void> press(
      WidgetTester tester,
      Offset from, {
      Offset by = Offset.zero,
    }) async {
      final mouse = variant == TargetPlatform.android
          ? null
          : await tester.createGesture(kind: PointerDeviceKind.mouse);
      final touch = mouse ?? await tester.startGesture(from);
      if (mouse != null) {
        await mouse.addPointer(location: from);
        addTearDown(mouse.removePointer);
        await mouse.moveTo(from);
        await tester.pump(const Duration(milliseconds: 300));
        await mouse.down(from);
      }
      await tester.pump(const Duration(milliseconds: 80));
      if (by != Offset.zero) {
        await touch.moveBy(by);
        await tester.pump(const Duration(milliseconds: 80));
      }
      await touch.up();
      await settle(tester);
    }

    testWidgets('a click on a message opens its thread', (tester) async {
      await open(tester);
      await press(tester, tester.getCenter(find.text('message 59')));
      expect(opened, ['n59']);
      await close(tester);
    }, variant: TargetPlatformVariant.only(variant));

    testWidgets('a click on a reaction toggles it and opens no thread', (
      tester,
    ) async {
      await open(tester);
      await press(tester, tester.getCenter(find.byType(FilterChip)));
      expect(opened, isEmpty);
      await close(tester);
    }, variant: TargetPlatformVariant.only(variant));

    testWidgets('a click in a thread opens nothing', (tester) async {
      await open(tester, threads: false);
      await press(tester, tester.getCenter(find.text('message 59')));
      expect(opened, isEmpty);
      await close(tester);
    }, variant: TargetPlatformVariant.only(variant));
  }

  testWidgets('dragging over a message to select its text opens no thread', (
    tester,
  ) async {
    await open(tester);
    final at = tester.getTopLeft(find.text('message 59')) + const Offset(2, 8);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: at);
    addTearDown(mouse.removePointer);
    await mouse.moveTo(at);
    await tester.pump(const Duration(milliseconds: 300));
    await mouse.down(at);
    await mouse.moveTo(at + const Offset(40, 0));
    await tester.pump(const Duration(milliseconds: 80));
    await mouse.up();
    await settle(tester);
    expect(opened, isEmpty);
    await close(tester);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  group('with a mouse on desktop', () {
    final desktop = TargetPlatformVariant.only(TargetPlatform.linux);

    Finder rowOf(String text) =>
        find.ancestor(of: find.text(text), matching: find.byType(MessageHover));

    Future<TestGesture> mouseAt(WidgetTester tester, Offset at) async {
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: at);
      addTearDown(mouse.removePointer);
      return mouse;
    }

    testWidgets('hovering a message shows its toolbar and keeps its height', (
      tester,
    ) async {
      await open(tester);
      final row = rowOf('message 57');
      final before = tester.getRect(row);
      expect(find.byTooltip('More actions'), findsNothing);

      await mouseAt(tester, tester.getCenter(find.text('message 57')));
      await settle(tester);

      expect(find.byTooltip('More actions'), findsOneWidget);
      expect(find.byTooltip('Reply'), findsNothing); // no thread here
      expect(find.byType(IconButton), findsWidgets);
      expect(untitledIconButtons(tester), isEmpty);
      expect(tester.getRect(row), before);
      expect(
        tester.getRect(find.text('message 58')).top,
        greaterThanOrEqualTo(before.bottom),
      );
      await close(tester);
    }, variant: desktop);

    testWidgets('the hover tint fades in a moment after the pointer', (
      tester,
    ) async {
      await open(tester);
      double tint() {
        final box = tester.widget<DecoratedBox>(
          find
              .descendant(
                of: rowOf('message 57'),
                matching: find.byWidgetPredicate(
                  (w) =>
                      w is DecoratedBox &&
                      w.position == DecorationPosition.foreground,
                ),
              )
              .first,
        );
        return switch (box.decoration) {
          BoxDecoration(:final color) => color?.a ?? 0,
          _ => 0,
        };
      }

      final full = Theme.of(tester.element(rowOf('message 57'))).hoverColor.a;
      await mouseAt(tester, tester.getCenter(find.text('message 57')));
      await tester.pump();
      expect(tint(), 0);
      await tester.pump(const Duration(milliseconds: 40));
      expect(tint(), greaterThan(0));
      expect(tint(), lessThan(full / 2));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tint(), closeTo(full, 0.001));
      await close(tester);
    }, variant: desktop);

    testWidgets('moving over the list rebuilds only the rows the mouse '
        'enters and leaves', (tester) async {
      await open(tester);
      final mouse = await mouseAt(tester, Offset.zero);
      await settle(tester);
      final rebuilt = <String>[];
      debugOnRebuildDirtyWidget = (element, _) {
        switch (element.widget) {
          case PostTile(:final post):
            rebuilt.add('tile ${post.message}');
          case MessageHover(:final target):
            rebuilt.add(target.post.message);
        }
      };
      addTearDown(() => debugOnRebuildDirtyWidget = null);
      for (final i in [54, 55, 56, 57]) {
        await mouse.moveTo(tester.getCenter(find.text('message $i')));
        await tester.pump();
      }
      debugOnRebuildDirtyWidget = null;

      expect(rebuilt.where((r) => r.startsWith('tile')), isEmpty);
      expect(rebuilt.toSet(), {
        for (final i in [54, 55, 56, 57]) 'message $i',
      });
      await close(tester);
    }, variant: desktop);

    testWidgets('the keyboard reaches a message and its toolbar; Esc leaves '
        'it, and other rows stay as they are', (tester) async {
      await open(tester);
      expect(find.byTooltip('More actions'), findsNothing);
      final rebuilt = <String>[];
      debugOnRebuildDirtyWidget = (element, _) {
        switch (element.widget) {
          case PostTile(:final post):
            rebuilt.add('tile ${post.message}');
          case MessageHover(:final target):
            rebuilt.add(target.post.message);
        }
      };
      addTearDown(() => debugOnRebuildDirtyWidget = null);
      final row = tester.widget<Focus>(
        find.descendant(
          of: rowOf('message 57'),
          matching: find.byWidgetPredicate(
            (w) => w is Focus && w.focusNode?.debugLabel == 'Message',
          ),
        ),
      );
      row.focusNode!.requestFocus();
      await tester.pump();
      await tester.pump();
      debugOnRebuildDirtyWidget = null;
      expect(find.byTooltip('More actions'), findsOneWidget);
      expect(rebuilt.where((r) => r.startsWith('tile')), isEmpty);
      expect(rebuilt.toSet(), {'message 57'});

      bool inToolbar() =>
          FocusManager.instance.primaryFocus?.context
              ?.findAncestorWidgetOfExactType<MessageToolbar>() !=
          null;
      for (var i = 0; i < 6 && !inToolbar(); i++) {
        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pump();
        await tester.pump();
      }
      expect(inToolbar(), isTrue);
      expect(find.byTooltip('More actions'), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.pump();
      expect(find.byTooltip('More actions'), findsNothing);
      expect(row.focusNode!.hasFocus, isFalse);
      await close(tester);
    }, variant: desktop);

    testWidgets('a right click on a message opens its menu at the pointer', (
      tester,
    ) async {
      await open(tester);
      final at = tester.getCenter(find.text('message 57'));
      await tester.tapAt(
        at,
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await settle(tester);

      expect(find.text('Copy text'), findsOneWidget);
      expect(find.byType(BottomSheet), findsNothing);
      // A popup next to the pointer, not a sheet at the bottom.
      final entry = tester.getCenter(find.text('Copy text'));
      expect((entry - at).distance, lessThan(300));
      await close(tester);
    }, variant: desktop);

    testWidgets('dragging over a message selects its text for the menu', (
      tester,
    ) async {
      await open(tester);
      final text = tester.getRect(find.text('message 57'));
      final drag = await tester.startGesture(
        text.centerLeft + const Offset(1, 0),
        kind: PointerDeviceKind.mouse,
      );
      await drag.moveTo(text.center);
      await drag.moveTo(text.centerRight - const Offset(1, 0));
      await drag.up();
      await settle(tester);
      await tester.tapAt(
        text.center,
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await settle(tester);

      expect(find.text('Copy selection'), findsOneWidget);
      await close(tester);
    }, variant: desktop);

    testWidgets('a selection across a message takes in its code', (
      tester,
    ) async {
      String? copied;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          if (call.method == 'Clipboard.setData') {
            copied = (call.arguments as Map)['text'] as String?;
          }
          return null;
        },
      );
      await open(tester);
      final from = tester.getTopLeft(find.textContaining('ebb'));
      final to = tester.getBottomRight(find.text('message end'));
      final drag = await tester.startGesture(
        from + const Offset(1, 2),
        kind: PointerDeviceKind.mouse,
      );
      await drag.moveTo(from + const Offset(40, 20));
      await drag.moveTo(to - const Offset(1, 2));
      await drag.up();
      await settle(tester);
      await tester.tapAt(
        to - const Offset(10, 4),
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await settle(tester);
      await tester.tap(find.text('Copy selection'));
      await settle(tester);

      // The selection is drawn under the text; inline code must not cover
      // it.
      Color? codeShade;
      tester.widget<Text>(find.textContaining('ebb')).textSpan!.visitChildren((
        span,
      ) {
        if (span case TextSpan(text: 'low water', :final style?)) {
          codeShade = style.backgroundColor;
        }
        return true;
      });
      expect(codeShade!.a, lessThan(1));
      expect(copied, contains('low water'));
      expect(copied, contains('high water'));
      expect(copied, contains('message end'));
      await close(tester);
    }, variant: desktop);

    testWidgets('a click on a link opens it and moves nothing', (tester) async {
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

      final range = find.textRange.ofSubstring(link).evaluate().single;
      final onLink = range.renderObject.localToGlobal(
        range.renderObject
            .getBoxesForSelection(
              TextSelection(
                baseOffset: range.textRange.start,
                extentOffset: range.textRange.end,
              ),
            )
            .first
            .toRect()
            .center,
      );
      await tester.tapAt(onLink, kind: PointerDeviceKind.mouse);
      await settle(tester);

      expect(launched, [link]);
      for (final i in rows) {
        expect(
          tester.getTopLeft(find.text('message $i')).dy,
          closeTo(before[i]!, 0.5),
          reason: 'message $i',
        );
      }

      await tester.tapAt(
        onLink,
        kind: PointerDeviceKind.mouse,
        buttons: kSecondaryMouseButton,
      );
      await settle(tester);
      expect(find.text('Open link'), findsNothing);
      expect(find.text('Copy link'), findsOneWidget);
      expect(find.text('Copy text'), findsNothing);
      await close(tester);
    }, variant: desktop);

    testWidgets('a click never marks a message unread, whatever the Alt '
        'key looks like', (tester) async {
      await open(tester);
      final unread = <String>[];
      final inner = server.handle;
      server.handle = (r) {
        if (r.path.endsWith('/set_unread')) unread.add(r.path);
        return inner(r);
      };
      // Alt went down in another window and its release never arrived.
      await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
      await tester.tapAt(
        tester.getCenter(find.text('message 57')),
        kind: PointerDeviceKind.mouse,
      );
      await settle(tester);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
      expect(unread, isEmpty);
      await close(tester);
    }, variant: desktop);

    testWidgets('Shift+Up in an empty composer replies to the newest '
        'message, and moves the caret once there is text', (tester) async {
      var replies = 0;
      await open(tester, onReplyToNewest: () => replies++);
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      expect(replies, 1);

      await tester.enterText(find.byType(EditableText), 'draft');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      expect(replies, 1);
      await close(tester);
    }, variant: desktop);

    testWidgets('a middle click on a link opens it', (tester) async {
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
      final range = find.textRange.ofSubstring(link).evaluate().single;
      final onLink = range.renderObject.localToGlobal(
        range.renderObject
            .getBoxesForSelection(
              TextSelection(
                baseOffset: range.textRange.start,
                extentOffset: range.textRange.end,
              ),
            )
            .first
            .toRect()
            .center,
      );
      await tester.tapAt(
        onLink,
        kind: PointerDeviceKind.mouse,
        buttons: kMiddleMouseButton,
      );
      await settle(tester);
      expect(launched, [link]);
      await close(tester);
    }, variant: desktop);

    testWidgets('a message does not swipe open its menu', (tester) async {
      await open(tester);
      // From the margin, where no text selection takes the drag.
      final row = tester.getRect(rowOf('message 57'));
      await tester.dragFrom(
        Offset(row.left + 4, row.center.dy),
        const Offset(-120, 0),
      );
      await settle(tester);
      expect(find.text('Copy text'), findsNothing);
      await close(tester);
    }, variant: desktop);

    testWidgets('a touch shows no toolbar', (tester) async {
      await open(tester);
      await tester.tap(find.text('message 57'));
      await settle(tester);
      expect(find.byTooltip('More actions'), findsNothing);
      await close(tester);
    }, variant: desktop);
  });

  testWidgets('on a phone a mouse gets no toolbar and no right-click menu', (
    tester,
  ) async {
    await open(tester);
    final at = tester.getCenter(find.text('message 57'));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: at);
    addTearDown(mouse.removePointer);
    await settle(tester);
    expect(find.byTooltip('More actions'), findsNothing);

    await tester.tapAt(
      at,
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryMouseButton,
    );
    await settle(tester);
    expect(find.text('Copy text'), findsNothing);

    await tester.drag(find.text('message 57'), const Offset(-120, 0));
    await settle(tester);
    expect(find.text('Copy text'), findsOneWidget);
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
