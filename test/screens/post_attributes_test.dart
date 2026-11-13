import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/permission_providers.dart';
import 'package:matterleast/data/server_db/server_config.dart';
import 'package:matterleast/data/store/server_store.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/channel/conversation_view.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

const _fieldsPath = '/api/v4/properties/groups/post_attributes/post/fields';
const _valuesPath =
    '/api/v4/properties/groups/post_attributes/post/values/attr1';

Map<String, Object?> _field(
  String id,
  String name,
  String type, {
  List<(String, String)> options = const [],
  String writer = 'member',
}) => {
  'id': id,
  'name': name,
  'type': type,
  'object_type': 'post',
  'permission_values': writer,
  'attrs': {
    'sort_order': int.parse(id.substring(1)),
    'options': [
      for (final (id, name) in options) {'id': id, 'name': name},
    ],
  },
};

final _fields = [
  _field('f1', 'Ticket', 'text'),
  _field('f2', 'Severity', 'select', options: [('o1', 'High'), ('o2', 'Low')]),
  _field(
    'f3',
    'Tags',
    'multiselect',
    options: [('t1', 'Harbour'), ('t2', 'Tide')],
  ),
  _field('f4', 'Owner', 'text', writer: 'sysadmin'),
];

Map<String, Object?> _value(String field, Object value) => {
  'id': 'v$field',
  'target_id': 'attr1',
  'field_id': field,
  'value': value,
};

Map<String, Object?> _post({
  List<Map<String, Object?>> values = const [],
  bool unavailable = false,
}) => {
  'id': 'attr1',
  'channel_id': channelId,
  'user_id': 'someone',
  'create_at': DateTime.utc(2026, 10, 26, 8).millisecondsSinceEpoch,
  'message': 'dock schedule',
  'metadata': {
    if (values.isNotEmpty) 'property_values': values,
    if (unavailable) 'property_values_unavailable': true,
  },
};

