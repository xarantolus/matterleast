import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/channel/composer.dart';
import 'package:matterleast/screens/channel/composer_controller.dart';
import 'package:matterleast/screens/channel/composer_desktop.dart';
import 'package:matterleast/screens/channel/composer_keys.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/screens/root/rail_selection.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

/// Remembers what was picked without touching settings.
class _Rail extends RailSelection {
  @override
  RailTarget? build() => null;

  @override
  void select(RailTarget? target) => state = target;
}

ComposerKey? press(
  LogicalKeyboardKey key, {
  bool shift = false,
  bool control = false,
  bool enterSends = true,
  bool composing = false,
  bool open = false,
  bool editing = false,
  bool empty = false,
  bool desktop = true,
}) => composerKey(
  key: key,
  shift: shift,
  control: control,
  alt: false,
  meta: false,
  enterSends: enterSends,
  composing: composing,
  suggestionsOpen: open,
  editing: editing,
  empty: empty,
  desktop: desktop,
);

void main() {
  group('composerKey', () {
    test('Enter sends where a hardware keyboard sends with it', () {
      expect(press(LogicalKeyboardKey.enter), ComposerKey.send);
      expect(press(LogicalKeyboardKey.enter, enterSends: false), isNull);
    });

    test('Shift+Enter is left to the field, which makes a new line', () {
      expect(press(LogicalKeyboardKey.enter, shift: true), isNull);
    });

    test('Ctrl+Enter sends on every keyboard', () {
      expect(
        press(LogicalKeyboardKey.enter, control: true, enterSends: false),
        ComposerKey.send,
      );
    });

    test('nothing is sent or moved while an IME composes', () {
      for (final key in [
        LogicalKeyboardKey.enter,
        LogicalKeyboardKey.tab,
        LogicalKeyboardKey.arrowDown,
        LogicalKeyboardKey.escape,
      ]) {
        expect(press(key, composing: true, open: true), isNull);
      }
    });

    test('with suggestions open Enter and Tab accept, arrows move, Esc '
        'closes', () {
      expect(
        press(LogicalKeyboardKey.enter, open: true),
        ComposerKey.acceptSuggestion,
      );
      expect(
        press(LogicalKeyboardKey.tab, open: true),
        ComposerKey.acceptSuggestion,
      );
      expect(
        press(LogicalKeyboardKey.arrowDown, open: true),
        ComposerKey.nextSuggestion,
      );
      expect(
        press(LogicalKeyboardKey.arrowUp, open: true),
        ComposerKey.previousSuggestion,
      );
      expect(
        press(LogicalKeyboardKey.escape, open: true),
        ComposerKey.closeSuggestions,
      );
      expect(
        press(LogicalKeyboardKey.enter, open: true, control: true),
        ComposerKey.send,
      );
    });

    test('Tab and the down arrow are the field\'s without suggestions', () {
      expect(press(LogicalKeyboardKey.tab), isNull);
      expect(press(LogicalKeyboardKey.arrowDown), isNull);
    });

    test('Up in an empty field edits the last message on desktop only', () {
      expect(
        press(LogicalKeyboardKey.arrowUp, empty: true),
        ComposerKey.editLast,
      );
      expect(press(LogicalKeyboardKey.arrowUp), isNull);
      expect(
        press(LogicalKeyboardKey.arrowUp, empty: true, editing: true),
        isNull,
      );
      expect(
        press(LogicalKeyboardKey.arrowUp, empty: true, desktop: false),
        isNull,
      );
    });

    test('Esc stops editing, else leaves the field on desktop', () {
      expect(
        press(LogicalKeyboardKey.escape, editing: true),
        ComposerKey.stopEditing,
      );
      expect(press(LogicalKeyboardKey.escape), ComposerKey.blur);
      expect(press(LogicalKeyboardKey.escape, desktop: false), isNull);
    });

    test('the highlight wraps around', () {
      expect(movedHighlight(0, -1, 3), 2);
      expect(movedHighlight(2, 1, 3), 0);
      expect(movedHighlight(0, 1, 0), 0);
    });
  });

  group('in the composer', () {
    late FakeServer server;
    late ServerSession session;
    final unhandled = <LogicalKeyboardKey>[];

    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.linux);

    Future<void> settle(WidgetTester tester) async {
      for (var i = 0; i < 15; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    Future<void> start(WidgetTester tester) async {
      HttpOverrides.global = null;
      unhandled.clear();
      (server, session) = (await tester.runAsync(() async {
        final server = await FakeServer.start();
        server.handle = (r) => ok(
          r.method == 'POST' && r.path == '/api/v4/posts'
              ? {
                  'id': 'sent1',
                  'channel_id': channelId,
                  'user_id': meId,
                  'create_at': DateTime.now().millisecondsSinceEpoch,
                  'message': r.body['message'],
                  'pending_post_id': r.body['pending_post_id'],
                }
              : const <String, Object?>{},
        );
        final session = await testSession(server);
        await session.store.applyChannelPage(
          channelId: channelId,
          page: api.PostList.fromJson({
            'order': ['mine1'],
            'posts': {
              'mine1': {
                'id': 'mine1',
                'channel_id': channelId,
                'user_id': meId,
                'create_at': DateTime.now().millisecondsSinceEpoch,
                'message': 'on my way',
              },
            },
          }),
          kind: PageKind.page,
        );
        await session.store.applyRoles([
          api.Role.fromJson({
            'id': 'rl000000000000000000000r01',
            'name': 'system_user',
            'permissions': ['create_post', 'edit_post'],
          }),
        ]);
        await session.db.setSyncText(SyncKeys.currentUserRoles, 'system_user');
        return (server, session);
      }))!;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            railSelectionProvider.overrideWith(_Rail.new),
            serverSessionProvider(server.url.toString())
                .overrideWith((ref) async => session),
            serverImageCachesProvider(server.url.toString())
                .overrideWith((ref) => Completer<ServerImageCaches>().future),
          ],
          child: Consumer(
            builder: (context, ref, _) => MaterialApp(
              theme: MatterleastApp.lightTheme,
              navigatorObservers: [ref.watch(conversationRoutesProvider)],
              builder: (context, child) => Focus(
                // What no field handled, which the platform then types.
                onKeyEvent: (_, event) {
                  if (event is KeyDownEvent) unhandled.add(event.logicalKey);
                  return KeyEventResult.ignored;
                },
                child: child!,
              ),
              home: const Scaffold(body: SizedBox.expand()),
            ),
          ),
        ),
      );
      unawaited(
        openConversation(
          tester.state<NavigatorState>(find.byType(Navigator).first),
          url: server.url.toString(),
          channelId: channelId,
          title: 'Boats',
          teamId: teamId,
        ),
      );
      await settle(tester);
      await tester.tap(find.byType(TextField));
      await tester.pump();
    }

    Future<void> finish(WidgetTester tester) async {
      debugDefaultTargetPlatformOverride = null;
      tester.state<NavigatorState>(find.byType(Navigator).first).pop();
      await settle(tester);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() async {
        await session.outbox.close();
        await session.connection.close();
        session.users.close();
        session.runner.close();
        session.api.close();
        await session.db.close().timeout(const Duration(seconds: 5));
        await server.close();
      });
    }

    String text(WidgetTester tester) =>
        tester.widget<TextField>(find.byType(TextField)).controller!.text;

    /// Messages queued to be sent.
    Future<int> queued(WidgetTester tester) => tester
        .runAsync(
          () async => (await session.db.select(session.db.outbox).get()).length,
        )
        .then((n) => n!);

    testWidgets('Enter sends and Shift+Enter is left for a new line', (
      tester,
    ) async {
      await start(tester);
      await tester.enterText(find.byType(TextField), 'ahoy');
      await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
      await settle(tester);
      expect(await queued(tester), 0);
      expect(text(tester), 'ahoy');
      expect(unhandled, contains(LogicalKeyboardKey.enter));

      unhandled.clear();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);
      expect(unhandled, isEmpty);
      expect(text(tester), isEmpty);
      expect(await queued(tester), 1);
      await finish(tester);
    });

    testWidgets('Enter does not send while an IME composes', (tester) async {
      await start(tester);
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'ni',
          selection: TextSelection.collapsed(offset: 2),
          composing: TextRange(start: 0, end: 2),
        ),
      );
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await settle(tester);
      expect(await queued(tester), 0);
      expect(text(tester), 'ni');
      await finish(tester);
    });

    testWidgets('Tab accepts the highlighted suggestion, the arrows move '
        'it and Esc closes the list', (tester) async {
      await start(tester);
      await tester.enterText(find.byType(TextField), ':smil');
      await settle(tester);
      ListTile row(int i) => tester.widget<ListTile>(
        find
            .descendant(
              of: find.byType(SuggestionList),
              matching: find.byType(ListTile),
            )
            .at(i),
      );
      expect(row(0).selected, isTrue);
      expect(row(1).selected, isFalse);

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pump();
      expect(row(0).selected, isFalse);
      expect(row(1).selected, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pump();
      expect(row(0).selected, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await settle(tester);
      expect(find.byType(SuggestionList), findsNothing);
      expect(text(tester), ':smil');

      await tester.enterText(find.byType(TextField), ':smile');
      await settle(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await settle(tester);
      expect(text(tester), startsWith('😄'));
      expect(await queued(tester), 0);
      await finish(tester);
    });

    Future<void> dropOnPane(WidgetTester tester, List<String> paths) async {
      const codec = StandardMethodCodec();
      Future<void> send(String method, Object? args) async {
        await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'desktop_drop',
          codec.encodeMethodCall(MethodCall(method, args)),
          (_) {},
        );
      }

      await send('entered', [100.0, 100.0]);
      await send('exited', [100.0, 100.0]);
      await send('performOperation_linux', [
        paths.map((p) => Uri.file(p).toString()).join('\n'),
        [100.0, 100.0],
      ]);
      await settle(tester);
    }

    Future<List<String>> makeFiles(WidgetTester tester, int count) async {
      final dir = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('drop'),
      ))!;
      addTearDown(() => dir.deleteSync(recursive: true));
      return [
        for (var i = 0; i < count; i++)
          (File('${dir.path}/note$i.txt')..writeAsStringSync('hello $i')).path,
      ];
    }

    testWidgets('files dropped on the pane attach to the message', (
      tester,
    ) async {
      await start(tester);
      await dropOnPane(tester, await makeFiles(tester, 2));
      expect(find.text('note0.txt'), findsOneWidget);
      expect(find.text('note1.txt'), findsOneWidget);
      await finish(tester);
    });

    testWidgets('a drop stops at ten files and says so', (tester) async {
      await start(tester);
      await dropOnPane(tester, await makeFiles(tester, 12));
      final attached = ProviderScope.containerOf(
        tester.element(find.byType(TextField)),
      ).read(composerDraftProvider(server.url.toString(), channelId, ''));
      expect(attached.attachments, hasLength(maxAttachments));
      expect(
        find.text('A message can carry $maxAttachments files at most.'),
        findsOneWidget,
      );
      await finish(tester);
    });

    testWidgets('typing with nothing focused starts the message', (
      tester,
    ) async {
      await start(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      expect(FocusManager.instance.primaryFocus?.hasPrimaryFocus, isTrue);
      expect(textHasFocus(), isFalse);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyH, character: 'h');
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyH);
      await tester.pump();
      expect(text(tester), 'h');
      expect(textHasFocus(), isTrue);
      await finish(tester);
    });

    testWidgets('typing with Ctrl held or a dialog open leaves the field', (
      tester,
    ) async {
      await start(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyH, character: 'h');
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyH);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(text(tester), isEmpty);

      unawaited(
        showDialog<void>(
          context: tester.element(find.byType(TextField)),
          builder: (_) => const AlertDialog(content: Text('Sure?')),
        ),
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyH, character: 'h');
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyH);
      await tester.pump();
      expect(text(tester), isEmpty);
      Navigator.of(tester.element(find.text('Sure?'))).pop();
      await tester.pump(const Duration(milliseconds: 400));
      await finish(tester);
    });

    testWidgets('Up in an empty composer edits the last own message', (
      tester,
    ) async {
      await start(tester);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await settle(tester);
      expect(text(tester), 'on my way');
      await finish(tester);
    });
  });

  group('on desktop', () {
    test('the + sheet has no camera', () {
      expect(pickSources(desktop: true).map((c) => c.$1), [
        PickSource.media,
        PickSource.files,
      ]);
      expect(
        pickSources(desktop: false).map((c) => c.$1),
        contains(PickSource.camera),
      );
    });

    test('a pasted image is taken only without text beside it', () async {
      final png = Uint8List.fromList([1, 2, 3]);
      Future<Uint8List?> image() async => png;
      expect(await clipboardImage(image, () async => null), png);
      expect(await clipboardImage(image, () async => ''), png);
      expect(await clipboardImage(image, () async => 'cells'), isNull);
      expect(await clipboardImage(() async => null, () async => null), isNull);
    });

    test('a dropped name is cut to its last part', () {
      expect(baseName('/home/a/../b/x.png'), 'x.png');
      expect(baseName(r'C:\\dir\\y.png'), 'y.png');
    });

    test('typing needs a printable character and no shortcut', () {
      bool types({
        String? c = 'a',
        bool control = false,
        bool text = false,
        bool route = true,
      }) => typesIntoComposer(
        character: c,
        control: control,
        alt: false,
        meta: false,
        textFocused: text,
        otherFocused: false,
        routeCurrent: route,
      );
      expect(types(), isTrue);
      expect(types(c: null), isFalse);
      expect(types(c: '\n'), isFalse);
      expect(types(control: true), isFalse);
      expect(types(text: true), isFalse);
      expect(types(route: false), isFalse);
    });

    test('a typed character goes at the cursor', () {
      const value = TextEditingValue(
        text: 'ac',
        selection: TextSelection.collapsed(offset: 1),
      );
      final typed = typedInto(value, 'b');
      expect(typed.text, 'abc');
      expect(typed.selection.baseOffset, 2);
    });
  });
}
