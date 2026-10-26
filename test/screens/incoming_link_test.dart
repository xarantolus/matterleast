import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/incoming_links.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/server_entry.dart';

import '../support/fake_server.dart';
import '../support/test_session.dart';

void main() {
  testWidgets('a link from another app asks before it starts a conversation', (
    tester,
  ) async {
    HttpOverrides.global = null;
    final (server, session) = (await tester.runAsync(() async {
      final server = await FakeServer.start();
      final session = await testSession(server);
      await session.store.applyUsers([
        api.User.fromJson({
          'id': 'skipper0000000000000000u1',
          'username': 'skipper',
        }),
      ]);
      return (server, session);
    }))!;
    final url = server.url.toString();
    final link = Uri.parse(
      'matterleast://${server.url.authority}/harbour/messages/@skipper',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          serversProvider.overrideWith(
            (ref) => Stream.value([
              ServerEntry(
                url: url,
                displayName: 'Harbour',
                siteName: null,
                serverVersion: '12.0.1',
                diagnosticId: null,
                lastActiveAt: DateTime.utc(2026, 10, 25),
                ssoScheme: null,
              ),
            ]),
          ),
          serverSessionProvider(url).overrideWith((ref) async => session),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Consumer(
              builder: (context, ref, _) {
                // The rail keeps the server list alive in the app.
                ref.watch(serversProvider);
                return TextButton(
                  onPressed: () =>
                      openIncomingLink(Navigator.of(context), link),
                  child: const Text('open'),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    for (
      var i = 0;
      i < 100 && find.byType(AlertDialog).evaluate().isEmpty;
      i++
    ) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
    }

    expect(find.text('Message @skipper?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    expect(server.paths, isNot(contains('/api/v4/channels/direct')));

    await tester.runAsync(() async {
      await closeTestSession(session);
      await server.close();
    });
  });
}
