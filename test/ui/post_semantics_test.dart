import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/ui/post_tile.dart';

PostItem _post({String? sendState}) => PostItem(
  id: 'p1',
  key: 'p1',
  userId: 'u1',
  authorName: 'wren',
  createAt: DateTime.utc(2026, 3, 1, 9),
  message: 'Morning',
  sendState: sendState,
);

Future<void> _show(
  WidgetTester tester,
  PostItem post, {
  bool compact = false,
  Map<CustomSemanticsAction, VoidCallback> actions = const {},
}) => tester.pumpWidget(
  ProviderScope(
    child: MaterialApp(
      theme: MatterleastApp.lightTheme,
      home: Scaffold(
        body: PostTile(post: post, compact: compact, actions: actions),
      ),
    ),
  ),
);

void main() {
  testWidgets('a message is read with its author and time in one stop', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _show(tester, _post());
    expect(find.semantics.byLabel(RegExp(r'^wren\n.*AM$')), findsOne);
    handle.dispose();
  });

  testWidgets('a continued message still names its author', (tester) async {
    final handle = tester.ensureSemantics();
    await _show(tester, _post(), compact: true);
    expect(find.text('wren'), findsNothing);
    expect(find.semantics.byLabel(RegExp(r'^wren, ')), findsOne);
    handle.dispose();
  });

  testWidgets('a failed message says so in words, a pending one to a reader', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _show(tester, _post(sendState: 'failed'));
    expect(find.textContaining('Not sent'), findsOneWidget);
    await _show(tester, _post(sendState: 'pending'));
    expect(find.textContaining('Not sent'), findsNothing);
    expect(find.semantics.byLabel(RegExp('Sending')), findsOne);
    handle.dispose();
  });

  testWidgets('the message offers its actions to a screen reader', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    var replied = false;
    const reply = CustomSemanticsAction(label: 'Reply');
    await _show(tester, _post(), actions: {reply: () => replied = true});
    tester.semantics.customAction(
      find.semantics.byLabel(RegExp('^wren')),
      reply,
    );
    expect(replied, isTrue);
    handle.dispose();
  });

  testWidgets('a post whose thread has a draft reply shows it and opens the '
      'thread on tap', (tester) async {
    var opened = false;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: MatterleastApp.lightTheme,
          home: Scaffold(
            body: PostTile(
              post: _post().copyWith(hasDraftReply: true),
              onOpenThread: () => opened = true,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Draft'));
    expect(opened, isTrue);
  });
}
