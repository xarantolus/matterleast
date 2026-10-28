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

  Future<void> open(WidgetTester tester) async {
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
            'order': ['mine1', 'other1'],
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
          requested: 2,
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
              return Column(
                children: [
                  Expanded(
                    child: ConversationView(
                      url: url,
                      conversation: conversation,
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
            },
          ),
        ),
      ),
    );
  }

  EditableText field(WidgetTester tester) =>
      tester.widget<EditableText>(find.byType(EditableText));

  Future<void> key(WidgetTester tester, LogicalKeyboardKey k) async {
    await tester.sendKeyEvent(k);
    await h.settle(tester, rounds: 5);
  }

  testWidgets('Up in an empty composer edits the newest own message with '
      'the cursor at its end', (tester) async {
    await open(tester);
    await tester.tap(find.byType(EditableText));
    await tester.pump();
    await key(tester, LogicalKeyboardKey.arrowUp);
    expect(
      find.textContaining('Editing message', findRichText: true),
      findsOneWidget,
    );
    expect(field(tester).controller.text, 'my first words');
    expect(field(tester).focusNode.hasPrimaryFocus, isTrue);
    expect(
      field(tester).controller.selection,
      const TextSelection.collapsed(offset: 'my first words'.length),
    );
    await h.close(tester);
  }, variant: desktop);

  testWidgets('Esc cancels the edit and brings back the draft', (tester) async {
    await open(tester);
    await tester.tap(find.byType(EditableText));
    await tester.pump();
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Composer)),
    );
    final draft = composerDraftProvider(h.url, channelId, '');
    container
        .read(draft.notifier)
        .changed(const TextEditingValue(text: 'my draft'));
    await h.settle(tester, rounds: 3);
    final post = lastOwnPost(
      container.read(conversationProvider(h.url, channelId)).rows,
      meId,
    )!;
    container.read(draft.notifier).startEditing(post);
    await h.settle(tester, rounds: 3);
    expect(field(tester).controller.text, 'my first words');

    await key(tester, LogicalKeyboardKey.escape);
    expect(
      find.textContaining('Editing message', findRichText: true),
      findsNothing,
    );
    expect(field(tester).controller.text, 'my draft');
    await h.close(tester);
  }, variant: desktop);

  testWidgets('Enter saves the edit', (tester) async {
    await open(tester);
    await tester.tap(find.byType(EditableText));
    await tester.pump();
    await key(tester, LogicalKeyboardKey.arrowUp);
    await tester.enterText(find.byType(EditableText), 'my better words');
    await tester.pump();
    await key(tester, LogicalKeyboardKey.enter);
    await h.settle(tester);
    expect(h.server.paths, contains('/api/v4/posts/mine1/patch'));
    expect(
      find.textContaining('Editing message', findRichText: true),
      findsNothing,
    );
    await h.close(tester);
  }, variant: desktop);

  testWidgets('Up while editing moves the cursor, not to another message', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.byType(EditableText));
    await tester.pump();
    await key(tester, LogicalKeyboardKey.arrowUp);
    await key(tester, LogicalKeyboardKey.arrowUp);
    expect(field(tester).controller.text, 'my first words');
    expect(
      find.textContaining('Editing message', findRichText: true),
      findsOneWidget,
    );
    await h.close(tester);
  }, variant: desktop);

  testWidgets('Edit from a menu puts the cursor at the end at once', (
    tester,
  ) async {
    await open(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Composer)),
    );
    final post = lastOwnPost(
      container.read(conversationProvider(h.url, channelId)).rows,
      meId,
    )!;
    container
        .read(composerDraftProvider(h.url, channelId, '').notifier)
        .startEditing(post);
    await tester.pump();
    expect(field(tester).focusNode.hasPrimaryFocus, isTrue);
    expect(
      field(tester).controller.selection,
      const TextSelection.collapsed(offset: 'my first words'.length),
    );
    await h.close(tester);
  }, variant: desktop);
}
