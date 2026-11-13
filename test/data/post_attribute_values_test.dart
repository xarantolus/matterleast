import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/domain/post_details.dart';

import '../support/test_session.dart';

Map<String, Object?> _post(String message, {Object? values}) => {
  'id': 'attr1',
  'channel_id': channelId,
  'user_id': 'someone',
  'create_at': DateTime.utc(2026, 10, 26, 8).millisecondsSinceEpoch,
  'message': message,
  'metadata': {'property_values': ?values},
};

final _values = [
  {'id': 'v1', 'field_id': 'f1', 'value': 'T-1'},
  {
    'id': 'v2',
    'field_id': 'f3',
    'value': ['t1', 't2'],
  },
];

void main() {
  late ServerSession session;

  Future<Map<String, List<String>>> stored() async {
    final row = await session.store.post('attr1');
    return detailsFor(row!.id, row.propsJson, row.metadataJson).attributes;
  }

  Future<void> apply(Map<String, Object?> post) =>
      session.store.applyEdit(api.Post.fromJson(post));

  setUp(() async {
    (_, session) = await startServerSession();
  });

  test(
    'a post stores its attribute values, several choices as a list',
    () async {
      await apply(_post('dock schedule', values: _values));
      expect(await stored(), {
        'f1': ['T-1'],
        'f3': ['t1', 't2'],
      });
    },
  );

  test('a copy without values, such as a live event, keeps them', () async {
    await apply(_post('dock schedule', values: _values));
    await apply(_post('dock schedule'));
    expect((await stored()).keys, containsAll(['f1', 'f3']));
  });

  test('a copy with new values replaces them', () async {
    await apply(_post('dock schedule', values: _values));
    await apply(
      _post(
        'dock schedule',
        values: [
          {'id': 'v1', 'field_id': 'f1', 'value': 'T-2'},
        ],
      ),
    );
    expect(await stored(), {
      'f1': ['T-2'],
    });
  });
}
