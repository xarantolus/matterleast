import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_config.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/permissions.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/settings/custom_emoji_page.dart';
import 'package:matterleast/ui/add_emoji.dart';
import 'package:matterleast/ui/emoji_picker.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';

Map<String, Object?> emojiJson(String name, {String creator = 'other'}) => {
  'id': 'id-$name',
  'name': name,
  'creator_id': creator,
  'create_at': 1000,
  'update_at': 1000,
  'delete_at': 0,
};

/// The user may add and delete their own emoji; [admin] also others'.
Future<void> seedEmoji(
  ServerSession session, {
  bool enabled = true,
  bool create = true,
  bool deleteOwn = true,
  bool deleteOthers = false,
  List<Map<String, Object?>> stored = const [],
}) async {
  await session.store.applyConfig(ConfigKeys.clientConfig, {
    'EnableCustomEmoji': '$enabled',
  });
  await session.store.applyRoles([
    api.Role.fromJson({
      'id': '1',
      'name': 'system_user',
      'permissions': [
        if (create) Permission.createEmojis,
        if (deleteOwn) Permission.deleteEmojis,
        if (deleteOthers) Permission.deleteOthersEmojis,
      ],
    }),
  ]);
  await session.store.applyMyRoles('system_user');
  await session.store.applyCustomEmoji([
    for (final e in stored) api.Emoji.fromJson(e),
  ]);
}

final _png = Uint8List.fromList(
  base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  ),
);

Future<EmojiImage?> _pickPng() async =>
    (fileName: 'Spark Fox.png', bytes: _png, size: _png.length);

const _tall = Size(800, 1400);

