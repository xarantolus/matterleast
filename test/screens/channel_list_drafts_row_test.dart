import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/agent_providers.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/screens/channel_list/channel_list_pane.dart';
import 'package:matterleast/screens/channel_list/channel_list_state.dart';
import 'package:matterleast/screens/drafts/drafts_providers.dart';

const _url = 'https://chat.example.test';

Future<void> _show(WidgetTester tester, {required int drafts}) =>
    tester.pumpWidget(
      ProviderScope(
        overrides: [
          teamScheduledProvider(
            _url,
            't1',
          ).overrideWith((ref) => Stream.value([])),
          agentsAvailableProvider(_url).overrideWithValue(true),
        ],
        child: MaterialApp(
          theme: MatterleastApp.lightTheme,
          home: Scaffold(
            body: ChannelListPane(
              url: _url,
              teamId: 't1',
              serverLabel: 'Example',
              state: ChannelListReady(
                ChannelList(
                  teamName: 'Harbour',
                  sections: const [],
                  unreadThreads: 0,
                  drafts: drafts,
                  synced: true,
                ),
                refreshing: false,
              ),
            ),
          ),
        ),
      ),
    );

Future<void> _end(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('the Drafts row is there without drafts, under Agents, no '
      'count', (tester) async {
    await _show(tester, drafts: 0);
    await tester.pump();
    expect(find.text('Drafts'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('Drafts')).dy,
      greaterThan(tester.getTopLeft(find.text('Agents')).dy),
    );
    expect(find.text('0'), findsNothing);
    await _end(tester);
  });

  testWidgets('the Drafts row shows how many there are', (tester) async {
    await _show(tester, drafts: 2);
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
    await _end(tester);
  });
}
