import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/post_tile.dart';

import '../support/pump_app.dart';

PostItem _added({Map<String, String> current = const {}}) => PostItem(
  id: 'p1',
  key: 'p1',
  userId: 'u-admin',
  authorName: 'Admin',
  createAt: DateTime.utc(2026, 10, 20, 9),
  message: 'server text',
  type: 'system_add_to_channel',
  systemUsernames: current,
  propsJson:
      '{"userId":"u-admin","username":"admin",'
      '"addedUserId":"u-pat","addedUsername":"pat"}',
);

void main() {
  Future<List<String>> show(WidgetTester tester, PostItem post) async {
    final tapped = <String>[];
    await pumpApp(
      tester,
      Scaffold(
        body: PostEnvironment(
          server: Uri.parse('https://chat.example.test'),
          options: const ParseOptions(),
          myUsername: 'me',
          onMention: (name, _) => tapped.add(name),
          onChannel: (_) {},
          onLink: (_) {},
          child: ListView(children: [PostTile(post: post)]),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return tapped;
  }

  testWidgets('a renamed person shows under the new name and opens', (
    tester,
  ) async {
    final tapped = await show(
      tester,
      _added(current: {'u-pat': 'patricia', 'u-admin': 'admin'}),
    );
    expect(find.textContaining('@pat ', findRichText: true), findsNothing);
    expect(
      find.textContaining('@patricia', findRichText: true),
      findsOneWidget,
    );
    await tester.tapOnText(find.textRange.ofSubstring('@patricia'));
    expect(tapped, ['patricia']);
  });

  testWidgets('without a known user the stored name is shown', (tester) async {
    await show(tester, _added());
    expect(
      find.textContaining('@pat added', findRichText: true),
      findsOneWidget,
    );
  });
}
