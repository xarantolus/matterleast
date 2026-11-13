import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/data/server_db/server_config.dart';
import 'package:matterleast/screens/channel_info/edit_channel_screen.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

const _fieldsPath = '/api/v4/properties/groups/access_control/channel/fields';

Map<String, Object?> _field(
  String id,
  String name,
  String type, {
  bool required = true,
  String writer = '',
}) => {
  'id': id,
  'name': name,
  'type': type,
  'object_type': 'channel',
  'permission_values': writer,
  'attrs': {
    'required': required,
    'options': [
      {'id': 'o1', 'name': 'Public'},
      {'id': 'o2', 'name': 'Secret'},
    ],
  },
};

void main() {
  late ServerHarness h;

  Future<void> open(
    WidgetTester tester, {
    bool flag = true,
    Reply? Function(SeenRequest r)? handle,
  }) async {
    h = await pumpWithServer(
      tester,
      size: const Size(800, 1600),
      seed: (session) async {
        await session.store.applyConfig(ConfigKeys.clientConfig, {
          'FeatureFlagChannelAttributes': flag ? 'true' : 'false',
        });
      },
      handle: (r) =>
          handle?.call(r) ??
          switch ((r.method, r.path)) {
            ('POST', '/api/v4/channels') => ok({
              'id': 'newchannel',
              'team_id': teamId,
              'type': 'O',
              'name': 'reef',
              'display_name': 'Reef',
            }),
            _ => emptyAnswer(r),
          },
      home: (url) => EditChannelScreen(url: url, teamId: teamId),
    );
    await h.settle(tester);
    await tester.enterText(find.byType(TextField).first, 'Reef');
    await h.settle(tester);
  }

  bool createEnabled(WidgetTester tester) =>
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Create'))
          .onPressed !=
      null;

  testWidgets('a required attribute must be filled before creating', (
    tester,
  ) async {
    await open(
      tester,
      handle: (r) => switch ((r.method, r.path)) {
        ('GET', _fieldsPath) => ok([_field('f1', 'Project code', 'text')]),
        ('POST', '/api/v4/channels') => ok({
          'id': 'newchannel',
          'team_id': teamId,
          'type': 'O',
          'name': 'reef',
          'display_name': 'Reef',
        }),
        _ => emptyAnswer(r),
      },
    );
    expect(find.text('Project code'), findsOneWidget);
    expect(createEnabled(tester), isFalse);
    await tester.enterText(
      find.widgetWithText(TextField, 'Project code'),
      'P-9',
    );
    await h.settle(tester);
    expect(createEnabled(tester), isTrue);
    await tester.tap(find.text('Create'));
    await h.settle(tester);
    final created = h.server.seen.singleWhere(
      (r) => r.method == 'POST' && r.path == '/api/v4/channels',
    );
    expect(created.body['property_values'], [
      {'field_id': 'f1', 'value': 'P-9'},
    ]);
    await h.close(tester);
  });

  testWidgets('optional attributes and ones only admins set are not asked', (
    tester,
  ) async {
    await open(
      tester,
      handle: (r) => switch ((r.method, r.path)) {
        ('GET', _fieldsPath) => ok([
          _field('f1', 'Nickname', 'text', required: false),
          _field('f2', 'Clearance', 'select', writer: 'sysadmin'),
        ]),
        _ => emptyAnswer(r),
      },
    );
    expect(find.text('Nickname'), findsNothing);
    expect(find.text('Clearance'), findsNothing);
    expect(createEnabled(tester), isTrue);
    await h.close(tester);
  });

  testWidgets('without channel attributes the request carries none', (
    tester,
  ) async {
    await open(tester, flag: false);
    await tester.tap(find.text('Create'));
    await h.settle(tester);
    final created = h.server.seen.singleWhere(
      (r) => r.method == 'POST' && r.path == '/api/v4/channels',
    );
    expect(created.body['property_values'], isNull);
    expect(
      h.server.seen.where((r) => r.path.contains('/properties/')),
      isEmpty,
    );
    await h.close(tester);
  });

  testWidgets('a server that refuses the fields creates the channel plainly', (
    tester,
  ) async {
    await open(
      tester,
      handle: (r) => switch ((r.method, r.path)) {
        ('GET', _fieldsPath) => error(501, 'api.property.license.app_error'),
        _ => emptyAnswer(r),
      },
    );
    expect(createEnabled(tester), isTrue);
    await h.close(tester);
  });

  testWidgets('a refusal for missing attributes is said in words', (
    tester,
  ) async {
    await open(
      tester,
      handle: (r) => switch ((r.method, r.path)) {
        ('POST', '/api/v4/channels') => error(
          400,
          'api.channel.create_channel.missing_required_attributes.app_error',
        ),
        _ => emptyAnswer(r),
      },
    );
    await tester.tap(find.text('Create'));
    await h.settle(tester);
    expect(find.text('Fill in the required attributes.'), findsOneWidget);
    await h.close(tester);
  });
}
