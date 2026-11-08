import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' hide Notifier;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/notifications/notifier.dart';
import 'package:matterleast/screens/settings/phone_notifications.dart';

class _Allowed extends Notifier {
  var settingsOpened = 0;

  @override
  Future<bool> permitted() async => true;

  @override
  Future<void> openSettings() async => settingsOpened++;
}

void main() {
  const refresh = MethodChannel('matterleast/background_refresh');
  const stayConnected = MethodChannel('matterleast/stay_connected');
  late String refreshStatus;

  setUp(() {
    refreshStatus = 'available';
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(refresh, (call) async => refreshStatus);
    messenger.setMockMethodCallHandler(
      stayConnected,
      (call) async => call.method == 'isEnabled' ? false : null,
    );
  });

  Future<_Allowed> pump(WidgetTester tester) async {
    final notifier = _Allowed();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [notifierProvider.overrideWithValue(notifier)],
        child: MaterialApp(
          theme: MatterleastApp.lightTheme,
          home: const Scaffold(
            body: SingleChildScrollView(child: PhoneNotifications()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    return notifier;
  }

  testWidgets('on iOS the settings say when the app checks while closed, '
      'instead of offering Stay connected', (tester) async {
    await pump(tester);
    expect(find.text('Stay connected'), findsNothing);
    expect(find.text('Checks in the background'), findsOneWidget);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('on iOS with Background App Refresh off, the settings say so '
      'and open the system settings', (tester) async {
    refreshStatus = 'denied';
    final notifier = await pump(tester);
    expect(find.text('Background App Refresh is off'), findsOneWidget);
    await tester.tap(find.text('Settings'));
    expect(notifier.settingsOpened, 1);
  }, variant: TargetPlatformVariant.only(TargetPlatform.iOS));

  testWidgets('on Android Stay connected is offered', (tester) async {
    await pump(tester);
    expect(find.text('Stay connected'), findsOneWidget);
    expect(find.text('Checks in the background'), findsNothing);
  }, variant: TargetPlatformVariant.only(TargetPlatform.android));
}