void main() {
  group('searching the server from the picker', () {
    Future<ServerHarness> open(
      WidgetTester tester, {
      Reply Function(SeenRequest)? search,
      bool enabled = true,
    }) => pumpWithServer(
      tester,
      size: _tall,
      handle: (r) => switch ((r.method, r.path)) {
        ('POST', '/api/v4/emoji/search') =>
          search?.call(r) ?? ok([emojiJson('sparklefox')]),
        ('GET', '/api/v4/emoji') => ok(const <Object?>[]),
        _ => emptyAnswer(r),
      },
      seed: (s) => seedEmoji(s, enabled: enabled),
      home: (url) => Scaffold(body: EmojiPicker(url: url)),
    );

    testWidgets('an emoji not stored yet turns up in the results', (
      tester,
    ) async {
      final h = await open(tester);
      expect(find.byTooltip(':sparklefox:'), findsNothing);

      await tester.enterText(find.byType(EditableText), 'sparkle');
      await tester.pump(const Duration(milliseconds: 400));
      await h.settle(tester);

      expect(find.byTooltip(':sparklefox:'), findsOneWidget);
      final asked = h.server.seen.where(
        (r) => r.path == '/api/v4/emoji/search',
      );
      expect(asked, hasLength(1));
      expect(asked.single.body['term'], 'sparkle');
      await h.close(tester);
    });

    testWidgets('an emoji the picker already shows is not searched for', (
      tester,
    ) async {
      final h = await pumpWithServer(
        tester,
        size: _tall,
        handle: (r) => ok(const <Object?>[]),
        seed: (s) => seedEmoji(
          s,
          stored: [for (var i = 0; i < 6; i++) emojiJson('spark$i')],
        ),
        home: (url) => Scaffold(body: EmojiPicker(url: url)),
      );
      await tester.enterText(find.byType(EditableText), 'spark');
      await tester.pump(const Duration(milliseconds: 400));
      await h.settle(tester);
      expect(h.server.paths, isNot(contains('/api/v4/emoji/search')));
      await h.close(tester);
    });

    testWidgets('a server without custom emoji is not asked and shows no add', (
      tester,
    ) async {
      final h = await open(tester, enabled: false);
      await tester.enterText(find.byType(EditableText), 'sparkle');
      await tester.pump(const Duration(milliseconds: 400));
      await h.settle(tester);
      expect(h.server.paths, isNot(contains('/api/v4/emoji/search')));
      expect(find.byTooltip('Add custom emoji'), findsNothing);
      await h.close(tester);
    });

    testWidgets('a 501 turns custom emoji off', (tester) async {
      final h = await open(
        tester,
        search: (_) => error(501, 'not_implemented'),
      );
      await tester.enterText(find.byType(EditableText), 'sparkle');
      await tester.pump(const Duration(milliseconds: 400));
      await h.settle(tester);
      final features = await tester.runAsync(h.session.db.features);
      expect(features!.customEmoji, isFalse);
      await h.close(tester);
    });

    testWidgets('the add button shows only with the permission', (
      tester,
    ) async {
      var h = await open(tester);
      expect(find.byTooltip('Add custom emoji'), findsOneWidget);
      await h.close(tester);

      h = await pumpWithServer(
        tester,
        size: _tall,
        handle: (r) => ok(const <Object?>[]),
        seed: (s) => seedEmoji(s, create: false),
        home: (url) => Scaffold(body: EmojiPicker(url: url)),
      );
      expect(find.byTooltip('Add custom emoji'), findsNothing);
      await h.close(tester);
    });

    testWidgets('a right granted by a team role shows the add button', (
      tester,
    ) async {
      final h = await pumpWithServer(
        tester,
        size: _tall,
        handle: (r) => ok(const <Object?>[]),
        seed: (s) async {
          await seedEmoji(s, create: false);
          await s.store.applyRoles([
            api.Role.fromJson({
              'id': '2',
              'name': 'team_user',
              'permissions': [Permission.createEmojis],
            }),
          ]);
          await s.store.applyTeams(
            [
              api.Team.fromJson({
                'id': 'team1',
                'name': 'bay',
                'display_name': 'Bay',
              }),
            ],
            [
              api.TeamMember.fromJson({
                'team_id': 'team1',
                'roles': 'team_user',
              }),
            ],
          );
        },
        home: (url) => Scaffold(body: EmojiPicker(url: url)),
      );
      expect(find.byTooltip('Add custom emoji'), findsOneWidget);
      await h.close(tester);
    });
  });

  group('adding an emoji', () {
    Future<ServerHarness> open(
      WidgetTester tester, {
      Reply Function(SeenRequest)? create,
    }) => pumpWithServer(
      tester,
      size: _tall,
      handle: (r) => r.method == 'POST' && r.path == '/api/v4/emoji'
          ? create?.call(r) ?? ok(emojiJson('spark_fox', creator: 'me'))
          : emptyAnswer(r),
      seed: (s) => seedEmoji(s, stored: [emojiJson('partyblob')]),
      home: (url) => Scaffold(
        body: AddEmojiForm(url: url, pick: _pickPng),
      ),
    );

    testWidgets('sends the image with its name and the emoji is stored', (
      tester,
    ) async {
      final h = await open(tester);
      await tester.tap(find.byTooltip('Choose an image'));
      await h.settle(tester);
      // The name starts from the file name.
      expect(find.widgetWithText(TextField, 'spark_fox'), findsOneWidget);

      await tester.tap(find.text('Add emoji'));
      await h.settle(tester);

      final sent = h.server.seen.singleWhere(
        (r) => r.method == 'POST' && r.path == '/api/v4/emoji',
      );
      expect(sent.text, contains('name="image"'));
      expect(sent.text, contains('name="emoji"'));
      expect(sent.text, contains('"name":"spark_fox"'));
      expect(sent.text, contains('"creator_id":"$_me"'));
      final stored = await tester.runAsync(
        () => h.session.db.select(h.session.db.customEmoji).get(),
      );
      expect([for (final e in stored!) e.name], contains('spark_fox'));
      await h.close(tester);
    });

    testWidgets('a name that is not valid is refused before any request', (
      tester,
    ) async {
      final h = await open(tester);
      await tester.tap(find.byTooltip('Choose an image'));
      await h.settle(tester);

      for (final bad in ['Spark Fox', 'partyblob', 'smile']) {
        await tester.enterText(find.byType(TextField), bad);
        await tester.pump();
        final button = tester.widget<FilledButton>(
          find.widgetWithText(FilledButton, 'Add emoji'),
        );
        expect(button.onPressed, isNull, reason: bad);
      }
      expect(h.server.paths, isNot(contains('/api/v4/emoji')));
      expect(find.text('That name is already used.'), findsOneWidget);
      await h.close(tester);
    });

    testWidgets('says what the server said when it refuses', (tester) async {
      final h = await open(tester, create: (_) => error(413, 'too_large'));
      await tester.tap(find.byTooltip('Choose an image'));
      await h.settle(tester);
      await tester.tap(find.text('Add emoji'));
      await h.settle(tester);
      expect(find.textContaining('too_large'), findsOneWidget);
      await h.close(tester);
    });
  });

  group('the custom emoji list', () {
    Future<ServerHarness> open(
      WidgetTester tester, {
      bool deleteOwn = true,
      bool deleteOthers = false,
      Reply Function(SeenRequest)? delete,
    }) => pumpWithServer(
      tester,
      size: _tall,
      handle: (r) => switch ((r.method, r.path)) {
        ('DELETE', _) => delete?.call(r) ?? ok({'status': 'OK'}),
        ('GET', '/api/v4/emoji') => ok([
          emojiJson('mine', creator: _me),
          emojiJson('theirs'),
        ]),
        _ => emptyAnswer(r),
      },
      seed: (s) => seedEmoji(
        s,
        deleteOwn: deleteOwn,
        deleteOthers: deleteOthers,
        stored: [
          emojiJson('mine', creator: _me),
          emojiJson('theirs'),
        ],
      ),
      home: (url) => CustomEmojiPage(
        server: ServerEntry(
          url: url,
          displayName: 'Harbour',
          siteName: null,
          serverVersion: null,
          diagnosticId: null,
          lastActiveAt: null,
          ssoScheme: null,
        ),
      ),
    );

    testWidgets('deleting one asks, calls the server and removes it', (
      tester,
    ) async {
      final h = await open(tester);
      expect(find.text(':mine:'), findsOneWidget);
      expect(find.text(':theirs:'), findsOneWidget);
      // Only their own can be deleted without the wider right.
      expect(find.byTooltip('Delete :mine:'), findsOneWidget);
      expect(find.byTooltip('Delete :theirs:'), findsNothing);

      await tester.tap(find.byTooltip('Delete :mine:'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await h.settle(tester);

      expect(
        h.server.seen.any(
          (r) => r.method == 'DELETE' && r.path == '/api/v4/emoji/id-mine',
        ),
        isTrue,
      );
      expect(find.text(':mine:'), findsNothing);
      expect(find.text(':theirs:'), findsOneWidget);
      await h.close(tester);
    });

    testWidgets('cancelling keeps it and sends nothing', (tester) async {
      final h = await open(tester);
      await tester.tap(find.byTooltip('Delete :mine:'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
      await h.settle(tester);
      expect(h.server.seen.any((r) => r.method == 'DELETE'), isFalse);
      expect(find.text(':mine:'), findsOneWidget);
      await h.close(tester);
    });

    testWidgets('the wider right shows delete on others, too', (tester) async {
      final h = await open(tester, deleteOthers: true);
      expect(find.byTooltip('Delete :theirs:'), findsOneWidget);
      await h.close(tester);
    });

    testWidgets('without any delete right there is no delete', (tester) async {
      final h = await open(tester, deleteOwn: false);
      expect(find.byTooltip('Delete :mine:'), findsNothing);
      await h.close(tester);
    });

    testWidgets('a refusal keeps it and shows the server\'s words', (
      tester,
    ) async {
      final h = await open(tester, delete: (_) => error(403, 'no_permission'));
      await tester.tap(find.byTooltip('Delete :mine:'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await h.settle(tester);
      expect(find.text(':mine:'), findsOneWidget);
      expect(find.textContaining('no_permission'), findsOneWidget);
      await h.close(tester);
    });
  });
}

const _me = 'me0000000000000000000000me';
