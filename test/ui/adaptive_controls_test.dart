import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/theme.dart';
import 'package:matterleast/screens/settings/settings_widgets.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/refresh_area.dart';

void main() {
  /// A bare app whose theme is built on the platform under test.
  Future<void> pumpApp(WidgetTester tester, Widget home) => tester.pumpWidget(
    MaterialApp(theme: buildTheme(Brightness.light), home: home),
  );

  /// The widget tests check the override is unset before any tear-down.
  Future<void> on(TargetPlatform platform, Future<void> Function() body) async {
    debugDefaultTargetPlatformOverride = platform;
    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  test('only iOS uses its own dialogs and sheets', () {
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final uses = {
      for (final platform in TargetPlatform.values)
        platform: () {
          debugDefaultTargetPlatformOverride = platform;
          return usesCupertinoDialogs;
        }(),
    };
    expect(uses.entries.where((e) => e.value).map((e) => e.key), [
      TargetPlatform.iOS,
    ]);
  });

  test('iOS pages use the Cupertino transition and Android keeps its own', () {
    final builders = buildTheme(Brightness.light).pageTransitionsTheme.builders;
    expect(
      builders[TargetPlatform.iOS],
      isA<CupertinoPageTransitionsBuilder>(),
    );
    expect(
      builders[TargetPlatform.android],
      isA<PredictiveBackPageTransitionsBuilder>(),
    );
  });

  final elsewhere = [
    TargetPlatform.android,
    TargetPlatform.linux,
    TargetPlatform.windows,
  ];

  Future<void> showConfirm(WidgetTester tester) async {
    await pumpApp(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => confirm(
            context,
            title: 'Sure?',
            body: 'Really.',
            action: 'Do it',
          ),
          child: const Text('ask'),
        ),
      ),
    );
    await tester.tap(find.text('ask'));
    await tester.pumpAndSettle();
  }

  for (final platform in elsewhere) {
    testWidgets('a question is a Material dialog on $platform', (tester) async {
      await on(platform, () async {
        await showConfirm(tester);
        expect(find.byType(CupertinoAlertDialog), findsNothing);
        expect(find.byType(CupertinoDialogAction), findsNothing);
        expect(find.widgetWithText(TextButton, 'Do it'), findsOneWidget);
      });
    });
  }

  testWidgets('a question is an iOS alert on iOS and still answers', (
    tester,
  ) async {
    await on(TargetPlatform.iOS, () async {
      await showConfirm(tester);
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.byType(CupertinoDialogAction), findsNWidgets(2));
      await tester.tap(find.text('Do it'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsNothing);
    });
  });

  Future<Future<String?>> pick(WidgetTester tester) async {
    late Future<String?> picked;
    await pumpApp(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => picked = pickOne<String>(
            context,
            title: 'Theme',
            options: const ['light', 'dark'],
            current: 'light',
            label: (v) => v,
          ),
          child: const Text('pick'),
        ),
      ),
    );
    await tester.tap(find.text('pick'));
    await tester.pumpAndSettle();
    return picked;
  }

  for (final platform in elsewhere) {
    testWidgets('choosing one is a radio dialog on $platform', (tester) async {
      await on(platform, () async {
        final picked = await pick(tester);
        expect(find.byType(CupertinoActionSheet), findsNothing);
        await tester.tap(find.text('dark'));
        await tester.pumpAndSettle();
        expect(await picked, 'dark');
      });
    });
  }

  testWidgets('choosing one is an action sheet on iOS with the same result', (
    tester,
  ) async {
    await on(TargetPlatform.iOS, () async {
      final picked = await pick(tester);
      expect(find.byType(CupertinoActionSheet), findsOneWidget);
      expect(find.byType(RadioListTile<String>), findsNothing);
      await tester.tap(find.text('dark'));
      await tester.pumpAndSettle();
      expect(await picked, 'dark');
    });
  });

  Future<void> pumpControls(WidgetTester tester) => pumpApp(
    tester,
    Scaffold(
      body: Column(
        children: [
          SwitchListTile.adaptive(
            value: true,
            onChanged: (_) {},
            title: const Text('s'),
          ),
          const CircularProgressIndicator.adaptive(),
          Expanded(
            child: RefreshArea(
              onRefresh: () async {},
              child: ListView(children: const [Text('row')]),
            ),
          ),
        ],
      ),
    ),
  );

  for (final platform in elsewhere) {
    testWidgets('spinners and refresh are Material on $platform', (
      tester,
    ) async {
      await on(platform, () async {
        await pumpControls(tester);
        expect(find.byType(CupertinoActivityIndicator), findsNothing);
        expect(find.byType(CupertinoSliverRefreshControl), findsNothing);
        expect(find.byType(Switch), findsOneWidget);
      });
    });
  }

  testWidgets('spinners and refresh are iOS ones on iOS', (tester) async {
    await on(TargetPlatform.iOS, () async {
      await pumpControls(tester);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byType(CupertinoActivityIndicator), findsWidgets);
    });
  });
}
