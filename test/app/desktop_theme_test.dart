import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/theme.dart';

void main() {
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

  Future<void> showPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        // Built here: Material picks its density from the platform.
        theme: themeForPlatform(buildTheme(Brightness.light)),
        home: Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
            actions: [
              IconButton(
                tooltip: 'Search',
                onPressed: () {},
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          body: ListView(
            children: const [
              ListTile(dense: true, title: Text('Town Square')),
              ListTile(title: Text('Display'), subtitle: Text('Clock')),
            ],
          ),
        ),
      ),
    );
  }

  double height(WidgetTester tester, String text) => tester
      .getSize(
        find.ancestor(of: find.text(text), matching: find.byType(ListTile)),
      )
      .height;

  double fontSize(WidgetTester tester, String text) => tester
      .renderObject<RenderParagraph>(find.text(text))
      .text
      .style!
      .fontSize!;

  for (final platform in [TargetPlatform.windows, TargetPlatform.linux]) {
    testWidgets('a ${platform.name} window gets mouse sizes', (tester) async {
      await on(platform, () async {
        await showPage(tester);
        expect(tester.getSize(find.byType(AppBar)).height, 48);
        expect(height(tester, 'Town Square'), 36);
        expect(height(tester, 'Display'), 60);
        expect(fontSize(tester, 'Display'), 14);
        expect(tester.getSize(find.byType(IconButton)).height, 36);
      });
    });
  }

  testWidgets('a phone keeps touch sizes', (tester) async {
    await on(TargetPlatform.android, () async {
      await showPage(tester);
      expect(tester.getSize(find.byType(AppBar)).height, kToolbarHeight);
      expect(height(tester, 'Town Square'), 48);
      expect(height(tester, 'Display'), 72);
      expect(fontSize(tester, 'Display'), 16);
      expect(tester.getSize(find.byType(IconButton)).height, 48);
    });
  });

  testWidgets('desktop rows hold their text at 1.5 times the system text '
      'size', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await on(TargetPlatform.linux, () async {
      await showPage(tester);
      expect(tester.takeException(), isNull);
      for (final (row, text) in [
        ('Town Square', 'Town Square'),
        ('Display', 'Clock'),
      ]) {
        final tile = tester.getRect(
          find.ancestor(of: find.text(row), matching: find.byType(ListTile)),
        );
        final shown = tester.getRect(find.text(text));
        expect(tile.top <= shown.top && shown.bottom <= tile.bottom, isTrue);
      }
    });
  });
}
