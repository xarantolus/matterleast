import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/theme.dart';
import 'package:matterleast/app/update_providers.dart';
import 'package:matterleast/ui/refresh_area.dart';
import 'package:matterleast/ui/window_strip.dart';
import 'package:window_manager/window_manager.dart';

/// Runs [body] as [platform]; the override has to be gone before the test
/// ends.
Future<void> on(TargetPlatform platform, Future<void> Function() body) async {
  debugDefaultTargetPlatformOverride = platform;
  try {
    await body();
  } finally {
    debugDefaultTargetPlatformOverride = null;
  }
}

void main() {
  Widget app({ThemeData? theme}) => UncontrolledProviderScope(
    container: ProviderContainer.test(
      overrides: [availableUpdateProvider.overrideWithValue(null)],
    ),
    child: MaterialApp(
      theme: theme,
      builder: (context, child) => WindowFrame(child: child!),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Town Square'),
          actions: const [
            IconButton(
              tooltip: 'Search',
              onPressed: null,
              icon: Icon(Icons.search),
            ),
          ],
        ),
      ),
    ),
  );

  group('the window strip', () {
    testWidgets("its title is in the app's typeface", (tester) async {
      await on(TargetPlatform.linux, () async {
        await tester.pumpWidget(app(theme: buildTheme(Brightness.light)));
        final title = tester.widget<Text>(find.text('Matterleast'));
        expect(title.style?.fontFamily, appFont);
      });
    });

    for (final platform in [TargetPlatform.linux, TargetPlatform.windows]) {
      testWidgets('on ${platform.name}: a thin strip across the window above '
          'the app bar holds the drag area and the window buttons', (
        tester,
      ) async {
        await on(platform, () async {
          await tester.pumpWidget(app());
          final width =
              tester.view.physicalSize.width / tester.view.devicePixelRatio;
          final strip = tester.getRect(find.byType(WindowStrip));
          expect(strip, Rect.fromLTWH(0, 0, width, windowStripHeight));
          expect(tester.getTopLeft(find.byType(AppBar)).dy, windowStripHeight);

          final inStrip = find.descendant(
            of: find.byType(WindowStrip),
            matching: find.byType(DragToMoveArea),
          );
          expect(inStrip, findsOneWidget);
          expect(find.byType(DragToMoveArea), findsOneWidget);
          for (final button in ['Minimise', 'Maximise', 'Close']) {
            expect(find.byTooltip(button), findsOneWidget);
            expect(
              find.descendant(
                of: find.byType(WindowStrip),
                matching: find.byTooltip(button),
              ),
              findsOneWidget,
            );
          }
          final close = tester.getRect(find.byTooltip('Close'));
          expect(close.topRight, Offset(width, 0));
          expect(close.height, windowStripHeight);
          expect(
            find.descendant(
              of: find.byType(AppBar),
              matching: find.byTooltip('Close'),
            ),
            findsNothing,
          );
        });
      });
    }

    testWidgets('the strip grows with the system text size', (tester) async {
      await on(TargetPlatform.linux, () async {
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(app());
        expect(
          tester.getSize(find.byType(WindowStrip)).height,
          greaterThan(windowStripHeight),
        );
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('not on Android', (tester) async {
      await on(TargetPlatform.android, () async {
        await tester.pumpWidget(app());
        expect(find.text('Town Square'), findsOneWidget);
        expect(tester.getTopLeft(find.byType(AppBar)).dy, 0);
        expect(find.byType(WindowStrip), findsNothing);
        expect(find.byType(DragToMoveArea), findsNothing);
        for (final button in ['Minimise', 'Maximise', 'Close']) {
          expect(find.byTooltip(button), findsNothing);
        }
      });
    });
  });

  group('F5 refreshes like a pull', () {
    Widget list(String name, List<String> refreshed) => Scaffold(
      body: RefreshArea(
        onRefresh: () async => refreshed.add(name),
        child: ListView(children: [Text(name)]),
      ),
    );

    Future<void> pressF5(WidgetTester tester) async {
      await tester.sendKeyEvent(LogicalKeyboardKey.f5);
      await tester.pumpAndSettle();
    }

    testWidgets('on desktop, the page on top only', (tester) async {
      await on(TargetPlatform.linux, () async {
        final refreshed = <String>[];
        final navigator = GlobalKey<NavigatorState>();
        await tester.pumpWidget(
          MaterialApp(navigatorKey: navigator, home: list('home', refreshed)),
        );
        await pressF5(tester);
        expect(refreshed, ['home']);

        navigator.currentState!
            .push(
              MaterialPageRoute<void>(
                builder: (_) => list('pinned', refreshed),
              ),
            )
            .ignore();
        await tester.pumpAndSettle();
        await pressF5(tester);
        expect(refreshed, ['home', 'pinned']);

        navigator.currentState!.pop();
        await tester.pumpAndSettle();
        await pressF5(tester);
        expect(refreshed, ['home', 'pinned', 'home']);
        await tester.pumpWidget(const SizedBox());
      });
    });

    testWidgets('not on Android', (tester) async {
      await on(TargetPlatform.android, () async {
        final refreshed = <String>[];
        await tester.pumpWidget(MaterialApp(home: list('home', refreshed)));
        await pressF5(tester);
        expect(refreshed, isEmpty);
      });
    });
  });
}
