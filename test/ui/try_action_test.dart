import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/ui/failed_state.dart';
import 'package:matterleast/ui/try_action.dart';

void main() {
  Future<bool> run(
    WidgetTester tester,
    Future<void> Function() action, {
    String failure = '',
  }) async {
    late Future<bool> result;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => result = tryAction(
                context,
                'chat.example',
                action,
                failure: failure,
              ),
              child: const Text('go'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    await tester.pump();
    return result;
  }

  testWidgets('a refusal says what failed and what the server said', (
    tester,
  ) async {
    final ok = await run(
      tester,
      () async => throw const ServerError(
        statusCode: 403,
        message: 'You need to be a channel admin.',
      ),
      failure: "Couldn't save.",
    );
    expect(await tester.runAsync(() => Future.value(ok)), isFalse);
    expect(
      find.text(
        "Couldn't save. chat.example said: You need to be a channel admin.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('success shows nothing', (tester) async {
    final ok = await run(tester, () async {});
    expect(ok, isTrue);
    expect(find.byType(SnackBar), findsNothing);
  });

  testWidgets('a failed load shows the cause and Retry', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: MatterleastApp.lightTheme,
        home: FailedState(
          title: "Couldn't load things",
          error: const ServerError(statusCode: 500, message: 'Disk is full.'),
          host: 'chat.example',
          onRetry: () => retried = true,
        ),
      ),
    );
    expect(find.text('chat.example said: Disk is full.'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    expect(retried, isTrue);
  });
}
