import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/domain/post_files.dart';
import 'package:matterleast/screens/gallery/gallery_screen.dart';
import 'package:matterleast/screens/open_page.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/screens/root/pane_layout.dart';
import 'package:matterleast/ui/content_page.dart';
import 'package:matterleast/ui/post_files.dart';

/// A content view such as Threads, with a button that opens a picture.
class _Threads extends StatelessWidget {
  const _Threads();

  @override
  Widget build(BuildContext context) => ContentPage(
    title: const Text('Threads'),
    body: Center(
      child: TextButton(
        onPressed: () => openGallery(
          context,
          url: 'https://chat.example.test',
          media: const [PostFile(id: 'f1', name: 'boat.png')],
          index: 0,
          heroPrefix: 'test',
          author: 'Pat',
          sentAt: DateTime(2026),
        ),
        child: const Text('A picture'),
      ),
    ),
  );
}

/// A page such as Settings, leading to a page of its own.
class _Settings extends StatelessWidget {
  const _Settings();

  @override
  Widget build(BuildContext context) => ContentPage(
    title: const Text('Settings'),
    body: Center(
      child: TextButton(
        onPressed: () => openPage(
          Navigator.of(context),
          const ContentPage(title: Text('Display'), body: Text('Clock')),
        ),
        child: const Text('Open display'),
      ),
    ),
  );
}

void main() {
  Future<void> start(WidgetTester tester, {required Size size}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final db = AppDatabase(DatabaseConnection(NativeDatabase.memory()));
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            theme: MatterleastApp.lightTheme,
            navigatorObservers: [ref.watch(conversationRoutesProvider)],
            home: PaneLayout(
              list: ContentPage(
                focusRegion: false,
                title: const Text('Team'),
                body: Builder(
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        onPressed: () =>
                            openPage(Navigator.of(context), const _Threads()),
                        child: const Text('Open threads'),
                      ),
                      TextButton(
                        onPressed: () => openPage(
                          Navigator.of(context),
                          const _Settings(),
                          popout: true,
                        ),
                        child: const Text('Open settings'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    // The database answers outside the fake clock.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump();
  }

  Future<void> finish(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    // Drift closes its queries on a zero timer.
    await tester.pump(Duration.zero);
  }

  testWidgets('on a phone a content view takes the header and slides in '
      'below it, and Back goes to the list', (tester) async {
    await start(tester, size: const Size(400, 800));
    await tester.tap(find.text('Open threads'));
    await tester.pumpAndSettle();
    expect(find.byType(AppBar), findsOneWidget);
    expect(find.text('Threads'), findsOneWidget);
    expect(find.text('Team'), findsNothing);
    await tester.fling(find.text('A picture'), const Offset(300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Threads'), findsNothing);
    expect(find.text('Team'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('on a wide window a content view opens in the conversation '
      'pane beside the list, and Back closes it', (tester) async {
    await start(tester, size: const Size(1400, 900));
    expect(find.text('No conversation open'), findsOneWidget);
    await tester.tap(find.text('Open threads'));
    await tester.pumpAndSettle();
    // The list stays; the view covers only the pane.
    expect(find.text('Team'), findsOneWidget);
    expect(find.text('Threads'), findsOneWidget);
    final listRight = tester.getTopRight(find.text('Open threads')).dx;
    expect(tester.getTopLeft(find.text('Threads')).dx, greaterThan(listRight));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Threads'), findsNothing);
    expect(find.text('No conversation open'), findsOneWidget);
    await finish(tester);
  });

  testWidgets('a picture opened from a view in the pane covers the whole '
      'window', (tester) async {
    await start(tester, size: const Size(1400, 900));
    await tester.tap(find.text('Open threads'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('A picture'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    final gallery = find.byType(GalleryScreen);
    expect(gallery, findsOneWidget);
    expect(tester.getRect(gallery), Offset.zero & const Size(1400, 900));
    await finish(tester);
  });

  testWidgets('on desktop settings open in a card over the window; their '
      'pages open inside it, and Esc goes back, then closes it', (
    tester,
  ) async {
    await start(tester, size: const Size(1400, 900));
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    final card = find.byType(Dialog);
    expect(
      find.descendant(of: card, matching: find.text('Settings')),
      findsOneWidget,
    );
    expect(
      tester
          .getSize(
            find.ancestor(
              of: find.text('Settings'),
              matching: find.byType(AppBar),
            ),
          )
          .width,
      lessThan(1400 * 0.6),
    );
    await tester.tap(find.text('Open display'));
    await tester.pumpAndSettle();
    expect(
      find.descendant(of: card, matching: find.text('Clock')),
      findsOneWidget,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Clock'), findsNothing);
    expect(find.text('Open display'), findsOneWidget);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(card, findsNothing);
    await finish(tester);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));
}
