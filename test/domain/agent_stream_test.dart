import 'package:flutter_test/flutter_test.dart';
import 'package:matterleast/api/json/agents.dart';
import 'package:matterleast/api/websocket/server_events.dart';
import 'package:matterleast/domain/agent_stream.dart';

AgentPostUpdate _event(Map<String, Object?> json) =>
    AgentPostUpdate.fromJson({'post_id': 'answer1', ...json});

AgentStream _play(List<Map<String, Object?>> events, [AgentStream? from]) {
  var state = from;
  for (final e in events) {
    state = reduceAgentStream(state, _event(e));
  }
  return state!;
}

/// An invented conversation in the shape plugin 2.x serves: a question,
/// then an answer that asks the user something and waits.
final _conversation = AgentConversation.fromJson({
  'id': 'conv1',
  'user_id': 'asker',
  'bot_id': 'bot1',
  'channel_id': 'dm1',
  'root_post_id': 'question1',
  'title': 'Harbour lights',
  'turns': [
    {
      'id': 't1',
      'post_id': 'question1',
      'role': 'user',
      'content': [
        {'type': 'text', 'text': 'Earlier question'},
      ],
      'sequence': 1,
    },
    {
      'id': 't2',
      'post_id': 'answer0',
      'role': 'assistant',
      'content': [
        {'type': 'thinking', 'text': 'Keep it short.'},
        {
          'type': 'text',
          'text': 'Earlier answer',
          'citations': [
            {
              'type': 'url_citation',
              'url': 'https://example.test/a',
              'title': 'A',
            },
          ],
        },
      ],
      'sequence': 2,
      'approval_state': 'done',
    },
    {
      'id': 't3',
      'post_id': 'question2',
      'role': 'user',
      'content': [
        {'type': 'text', 'text': 'Ask me something'},
      ],
      'sequence': 3,
    },
    {
      'id': 't4',
      'post_id': 'answer1',
      'role': 'assistant',
      'content': [
        {
          'type': 'tool_use',
          'id': 'call1',
          'name': 'AskUserQuestion',
          'input': {
            'question': 'Which light?',
            'options': [
              {'label': 'Red', 'description': 'Port side'},
              {'label': 'Green'},
            ],
            'multi_select': false,
          },
          'status': 'pending',
          'user_interaction': 'select',
        },
      ],
      'sequence': 4,
      'approval_state': 'call',
    },
    {'id': 'broken', 'content': 'not a list', 'sequence': 'x'},
  ],
});

