import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/slide_route.dart';

void main() {
  Future<NavigatorState> openPage(WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: Text('List'))),
    );
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(
      navigator.push(
        SlideRoute<void>(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('Threads')),
            body: Column(
              children: [
                SizedBox(
                  height: 60,
                  child: ListView(
                    key: const Key('chips'),
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (var i = 0; i < 20; i++)
                        SizedBox(width: 120, child: Text('Chip $i')),
                    ],
                  ),
                ),
                const Expanded(child: Center(child: Text('A thread'))),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return navigator;
  }

  testWidgets('a right swipe anywhere on a page goes back', (tester) async {
    await openPage(tester);
    expect(find.text('Threads'), findsOneWidget);
    await tester.fling(find.text('A thread'), const Offset(300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Threads'), findsNothing);
    expect(find.text('List'), findsOneWidget);
  });

  testWidgets('on desktop a drag leaves the page where it is', (tester) async {
    await openPage(tester);
    await tester.fling(find.text('A thread'), const Offset(300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Threads'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('on desktop Esc closes the page', (tester) async {
    await openPage(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Threads'), findsNothing);
    expect(find.text('List'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.linux));

  testWidgets('on a phone Esc leaves the page open', (tester) async {
    await openPage(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Threads'), findsOneWidget);
  });

  testWidgets('a short slow swipe springs back', (tester) async {
    await openPage(tester);
    await tester.timedDrag(
      find.text('A thread'),
      const Offset(60, 0),
      const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();
    expect(find.text('Threads'), findsOneWidget);
    expect(tester.getTopLeft(find.byType(AppBar)).dx, 0);
  });

  testWidgets('a sideways scroller on the page keeps its swipe', (
    tester,
  ) async {
    await openPage(tester);
    final chips = find.byKey(const Key('chips'));
    await tester.fling(chips, const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();
    await tester.fling(chips, const Offset(300, 0), 1000);
    await tester.pumpAndSettle();
    expect(find.text('Threads'), findsOneWidget);
  });

  testWidgets('the system back gesture moves the page with the finger', (
    tester,
  ) async {
    await openPage(tester);
    Future<void> send(String method, [Map<String, Object?>? args]) =>
        tester.binding.defaultBinaryMessenger.handlePlatformMessage(
          'flutter/backgesture',
          const StandardMethodCodec().encodeMethodCall(
            MethodCall(method, args),
          ),
          (_) {},
        );
    await send('startBackGesture', {
      'touchOffset': [5.0, 300.0],
      'progress': 0.0,
      'swipeEdge': 0,
    });
    await tester.pump();
    await send('updateBackGestureProgress', {
      'touchOffset': [200.0, 300.0],
      'progress': 0.5,
      'swipeEdge': 0,
    });
    await tester.pump();
    final width = tester.getSize(find.byType(MaterialApp)).width;
    expect(tester.getTopLeft(find.byType(AppBar)).dx, closeTo(width / 2, 1));
    await send('commitBackGesture');
    await tester.pumpAndSettle();
    expect(find.text('Threads'), findsNothing);
  });

  testWidgets('a field typed in below gives up the keyboard when a page '
      'opens over it, and leaves it down when the page goes', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TextField())),
    );
    await tester.showKeyboard(find.byType(TextField));
    expect(tester.testTextInput.isVisible, isTrue);
    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(
      navigator.push(
        SlideRoute<void>(builder: (_) => const Scaffold(body: Text('Thread'))),
      ),
    );
    await tester.pump();
    expect(tester.testTextInput.isVisible, isFalse);
    await tester.pumpAndSettle();
    navigator.pop();
    await tester.pumpAndSettle();
    expect(find.text('Thread'), findsNothing);
    expect(tester.testTextInput.isVisible, isFalse);
    expect(
      tester.widget<EditableText>(find.byType(EditableText)).focusNode.hasFocus,
      isFalse,
    );
  });
}
