import 'dart:async';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/data/app_db/settings.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/screens/root/conversation_memory.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/ui/conversation_route.dart';

const _general = ChannelTarget(
  url: 'https://chat.example.test',
  channelId: 'c1',
  title: 'General',
  teamId: 't1',
);

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<String?> stored() async =>
      (await db.allSettings())[Settings.lastConversation.key];

  testWidgets('the open conversation is remembered until it is closed', (
    tester,
  ) async {
    final routes = container.read(conversationRoutesProvider);
    await tester.runAsync(container.read(conversationMemoryProvider).start);
    final navigatorKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: navigatorKey,
          navigatorObservers: [routes],
          home: const Scaffold(body: Text('list')),
        ),
      ),
    );

    unawaited(
      navigatorKey.currentState!.push(
        ConversationRoute<void>(
          target: _general,
          builder: (_) => const Scaffold(body: Text('chat')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    expect(await tester.runAsync(stored), contains('"channelId":"c1"'));

    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    expect(await tester.runAsync(stored), isEmpty);
  });

  testWidgets('a conversation in a pane is remembered too', (tester) async {
    await tester.runAsync(container.read(conversationMemoryProvider).start);
    container.read(openPanesProvider.notifier).open(_general);
    await tester.runAsync(() => Future<void>.delayed(Duration.zero));
    expect(await tester.runAsync(stored), contains('"channelId":"c1"'));
  });
}
