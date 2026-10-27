import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/refresh_area.dart';
import 'package:matterleast/ui/update_indicator.dart';
import 'package:matterleast/ui/window_bar.dart';
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
  Widget page({bool corner = true}) => MaterialApp(
    home: WindowCorner(
      here: corner,
      child: Scaffold(
        appBar: WindowAppBar(
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

  group('the app bar is the window title bar', () {
    for (final platform in [TargetPlatform.linux, TargetPlatform.windows]) {
      testWidgets('on ${platform.name}: drag area, window buttons last', (
        tester,
      ) async {
        await on(platform, () async {
          await tester.pumpWidget(page());
          expect(find.byType(DragToMoveArea), findsOneWidget);
          for (final button in ['Minimise', 'Maximise', 'Close']) {
            expect(find.byTooltip(button), findsOneWidget);
          }
          final width =
              tester.view.physicalSize.width / tester.view.devicePixelRatio;
          final close = tester.getRect(find.byTooltip('Close'));
          expect(close.topRight, Offset(width, 0));
          expect(close.size, const Size(46, kToolbarHeight));
          expect(
            tester.getTopRight(find.byTooltip('Search')).dx,
            lessThanOrEqualTo(tester.getTopLeft(find.byTooltip('Minimise')).dx),
          );
        });
      });
    }

    testWidgets('a pane away from the top right corner has no buttons', (
      tester,
    ) async {
      await on(TargetPlatform.linux, () async {
        await tester.pumpWidget(page(corner: false));
        expect(find.byType(DragToMoveArea), findsOneWidget);
        expect(find.byTooltip('Close'), findsNothing);
      });
    });

    testWidgets('a page pushed over the whole window has them', (tester) async {
      await on(TargetPlatform.linux, () async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(appBar: WindowAppBar(title: const Text('Settings'))),
          ),
        );
        expect(find.byTooltip('Close'), findsOneWidget);
      });
    });

    testWidgets('not on Android', (tester) async {
      await on(TargetPlatform.android, () async {
        await tester.pumpWidget(page());
        expect(find.text('Town Square'), findsOneWidget);
        expect(find.byType(DragToMoveArea), findsNothing);
        expect(find.byTooltip('Close'), findsNothing);
        expect(find.byTooltip('Minimise'), findsNothing);
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
