import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/app_db/app_database.dart';

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
        final db = AppDatabase(schema.newConnection());
        await verifier.migrateAndValidate(db, to);
        await db.close();
      });
    }
  }

  test('keeps the added servers when going from v1 to v2', () async {
    const url = 'https://chat.example.test';
    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: AppDatabase.new,
      createItems: (batch, oldDb) => batch.insert(
        oldDb.servers,
        const v1.ServersCompanion(
          url: Value(url),
          displayName: Value('Example'),
          dbFile: Value('server-1.sqlite'),
          addedAt: Value(1000),
        ),
      ),
      validateItems: (newDb) async {
        final row = await newDb.select(newDb.servers).getSingle();
        expect(row.url, url);
        expect(row.displayName, 'Example');
        expect(row.ssoScheme, isNull);
      },
    );
  });
}
