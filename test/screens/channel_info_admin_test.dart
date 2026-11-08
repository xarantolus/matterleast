import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/screens/channel_info/channel_info_screen.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/seed.dart';
import '../support/test_session.dart';

void main() {
  late ServerHarness h;

  Future<void> start(
    WidgetTester tester, {
    required List<String> permissions,
    Reply? archive,
    bool archived = false,
  }) async {
    h = await pumpWithServer(
      tester,
      size: const Size(900, 1600),
      handle: (r) => switch ((r.method, r.path)) {
        ('DELETE', final p) when p.endsWith('/channels/$channelId') =>
          archive ?? ok({'status': 'OK'}),
        ('PUT', final p) when p.endsWith('/privacy') => ok({
          'id': channelId,
          'team_id': teamId,
          'type': 'P',
          'name': 'boats',
          'display_name': 'Boats',
        }),
        _ => emptyAnswer(r),
      },
      seed: (session) async {
        await seedMyPermissions(session, permissions);
        if (archived) {
          await session.store.applyChannelArchived(
            channelId,
            DateTime.utc(2026, 10, 1),
          );
        }
      },
      home: (url) => ChannelInfoScreen(url: url, channelId: channelId),
    );
  }

  Future<void> openArchiveDialog(WidgetTester tester) async {
    await tester.scrollUntilVisible(find.text('Archive channel'), 300);
    await tester.tap(find.text('Archive channel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('without the rights no admin option is offered', (tester) async {
    await start(tester, permissions: const []);
    expect(find.text('Archive channel'), findsNothing);
    expect(find.text('Convert to private channel'), findsNothing);
    await h.close(tester);
  });

  testWidgets('archiving asks first, then sends the delete', (tester) async {
    await start(tester, permissions: const ['delete_public_channel']);
    await openArchiveDialog(tester);
    expect(find.text('Archive Boats?'), findsOneWidget);
    expect(h.server.seen.any((r) => r.method == 'DELETE'), isFalse);
    await tester.tap(find.text('Archive').last);
    await h.settle(tester);
    expect(
      h.server.seen.where((r) => r.method == 'DELETE').single.path,
      endsWith('/channels/$channelId'),
    );
    await h.close(tester);
  });

  testWidgets('cancelling the archive sends nothing', (tester) async {
    await start(tester, permissions: const ['delete_public_channel']);
    await openArchiveDialog(tester);
    await tester.tap(find.text('Cancel'));
    await h.settle(tester);
    expect(h.server.seen.any((r) => r.method == 'DELETE'), isFalse);
    await h.close(tester);
  });

  testWidgets('a refused archive says what the server said', (tester) async {
    await start(
      tester,
      permissions: const ['delete_public_channel'],
      archive: error(403, 'api.channel.delete_channel.disabled.app_error'),
    );
    await openArchiveDialog(tester);
    await tester.tap(find.text('Archive').last);
    await h.settle(tester);
    expect(find.textContaining("Couldn't archive Boats"), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('converting to private sends the privacy change', (tester) async {
    await start(
      tester,
      permissions: const ['convert_public_channel_to_private'],
    );
    await tester.scrollUntilVisible(
      find.text('Convert to private channel'),
      300,
    );
    await tester.tap(find.text('Convert to private channel'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.text('Convert').last);
    await h.settle(tester);
    final put = h.server.seen.singleWhere((r) => r.method == 'PUT');
    expect(put.path, endsWith('/privacy'));
    expect(put.body['privacy'], 'P');
    await h.close(tester);
  });

  testWidgets('an archived channel offers Unarchive only with team rights', (
    tester,
  ) async {
    await start(tester, permissions: const [], archived: true);
    expect(find.text('Unarchive channel'), findsNothing);
    await h.close(tester);
  });
}
