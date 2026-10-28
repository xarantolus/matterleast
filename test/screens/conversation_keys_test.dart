import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/keyboard_shortcuts.dart';
import 'package:matterleast/app/permission_providers.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/screens/channel/composer.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/channel/conversation_keys.dart';
import 'package:matterleast/screens/channel/conversation_view.dart';
import 'package:matterleast/ui/focus_region.dart';
import 'package:matterleast/ui/post_tile.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

const _viewPath = '/api/v4/channels/members/me/view';

Future<void> _press(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool control = false,
  bool shift = false,
  bool alt = false,
}) async {
  if (control) await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  if (alt) await tester.sendKeyDownEvent(LogicalKeyboardKey.altLeft);
  await tester.sendKeyEvent(key);
  if (alt) await tester.sendKeyUpEvent(LogicalKeyboardKey.altLeft);
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  if (control) await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
  await tester.pump();
}

void main() {
  final desktop = TargetPlatformVariant.only(TargetPlatform.linux);
  late ServerHarness h;
  var dismissed = 0;

  Future<void> open(WidgetTester tester) async {
    dismissed = 0;
    h = await pumpWithServer(
      tester,
      size: const Size(900, 700),
      seed: (session) => session.store.applyChannelPage(
        channelId: channelId,
        page: api.PostList.fromJson({
          'order': ['n2', 'n1', 'n0'],
          'posts': {
            for (var i = 0; i < 3; i++)
              'n$i': {
                'id': 'n$i',
                'channel_id': channelId,
                'user_id': 'someone',
                'create_at': DateTime.utc(
                  2026,
                  10,
                  26,
                  8,
                  i,
                ).millisecondsSinceEpoch,
                'message': 'message $i',
              },
          },
        }),
        kind: PageKind.page,
        requested: 3,
      ),
      handle: (r) {
        if (r.path.endsWith('/posts')) {
          return ok({'order': <String>[], 'posts': <String, Object?>{}});
        }
        if (r.path == '/api/v4/users/ids') return ok(<Object?>[]);
        return ok(<String, Object?>{});
      },
      overrides: (url) => [
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
      ],
      home: (url) => AppShortcuts(
        child: Scaffold(
          body: Actions(
            // What Esc does when the conversation has nothing to mark read.
            actions: {
              DismissIntent: EnabledAction<DismissIntent>(
                enabled: () => true,
                onInvoke: (_) => dismissed++,
              ),
            },
            child: ConversationKeys(
              conversation: conversationProvider(url, channelId),
              isThread: false,
              builder: (composerFocus) => Column(
                children: [
                  Expanded(
                    child: FocusRegion(
                      entry: RegionEntry.self,
                      child: ConversationView(
                        url: url,
                        conversation: conversationProvider(url, channelId),
                        startText: 'Start',
                      ),
                    ),
                  ),
                  Composer(
                    url: url,
                    channelId: channelId,
                    teamId: teamId,
                    hint: 'Write',
                    focusNode: composerFocus,
                    ownTexts: () => ['third', 'second', 'first'],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The reader has the keyboard in the message list.
  Future<void> focusList(WidgetTester tester) async {
    tester
        .widget<Focus>(
          find.byWidgetPredicate(
            (w) => w is Focus && w.focusNode?.debugLabel == 'Region',
          ),
        )
        .focusNode!
        .requestFocus();
    await tester.pump();
  }

  FocusNode field(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText)).focusNode;

  String text(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText)).controller.text;

  Future<void> select(
    WidgetTester tester,
    String value,
    int from,
    int to,
  ) async {
    tester.testTextInput.updateEditingValue(
      TextEditingValue(
        text: value,
        selection: TextSelection(baseOffset: from, extentOffset: to),
      ),
    );
    await tester.pump();
  }

  testWidgets('Ctrl+Shift+L puts the cursor in the message field', (
    tester,
  ) async {
    await open(tester);
    await focusList(tester);
    expect(field(tester).hasFocus, isFalse);
    await _press(tester, LogicalKeyboardKey.keyL, control: true, shift: true);
    expect(field(tester).hasFocus, isTrue);
    await h.close(tester);
  }, variant: desktop);

  testWidgets('Esc marks a channel with a new-messages line read, and only '
      'then goes on to what closes things', (tester) async {
    await open(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ConversationView)),
    );
    final provider = conversationProvider(h.url, channelId);
    final post = container
        .read(provider)
        .rows
        .whereType<MessageRow>()
        .first
        .post;
    container.read(provider.notifier).markedUnread(post);
    await focusList(tester);
    await h.settle(tester);
    expect(find.byType(NewMessagesTile), findsOneWidget);
    final views = h.server.paths.where((p) => p == _viewPath).length;

    await _press(tester, LogicalKeyboardKey.escape);
    await h.settle(tester);
    expect(find.byType(NewMessagesTile), findsNothing);
    expect(h.server.paths.where((p) => p == _viewPath).length, views + 1);
    expect(dismissed, 0);

    await _press(tester, LogicalKeyboardKey.escape);
    expect(dismissed, 1);
    await h.close(tester);
  }, variant: desktop);

  group('formatting', () {
    testWidgets('Ctrl+B, Ctrl+I and Ctrl+Shift+X wrap the selection, and '
        'press again to unwrap', (tester) async {
      await open(tester);
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await select(tester, 'hello', 0, 5);
      await _press(tester, LogicalKeyboardKey.keyB, control: true);
      expect(text(tester), '**hello**');
      await _press(tester, LogicalKeyboardKey.keyB, control: true);
      expect(text(tester), 'hello');
      await _press(tester, LogicalKeyboardKey.keyI, control: true);
      expect(text(tester), '_hello_');
      await _press(tester, LogicalKeyboardKey.keyI, control: true);
      await _press(tester, LogicalKeyboardKey.keyX, control: true, shift: true);
      expect(text(tester), '~~hello~~');
      await h.close(tester);
    }, variant: desktop);

    testWidgets('Ctrl+Alt+K makes a link with the url selected', (
      tester,
    ) async {
      await open(tester);
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await select(tester, 'docs', 0, 4);
      await _press(tester, LogicalKeyboardKey.keyK, control: true, alt: true);
      expect(text(tester), '[docs](url)');
      await h.close(tester);
    }, variant: desktop);

    testWidgets('nothing is formatted while the field has no focus', (
      tester,
    ) async {
      await open(tester);
      await _press(tester, LogicalKeyboardKey.keyB, control: true);
      expect(text(tester), isEmpty);
      await h.close(tester);
    }, variant: desktop);
  });

  testWidgets('Ctrl+Up and Ctrl+Down step through the own messages and back '
      'to the draft', (tester) async {
    await open(tester);
    await tester.tap(find.byType(EditableText));
    await tester.pump();
    await tester.enterText(find.byType(EditableText), 'draft');
    await tester.pump();

    await _press(tester, LogicalKeyboardKey.arrowUp, control: true);
    expect(text(tester), 'third');
    await _press(tester, LogicalKeyboardKey.arrowUp, control: true);
    expect(text(tester), 'second');
    await _press(tester, LogicalKeyboardKey.arrowDown, control: true);
    expect(text(tester), 'third');
    await _press(tester, LogicalKeyboardKey.arrowDown, control: true);
    expect(text(tester), 'draft');
    await h.close(tester);
  }, variant: desktop);

  testWidgets(
    'typing after Ctrl+Up starts from that message, not the history',
    (tester) async {
      await open(tester);
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      await _press(tester, LogicalKeyboardKey.arrowUp, control: true);
      await tester.enterText(find.byType(EditableText), 'third!');
      await tester.pump();
      await _press(tester, LogicalKeyboardKey.arrowUp, control: true);
      expect(text(tester), 'third');
      await _press(tester, LogicalKeyboardKey.arrowDown, control: true);
      expect(text(tester), 'third!');
      await h.close(tester);
    },
    variant: desktop,
  );
}
