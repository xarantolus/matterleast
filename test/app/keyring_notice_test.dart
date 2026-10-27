import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/app/launch_gate.dart';
import 'package:matterleast/domain/sign_in_problems.dart';

Widget _app({required bool shown, required VoidCallback onRetry}) =>
    MaterialApp(
      home: Scaffold(
        body: KeyringNotice(
          shown: shown,
          onRetry: onRetry,
          child: const Text('Home'),
        ),
      ),
    );

void main() {
  testWidgets('a missing keyring shows what to do and Try again, '
      'with the app still below', (tester) async {
    var retried = 0;
    await tester.pumpWidget(_app(shown: true, onRetry: () => retried++));

    expect(find.text(keyringUnavailableText), findsOneWidget);
    expect(find.textContaining('GNOME Keyring or KWallet'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);

    await tester.tap(find.text('Try again'));
    expect(retried, 1);
  });

  testWidgets('a working keyring shows no notice', (tester) async {
    await tester.pumpWidget(_app(shown: false, onRetry: () {}));

    expect(find.text(keyringUnavailableText), findsNothing);
    expect(find.text('Try again'), findsNothing);
    expect(find.text('Home'), findsOneWidget);
  });
}
