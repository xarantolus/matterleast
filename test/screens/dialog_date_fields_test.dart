import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/websocket/dialog.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/screens/channel/dialog_screen.dart';

void main() {
  Future<void> showDialogScreen(
    WidgetTester tester,
    List<Map<String, Object?>> elements, {
    bool use24 = true,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MatterleastApp.lightTheme,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: use24),
            child: child!,
          ),
          home: DialogScreen(
            url: 'https://chat.example.test',
            channelId: 'ch1',
            teamId: 'tm1',
            dialog: OpenDialog.fromJson({
              'trigger_id': 't1',
              'url': 'https://integration.invalid/submit',
              'dialog': {'title': 'Book a room', 'elements': elements},
            }),
          ),
        ),
      ),
    );
  }

  testWidgets('a date field shows its default and takes a picked day', (
    tester,
  ) async {
    await showDialogScreen(tester, [
      {
        'display_name': 'Day',
        'name': 'day',
        'type': 'date',
        'default': '2026-03-10',
      },
    ]);
    expect(find.text('10 Mar 2026'), findsOneWidget);

    await tester.tap(find.text('10 Mar 2026'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('15'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('15 Mar 2026'), findsOneWidget);
  });

  testWidgets('a datetime field shows times on its own clock, follows the '
      '12/24-hour setting and keeps picks to its steps', (tester) async {
    final field = {
      'display_name': 'Start',
      'name': 'start',
      'type': 'datetime',
      'default': '2026-03-10T00:00:00Z',
      'optional': true,
      'datetime_config': {
        'location_timezone': 'Asia/Tokyo',
        'time_interval': 30,
      },
    };
    await showDialogScreen(tester, [field], use24: false);
    expect(find.text('10 Mar 2026 at 9:00 AM'), findsOneWidget);

    await showDialogScreen(tester, [field]);
    expect(find.text('10 Mar 2026 at 09:00'), findsOneWidget);
    expect(find.textContaining('Times in Asia/Tokyo'), findsOneWidget);
    expect(find.textContaining('steps of 30 minutes'), findsOneWidget);

    await tester.tap(find.text('10 Mar 2026 at 09:00'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('12'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Switch to text input mode'));
    await tester.pumpAndSettle();
    final inputs = find.descendant(
      of: find.byType(Dialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(inputs.at(0), '10');
    await tester.enterText(inputs.at(1), '20');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('12 Mar 2026 at 10:30'), findsOneWidget);

    await tester.tap(find.byTooltip('Clear'));
    await tester.pump();
    expect(find.text('Pick a date and time'), findsOneWidget);
  });
}
