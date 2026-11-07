import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/search/quick_search.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';

void main() {
  late ServerHarness h;

  Future<void> search(WidgetTester tester, Reply groups) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    h = await pumpWithServer(
      tester,
      handle: (r) => switch ((r.method, r.path)) {
        ('POST', '/api/v4/channels/group/search') => groups,
        _ => ok(const <Object?>[]),
      },
      home: (url) => QuickSearchView(
        controller: controller,
        servers: [
          ServerEntry(
            url: url,
            displayName: 'Test',
            siteName: null,
            serverVersion: null,
            diagnosticId: null,
            lastActiveAt: DateTime(2026),
            ssoScheme: null,
          ),
        ],
        target: null,
        onOpen: (_) {},
      ),
    );
    controller.text = 'bobby';
    await h.settle(tester);
  }

  testWidgets('a group message the phone has not stored is found by member', (
    tester,
  ) async {
    await search(
      tester,
      ok([
        {
          'id': 'gm000000000000000000000g01',
          'type': 'G',
          'name': 'abc',
          'display_name': 'bobby, river, tide',
        },
      ]),
    );
    expect(find.text('bobby, river, tide'), findsOneWidget);
    final asked = h.server.seen.singleWhere(
      (r) => r.path == '/api/v4/channels/group/search',
    );
    expect(asked.body['term'], 'bobby');
    await h.close(tester);
  });

  testWidgets('a server without the search leaves the other results alone', (
    tester,
  ) async {
    await search(tester, error(404, 'api.not_found'));
    expect(find.text('bobby, river, tide'), findsNothing);
    expect(find.textContaining("Couldn't"), findsNothing);
    await h.close(tester);
  });
}
