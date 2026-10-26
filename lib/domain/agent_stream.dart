import 'package:matterleast/api/json/agents.dart';

/// Post types of the Agents plugin.
const agentPostTypes = {'custom_llmbot', 'custom_llm_postback'};
const agentMentionReminderType = 'custom_agent_mention_reminder';

/// The plugin's id and the first version the app supports.
const agentsPluginId = 'mattermost-ai';
const agentsMinVersion = (1, 4, 0);

/// One step of an agent's answer: what it thought, wrote and which tools
/// it called, in that order.
class AgentRound {
  const AgentRound({
    required this.id,
    this.text = '',
    this.reasoning = '',
    this.toolCalls = const [],
    this.citations = const [],
  });

  final String id;
  final String text;
  final String reasoning;
  final List<AgentToolCall> toolCalls;
  final List<AgentCitation> citations;

  bool get isEmpty =>
      text.isEmpty &&
      reasoning.isEmpty &&
      toolCalls.isEmpty &&
      citations.isEmpty;
}

/// What is streaming into one agent post right now, from the plugin's
/// WebSocket events. Kept in memory only.
class AgentStream {
  const AgentStream({
    this.generating = false,
    this.precontent = false,
    this.message = '',
    this.reasoning = '',
    this.reasoningLoading = false,
    this.toolCalls = const [],
    this.citations = const [],
    this.rounds = const [],
    this.stopped = false,
    this.resumed = 0,
  });

  final bool generating;

  /// Started, nothing to show yet: "Generating response…".
  final bool precontent;
  final String message;
  final String reasoning;
  final bool reasoningLoading;
  final List<AgentToolCall> toolCalls;
  final List<AgentCitation> citations;

  /// Earlier steps of this answer whose tools have all finished.
  final List<AgentRound> rounds;

  /// The user tapped Stop; late text is ignored until the next start.
  final bool stopped;

  /// Counts resumes after a tool decision; the conversation is fetched
  /// again on each.
  final int resumed;

  bool get busy => generating || reasoningLoading || precontent;

  /// The step being written now, if it has anything.
  AgentRound? get live {
    final round = AgentRound(
      id: 'live',
      text: message,
      reasoning: reasoning,
      toolCalls: toolCalls,
      citations: citations,
    );
    return round.isEmpty ? null : round;
  }

  AgentStream copyWith({
    bool? generating,
    bool? precontent,
    String? message,
    String? reasoning,
    bool? reasoningLoading,
    List<AgentToolCall>? toolCalls,
    List<AgentCitation>? citations,
    List<AgentRound>? rounds,
    bool? stopped,
    int? resumed,
  }) => AgentStream(
    generating: generating ?? this.generating,
    precontent: precontent ?? this.precontent,
    message: message ?? this.message,
    reasoning: reasoning ?? this.reasoning,
    reasoningLoading: reasoningLoading ?? this.reasoningLoading,
    toolCalls: toolCalls ?? this.toolCalls,
    citations: citations ?? this.citations,
    rounds: rounds ?? this.rounds,
    stopped: stopped ?? this.stopped,
    resumed: resumed ?? this.resumed,
  );
}

