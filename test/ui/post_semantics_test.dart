import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/markdown/links.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/post_tile.dart';

const _url = 'https://chat.example.test';

PostItem _post({
  String? sendState,
  String message = 'Morning',
  List<ReactionGroup> reactions = const [],
  int replyCount = 0,
}) => PostItem(
  id: 'p1',
  key: 'p1',
  userId: 'u1',
  authorName: 'wren',
  createAt: DateTime.utc(2026, 3, 1, 9),
  message: message,
  sendState: sendState,
  reactions: reactions,
  replyCount: replyCount,
);

const _me = (id: 'u-me', name: 'me', username: 'me', pictureAt: null);
const _kit = (id: 'u-kit', name: 'kit', username: 'kit', pictureAt: null);

/// What the environment was asked to open.
final _opened = <String>[];

Future<void> _show(
  WidgetTester tester,
  PostItem post, {
  bool compact = false,
  Map<CustomSemanticsAction, VoidCallback> actions = const {},
  ValueChanged<String>? onToggleReaction,
  VoidCallback? onOpenThread,
  VoidCallback? onTap,
  VoidCallback? onLongPress,
}) {
  _opened.clear();
  return tester.pumpWidget(
    ProviderScope(
      overrides: [
        serverImageCachesProvider(_url)
            .overrideWith((ref) => Completer<ServerImageCaches>().future),
      ],
      child: MaterialApp(
        theme: MatterleastApp.lightTheme,
        home: Scaffold(
          body: PostEnvironment(
            server: Uri.parse(_url),
            options: const ParseOptions(),
            myUsername: 'me',
            onMention: (name) => _opened.add('@$name'),
            onChannel: (name) => _opened.add('~$name'),
            onLink: (target) => _opened.add(switch (target) {
              UriLink(:final uri) => '$uri',
              _ => '$target',
            }),
            child: ListView(
              children: [
                PostTile(
                  post: post,
                  compact: compact,
                  actions: actions,
                  onToggleReaction: onToggleReaction,
                  onOpenThread: onOpenThread,
                  onTap: onTap,
                  tapHint: 'open thread',
                  onLongPress: onLongPress,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

/// The one node a screen reader stops on for the message.
SemanticsNode _message(WidgetTester tester) =>
    find.semantics.byLabel(RegExp('^wren')).evaluate().single;

void main() {
  testWidgets('a message is one stop: author, time and text in that order', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _show(
      tester,
      _post(
        message:
            'Hi @kit, the **tide** is at [the table](https://example.test/t)',
      ),
    );
    expect(
      _message(tester).label,
      matches(RegExp(r'^wren, \d+:00 AM\nHi @kit, the tide is at the table$')),
    );
    // Not split into a stop per name, time, mention and link.
    expect(find.semantics.byLabel('@kit'), findsNothing);
    expect(find.semantics.byLabel(RegExp('the table')), findsOne);
    handle.dispose();
  });

  testWidgets('a continued message still names its author', (tester) async {
    final handle = tester.ensureSemantics();
    await _show(tester, _post(), compact: true);
    expect(find.text('wren'), findsNothing);
    expect(_message(tester).label, matches(RegExp(r'^wren, .*\nMorning$')));
    handle.dispose();
  });

  testWidgets('a failed message says so in words, a pending one to a reader', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _show(tester, _post(sendState: 'failed'));
    expect(find.textContaining('Not sent'), findsOneWidget);
    expect(_message(tester).label, endsWith('\nNot sent'));
    await _show(tester, _post(sendState: 'pending'));
    expect(find.textContaining('Not sent'), findsNothing);
    expect(_message(tester).label, endsWith('\nSending'));
    handle.dispose();
  });

  testWidgets('reactions and replies are told in words on the message', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await _show(
      tester,
      _post(
        replyCount: 3,
        reactions: [
          const ReactionGroup(emojiName: '+1', people: [_kit, _me], mine: true),
          const ReactionGroup(
            emojiName: 'party_parrot',
            people: [_kit],
            mine: false,
          ),
        ],
      ),
      onOpenThread: () {},
    );
    expect(
      _message(tester).label,
      endsWith(
        '\nMorning\nReactions: 👍 2 including you, party parrot 1\n3 replies',
      ),
    );
    // The chips and the replies bar are not stops of their own.
    expect(find.semantics.byLabel(RegExp('including you')), findsOne);
    expect(find.semantics.byLabel(RegExp('^3 replies')), findsNothing);
    handle.dispose();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('tap, long-press and every control of the message are '
      'actions on its one stop', (tester) async {
    final handle = tester.ensureSemantics();
    var replied = 0;
    var tapped = 0;
    var held = 0;
    final toggled = <String>[];
    const reply = CustomSemanticsAction(label: 'Reply');
    await _show(
      tester,
      _post(
        message:
            'Ask @kit in ~boats or see [the table](https://example.test/t)',
        reactions: [
          const ReactionGroup(emojiName: '+1', people: [_me], mine: true),
          const ReactionGroup(emojiName: 'tada', people: [_kit], mine: false),
        ],
      ),
      actions: {reply: () => replied++},
      onToggleReaction: toggled.add,
      onTap: () => tapped++,
      onLongPress: () => held++,
    );
    final node = _message(tester);
    final data = node.getSemanticsData();
    expect(data.hasAction(SemanticsAction.tap), isTrue);
    expect(data.hasAction(SemanticsAction.longPress), isTrue);
    expect(node.hintOverrides?.onTapHint, 'open thread');
    expect(node.hintOverrides?.onLongPressHint, 'message options');

    final labels = [
      for (final id in data.customSemanticsActionIds ?? const <int>[])
        if (CustomSemanticsAction.getAction(id)! case final a
            when a.action == null)
          a.label,
    ];
    expect(labels, [
      'Reply',
      'Remove your 👍',
      'React with 🎉',
      'Who reacted',
      'Show @kit',
      'Open ~boats',
      'Open the table',
      'Show profile of wren',
    ]);

    final finder = find.semantics.byLabel(RegExp('^wren'));
    tester.semantics.tap(finder);
    tester.semantics.longPress(finder);
    tester.semantics.customAction(finder, reply);
    tester.semantics.customAction(
      finder,
      const CustomSemanticsAction(label: 'React with 🎉'),
    );
    tester.semantics.customAction(
      finder,
      const CustomSemanticsAction(label: 'Open the table'),
    );
    tester.semantics.customAction(
      finder,
      const CustomSemanticsAction(label: 'Show @kit'),
    );
    expect((tapped, held, replied), (1, 1, 1));
    expect(toggled, ['tada']);
    expect(_opened, ['https://example.test/t', '@kit']);
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
