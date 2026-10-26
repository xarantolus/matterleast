import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/data/views/extras_views.dart';
import 'package:matterleast/domain/profile_attributes.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

const _otherId = 'us000000000000000000000u02';

final _fields = [
  {
    'id': 'f_dept',
    'name': 'Department',
    'type': 'text',
    'attrs': {'visibility': 'always', 'sort_order': 2},
  },
  {
    'id': 'f_site',
    'name': 'Website',
    'type': 'text',
    'attrs': {'value_type': 'url', 'sort_order': 1},
  },
  {
    'id': 'f_office',
    'name': 'Office',
    'type': 'select',
    'attrs': {
      'sort_order': 3,
      'options': [
        {'id': 'o1', 'name': 'Harbour'},
        {'id': 'o2', 'name': 'Hilltop'},
      ],
    },
  },
  {
    'id': 'f_lang',
    'name': 'Languages',
    'type': 'multiselect',
    'attrs': {
      'sort_order': 4,
      'options': [
        {'id': 'l1', 'name': 'English'},
        {'id': 'l2', 'name': 'German'},
      ],
    },
  },
  {
    'id': 'f_badge',
    'name': 'Badge',
    'type': 'text',
    'attrs': {'sort_order': 5, 'managed': 'admin'},
  },
  {
    'id': 'f_secret',
    'name': 'Secret',
    'type': 'text',
    'attrs': {'visibility': 'hidden'},
  },
];

void main() {
  late FakeServer server;
  late ServerSession session;
  var values = <String, Object?>{};

  setUp(() async {
    server = await FakeServer.start();
    values = {};
    server.handle = (r) => switch ((r.method, r.path)) {
      ('GET', '/api/v4/custom_profile_attributes/fields') => ok(_fields),
      ('GET', '/api/v4/users/$_otherId/custom_profile_attributes') => ok(
        values,
      ),
      ('PATCH', '/api/v4/users/$meId/custom_profile_attributes') => ok(r.json),
      _ => error(404, 'not_found'),
    };
    session = await testSession(server);
    await session.store.applyConfig('client_config', {'Version': '12.0.1'});
  });

  tearDown(() async {
    await closeTestSession(session);
    await server.close();
  });

  Future<List<(String, String)>> shown(String userId) async => [
    for (final a in await AttributeViews(session.db).shown(userId).first)
      (a.name, a.text),
  ];

  Future<void> receive(String event, Map<String, Object?> data) =>
      session.connection.events.add(
        decodeEvent(
          SocketFrame.fromJson({'event': event, 'data': data, 'seq': 1}),
        ),
      );

  test('a profile shows the attributes in the server order with option '
      'names, hiding hidden and unset ones', () async {
    values = {
      'f_site': 'example.com/wren',
      'f_office': 'o2',
      'f_lang': ['l1', 'l2'],
      'f_secret': 'kept back',
    };
    await session.attributes.refresh(_otherId);
    expect(await shown(_otherId), [
      ('Website', 'example.com/wren'),
      ('Department', ''),
      ('Office', 'Hilltop'),
      ('Languages', 'English, German'),
    ]);
  });

  test(
    'a server from before the feature shows nothing and asks nothing',
    () async {
      await session.store.applyConfig('client_config', {'Version': '10.4.0'});
      await session.attributes.refresh(_otherId);
      expect(server.seen, isEmpty);
      expect(await shown(_otherId), isEmpty);
    },
  );

  test('the feature flag turns them on before they were always on', () async {
    await session.store.applyConfig('client_config', {
      'Version': '10.6.0',
      'FeatureFlagCustomProfileAttributes': 'true',
    });
    values = {'f_site': 'example.com'};
    await session.attributes.refresh(_otherId);
    expect(await shown(_otherId), contains(('Website', 'example.com')));
  });

  test('a 501 for the fields turns them off', () async {
    server.handle = (_) => error(501, 'license_error');
    await expectLater(session.attributes.refresh(_otherId), throwsA(anything));
    expect((await session.db.features()).profileAttributes, isFalse);
  });

  test('changes elsewhere follow: a value, a deleted field', () async {
    values = {'f_site': 'example.com'};
    await session.attributes.refresh(_otherId);
    await receive('custom_profile_attributes_values_updated', {
      'user_id': _otherId,
      'values': {'f_office': 'o1'},
    });
    expect(await shown(_otherId), contains(('Office', 'Harbour')));
    await receive('custom_profile_attributes_field_deleted', {
      'field_id': 'f_site',
    });
    expect(
      (await shown(_otherId)).map((a) => a.$1),
      isNot(contains('Website')),
    );
  });

  test('saving one\'s own values sends a list for multiselect and keeps '
      'the answer', () async {
    await session.attributes.refresh(_otherId);
    final (fields, _) = await AttributeViews(session.db).editable(meId).first;
    final byName = {for (final f in fields) f.name: f};
    expect(byName['Badge']!.editable, isFalse);
    await session.attributes.saveMine({
      byName['Languages']!: ['l2'],
      byName['Department']!: ['Ops'],
    });
    final sent = server.seen.last.json! as List<Object?>;
    expect(sent, [
      {
        'id': 'f_lang',
        'value': ['l2'],
      },
      {'id': 'f_dept', 'value': 'Ops'},
    ]);
    expect(await shown(meId), [('Department', 'Ops'), ('Languages', 'German')]);
  });

  group('links', () {
    test('web, mail and phone values open; plain text does not', () {
      expect(
        attributeLink(AttributeKind.url, 'example.com/a').toString(),
        'https://example.com/a',
      );
      expect(
        attributeLink(AttributeKind.email, 'wren@example.com').toString(),
        'mailto:wren@example.com',
      );
      expect(
        attributeLink(AttributeKind.phone, '+49 (30) 123').toString(),
        'tel:+4930123',
      );
      expect(attributeLink(AttributeKind.text, 'example.com'), isNull);
    });
  });
}
