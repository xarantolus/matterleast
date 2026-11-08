import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/generated/export.dart' as api;
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/screens/channel_list/category_menu.dart';

import '../../support/fake_server.dart';
import '../../support/pump_with_server.dart';
import '../../support/test_session.dart';

ChannelItem item(String id, {bool unread = false}) => ChannelItem(
  id: id,
  title: id,
  kind: ChannelKind.public,
  unread: unread,
  mentions: 0,
  muted: false,
  favorite: false,
  hasDraft: false,
);

CategorySection section(
  CategoryKind kind, {
  String sorting = '',
  bool muted = false,
  List<ChannelItem> rows = const [],
}) => CategorySection(
  id: 'cat1',
  title: 'Crew',
  kind: kind,
  collapsed: false,
  sorting: sorting,
  muted: muted,
  rows: rows,
);

String typeOf(CategoryKind kind) => switch (kind) {
  CategoryKind.favorites => 'favorites',
  CategoryKind.channels => 'channels',
  CategoryKind.directMessages => 'direct_messages',
  CategoryKind.custom => 'custom',
};

void main() {
  late ServerHarness h;
  final changes = <Object?>[];
  final views = <Object?>[];
  final preferences = <Object?>[];

  Future<void> open(
    WidgetTester tester,
    CategorySection shown, {
    Reply? answer,
  }) async {
    changes.clear();
    views.clear();
    preferences.clear();
    h = await pumpWithServer(
      tester,
      size: const Size(800, 1400),
      handle: (r) {
        if (r.path.endsWith('/channels/categories')) {
          changes.add(r.json);
          return answer ?? ok(r.json);
        }
        if (r.path.endsWith('/channels/members/me/view')) {
          views.add(r.body['channel_id']);
        }
        if (r.path.endsWith('/preferences')) preferences.add(r.json);
        return emptyAnswer(r);
      },
      seed: (session) => session.store.applyCategoryUpdates([
        api.SidebarCategoryWithChannels.fromJson({
          'id': 'cat1',
          'user_id': meId,
          'team_id': teamId,
          'display_name': 'Crew',
          'type': typeOf(shown.kind),
          'sorting': shown.sorting,
          'channel_ids': [for (final r in shown.rows) r.id],
        }),
      ]),
      home: (url) => Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => showCategoryMenu(
              context,
              url: url,
              teamId: teamId,
              section: shown,
              onReorder: () {},
            ),
            child: const Text('menu'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('menu'));
    await h.settle(tester);
  }

  Future<void> tapText(WidgetTester tester, String text) async {
    await tester.tap(find.text(text));
    await h.settle(tester);
  }

  testWidgets('a custom category offers sort and mute, not the DM limit', (
    tester,
  ) async {
    await open(tester, section(CategoryKind.custom));
    expect(find.text('Sort'), findsOneWidget);
    expect(find.text('Mute category'), findsOneWidget);
    expect(find.text('Show recent messages'), findsNothing);
    expect(find.text('Mark category as read'), findsNothing);
    await h.close(tester);
  });

  testWidgets('direct messages offer the limit but no muting', (tester) async {
    await open(tester, section(CategoryKind.directMessages));
    expect(find.text('Show recent messages'), findsOneWidget);
    expect(find.text('Mute category'), findsNothing);
    await h.close(tester);
  });

  testWidgets('direct messages sort only by name or activity', (tester) async {
    await open(tester, section(CategoryKind.directMessages));
    await tapText(tester, 'Sort');
    expect(find.text('Recent activity'), findsOneWidget);
    expect(find.text('Manually'), findsNothing);
    await h.close(tester);
  });

  testWidgets('favorites can be sorted but not muted', (tester) async {
    await open(tester, section(CategoryKind.favorites));
    expect(find.text('Sort'), findsOneWidget);
    expect(find.text('Mute category'), findsNothing);
    await h.close(tester);
  });

  testWidgets('choosing a sorting sends it for that category', (tester) async {
    await open(tester, section(CategoryKind.custom));
    await tapText(tester, 'Sort');
    await tapText(tester, 'Recent activity');
    final sent = (changes.single! as List).single as Map;
    expect(sent['id'], 'cat1');
    expect(sent['sorting'], 'recent');
    await h.close(tester);
  });

  testWidgets('a failed sort shows what the server said', (tester) async {
    await open(
      tester,
      section(CategoryKind.custom),
      answer: error(403, 'no_way'),
    );
    await tapText(tester, 'Sort');
    await tapText(tester, 'Manually');
    expect(find.textContaining('no_way'), findsOneWidget);
    await h.close(tester);
  });

  testWidgets('the current sorting is checked', (tester) async {
    await open(tester, section(CategoryKind.custom, sorting: 'manual'));
    await tapText(tester, 'Sort');
    expect(
      find.descendant(
        of: find.widgetWithText(ListTile, 'Manually'),
        matching: find.byIcon(Icons.check),
      ),
      findsOneWidget,
    );
    await h.close(tester);
  });

  testWidgets('choosing a number of recent messages saves the preference', (
    tester,
  ) async {
    await open(tester, section(CategoryKind.directMessages));
    await tapText(tester, 'Show recent messages');
    await tapText(tester, '40');
    final saved = (preferences.single! as List).single as Map;
    expect(saved['category'], 'sidebar_settings');
    expect(saved['name'], 'limit_visible_dms_gms');
    expect(saved['value'], '40');
    await h.close(tester);
  });

  testWidgets('muting sends the category as muted', (tester) async {
    await open(tester, section(CategoryKind.custom));
    await tapText(tester, 'Mute category');
    expect(((changes.single! as List).single as Map)['muted'], true);
    await h.close(tester);
  });

  testWidgets('unmuting sends the category as not muted', (tester) async {
    await open(tester, section(CategoryKind.custom, muted: true));
    await tapText(tester, 'Unmute category');
    expect(((changes.single! as List).single as Map)['muted'], false);
    await h.close(tester);
  });

  testWidgets('marking a category read marks only its unread channels', (
    tester,
  ) async {
    await open(
      tester,
      section(
        CategoryKind.channels,
        rows: [item('a', unread: true), item('b'), item('c', unread: true)],
      ),
    );
    await tapText(tester, 'Mark category as read');
    expect(views, ['a', 'c']);
    await h.close(tester);
  });
}
