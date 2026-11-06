import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/screens/channel/channel_screen.dart';
import 'package:matterleast/screens/channel/header_strip.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

const _link = 'https://example.test/weekly';
const _header =
    '[Weekly meeting]($_link) every Tuesday, bring the tide tables and '
    'the harbour charts and anything else the crew needs to see before '
    'the boats go out on the water';

Future<ServerHarness> _open(WidgetTester tester, {String header = ''}) =>
    pumpWithServer(
      tester,
      handle: (r) => ok(<String, Object?>{}),
      seed: (session) => session.store.applyChannels(
        channels: [
          api.Channel.fromJson({
            'id': channelId,
            'team_id': teamId,
            'type': 'O',
            'name': 'boats',
            'display_name': 'Boats',
            'header': header,
            'total_msg_count': 1,
          }),
        ],
        members: const [],
      ),
      home: (url) =>
          ChannelScreen(url: url, channelId: channelId, title: 'Boats'),
    );

void main() {
  testWidgets('a header with a link is shown and the link opens', (
    tester,
  ) async {
    final launched = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/url_launcher'),
      (call) async {
        if (call.method == 'canLaunch') return true;
        launched.add((call.arguments as Map)['url'] as String);
        return true;
      },
    );
    final h = await _open(tester, header: _header);

    expect(find.byType(HeaderStrip), findsOneWidget);
    await tester.tapOnText(find.textRange.ofSubstring('Weekly meeting'));
    await h.settle(tester);

    expect(launched, [_link]);
    await h.close(tester);
  });

  testWidgets(
    'a tap on the text shows the whole header and a second hides it',
    (tester) async {
      final h = await _open(tester, header: _header);
      final strip = find.byType(HeaderStrip);
      final oneLine = tester.getSize(strip).height;

      await tester.tapOnText(find.textRange.ofSubstring('every Tuesday'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.getSize(strip).height, greaterThan(oneLine));

      await tester.tapOnText(find.textRange.ofSubstring('every Tuesday'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.getSize(strip).height, oneLine);
      await h.close(tester);
    },
  );

  testWidgets('a header that fits offers nothing to expand', (tester) async {
    final h = await _open(tester, header: 'Boats only');

    expect(find.byIcon(Icons.expand_more), findsNothing);
    expect(find.byTooltip('Show the whole header'), findsNothing);
    final oneLine = tester.getSize(find.byType(HeaderStrip)).height;
    await tester.tapOnText(find.textRange.ofSubstring('Boats only'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.getSize(find.byType(HeaderStrip)).height, oneLine);
    await h.close(tester);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('a cut header shows that it opens', (tester) async {
    final h = await _open(tester, header: _header);

    expect(find.byIcon(Icons.expand_more), findsOneWidget);
    await tester.tap(find.byIcon(Icons.expand_more));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byIcon(Icons.expand_less), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('a channel without a header has no strip', (tester) async {
    final h = await _open(tester);

    expect(tester.getSize(find.byType(HeaderStrip)).height, 0);
    await h.close(tester);
  });
}
