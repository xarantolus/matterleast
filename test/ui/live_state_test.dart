import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/agent_providers.dart';
import 'package:matterleast/app/app.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/live_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/images/server_image_caches.dart';
import 'package:matterleast/domain/agent_stream.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/user_profile.dart';
import 'package:matterleast/markdown/post_doc.dart';
import 'package:matterleast/ui/agent_post.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/post_tile.dart';
import 'package:matterleast/ui/progress_slot.dart';

const _url = 'https://chat.example.test';
final _created = DateTime.utc(2026, 10, 26, 9);

Widget _host(Widget child, {List<Override> overrides = const []}) =>
    ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        theme: MatterleastApp.lightTheme,
        home: Scaffold(
          body: PostEnvironment(
            server: Uri.parse(_url),
            options: const ParseOptions(),
            myUsername: 'kite',
            onMention: (_) {},
            onChannel: (_) {},
            onLink: (_) {},
            image: (url, size, fit) => SizedBox.fromSize(size: size),
            child: SingleChildScrollView(child: child),
          ),
        ),
      ),
    );

void main() {
  group('an answer being written by an agent', () {
    final live = ValueNotifier(true);
    final answer = PostItem(
      id: 'a1',
      key: 'a1',
      userId: 'bot1',
      authorName: 'Pilot',
      authorUsername: 'pilot',
      createAt: _created,
      message: '',
      type: 'custom_llmbot',
      rootId: 'q1',
      propsJson: '{"llm_requester_user_id":"me1"}',
    );

    Widget show() => _host(
      AgentPostBody(post: answer),
      overrides: [
        serverLiveProvider(_url).overrideWith((ref) {
          live.addListener(ref.invalidateSelf);
          ref.onDispose(() => live.removeListener(ref.invalidateSelf));
          return live.value;
        }),
        agentStreamProvider(_url, 'a1').overrideWith(
          (ref) => Stream.value(
            const AgentStream(generating: true, message: 'The tide turns at'),
          ),
        ),
        currentUserProvider(_url).overrideWith(
          (ref) => Stream.value(
            const Me(
              id: 'me1',
              username: 'kite',
              firstName: '',
              lastName: '',
              nickname: '',
              status: 'online',
            ),
          ),
        ),
      ],
    );

    testWidgets('offers Stop while the server is live, and waits without '
        'Stop when it is not', (tester) async {
      live.value = true;
      await tester.pumpWidget(show());
      await tester.pump();
      expect(find.text('Stop'), findsOneWidget);
      expect(find.text('Waiting for the server…'), findsNothing);

      live.value = false;
      await tester.pump();
      expect(find.text('Waiting for the server…'), findsOneWidget);
      expect(find.text('Stop'), findsNothing);
      expect(find.text('Regenerate'), findsNothing);
      expect(find.textContaining('The tide turns at'), findsOneWidget);

      live.value = true;
      await tester.pump();
      expect(find.text('Stop'), findsOneWidget);
    });
  });

  testWidgets('an agent reply is selectable where the post has a context '
      'menu', (tester) async {
    final post = PostItem(
      id: 'a2',
      key: 'a2',
      userId: 'bot1',
      authorName: 'Pilot',
      authorUsername: 'pilot',
      createAt: _created,
      message: 'High water at noon.',
      type: 'custom_llmbot',
      rootId: 'q1',
      propsJson: '{"llm_requester_user_id":"me1"}',
    );
    final overrides = [
      serverLiveProvider(_url).overrideWith((ref) => true),
      agentStreamProvider(
        _url,
        'a2',
      ).overrideWith((ref) => Stream.value(const AgentStream())),
      currentUserProvider(_url).overrideWith((ref) => const Stream.empty()),
      serverImageCachesProvider(_url)
          .overrideWith((ref) => Completer<ServerImageCaches>().future),
    ];
    await tester.pumpWidget(
      _host(PostTile(post: post, compact: false), overrides: overrides),
    );
    await tester.pump();
    expect(find.byType(SelectionArea), findsNothing);

    await tester.pumpWidget(
      _host(
        PostTile(post: post, compact: false, onContextMenu: (_, _) {}),
        overrides: overrides,
      ),
    );
    await tester.pump();
    expect(
      find.descendant(
        of: find.byType(SelectionArea),
        matching: find.byType(AgentPostBody),
      ),
      findsOneWidget,
    );
  });

  group('custom status beside the author', () {
    final start = DateTime.utc(2026, 10, 26, 9, 30);
    var now = start;
    final post = PostItem(
      id: 'p1',
      key: 'p1',
      userId: 'u1',
      authorName: 'wren',
      authorUsername: 'wren',
      createAt: _created,
      message: 'Back soon.',
      authorStatus: CustomStatus(
        emoji: 'sailboat',
        text: 'Sailing',
        duration: customStatusDateAndTime,
        expiresAt: start.add(const Duration(minutes: 30)),
      ),
    );
    List<Override> clock() => [wallClockProvider.overrideWithValue(() => now)];

    testWidgets('shows next to the name and goes at its expiry by the clock', (
      tester,
    ) async {
      now = start;
      await tester.pumpWidget(
        _host(PostTile(post: post, compact: false), overrides: clock()),
      );
      expect(find.text('⛵'), findsOneWidget);

      now = start.add(const Duration(minutes: 31));
      await tester.pump(const Duration(minutes: 31));
      expect(find.text('⛵'), findsNothing);
      expect(find.text('wren'), findsOneWidget);
    });

    testWidgets(
      'on a desktop, hovering it tells the text and when it clears',
      variant: TargetPlatformVariant.only(TargetPlatform.linux),
      (tester) async {
        now = start;
        await tester.pumpWidget(
          _host(PostTile(post: post, compact: false), overrides: clock()),
        );
        final glyph = find.text('⛵');
        final tooltip = tester.widget<Tooltip>(
          find.ancestor(of: glyph, matching: find.byType(Tooltip)),
        );
        expect(tooltip.message, 'Sailing\nUntil 11:00 AM');
        final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
        await mouse.addPointer(location: tester.getCenter(glyph));
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('Sailing\nUntil 11:00 AM'), findsOneWidget);
        await mouse.removePointer();
      },
    );
  });

  group('the tooltip in local time', () {
    // Run with TZ=Europe/Berlin: 25 Oct 2026 03:00 summer time turns into
    // 02:00 winter time.
    String tooltip(DateTime now, DateTime ends) => customStatusTooltip(
      CustomStatus(
        text: 'Away',
        duration: customStatusDateAndTime,
        expiresAt: ends.toUtc(),
      ),
      now,
      use24: true,
    );

    test('later today is a time, after midnight it is tomorrow', () {
      final evening = DateTime(2026, 10, 27, 23, 30);
      expect(
        tooltip(evening, DateTime(2026, 10, 27, 23, 45)),
        'Away\nUntil 23:45',
      );
      expect(
        tooltip(evening, DateTime(2026, 10, 28, 0, 15)),
        'Away\nUntil tomorrow at 00:15',
      );
      // Ten minutes before midnight, "tomorrow" is only half an hour away.
      expect(
        tooltip(DateTime(2026, 10, 27, 23, 50), DateTime(2026, 10, 28, 0, 20)),
        'Away\nUntil tomorrow at 00:20',
      );
    });

    test('across the change to winter time, by the calendar date', () {
      expect(
        tooltip(DateTime(2026, 10, 24, 23, 30), DateTime(2026, 10, 25, 9)),
        'Away\nUntil tomorrow at 09:00',
      );
    });

    test('across the year boundary', () {
      expect(
        tooltip(DateTime(2026, 12, 31, 22), DateTime(2027, 1, 1, 10)),
        'Away\nUntil tomorrow at 10:00',
      );
    });

    test('a status that never clears says only its text', () {
      expect(
        customStatusTooltip(
          const CustomStatus(text: 'Away'),
          DateTime(2026, 10, 27, 12),
          use24: true,
        ),
        'Away',
      );
    });
  });

  group('the slim bar after coming back', () {
    Widget bar({required bool active}) => MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          bottom: ProgressSlot(active: active, delay: ProgressSlot.settleDelay),
        ),
      ),
    );

    testWidgets('a refresh done within the threshold never shows it', (
      tester,
    ) async {
      await tester.pumpWidget(bar(active: true));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(LinearProgressIndicator), findsNothing);
      await tester.pumpWidget(bar(active: false));
      await tester.pump(const Duration(seconds: 1));
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('a longer refresh shows it until it is done', (tester) async {
      await tester.pumpWidget(bar(active: true));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(LinearProgressIndicator), findsNothing);
      await tester.pump(const Duration(milliseconds: 150));
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      await tester.pumpWidget(bar(active: false));
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });
  });
}
