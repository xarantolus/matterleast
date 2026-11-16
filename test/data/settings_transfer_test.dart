import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/data/app_db/settings_transfer.dart';
import 'package:matterleast/domain/message_text_size.dart';
import 'package:matterleast/domain/settings_file.dart';

import '../support/memory_database.dart';

void main() {
  late AppDatabase source;
  late AppDatabase target;

  setUp(() async {
    source = memoryAppDatabase();
    target = memoryAppDatabase();
    await source.upsertServer(
      ServersCompanion.insert(
        url: 'https://chat.example.org',
        displayName: 'Example',
        dbFile: 'a',
        sortOrder: const Value(0),
        addedAt: DateTime(2026),
        lastActiveAt: Value(DateTime(2026)),
        themeMode: const Value('brandDark'),
        ssoScheme: const Value('myapp'),
        lastLoginId: const Value('alice'),
      ),
    );
    await SettingsStore(source).write(Settings.keepDays, 7);
    await SettingsStore(source)
        .write(Settings.messageTextSize, MessageTextSize.large);
    await SettingsStore(source).write(Settings.notificationsAsked, true);
  });

  tearDown(() async {
    await source.close();
    await target.close();
  });

  Future<String> exported() async => encodeSettingsFile(
    await SettingsTransfer(source).export(stayConnected: null),
  );

  test('every setting is exported or marked as device-only, not both', () {
    final exported = Settings.exported.toSet();
    final device = Settings.deviceOnly.toSet();
    expect(exported.intersection(device), isEmpty);
    expect(Settings.all.toSet(), exported.union(device));
  });

  test('the file holds no credential and no device state', () async {
    final text = await exported();
    expect(text, isNot(contains('alice')));
    expect(text, isNot(contains('notificationsAsked')));
    expect(text, isNot(contains('lastLoginId')));
    expect(text, isNot(contains('token')));
  });

  test(
    'importing an export recreates the servers (signed out) and settings',
    () async {
      final transfer = SettingsTransfer(target);
      final file = parseSettingsFile(await exported());
      final plan = await transfer.plan(file, stayConnected: null);
      expect(importSummary(plan), contains('chat.example.org'));
      await transfer.apply(plan);

      final servers = await target.allServers();
      expect(servers.map((s) => s.url), ['https://chat.example.org']);
      expect(servers.single.lastActiveAt, isNull);
      expect(servers.single.lastLoginId, isNull);
      expect(servers.single.themeMode, 'brandDark');
      expect(servers.single.ssoScheme, 'myapp');
      final store = SettingsStore(target);
      expect(await store.read(Settings.keepDays), 7);
      expect(await store.read(Settings.messageTextSize), MessageTextSize.large);
      expect(await store.read(Settings.notificationsAsked), isFalse);

      expect((await transfer.plan(file, stayConnected: null)).isEmpty, isTrue);
    },
  );

  test('a known server keeps its session and only takes the colours', () async {
    await target.upsertServer(
      ServersCompanion.insert(
        url: 'https://chat.example.org',
        displayName: 'Mine',
        dbFile: 'b',
        addedAt: DateTime(2026),
        lastActiveAt: Value(DateTime(2026)),
      ),
    );
    final transfer = SettingsTransfer(target);
    await transfer.apply(
      await transfer.plan(
        parseSettingsFile(await exported()),
        stayConnected: null,
      ),
    );
    final server = (await target.allServers()).single;
    expect(server.displayName, 'Mine');
    expect(server.lastActiveAt, isNotNull);
    expect(server.themeMode, 'brandDark');
  });

  test('Stay connected is planned only where the device has it', () async {
    final file = SettingsFile(
      version: 1,
      servers: const [],
      settings: const {},
      stayConnected: true,
    );
    final transfer = SettingsTransfer(target);
    expect(
      (await transfer.plan(file, stayConnected: null)).stayConnected,
      isNull,
    );
    expect(
      (await transfer.plan(file, stayConnected: false)).stayConnected,
      isTrue,
    );
    expect(
      (await transfer.plan(file, stayConnected: true)).stayConnected,
      isNull,
    );
  });

  group('a file that is not ours is refused with a reason', () {
    Future<void> refused(String text, Matcher message) async {
      expect(
        () => parseSettingsFile(text),
        throwsA(
          isA<SettingsFileException>().having(
            (e) => e.message,
            'message',
            message,
          ),
        ),
      );
    }

    Map<String, Object?> valid() => {
      'version': 1,
      'servers': <Object?>[],
      'settings': <String, String>{},
    };

    test('not JSON, wrong shape, unknown key', () async {
      await refused('hello', contains('not a Matterleast'));
      await refused('[]', contains('not a Matterleast'));
      await refused(
        jsonEncode({...valid(), 'extra': 1}),
        contains('not a Matterleast'),
      );
    });

    test('a newer version', () async {
      await refused(
        jsonEncode({...valid(), 'version': 2}),
        contains('version 2'),
      );
    });

    test('an invalid server, setting or setting value', () async {
      Map<String, Object?> server(String url) => {
        'url': url,
        'displayName': 'x',
        'sortOrder': 0,
        'themeMode': 'brand',
      };
      await refused(
        jsonEncode({
          ...valid(),
          'servers': [server('ftp://host')],
        }),
        contains('invalid'),
      );
      await refused(
        jsonEncode({
          ...valid(),
          'settings': {'notificationsAsked': 'true'},
        }),
        contains('notificationsAsked'),
      );
      await refused(
        jsonEncode({
          ...valid(),
          'settings': {'keepDays': 'many'},
        }),
        contains('keepDays'),
      );
    });

    test('and changes nothing', () async {
      await expectLater(
        () => parseSettingsFile('{"version":1}'),
        throwsA(isA<SettingsFileException>()),
      );
      expect(await target.allServers(), isEmpty);
      expect(await target.allSettings(), isEmpty);
    });
  });

  test('the file name carries the local date', () {
    expect(
      settingsFileName(DateTime(2026, 1, 5, 23, 59)),
      'matterleast-settings-2026-01-05.json',
    );
    expect(
      settingsFileName(DateTime(2025, 12, 31)),
      'matterleast-settings-2025-12-31.json',
    );
  });
}
