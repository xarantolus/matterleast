import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/websocket/dialog.dart';
import 'package:matterleast/data/live/dialogs.dart';
import 'package:matterleast/screens/channel/dialog_screen.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';

OpenDialog _dialog(
  String title,
  String trigger, {
  List<Map<String, Object?>> elements = const [],
  Map<String, Object?> extra = const {},
}) => OpenDialog.fromJson({
  'trigger_id': trigger,
  'url': 'https://integration.invalid/submit',
  'dialog': {
    'callback_id': 'cb',
    'title': title,
    'state': 'st',
    'elements': [
      {
        'display_name': 'More',
        'name': 'more',
        'type': 'action_button',
        'help_text': 'Add a detail',
        'action_button': {
          'url': 'https://integration.invalid/more',
          'context': {'k': 'v'},
        },
      },
      ...elements,
    ],
    ...extra,
  },
});

void main() {
  var triggers = 0;
  Reply? Function(SeenRequest) answers(
    Map<String, Reply Function(SeenRequest)> by,
  ) =>
      (r) => by[r.path]?.call(r) ?? error(404, 'not_found');

  Future<ServerHarness> show(
    WidgetTester tester,
    OpenDialog dialog, {
    Map<String, Reply Function(SeenRequest)> extra = const {},
  }) => pumpWithServer(
    tester,
    handle: answers({
      '/api/v4/actions/dialogs/execute': (r) =>
          ok({'status': 'OK', 'trigger_id': 't${++triggers}'}),
      ...extra,
    }),
    home: (url) =>
        DialogScreen(url: url, dialog: dialog, channelId: 'ch1', teamId: 'tm1'),
  );

  Future<void> press(WidgetTester tester, ServerHarness h, String next) async {
    await tester.tap(find.text('More').last);
    await h.settle(tester, until: () => triggers > 0);
    h.session.connection.dialogs.offer(_dialog(next, 't$triggers'));
    await h.settle(tester);
  }

  setUp(() => triggers = 0);

  testWidgets('an action button sends its context and opens the dialog the '
      'integration answers with over the form, no deeper than three', (
    tester,
  ) async {
    final h = await show(tester, _dialog('Step 1', 'x'));
    final inbox = h.session.connection.dialogs..opened();

    expect(find.text('Add a detail'), findsOneWidget);
    await press(tester, h, 'Step 2');
    expect(h.server.seen.single.body, {
      'url': 'https://integration.invalid/more',
      'context': {'k': 'v'},
      'channel_id': 'ch1',
      'team_id': 'tm1',
    });
    expect(find.text('Step 2'), findsOneWidget);

    await press(tester, h, 'Step 3');
    expect(find.text('Step 3'), findsOneWidget);

    await press(tester, h, 'Step 4');
    expect(find.text('Step 4'), findsNothing);
    expect(inbox.canOpen, isFalse);

    await tester.tap(find.byTooltip('Close'));
    await h.settle(tester);
    expect(find.text('Step 3'), findsNothing);
    expect(inbox.canOpen, isTrue);
    await h.close(tester);
  });

  testWidgets('a failing action button says what the server said and the '
      'form stays', (tester) async {
    final h = await show(
      tester,
      _dialog('Step 1', 'x'),
      extra: {
        '/api/v4/actions/dialogs/execute': (r) => error(400, 'No such action'),
      },
    );
    await tester.tap(find.text('More'));
    await h.settle(tester, until: () => h.server.seen.isNotEmpty);
    expect(find.text('No such action'), findsOneWidget);
    expect(find.text('Step 1'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('submit buttons replace the Submit action and send their '
      'option', (tester) async {
    final h = await show(
      tester,
      _dialog(
        'Notes',
        'x',
        elements: [
          {
            'display_name': 'Then',
            'name': 'then',
            'type': 'select',
            'options': [
              {'text': 'Save and close', 'value': 'close'},
              {'text': 'Save and add', 'value': 'add'},
            ],
          },
        ],
        extra: {'submit_buttons': 'then'},
      ),
      extra: {'/api/v4/actions/dialogs/submit': (r) => ok({})},
    );
    expect(find.text('Submit'), findsNothing);
    expect(find.text('Then'), findsNothing);
    await tester.tap(find.text('Save and add'));
    await h.settle(tester, until: () => h.server.seen.isNotEmpty);
    expect(h.server.seen.single.body['submission'], {'then': 'add'});
    await h.close(tester);
  });

  testWidgets('a dialog that asks for it is fetched again when the dialog '
      'over it closes, keeping what was typed', (tester) async {
    final h = await show(
      tester,
      _dialog(
        'Board',
        'x',
        elements: [
          {'display_name': 'Note', 'name': 'note', 'type': 'text'},
        ],
        extra: {
          'source_url': 'https://integration.invalid/board',
          'refresh_on_return': true,
        },
      ),
      extra: {
        '/api/v4/actions/dialogs/submit': (r) => ok({
          'type': 'form',
          'form': {
            'title': 'Board (2 items)',
            'elements': [
              {'display_name': 'Note', 'name': 'note', 'type': 'text'},
            ],
          },
        }),
      },
    );
    h.session.connection.dialogs.opened();
    await tester.enterText(find.byType(EditableText), 'draft');
    await press(tester, h, 'Child');
    await tester.tap(find.byTooltip('Close'));
    await h.settle(
      tester,
      until: () => h.server.seen.any((r) => r.body['type'] == 'refresh'),
    );
    final refresh = h.server.seen.last.body;
    expect(refresh['url'], 'https://integration.invalid/board');
    expect(refresh['submission'], {'note': 'draft'});
    expect(find.text('Board (2 items)'), findsOneWidget);
    expect(find.text('draft'), findsOneWidget);
    await h.close(tester);
  });

  test('two dialogs expected at once both open, and a dialog nobody asked '
      'for does not', () async {
    final inbox = DialogInbox();
    final shown = <String?>[];
    inbox.dialogs.listen((d) => shown.add(d.triggerId));
    inbox
      ..expect('a')
      ..expect('b')
      ..offer(const OpenDialog(triggerId: 'b'))
      ..offer(const OpenDialog(triggerId: 'a'))
      ..offer(const OpenDialog(triggerId: 'c'));
    await Future<void>.delayed(Duration.zero);
    expect(shown, ['b', 'a']);
  });
}
