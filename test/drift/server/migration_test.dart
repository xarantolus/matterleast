import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/server_db/server_database.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

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
}
