import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/screens/gallery/pdf_screen.dart';
import 'package:pdfrx/pdfrx.dart';

const _server = 'http://localhost:8065';

void main() {
  setUpAll(() async {
    // pdfium_dart looks for the library next to flutter_tester or through
    // dartdev's .dart_tool/native_assets.yaml, but flutter test puts the
    // build hook's output here.
    Pdfrx.pdfiumModulePath = File('build/native_assets/linux/libpdfium.so')
        .absolute
        .path;
    Pdfrx.cacheDirectoryPath = Directory.systemTemp.path;
    await pdfrxFlutterInitialize();
  });

  Future<void> show(WidgetTester tester, String name) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          featuresProvider(_server).overrideWith((ref) => const Stream.empty()),
        ],
        child: MaterialApp(
          theme: MatterleastApp.lightTheme,
          home: PdfScreen(
            local: File('test/fixtures/pdf/$name'),
            url: _server,
            file: PostFile(id: 'f1', name: name, extension: 'pdf'),
          ),
        ),
      ),
    );
  }

  /// PDFium answers outside the fake clock; the viewer's timers inside it.
  Future<void> waitFor(WidgetTester tester, Finder finder) async {
    for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(finder, findsWidgets);
  }

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    for (var i = 0; i < 5; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 200));
    }
  }

  testWidgets('a search finds and counts every match in the document', (
    tester,
  ) async {
    await show(tester, 'guide.pdf');
    await waitFor(tester, find.byTooltip('Search'));
    // The guide has an outline, so its contents can be opened.
    await waitFor(tester, find.byTooltip('Contents'));

    await tester.tap(find.byTooltip('Search'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'heron');
    await waitFor(tester, find.text('1 of 4'));

    await tester.tap(find.byTooltip('Next match'));
    await waitFor(tester, find.text('2 of 4'));

    await tester.enterText(find.byType(TextField), 'pelican');
    await waitFor(tester, find.text('No matches'));
    await close(tester);
  });

  testWidgets('a PDF with a password asks for it until it opens', (
    tester,
  ) async {
    await show(tester, 'locked.pdf');
    await waitFor(tester, find.text('Password needed'));
    expect(find.byTooltip('Search'), findsNothing);

    await tester.enterText(find.byType(TextField), 'albatross');
    await tester.tap(find.text('Open'));
    await waitFor(
      tester,
      find.text("That password didn't open it. Try again."),
    );

    await tester.tap(find.text('Cancel'));
    await waitFor(tester, find.text('This PDF has a password'));

    await tester.tap(find.text('Enter password'));
    await waitFor(tester, find.text('Password needed'));
    expect(find.text("That password didn't open it. Try again."), findsNothing);
    await tester.enterText(find.byType(TextField), 'kingfisher');
    await tester.tap(find.text('Open'));
    await waitFor(tester, find.byTooltip('Search'));
    // One page and no outline: nothing to list.
    expect(find.byTooltip('Contents'), findsNothing);
    await close(tester);
  });

  test('the match count reads like a sentence', () {
    String text(String query, int matches, int? current, bool searching) =>
        matchCountText(
          query: query,
          matches: matches,
          current: current,
          searching: searching,
        );
    expect(text('', 0, null, false), '');
    expect(text('owl', 0, null, true), 'Searching…');
    expect(text('owl', 0, null, false), 'No matches');
    expect(text('owl', 3, 0, true), '1 of 3…');
    expect(text('owl', 3, 2, false), '3 of 3');
    expect(text('owl', 3, null, false), '3');
  });
}
