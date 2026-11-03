import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/confirm_dialog.dart';

import '../support/pump_app.dart';

void main() {
  Future<Future<bool>> ask(
    WidgetTester tester,
    Future<bool> Function(BuildContext context) question,
  ) async {
    late Future<bool> answer;
    await pumpApp(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => answer = question(context),
          child: const Text('ask'),
        ),
      ),
    );
    await tester.tap(find.text('ask'));
    await tester.pumpAndSettle();
    return answer;
  }

  /// The colour the label is drawn in.
  Color? colourOf(WidgetTester tester, String label) {
    final paragraph = tester.renderObject<RenderParagraph>(find.text(label));
    return paragraph.text.style?.color;
  }

  Color errorColour(WidgetTester tester) =>
      Theme.of(tester.element(find.byType(AlertDialog))).colorScheme.error;

  testWidgets('leaving is drawn as destructive and answers true', (
    tester,
  ) async {
    final answer = await ask(
      tester,
      (context) => confirmLeave(context, 'Design', private: true),
    );
    expect(find.text('Leave Design?'), findsOneWidget);
    expect(find.textContaining('need an invite'), findsOneWidget);
    expect(colourOf(tester, 'Leave'), errorColour(tester));
    await tester.tap(find.text('Leave'));
    await tester.pumpAndSettle();
    expect(await answer, isTrue);
  });

  testWidgets('joining is not destructive and says why when asked to', (
    tester,
  ) async {
    final answer = await ask(
      tester,
      (context) => confirmJoin(
        context,
        'Open Mic',
        why: "The message is in a channel you're not in.",
      ),
    );
    expect(
      find.textContaining("The message is in a channel you're not in. You "),
      findsOneWidget,
    );
    expect(colourOf(tester, 'Join'), isNot(errorColour(tester)));
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await answer, isFalse);
  });

  Future<Future<String?>> prompt(WidgetTester tester) async {
    late Future<String?> answer;
    await pumpApp(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => answer = promptText(
            context,
            title: 'Rename',
            initial: 'Old',
            required: true,
          ),
          child: const Text('ask'),
        ),
      ),
    );
    await tester.tap(find.text('ask'));
    await tester.pumpAndSettle();
    return answer;
  }

  testWidgets('a prompt answers the trimmed text', (tester) async {
    final answer = await prompt(tester);
    await tester.enterText(find.byType(TextField), '  New name ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(await answer, 'New name');
  });

  testWidgets('cancelling a prompt answers nothing, and a blank one cannot '
      'be saved', (tester) async {
    final answer = await prompt(tester);
    await tester.enterText(find.byType(TextField), '   ');
    await tester.pump();
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Save'))
          .onPressed,
      isNull,
    );
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await answer, isNull);
  });
}