void main() {
  group('streaming an answer', () {
    test('shows "Generating" until text arrives, then the whole text', () {
      final started = _play([
        {'control': 'start'},
      ]);
      expect(started.precontent, isTrue);
      expect(started.live, isNull);

      final writing = _play([
        {'next': 'Hello'},
        {'next': 'Hello there'},
      ], started);
      expect(writing.precontent, isFalse);
      expect(writing.generating, isTrue);
      expect(writing.live!.text, 'Hello there');
    });

    test('progress before start already says it is generating', () {
      final s = _play([
        {'control': 'progress', 'progress_phase': 'loading_conversation'},
      ]);
      expect(s.precontent, isTrue);
      expect(s.busy, isTrue);
    });

    test('ends with the text kept and nothing busy', () {
      final s = _play([
        {'control': 'start'},
        {'next': 'Done.'},
        {'control': 'end'},
      ]);
      expect(s.busy, isFalse);
      expect(s.live!.text, 'Done.');
    });

    test('late text after Stop is ignored until the next start', () {
      var s = _play([
        {'control': 'start'},
        {'next': 'One two'},
      ]);
      s = stopAgentStream(s);
      s = _play([
        {'next': 'One two three'},
        {'control': 'reasoning_summary', 'reasoning': 'late'},
      ], s);
      expect(s.live!.text, 'One two');
      expect(s.reasoning, isEmpty);
      expect(s.busy, isFalse);

      s = _play([
        {'control': 'start'},
        {'next': 'Fresh'},
      ], s);
      expect(s.live!.text, 'Fresh');
    });

    test('reasoning streams before the text and stops loading when done', () {
      var s = _play([
        {'control': 'start'},
        {'control': 'reasoning_summary', 'reasoning': 'Thinking about'},
      ]);
      expect(s.reasoningLoading, isTrue);
      expect(s.reasoning, 'Thinking about');
      s = _play([
        {'control': 'reasoning_summary_done', 'reasoning': 'Thinking about it'},
        {'next': 'Answer'},
      ], s);
      expect(s.reasoningLoading, isFalse);
      expect(s.reasoning, 'Thinking about it');
      expect(s.live!.text, 'Answer');
    });

    test('tool calls update by id and a finished round becomes a step', () {
      var s = _play([
        {'control': 'start'},
        {'next': 'Let me look.'},
        {
          'control': 'tool_call',
          'tool_call':
              '[{"id":"c1","name":"Lookup","arguments":{"q":"x"},"status":0}]',
        },
      ]);
      expect(s.toolCalls.single.status, AgentToolStatus.pending);
      expect(s.toolCalls.single.arguments, contains('"q": "x"'));

      s = _play([
        {
          'control': 'tool_call',
          'tool_call':
              '[{"id":"c1","name":"Lookup","result":"found","status":4}]',
        },
      ], s);
      expect(s.rounds, hasLength(1));
      expect(s.rounds.single.text, 'Let me look.');
      expect(s.rounds.single.toolCalls.single.result, 'found');
      expect(s.toolCalls, isEmpty);
      expect(s.message, isEmpty);
    });

    test('unreadable tool calls leave the state as it was', () {
      final before = _play([
        {'control': 'start'},
        {'next': 'Hi'},
      ]);
      final after = _play([
        {'control': 'tool_call', 'tool_call': 'not json'},
      ], before);
      expect(after.toolCalls, isEmpty);
      expect(after.live!.text, 'Hi');
    });

    test('continue after a tool decision starts a clean live round', () {
      final s = _play([
        {'control': 'start'},
        {'next': 'Before'},
        {'control': 'continue'},
      ]);
      expect(s.live, isNull);
      expect(s.resumed, 1);
      expect(s.precontent, isTrue);
    });
  });

  group('rounds from the conversation', () {
    test('an answer is its own turns, not the earlier answer', () {
      final rounds = roundsFromConversation(_conversation, 'answer1');
      expect(rounds, hasLength(1));
      final call = rounds.single.toolCalls.single;
      expect(call.name, 'AskUserQuestion');
      expect(call.question!.question, 'Which light?');
      expect(call.question!.options.map((o) => o.label), ['Red', 'Green']);
      expect(call.asksUser, isTrue);
    });

    test('text, reasoning and sources of an earlier answer', () {
      final rounds = roundsFromConversation(_conversation, 'answer0');
      expect(rounds.single.text, 'Earlier answer');
      expect(rounds.single.reasoning, 'Keep it short.');
      expect(citationsOf(rounds).single.url, 'https://example.test/a');
    });

    test('the open decision comes from the anchor turn', () {
      expect(toolStageOf(_conversation, 'answer1'), ToolStage.call);
      expect(toolStageOf(_conversation, 'answer0'), ToolStage.done);
      expect(toolStageOf(_conversation, 'unknown'), ToolStage.done);
    });

    test('a fresh stream replaces the stored answer, a resumed one adds', () {
      final stored = roundsFromConversation(_conversation, 'answer1');
      final fresh = _play([
        {'control': 'start'},
        {'next': 'New text'},
      ]);
      expect(
        agentRoundsToShow(
          stored: stored,
          stream: fresh,
          message: '',
          loading: false,
        ).map((r) => r.text),
        ['New text'],
      );
      final resumed = _play([
        {'control': 'continue'},
        {'next': 'After the answer'},
      ]);
      expect(
        agentRoundsToShow(
          stored: stored,
          stream: resumed,
          message: '',
          loading: false,
        ),
        hasLength(2),
      );
    });

    test("the post's text stands in when nothing else is there", () {
      expect(
        agentRoundsToShow(
          stored: const [],
          stream: null,
          message: 'Plain',
          loading: false,
        ).single.text,
        'Plain',
      );
      expect(
        agentRoundsToShow(
          stored: const [],
          stream: null,
          message: 'Plain',
          loading: true,
        ),
        isEmpty,
      );
    });
  });

  group('decisions', () {
    const pending = AgentToolCall(id: 'a', name: 'Run');
    const auto = AgentToolCall(id: 'b', name: 'Run', wouldAutoExecute: true);
    const ran = AgentToolCall(
      id: 'c',
      name: 'Run',
      status: AgentToolStatus.success,
    );

    test('pending calls wait for the user unless they run on their own', () {
      expect(needsDecision(pending, ToolStage.call), isTrue);
      expect(needsDecision(auto, ToolStage.call), isFalse);
      expect(needsDecision(pending, ToolStage.done), isFalse);
    });

    test('results wait for a share decision once', () {
      expect(needsDecision(ran, ToolStage.result), isTrue);
      expect(
        needsDecision(
          const AgentToolCall(
            id: 'd',
            status: AgentToolStatus.success,
            decided: true,
          ),
          ToolStage.result,
        ),
        isFalse,
      );
      expect(needsDecision(pending, ToolStage.result), isFalse);
    });

    test('only the person who asked may act', () {
      const props = AgentPostProps(llmRequesterUserId: 'asker');
      expect(isAgentRequester(me: 'asker', props: props), isTrue);
      expect(isAgentRequester(me: 'other', props: props), isFalse);
      expect(
        isAgentRequester(
          me: 'other',
          props: props,
          conversation: const AgentConversation(userId: 'other'),
        ),
        isTrue,
      );
      expect(isAgentRequester(me: null, props: props), isFalse);
    });

    test('the picker starts on the saved agent, else the default', () {
      final bots = AgentBotsAnswer.fromJson({
        'bots': [
          {'id': 'b1', 'username': 'one'},
          {'id': 'b2', 'username': 'two', 'isDefault': true},
          'junk',
        ],
      }).bots;
      expect(bots, hasLength(2));
      expect(pickAgent(bots)!.id, 'b2');
      expect(pickAgent(bots, saved: 'b1')!.id, 'b1');
      expect(pickAgent(bots, saved: 'gone')!.id, 'b2');
      expect(pickAgent(const []), isNull);
    });
  });

  test('plugin WebSocket events decode into agent events', () {
    final update = decodeEvent(
      SocketFrame.fromJson({
        'event': 'custom_mattermost-ai_tool_call_status_updated',
        'data': {
          'post_id': 'answer1',
          'control': 'tool_call',
          'tool_call': '[{"id":"c1","name":"Lookup","status":"error"}]',
        },
      }),
    );
    expect(update, isA<AgentPostEvent>());
    final calls = (update as AgentPostEvent).update.toolCalls!;
    expect(calls.single.status, AgentToolStatus.error);

    final changed = decodeEvent(
      SocketFrame.fromJson({
        'event': 'custom_mattermost-ai_conversation_updated',
        'data': {'conversation_id': 'conv1'},
      }),
    );
    expect((changed as AgentConversationEvent).conversationId, 'conv1');
  });
}
