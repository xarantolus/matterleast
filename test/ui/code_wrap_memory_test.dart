import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/app_db/app_database.dart';
import 'package:matterleast/ui/markdown/code_block.dart';
import 'package:matterleast/ui/message_display.dart';

import '../support/memory_database.dart';

const _long =
    'final answer = computeTheAnswerToEverything(lifeTheUniverse, '
    'andEverythingElse, withExtraCareForTheLongestArgumentNames);';

/// Blocks follow the stored setting the way the app does.
class _Follow extends ConsumerWidget {
  const _Follow({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) => MessageDisplay(
    textScale: 1,
    wrapCode: ref.watch(wrapCodeProvider).value ?? false,
    child: child,
  );
}

void main() {
  late AppDatabase db;

  setUp(() => db = memoryAppDatabase());
  tearDown(() => db.close());

  Finder sideways() => find.ancestor(
    of: find.textContaining('computeTheAnswer', findRichText: true),
    matching: find.byWidgetPredicate(
      (w) => w is SingleChildScrollView && w.scrollDirection == Axis.horizontal,
    ),
  );

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 3; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump(const Duration(milliseconds: 20));
    }
  }

  /// Drift closes its queries on a zero timer.
  Future<void> unmount(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pump(Duration.zero);
  }

  /// A fresh app run over the same database, like a restart.
  Future<void> launch(WidgetTester tester, int blocks) async {
    tester.view.physicalSize = const Size(320, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await unmount(tester);
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: MatterleastApp.lightTheme,
          builder: (context, home) => _Follow(child: home!),
          home: Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  for (var i = 0; i < blocks; i++)
                    const CodePreview(code: _long, language: 'dart'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await settle(tester);
  }

  testWidgets('wrapping one block wraps every block, and stays so after a '
      'restart', (tester) async {
    await launch(tester, 2);
    expect(sideways(), findsNWidgets(2));

    await tester.tap(find.byTooltip('Wrap lines').first);
    await settle(tester);
    expect(sideways(), findsNothing);
    expect(find.byTooltip("Don't wrap lines"), findsNWidgets(2));

    await launch(tester, 2);
    expect(sideways(), findsNothing);
    expect(find.byTooltip("Don't wrap lines"), findsNWidgets(2));

    await tester.tap(find.byTooltip("Don't wrap lines").first);
    await settle(tester);
    await launch(tester, 2);
    expect(sideways(), findsNWidgets(2));
    await unmount(tester);
  });

  testWidgets('the full view opens as the blocks are and its switch changes '
      'them too', (tester) async {
    await launch(tester, 1);
    await tester.tap(find.byTooltip('Wrap lines'));
    await settle(tester);
    await tester.tap(
      find.textContaining('computeTheAnswer', findRichText: true),
    );
    await tester.pumpAndSettle();
    final inFull = find.descendant(
      of: find.byType(AppBar),
      matching: find.byTooltip("Don't wrap lines"),
    );
    expect(find.byType(CodeScreen), findsOneWidget);
    expect(inFull, findsOneWidget);

    await tester.tap(inFull);
    await settle(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(CodeScreen), findsNothing);
    expect(sideways(), findsOneWidget);
    await unmount(tester);
  });
}
