import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/data/server_db/server_config.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/root/root_screen.dart';

import '../support/pump_with_server.dart';
import '../support/rail.dart';
import '../support/servers.dart';

const _team = 'team0000000000000000000000';

Map<String, Object?> _config({
  String text = 'Maintenance at **noon**',
  bool dismissible = true,
}) => {
  'EnableBanner': 'true',
  'BannerText': text,
  'BannerColor': '#f2a52b',
  'BannerTextColor': '#000000',
  'AllowBannerDismissal': dismissible ? 'true' : 'false',
};

Future<ServerHarness> _open(
  WidgetTester tester, {
  Map<String, Object?>? config,
  bool licensed = true,
}) => pumpWithServer(
  tester,
  size: const Size(1400, 900),
  seed: (s) async {
    if (config != null) {
      await s.store.applyConfig(ConfigKeys.clientConfig, config);
    }
    await s.store.applyConfig(ConfigKeys.license, {
      'IsLicensed': licensed ? 'true' : 'false',
    });
  },
  overrides: (url) => [
    railSelectionProvider.overrideWith(
      () => MemoryRailSelection(RailTarget(url: url, teamId: _team)),
    ),
  ],
  home: (url) => RootScreen(servers: [testServerEntry(url)]),
);

Future<void> _change(
  WidgetTester tester,
  ServerHarness h,
  Map<String, Object?> config,
  bool Function() until,
) async {
  await tester.runAsync(
    () => h.session.store.applyConfig(ConfigKeys.clientConfig, config),
  );
  await h.settle(tester, until: until);
}

void main() {
  testWidgets('a licensed server\'s announcement shows as one line', (
    tester,
  ) async {
    final h = await _open(tester, config: _config());
    await h.settle(
      tester,
      until: () => find.text('Maintenance at noon').tryEvaluate(),
    );

    expect(find.text('Maintenance at noon'), findsOneWidget);
    expect(find.byTooltip('Dismiss'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('an unlicensed server shows no announcement', (tester) async {
    final h = await _open(tester, config: _config(), licensed: false);

    expect(find.textContaining('Maintenance'), findsNothing);
    await h.close(tester);
  });

  testWidgets('closing it hides it, and it stays hidden when the server '
      'sends the same text again', (tester) async {
    final h = await _open(tester, config: _config());
    await h.settle(
      tester,
      until: () => find.text('Maintenance at noon').tryEvaluate(),
    );

    await tester.tap(find.byTooltip('Dismiss'));
    await h.settle(
      tester,
      until: () => !find.text('Maintenance at noon').tryEvaluate(),
    );
    expect(find.textContaining('Maintenance'), findsNothing);

    await _change(tester, h, {..._config(), 'SiteName': 'Harbour'}, () => true);
    expect(find.textContaining('Maintenance'), findsNothing);
    await h.close(tester);
  });

  testWidgets('a new text shows the banner again', (tester) async {
    final h = await _open(tester, config: _config());
    await h.settle(
      tester,
      until: () => find.text('Maintenance at noon').tryEvaluate(),
    );
    await tester.tap(find.byTooltip('Dismiss'));
    await h.settle(
      tester,
      until: () => !find.text('Maintenance at noon').tryEvaluate(),
    );

    await _change(
      tester,
      h,
      _config(text: 'Back at one'),
      () => find.text('Back at one').tryEvaluate(),
    );

    expect(find.text('Back at one'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('without permission to dismiss there is no close button', (
    tester,
  ) async {
    final h = await _open(tester, config: _config(dismissible: false));
    await h.settle(
      tester,
      until: () => find.text('Maintenance at noon').tryEvaluate(),
    );

    expect(find.byTooltip('Dismiss'), findsNothing);
    await h.close(tester);
  });

  testWidgets('a tap opens the whole text, with a way to dismiss it', (
    tester,
  ) async {
    final h = await _open(
      tester,
      config: _config(text: 'Maintenance at noon.\n\nPlease save your work.'),
    );
    await h.settle(
      tester,
      until: () => find
          .text('Maintenance at noon. Please save your work.')
          .tryEvaluate(),
    );

    await tester.tap(find.byTooltip('Show announcement'));
    await h.settle(
      tester,
      until: () => find.text('Please save your work.').tryEvaluate(),
    );
    expect(find.text('Please save your work.'), findsOneWidget);

    await tester.tap(find.text('Dismiss'));
    await h.settle(
      tester,
      until: () => !find.byTooltip('Show announcement').tryEvaluate(),
    );
    expect(find.byTooltip('Show announcement'), findsNothing);
    await h.close(tester);
  });

  testWidgets('a removed announcement goes away', (tester) async {
    final h = await _open(tester, config: _config());
    await h.settle(
      tester,
      until: () => find.text('Maintenance at noon').tryEvaluate(),
    );

    await _change(tester, h, {
      'EnableBanner': 'false',
    }, () => !find.text('Maintenance at noon').tryEvaluate());

    expect(find.textContaining('Maintenance'), findsNothing);
    await h.close(tester);
  });
}