/// Pure: [state] after one plugin event. Events can arrive before `start`
/// (from another WebSocket scope), so `start` keeps what is there.
AgentStream reduceAgentStream(AgentStream? state, AgentPostUpdate update) {
  final s = state ?? const AgentStream();
  switch (update.control) {
    case 'start':
      return s.copyWith(
        generating: true,
        precontent: s.live == null && s.rounds.isEmpty,
        stopped: false,
      );
    case 'progress':
      return s.stopped || s.generating || s.live != null
          ? s
          : s.copyWith(precontent: true);
    case 'end' || 'cancel':
      return s.copyWith(
        generating: false,
        precontent: false,
        reasoningLoading: false,
        stopped: false,
      );
    case 'continue':
      // The step before the tool decision is stored on the server now and
      // comes back with the conversation.
      return AgentStream(
        generating: true,
        precontent: true,
        resumed: s.resumed + 1,
      );
  }
  if (s.stopped) return s;
  switch (update.control) {
    case 'reasoning_summary':
      final text = update.reasoning;
      if (text == null || text.isEmpty) return s;
      return s.copyWith(
        reasoning: text,
        reasoningLoading: true,
        generating: false,
        precontent: false,
      );
    case 'reasoning_summary_done':
      final text = update.reasoning;
      return text == null || text.isEmpty
          ? s.copyWith(reasoningLoading: false)
          : s.copyWith(reasoning: text, reasoningLoading: false);
    case 'tool_call':
      final calls = update.toolCalls;
      if (calls == null) return s;
      final merged = _mergeById(s.toolCalls, calls);
      if (merged.isNotEmpty && merged.every((c) => c.status.finished)) {
        return AgentStream(
          generating: s.generating,
          rounds: [
            ...s.rounds,
            AgentRound(
              id: 'live-${s.rounds.length}',
              text: s.message,
              reasoning: s.reasoning,
              toolCalls: merged,
              citations: s.citations,
            ),
          ],
          resumed: s.resumed,
        );
      }
      return s.copyWith(toolCalls: merged, precontent: false);
    case 'annotations':
      final citations = update.annotations;
      return citations == null
          ? s
          : s.copyWith(citations: citations, precontent: false);
  }
  final next = update.next;
  if (next == null) return s;
  return s.copyWith(message: next, precontent: false, generating: true);
}

/// Pure: [state] once the user tapped Stop.
AgentStream stopAgentStream(AgentStream? state) =>
    (state ?? const AgentStream()).copyWith(
      stopped: true,
      generating: false,
      precontent: false,
      reasoningLoading: false,
    );

List<AgentToolCall> _mergeById(
  List<AgentToolCall> existing,
  List<AgentToolCall> incoming,
) {
  final merged = [...existing];
  for (final call in incoming) {
    final at = merged.indexWhere((c) => c.id == call.id);
    if (at < 0) {
      merged.add(call);
    } else {
      merged[at] = call;
    }
  }
  return merged;
}

/// Whether a decision on tools is open, and which.
enum ToolStage {
  /// Run or skip the pending calls.
  call,

  /// Share or keep private what they returned.
  result,
  done;

  static ToolStage fromName(String? name) => switch (name) {
    'call' => call,
    'result' => result,
    _ => done,
  };
}

/// Pure: whether [call] waits for the user's decision in [stage].
bool needsDecision(AgentToolCall call, ToolStage stage) => switch (stage) {
  ToolStage.call =>
    call.status == AgentToolStatus.pending && call.wouldAutoExecute != true,
  ToolStage.result =>
    !call.asksUser &&
        !call.decided &&
        (call.status == AgentToolStatus.success ||
            call.status == AgentToolStatus.error ||
            call.status == AgentToolStatus.autoApproved),
  ToolStage.done => false,
};

/// Pure: the turns that make up the answer in post [postId]: its anchor
/// (the last assistant turn of the post) and the tool rounds before it, up
/// to the user's message or another post's answer.
List<AgentTurn> responseTurns(AgentConversation conversation, String postId) {
  final sorted = [...conversation.turns]
    ..sort((a, b) => a.sequence.compareTo(b.sequence));
  final anchor = sorted.lastIndexWhere(
    (t) => t.postId == postId && t.role == 'assistant',
  );
  if (anchor < 0) return const [];
  var first = anchor;
  for (var i = anchor - 1; i >= 0; i--) {
    final t = sorted[i];
    if (t.role == 'user') break;
    if ((t.postId?.isNotEmpty ?? false) && t.postId != postId) break;
    first = i;
  }
  return sorted.sublist(first, anchor + 1);
}

