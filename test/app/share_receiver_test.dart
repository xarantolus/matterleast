import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/share_receiver.dart';

void main() {
  const channel = MethodChannel('matterleast/share_intake');
  final calls = <String>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call.method);
          return call.method == 'start' ? false : null;
        });
  });

  Future<void> fromPhone(String method, [Object? arguments]) =>
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(
            channel.name,
            const StandardMethodCodec().encodeMethodCall(
              MethodCall(method, arguments),
            ),
            (_) {},
          );

  Future<ShareReceiver> start(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: MatterleastApp.lightTheme,
        home: const Scaffold(body: Text('Home')),
      ),
    );
    final receiver = ShareReceiver(
      tester.state<NavigatorState>(find.byType(Navigator)),
      target: (_) async => null,
    );
    addTearDown(receiver.dispose);
    await receiver.start(Future.value('/cache'));
    return receiver;
  }

  testWidgets('a copy that takes a moment shows its progress, and Cancel '
      'stops it', (tester) async {
    await start(tester);
    await fromPhone('progress', {'done': 300 << 20, 'total': 600 << 20});
    await tester.pumpAndSettle();
    expect(find.text('Preparing the shared files'), findsOneWidget);
    expect(find.text('300 MB of 600 MB'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    expect(calls, contains('cancel'));
    await fromPhone('cancelled');
    await tester.pumpAndSettle();
    expect(find.text('Preparing the shared files'), findsNothing);
    expect(find.text('Home'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('a copy that fails says what the phone reported', (tester) async {
    await start(tester);
    await fromPhone('progress', {'done': 1, 'total': -1});
    await tester.pump(const Duration(milliseconds: 500));
    await fromPhone('failed', {'message': 'No space left on device'});
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Preparing the shared files'), findsNothing);
    expect(
      find.text("Couldn't take the shared files: No space left on device"),
      findsOneWidget,
    );
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
