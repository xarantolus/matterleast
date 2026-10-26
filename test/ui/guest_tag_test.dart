import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/ui/post_tile.dart';

PostItem _post({bool guest = false, bool bot = false}) => PostItem(
  id: 'p1',
  key: 'p1',
  userId: 'u1',
  authorName: 'wren',
  createAt: DateTime.utc(2026, 3, 1, 9),
  message: 'Morning',
  authorIsGuest: guest,
  authorIsBot: bot,
);

Future<void> _show(WidgetTester tester, PostItem post) => tester.pumpWidget(
  ProviderScope(
    child: MaterialApp(
      theme: MatterleastApp.lightTheme,
      home: Scaffold(body: PostTile(post: post)),
    ),
  ),
);

void main() {
  testWidgets('a guest is tagged next to their name', (tester) async {
    await _show(tester, _post(guest: true));
    expect(find.text('GUEST'), findsOneWidget);
    await _show(tester, _post());
    expect(find.text('GUEST'), findsNothing);
  });

  testWidgets('a bot keeps its own tag', (tester) async {
    await _show(tester, _post(guest: true, bot: true));
    expect(find.text('BOT'), findsOneWidget);
    expect(find.text('GUEST'), findsNothing);
  });
}