/// Pure: the steps of the answer in post [postId], from its conversation.
List<AgentRound> roundsFromConversation(
  AgentConversation conversation,
  String postId,
) {
  final results = <String, AgentBlock>{
    for (final turn in conversation.turns)
      for (final block in turn.content)
        if (block.type == 'tool_result' && block.toolUseId != null)
          block.toolUseId!: block,
  };
  return [
    for (final turn in responseTurns(conversation, postId))
      if (turn.role == 'assistant')
        AgentRound(
          id: turn.id,
          text: [
            for (final b in turn.content)
              if (b.type == 'text') b.text ?? '',
          ].join(),
          reasoning: [
            for (final b in turn.content)
              if (b.type == 'thinking') b.text ?? '',
          ].join('\n'),
          toolCalls: [
            for (final b in turn.content)
              if (b.type == 'tool_use')
                AgentToolCall(
                  id: b.id ?? '',
                  name: b.name ?? '',
                  arguments: b.input,
                  question: b.question,
                  result: results[b.id]?.content,
                  status: AgentToolStatus.fromName(b.status),
                  userInteraction: b.userInteraction,
                  wouldAutoExecute: b.wouldAutoExecute,
                  decided: results[b.id]?.decidedAt != null,
                ),
          ],
          citations: [
            for (final b in turn.content)
              if (b.type == 'text') ...b.citations,
          ],
        ),
  ];
}

/// Pure: the open decision on post [postId]'s tools; done when the
/// conversation doesn't say, so no buttons show in error.
ToolStage toolStageOf(AgentConversation conversation, String postId) {
  AgentTurn? anchor;
  for (final turn in conversation.turns) {
    if (turn.postId == postId &&
        turn.role == 'assistant' &&
        (anchor == null || turn.sequence > anchor.sequence)) {
      anchor = turn;
    }
  }
  return ToolStage.fromName(anchor?.approvalState);
}

/// Pure: the anchor turn's sequence, to tell a newer answer from an older.
int anchorSequence(AgentConversation conversation, String postId) {
  final turns = responseTurns(conversation, postId);
  return turns.isEmpty ? -1 : turns.last.sequence;
}

/// Pure: the steps an agent post shows: what the server stored, then what
/// is streaming; the post's own text when neither has anything. A stream
/// that started afresh (a new or regenerated answer) replaces what was
/// stored; one resumed after a tool decision continues it.
List<AgentRound> agentRoundsToShow({
  required List<AgentRound> stored,
  required AgentStream? stream,
  required String message,
  required bool loading,
}) {
  final rounds = [
    if (stream == null || stream.resumed > 0) ...stored,
    if (stream != null) ...stream.rounds,
    ?stream?.live,
  ];
  if (rounds.isEmpty &&
      !(stream?.busy ?? false) &&
      !loading &&
      message.isNotEmpty) {
    return [AgentRound(id: 'message', text: message)];
  }
  return rounds;
}

/// Pure: who may stop, regenerate and decide: the person who asked.
bool isAgentRequester({
  required String? me,
  required AgentPostProps props,
  AgentConversation? conversation,
}) {
  if (me == null || me.isEmpty) return false;
  if (conversation != null) return conversation.userId == me;
  return props.llmRequesterUserId == me;
}

/// Pure: the agent a picker starts on: the saved one if still offered,
/// else the server's default, else the first.
AgentBot? pickAgent(List<AgentBot> bots, {String? saved}) {
  if (bots.isEmpty) return null;
  for (final b in bots) {
    if (b.id == saved) return b;
  }
  for (final b in bots) {
    if (b.defaultAgent) return b;
  }
  return bots.first;
}

/// Pure: the sources cited across [rounds], each address once.
List<AgentCitation> citationsOf(List<AgentRound> rounds) {
  final seen = <String>{};
  return [
    for (final round in rounds)
      for (final c in round.citations)
        if (c.url.isEmpty || seen.add(c.url)) c,
  ];
}
