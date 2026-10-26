import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/server_db/server_database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;
import 'generated/schema_v3.dart' as v3;
import 'generated/schema_v4.dart' as v4;
import 'generated/schema_v5.dart' as v5;
import 'generated/schema_v6.dart' as v6;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  const versions = GeneratedHelper.versions;
  for (final (i, from) in versions.indexed) {
    for (final to in versions.skip(i + 1)) {
      test('migrates the schema from v$from to v$to', () async {
        final schema = await verifier.schemaAt(from);
        final db = ServerDatabase(schema.newConnection());
        await verifier.migrateAndValidate(db, to);
        await db.close();
      });
    }
  }

  test('keeps the drafts when going from v1 to v2', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: ServerDatabase.new,
      createItems: (batch, oldDb) => batch.insert(
        oldDb.drafts,
        const v1.DraftsCompanion(
          channelId: Value('channel-1'),
          message: Value('half a thought'),
          updatedAt: Value(1000),
        ),
      ),
      validateItems: (newDb) async {
        final row = await newDb.select(newDb.drafts).getSingle();
        expect(row.channelId, 'channel-1');
        expect(row.message, 'half a thought');
      },
    );
  });

  test('keeps the people when going from v3 to v4, roles unknown', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 3,
      newVersion: 4,
      createOld: v3.DatabaseAtV3.new,
      createNew: v4.DatabaseAtV4.new,
      openTestedDatabase: ServerDatabase.new,
      createItems: (batch, oldDb) => batch.insert(
        oldDb.users,
        const v3.UsersCompanion(id: Value('u1'), username: Value('wren')),
      ),
      validateItems: (newDb) async {
        final row = await newDb.select(newDb.users).getSingle();
        expect(row.username, 'wren');
        expect(row.roles, isNull);
      },
    );
  });

  test('keeps the people when going from v5 to v6, with no bookmarks or '
      'profile attributes yet', () async {
    await verifier.testWithDataIntegrity(
      oldVersion: 5,
      newVersion: 6,
      createOld: v5.DatabaseAtV5.new,
      createNew: v6.DatabaseAtV6.new,
      openTestedDatabase: ServerDatabase.new,
      createItems: (batch, oldDb) => batch.insert(
        oldDb.users,
        const v5.UsersCompanion(id: Value('u1'), username: Value('wren')),
      ),
      validateItems: (newDb) async {
        expect((await newDb.select(newDb.users).getSingle()).username, 'wren');
        expect(await newDb.select(newDb.channelBookmarks).get(), isEmpty);
        expect(await newDb.select(newDb.profileFields).get(), isEmpty);
      },
    );
  });
}
