import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/screens/channel/conversation_controller.dart';
import 'package:matterleast/screens/channel/conversation_view.dart';

import '../support/fake_server.dart';
import '../support/pump_with_server.dart';
import '../support/test_session.dart';

void main() {
  final start = DateTime.utc(2026, 10, 26, 8);
  Map<String, Object?> post(int i) => {
    'id': 'n$i',
    'channel_id': channelId,
    'user_id': 'someone',
    'create_at': start.add(Duration(minutes: i)).millisecondsSinceEpoch,
    'message': 'message $i',
  };

  Map<String, Object?> page(Iterable<int> newestFirst) => {
    'order': [for (final i in newestFirst) 'n$i'],
    'posts': {for (final i in newestFirst) 'n$i': post(i)},
  };

  Iterable<int> range(int newest, int oldest) sync* {
    for (var i = newest; i >= oldest; i--) {
      yield i;
    }
  }

  testWidgets('a message opened from search stays centred while the newer '
      'messages arrive', (tester) async {
    final answerNewer = Completer<void>();
    final h = await pumpWithServer(
      tester,
      handle: (r) async {
        if (r.path == '/api/v4/posts/n50') return ok(post(50));
        if (r.path == '/api/v4/channels/$channelId/posts') {
          final query = r.raw.uri.queryParameters;
          if (query['before'] == 'n50') return ok(page(range(49, 20)));
          if (query['after'] == 'n50') return ok(page(range(80, 51)));
          await answerNewer.future;
          return ok(page(range(200, 81)));
        }
        if (r.path == '/api/v4/users/ids') return ok(<Object?>[]);
        return ok(<String, Object?>{});
      },
      home: (url) => Scaffold(
        body: ConversationView(
          url: url,
          conversation: conversationProvider(
            url,
            channelId,
            highlightPostId: 'n50',
          ),
          startText: 'This is the start of Boats.',
        ),
      ),
    );
    await h.settle(tester);
    final row = find.text('message 50');
    expect(row, findsOneWidget);
    final before = tester.getTopLeft(row).dy;

    answerNewer.complete();
    await h.settle(tester);

    expect(row, findsOneWidget);
    expect(tester.getTopLeft(row).dy, closeTo(before, 1));
    await h.close(tester);
  });
}
