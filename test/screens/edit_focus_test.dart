import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/keyboard_shortcuts.dart';
import 'package:matterleast/app/permission_providers.dart';
import 'package:matterleast/data/server_db/server_database.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/screens/channel/composer.dart';
import 'package:matterleast/screens/channel/composer_controller.dart';
import 'package:matterleast/screens/channel/composer_keys.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/channel/conversation_view.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

void main() {
  final desktop = TargetPlatformVariant.only(TargetPlatform.linux);
  late ServerHarness h;

  final threadKey = GlobalKey();

  Future<void> open(WidgetTester tester, {bool thread = false}) async {
    h = await pumpWithServer(
      tester,
      size: const Size(900, 700),
      seed: (session) async {
        await session.db.setSyncText(SyncKeys.currentUserRoles, 'system_user');
        await session.store.applyRoles([
          api.Role.fromJson({
            'id': 'rl000000000000000000000r01',
            'name': 'system_user',
            'permissions': ['create_post', 'edit_post'],
          }),
        ]);
        await session.store.applyChannelPage(
          channelId: channelId,
          page: api.PostList.fromJson({
            'order': ['mine1', 'mine2', 'other1'],
            'posts': {
              'other1': {
                'id': 'other1',
                'channel_id': channelId,
                'user_id': 'someone',
                'create_at': DateTime.now()
                    .subtract(const Duration(minutes: 5))
                    .millisecondsSinceEpoch,
                'message': 'hello',
              },
              'mine2': {
                'id': 'mine2',
                'channel_id': channelId,
                'user_id': meId,
                'root_id': 'other1',
                'create_at': DateTime.now()
                    .subtract(const Duration(minutes: 4))
                    .millisecondsSinceEpoch,
                'message': 'my thread words',
              },
              'mine1': {
                'id': 'mine1',
                'channel_id': channelId,
                'user_id': meId,
                'create_at': DateTime.now()
                    .subtract(const Duration(minutes: 2))
                    .millisecondsSinceEpoch,
                'message': 'my first words',
              },
            },
          }),
          kind: PageKind.page,
          requested: 3,
        );
        await session.store.applyThreadPage(
          rootId: 'other1',
          page: api.PostList.fromJson({
            'order': ['other1', 'mine2'],
            'posts': {
              'other1': {
                'id': 'other1',
                'channel_id': channelId,
                'user_id': 'someone',
                'create_at': DateTime.now()
                    .subtract(const Duration(minutes: 5))
                    .millisecondsSinceEpoch,
                'message': 'hello',
              },
              'mine2': {
                'id': 'mine2',
                'channel_id': channelId,
                'user_id': meId,
                'root_id': 'other1',
                'create_at': DateTime.now()
                    .subtract(const Duration(minutes: 4))
                    .millisecondsSinceEpoch,
                'message': 'my thread words',
              },
            },
          }),
        );
      },
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
          body: Consumer(
            builder: (context, ref, _) {
              final conversation = conversationProvider(url, channelId);
              final channel = Column(
                children: [
                  Expanded(
                    child: ConversationView(
                      url: url,
                      conversation: conversation,
                      composer: composerDraftProvider(url, channelId, ''),
                      startText: 'Start',
                    ),
                  ),
                  Composer(
                    url: url,
                    channelId: channelId,
                    teamId: teamId,
                    hint: 'Write',
                    lastOwnPost: () {
                      final now = ref.read(conversation);
                      return lastOwnPost(now.rows, now.myUserId);
                    },
                  ),
                ],
              );
              if (!thread) return channel;
              final replies = conversationProvider(
                url,
                channelId,
                rootId: 'other1',
              );
              return Row(
                children: [
                  Expanded(child: channel),
                  SizedBox(
                    key: threadKey,
                    width: 400,
                    child: Column(
                      children: [
                        Expanded(
                          child: ConversationView(
                            url: url,
                            conversation: replies,
                            composer: composerDraftProvider(
                              url,
                              channelId,
                              'other1',
                            ),
                            startText: 'Start',
                          ),
                        ),
                        Composer(
                          url: url,
                          channelId: channelId,
                          rootId: 'other1',
                          teamId: teamId,
                          hint: 'Reply',
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Finder fieldIn(Finder? pane) => pane == null
      ? find.byType(EditableText)
      : find.descendant(of: pane, matching: find.byType(EditableText));

  /// The field has the focus, the cursor at the end of [text], and what is
  /// typed next lands in it.
  Future<void> expectEditing(
    WidgetTester tester,
    Finder fieldFinder,
    String text,
  ) async {
    final field = tester.widget<EditableText>(fieldFinder);
    expect(FocusManager.instance.primaryFocus, same(field.focusNode));
    expect(field.controller.text, text);
    expect(
      field.controller.selection,
      TextSelection.collapsed(offset: text.length),
    );
    tester.testTextInput.enterText('$text!');
    await tester.pump();
    expect(field.controller.text, '$text!');
    tester.testTextInput.enterText(text);
    await tester.pump();
  }

  Future<void> pumpMenuClosed(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(seconds: 1));
    await h.settle(tester, rounds: 3);
  }

  group('Edit from', () {
    testWidgets('Up in an empty composer focuses the field', (tester) async {
      await open(tester);
      await tester.tap(find.byType(EditableText));
      await tester.pump();
      final before = tester.state(find.byType(EditableText));
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await h.settle(tester, rounds: 5);
      await expectEditing(tester, fieldIn(null), 'my first words');
      expect(tester.state(find.byType(EditableText)), same(before));
      await h.close(tester);
    }, variant: desktop);

    testWidgets('the right-click menu focuses the field, also once the menu '
        'is gone', (tester) async {
      await open(tester);
      final before = tester.state(find.byType(EditableText));
      await tester.tap(find.text('my first words'), buttons: kSecondaryButton);
      await h.settle(tester, rounds: 5);
      await tester.tap(find.text('Edit'));
      await tester.pump();
      await tester.pump();
      await expectEditing(tester, fieldIn(null), 'my first words');
      await pumpMenuClosed(tester);
      await expectEditing(tester, fieldIn(null), 'my first words');
      expect(tester.state(find.byType(EditableText)), same(before));
      await h.close(tester);
    }, variant: desktop);

    testWidgets('the hover toolbar menu focuses the field, also once the '
        'menu is gone', (tester) async {
      await open(tester);
      final before = tester.state(find.byType(EditableText));
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await mouse.addPointer(location: Offset.zero);
      addTearDown(mouse.removePointer);
      await mouse.moveTo(tester.getCenter(find.text('my first words')));
      await h.settle(tester, rounds: 5);
      await tester.tap(find.byTooltip('More actions'));
      await h.settle(tester, rounds: 5);
      await tester.tap(find.text('Edit'));
      await tester.pump();
      await tester.pump();
      await expectEditing(tester, fieldIn(null), 'my first words');
      await pumpMenuClosed(tester);
      await expectEditing(tester, fieldIn(null), 'my first words');
      expect(tester.state(find.byType(EditableText)), same(before));
      await h.close(tester);
    }, variant: desktop);

    testWidgets('a thread pane focuses the thread composer, not the '
        "channel's", (tester) async {
      await open(tester, thread: true);
      final pane = find.byKey(threadKey);
      await tester.tap(
        find.descendant(of: pane, matching: find.text('my thread words')),
        buttons: kSecondaryButton,
      );
      await h.settle(tester, rounds: 5);
      await tester.tap(find.text('Edit'));
      await tester.pump();
      await tester.pump();
      await expectEditing(tester, fieldIn(pane), 'my thread words');
      await pumpMenuClosed(tester);
      await expectEditing(tester, fieldIn(pane), 'my thread words');
      await h.close(tester);
    }, variant: desktop);

    testWidgets('the long-press menu on a phone focuses the field, also once '
        'the sheet is gone', (tester) async {
      await open(tester);
      final before = tester.state(find.byType(EditableText));
      await tester.longPress(find.text('my first words'));
      await h.settle(tester, rounds: 5);
      await tester.tap(find.text('Edit'));
      await tester.pump();
      await tester.pump();
      await expectEditing(tester, fieldIn(null), 'my first words');
      await pumpMenuClosed(tester);
      await expectEditing(tester, fieldIn(null), 'my first words');
      expect(tester.state(find.byType(EditableText)), same(before));
      await h.close(tester);
    }, variant: TargetPlatformVariant.only(TargetPlatform.android));
  });
}