void main() {
  late ServerHarness h;
  bool fieldsAsked() => h.server.seen.any((r) => r.path == _fieldsPath);

  Future<void> open(
    WidgetTester tester, {
    required Map<String, Object?> post,
    bool flag = true,
    Reply? Function(SeenRequest r)? handle,
    String? shows,
  }) async {
    h = await pumpWithServer(
      tester,
      size: const Size(800, 1600),
      seed: (session) async {
        if (flag) {
          await session.store.applyConfig(ConfigKeys.clientConfig, {
            'FeatureFlagPostAttributes': 'true',
          });
        }
        await session.store.applyChannelPage(
          channelId: channelId,
          page: api.PostList.fromJson({
            'order': ['attr1'],
            'posts': {'attr1': post},
          }),
          kind: PageKind.page,
          requested: 1,
        );
      },
      handle: (r) =>
          handle?.call(r) ??
          switch (r.path) {
            _fieldsPath => ok(_fields),
            _ => emptyAnswer(r),
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
      home: (url) => Scaffold(
        body: ConversationView(
          url: url,
          conversation: conversationProvider(url, channelId),
          startText: 'This is the start of Boats.',
        ),
      ),
    );
    await h.settle(
      tester,
      until: () => find.text('dock schedule').evaluate().isNotEmpty,
    );
    // The fields are fetched after the post shows.
    await h.settle(tester, until: () => shows != null || fieldsAsked());
    await h.settle(tester);
  }

  testWidgets('a post shows two attributes and a badge for the rest', (
    tester,
  ) async {
    await open(
      tester,
      shows: 'Ticket: T-1',
      post: _post(
        values: [
          _value('f1', 'T-1'),
          _value('f2', 'o1'),
          _value('f3', ['t1', 't2']),
        ],
      ),
    );
    expect(find.text('Ticket: T-1'), findsOneWidget);
    expect(find.text('Severity: High'), findsOneWidget);
    expect(find.text('+1'), findsOneWidget);
    expect(find.textContaining('Tags'), findsNothing);
    await h.close(tester);
  });

  testWidgets('the sheet lists every attribute with its value', (tester) async {
    await open(
      tester,
      shows: 'Ticket: T-1',
      post: _post(
        values: [
          _value('f1', 'T-1'),
          _value('f2', 'o1'),
          _value('f3', ['t1', 't2']),
        ],
      ),
    );
    await tester.tap(find.text('Ticket: T-1'));
    await h.settle(tester);
    expect(find.text('Post attributes'), findsOneWidget);
    expect(find.text('Harbour, Tide'), findsOneWidget);
    expect(find.text('Not set'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('an attribute the user may set is saved to the server', (
    tester,
  ) async {
    await open(
      tester,
      shows: 'Ticket: T-1',
      post: _post(values: [_value('f1', 'T-1')]),
      handle: (r) => switch (r.path) {
        _fieldsPath => ok(_fields),
        _valuesPath when r.method == 'PATCH' => ok([_value('f1', 'T-2')]),
        '/api/v4/posts/attr1' => ok(_post(values: [_value('f1', 'T-2')])),
        _ => emptyAnswer(r),
      },
    );
    await tester.tap(find.text('Ticket: T-1'));
    await h.settle(tester);
    await tester.tap(find.text('Ticket').last);
    await h.settle(tester);
    await tester.enterText(find.byType(TextField), 'T-2');
    await tester.tap(find.text('Save'));
    await h.settle(tester);
    final patch = h.server.seen.singleWhere(
      (r) => r.method == 'PATCH' && r.path == _valuesPath,
    );
    expect(patch.json, [
      {'field_id': 'f1', 'value': 'T-2'},
    ]);
    expect(find.text('T-2'), findsWidgets);
    await h.close(tester);
  });

  testWidgets('an attribute only admins set cannot be edited', (tester) async {
    await open(
      tester,
      shows: 'Owner: Dana',
      post: _post(values: [_value('f4', 'Dana')]),
    );
    await tester.tap(find.text('Owner: Dana'));
    await h.settle(tester);
    expect(find.text('Owner'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsNWidgets(3));
    await h.close(tester);
  });

  testWidgets('values the server could not look up say so', (tester) async {
    await open(
      tester,
      shows: 'Attributes unavailable',
      post: _post(unavailable: true),
    );
    expect(find.text('Attributes unavailable'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('a server without post attributes shows nothing and asks '
      'nothing', (tester) async {
    await open(
      tester,
      shows: 'dock schedule',
      flag: false,
      post: _post(values: [_value('f1', 'T-1')]),
    );
    expect(find.textContaining('Ticket'), findsNothing);
    expect(
      h.server.seen.where((r) => r.path.contains('/properties/')),
      isEmpty,
    );
    for (final r in h.server.seen.where(
      (r) => r.path == '/api/v4/channels/$channelId/posts',
    )) {
      expect(r.raw.uri.queryParameters.containsKey('propertyGroup'), isFalse);
    }
    await h.close(tester);
  });

  testWidgets('post attributes ask for the group on the posts they fetch', (
    tester,
  ) async {
    await open(tester, post: _post(), shows: 'dock schedule');
    final fetches = h.server.seen.where(
      (r) => r.path == '/api/v4/channels/$channelId/posts',
    );
    expect(fetches, isNotEmpty);
    for (final r in fetches) {
      expect(r.raw.uri.queryParameters['propertyGroup'], 'post_attributes');
    }
    await h.close(tester);
  });

  testWidgets('a server that refuses the fields shows no chips', (
    tester,
  ) async {
    await open(
      tester,
      post: _post(values: [_value('f1', 'T-1')]),
      handle: (r) => switch (r.path) {
        _fieldsPath => error(404, 'api.property.not_found'),
        _ => emptyAnswer(r),
      },
    );
    expect(find.textContaining('Ticket'), findsNothing);
    await h.close(tester);
  });
}
