import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/data/updates/update_check.dart';
import 'package:matterleast/domain/app_update.dart';

import '../support/fake_releases.dart';

void main() {
  late AppDatabase db;
  late SettingsStore settings;
  late FakeReleases github;
  late DateTime now;
  late UpdateCheck check;

  setUp(() {
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    settings = SettingsStore(db);
    github = FakeReleases();
    now = DateTime.utc(2026, 10, 27, 9);
    check = UpdateCheck(
      http: github.dio,
      settings: settings,
      repo: 'owner/app',
      now: () => now,
    );
  });

  tearDown(() => db.close());

  test('asks the configured repository for its latest release', () async {
    await check.runIfDue();

    expect(
      github.requests.single.toString(),
      'https://api.github.com/repos/owner/app/releases/latest',
    );
    expect(
      await settings.read(Settings.latestRelease),
      const KnownRelease(
        tag: 'v0.12.0',
        url: 'https://github.com/owner/app/releases/tag/v0.12.0',
      ),
    );
  });

  test('asks at most once a day', () async {
    await check.runIfDue();
    now = now.add(const Duration(hours: 12));
    github.tag = 'v0.13.0';
    await check.runIfDue();

    expect(github.requests, hasLength(1));
    expect((await settings.read(Settings.latestRelease))?.tag, 'v0.12.0');

    now = now.add(const Duration(hours: 12));
    await check.runIfDue();

    expect(github.requests, hasLength(2));
    expect((await settings.read(Settings.latestRelease))?.tag, 'v0.13.0');
  });

  test('checks that run together ask once', () async {
    await Future.wait([check.runIfDue(), check.runIfDue()]);

    expect(github.requests, hasLength(1));
  });

  test('a failed check is retried the next day, not sooner', () async {
    github.status = 404;
    await check.runIfDue();

    expect(await settings.read(Settings.latestRelease), isNull);
    expect(await settings.read(Settings.lastUpdateCheck), now);

    github.status = 200;
    now = now.add(const Duration(hours: 1));
    await check.runIfDue();
    expect(github.requests, hasLength(1));

    now = now.add(const Duration(days: 1));
    await check.runIfDue();
    expect(github.requests, hasLength(2));
    expect((await settings.read(Settings.latestRelease))?.tag, 'v0.12.0');
  });

  test('a release with an unreadable tag is not kept', () async {
    github.tag = 'nightly';
    await check.runIfDue();

    expect(await settings.read(Settings.latestRelease), isNull);
  });
}
