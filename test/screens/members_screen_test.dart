import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/data/servers/server_session.dart';
import 'package:matterleast/screens/channel_info/members_screen.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

Map<String, Object?> _user(String id, String name) => {
  'id': id,
  'username': name,
  'first_name': name,
  'roles': 'system_user',
};

void main() {
  late FakeServer server;
  late ServerSession session;

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  Future<void> start(WidgetTester tester, {required bool canRemove}) async {
    HttpOverrides.global = null;
    (server, session) = (await tester.runAsync(() async {
      final server = await FakeServer.start();
      server.handle = (r) => switch ((r.method, r.path)) {
        ('GET', '/api/v4/users') => ok([
          _user(meId, 'river'),
          _user('u2', 'Mira'),
        ]),
        ('DELETE', _) => ok({'status': 'OK'}),
        _ => ok(const <String, Object?>{}),
      };
      return (server, await testSession(server));
    }))!;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serverSessionProvider(server.url.toString())
              .overrideWith((ref) async => session),
          serverImageCachesProvider(server.url.toString())
              .overrideWith((ref) => Completer<ServerImageCaches>().future),
        ],
        child: MaterialApp(
          theme: MatterleastApp.lightTheme,
          home: MembersScreen(
            url: server.url.toString(),
            channelId: channelId,
            teamId: teamId,
            title: 'Boats',
            canAdd: false,
            canRemove: canRemove,
          ),
        ),
      ),
    );
    await settle(tester);
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await settle(tester);
    await tester.runAsync(() async {
      await closeTestSession(session);
      await server.close();
    });
  }

  testWidgets('removing a member after confirming drops them from the list', (
    tester,
  ) async {
    await start(tester, canRemove: true);
    expect(find.text('Mira'), findsOneWidget);
    await tester.tap(find.byTooltip('Remove Mira from channel'));
    await settle(tester);
    expect(find.text('Remove from Channel'), findsOneWidget);
    await tester.tap(find.text('Remove'));
    await settle(tester);
    expect(find.text('Mira'), findsNothing);
    expect(
      server.seen.any(
        (r) => r.method == 'DELETE' && r.path.endsWith('/members/u2'),
      ),
      isTrue,
    );
    await finish(tester);
  });

  testWidgets('cancelling the confirm keeps the member', (tester) async {
    await start(tester, canRemove: true);
    await tester.tap(find.byTooltip('Remove Mira from channel'));
    await settle(tester);
    await tester.tap(find.text('Cancel'));
    await settle(tester);
    expect(find.text('Mira'), findsOneWidget);
    expect(server.seen.any((r) => r.method == 'DELETE'), isFalse);
    await finish(tester);
  });

  testWidgets('without the right there are no remove buttons', (tester) async {
    await start(tester, canRemove: false);
    expect(find.byTooltip('Remove Mira from channel'), findsNothing);
    await finish(tester);
  });

  testWidgets('you get no remove button for yourself', (tester) async {
    await start(tester, canRemove: true);
    expect(find.byTooltip('Remove Mira from channel'), findsOneWidget);
    expect(find.byTooltip('Remove river from channel'), findsNothing);
    await finish(tester);
  });
}
