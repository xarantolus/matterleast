import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/json/agents.dart';
import 'package:matterleast/data/live/agent_live.dart';
import 'package:matterleast/domain/agent_stream.dart';

AgentConversation _conversation({required bool answered}) =>
    AgentConversation.fromJson({
      'id': 'conv1',
      'user_id': 'asker',
      'turns': [
        {
          'id': 't1',
          'post_id': 'question1',
          'role': 'user',
          'content': [
            {'type': 'text', 'text': 'Hi'},
          ],
          'sequence': 1,
        },
        if (answered)
          {
            'id': 't2',
            'post_id': 'answer1',
            'role': 'assistant',
            'content': [
              {'type': 'text', 'text': 'Stored answer'},
            ],
            'sequence': 2,
            'approval_state': 'done',
          },
      ],
    });

AgentPostUpdate _event(Map<String, Object?> json) =>
    AgentPostUpdate.fromJson({'post_id': 'answer1', ...json});

void main() {
  test('an ended answer switches to the stored one without a gap, even '
      'when the first fetch was still running', () async {
    var answered = false;
    final fetches = <Completer<AgentConversation>>[];
    final live = AgentLive(
      fetchConversation: (_) {
        final c = Completer<AgentConversation>();
        fetches.add(c);
        return c.future;
      },
    );
    addTearDown(live.close);
    final states = <AgentConversationState>[];
    final sub = live
        .watchConversation('conv1', postId: 'answer1')
        .listen(states.add);
    addTearDown(sub.cancel);
    await pumpEventQueue();
    expect(fetches, hasLength(1));

    live
      ..apply(_event({'control': 'start'}))
      ..apply(_event({'next': 'Streamed answer'}));
    answered = true;
    live.apply(_event({'control': 'end'}));
    expect(live.stream('answer1')!.live!.text, 'Streamed answer');

    // The fetch from before the answer was stored arrives first.
    fetches.first.complete(_conversation(answered: false));
    await pumpEventQueue();
    expect(fetches, hasLength(2), reason: 'a fetch after the end follows');
    expect(
      live.stream('answer1'),
      isNotNull,
      reason: 'the streamed text stays until the stored answer is there',
    );

    fetches.last.complete(_conversation(answered: answered));
    await pumpEventQueue();
    expect(live.stream('answer1'), isNull);
    final stored = roundsFromConversation(states.last.conversation!, 'answer1');
    expect(stored.single.text, 'Stored answer');
  });

  test('a failed fetch keeps the conversation that was shown', () async {
    var fail = false;
    final live = AgentLive(
      fetchConversation: (_) async {
        if (fail) throw StateError('offline');
        return _conversation(answered: true);
      },
    );
    addTearDown(live.close);
    final states = <AgentConversationState>[];
    final sub = live
        .watchConversation('conv1', postId: 'answer1')
        .listen(states.add);
    addTearDown(sub.cancel);
    await pumpEventQueue();
    fail = true;
    await live.refresh('conv1');
    await pumpEventQueue();
    expect(states.last.conversation, isNotNull);
    expect(states.last.loading, isFalse);
  });

  test('Stop ignores text that is still on its way', () {
    final live = AgentLive(
      fetchConversation: (_) async => _conversation(answered: false),
    );
    addTearDown(live.close);
    live
      ..apply(_event({'control': 'start'}))
      ..apply(_event({'next': 'Partial'}))
      ..stop('answer1')
      ..apply(_event({'next': 'Partial and more'}));
    expect(live.stream('answer1')!.live!.text, 'Partial');
    expect(live.stream('answer1')!.busy, isFalse);
  });
}
