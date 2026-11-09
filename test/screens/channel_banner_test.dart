import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/data/server_db/server_config.dart';
import 'package:matterleast/screens/channel/channel_screen.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

api.Channel _channel({Map<String, Object?>? banner}) => api.Channel.fromJson({
  'id': channelId,
  'team_id': teamId,
  'type': 'O',
  'name': 'boats',
  'display_name': 'Boats',
  'total_msg_count': 1,
  'banner_info': ?banner,
});

const _banner = {
  'enabled': true,
  'text': 'Read the **harbour rules** first',
  'background_color': '#1c58d9',
};

Future<ServerHarness> _open(
  WidgetTester tester, {
  Map<String, Object?>? banner = _banner,
  String sku = 'advanced',
}) => pumpWithServer(
  tester,
  handle: emptyAnswer,
  seed: (session) async {
    await session.store.applyConfig(ConfigKeys.license, {
      'IsLicensed': 'true',
      'SkuShortName': sku,
    });
    await session.store.applyChannels(
      channels: [_channel(banner: banner)],
      members: const [],
    );
  },
  home: (url) => ChannelScreen(url: url, channelId: channelId, title: 'Boats'),
);

void main() {
  testWidgets('a channel banner shows under the app bar as one line', (
    tester,
  ) async {
    final h = await _open(tester);

    expect(find.text('Read the harbour rules first'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('a tap opens the whole banner', (tester) async {
    final h = await _open(
      tester,
      banner: {..._banner, 'text': 'Line one\n\nLine two'},
    );

    await tester.tap(find.byTooltip('Show the whole banner'));
    await h.settle(tester, until: () => find.text('Line two').tryEvaluate());

    expect(find.text('Line two'), findsOneWidget);
    expect(find.text('Dismiss'), findsNothing);
    await h.close(tester);
  });

  testWidgets('a banner that is switched off shows nothing', (tester) async {
    final h = await _open(tester, banner: {..._banner, 'enabled': false});

    expect(find.textContaining('harbour rules'), findsNothing);
    await h.close(tester);
  });

  testWidgets('a channel without a banner shows nothing', (tester) async {
    final h = await _open(tester, banner: null);

    expect(find.byTooltip('Show the whole banner'), findsNothing);
    await h.close(tester);
  });

  testWidgets('a server without the licence for it shows nothing', (
    tester,
  ) async {
    final h = await _open(tester, sku: 'professional');

    expect(find.textContaining('harbour rules'), findsNothing);
    await h.close(tester);
  });

  testWidgets('a change to the banner shows at once', (tester) async {
    final h = await _open(tester);
    expect(find.text('Read the harbour rules first'), findsOneWidget);

    await tester.runAsync(
      () => h.session.store.applyChannel(
        _channel(banner: {..._banner, 'text': 'Closed for repairs'}),
      ),
    );
    await h.settle(
      tester,
      until: () => find.text('Closed for repairs').tryEvaluate(),
    );

    expect(find.text('Closed for repairs'), findsOneWidget);
    expect(find.textContaining('harbour rules'), findsNothing);
    await h.close(tester);
  });
}
