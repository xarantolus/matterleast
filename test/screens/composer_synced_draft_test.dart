import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/app/permission_providers.dart';
import 'package:matterleast/data/server_db/server_config.dart';
import 'package:matterleast/screens/channel/composer.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

Future<ServerHarness> _pump(WidgetTester tester) => pumpWithServer(
  tester,
  handle: emptyAnswer,
  overrides: (url) => [
    channelRightsProvider(url, channelId).overrideWith(
      (ref) => Stream.value((
        block: null,
        react: true,
        editOwn: true,
        editOthers: false,
        deleteOwn: true,
        deleteOthers: false,
        channelMentions: true,
        groupMentions: true,
      )),
    ),
  ],
  seed: (session) => session.store.applyConfig(ConfigKeys.clientConfig, {
    'AllowSyncedDrafts': 'true',
  }),
  home: (url) => Scaffold(
    body: Align(
      alignment: Alignment.bottomCenter,
      child: Composer(
        url: url,
        channelId: channelId,
        teamId: teamId,
        hint: 'Write',
      ),
    ),
  ),
);

api.Draft _draft(String message, int at) => api.Draft.fromJson({
  'channel_id': channelId,
  'root_id': '',
  'user_id': meId,
  'message': message,
  'create_at': at,
  'update_at': at,
});

void main() {
  testWidgets('a draft written on another device fills the empty open '
      'composer', (tester) async {
    final h = await _pump(tester);
    unawaited(
      h.session.connection.drafts.applyEvent(
        _draft('from my laptop', 1000),
        deleted: false,
      ),
    );
    await h.settle(tester);
    expect(find.text('from my laptop'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('a draft from another device never replaces what is being '
      'typed', (tester) async {
    final h = await _pump(tester);
    await tester.enterText(find.byType(TextField), 'my own words');
    await tester.pump();
    unawaited(
      h.session.connection.drafts.applyEvent(
        _draft('from my laptop', 1000),
        deleted: false,
      ),
    );
    await h.settle(tester);
    expect(find.text('my own words'), findsOneWidget);
    expect(find.text('from my laptop'), findsNothing);
    // Leaving sends the typed draft; wait for it before the server closes.
    await tester.pumpWidget(const SizedBox());
    await h.settle(
      tester,
      until: () => h.server.seen.any(
        (r) => r.method == 'POST' && r.path == '/api/v4/drafts',
      ),
    );
    await h.close(tester);
  });
}
