import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/ui/post_tile.dart';

import '../support/builders.dart';
import '../support/pump_app.dart';

Future<void> _show(WidgetTester tester, PostItem post) =>
    pumpApp(tester, Scaffold(body: PostTile(post: post)));

void main() {
  testWidgets('a guest is tagged next to their name', (tester) async {
    await _show(tester, postItem(authorIsGuest: true));
    expect(find.text('GUEST'), findsOneWidget);
    await _show(tester, postItem());
    expect(find.text('GUEST'), findsNothing);
  });

  testWidgets('a bot keeps its own tag', (tester) async {
    await _show(tester, postItem(authorIsGuest: true, authorIsBot: true));
    expect(find.text('BOT'), findsOneWidget);
    expect(find.text('GUEST'), findsNothing);
  });
}
