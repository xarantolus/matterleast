import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/json/agents.dart';
import 'package:matterleast/api/json/lenient.dart';
import 'package:matterleast/api/websocket/encoded.dart';
import 'package:matterleast/app/agent_providers.dart';
import 'package:matterleast/app/live_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/agent_actions.dart';
import 'package:matterleast/data/live/agent_live.dart';
import 'package:matterleast/domain/agent_stream.dart';
import 'package:matterleast/domain/post_list.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/ui/clickable.dart';
import 'package:matterleast/ui/markdown/post_body.dart';
import 'package:matterleast/ui/markdown/post_environment.dart';
import 'package:matterleast/ui/tokens.dart';

final _props = <String, AgentPostProps>{};

/// The plugin's props of [post], decoded once per version.
AgentPostProps agentPropsOf(PostItem post) {
  final json = post.propsJson ?? '';
  final key = '${post.id}:${json.hashCode}';
  final hit = _props[key];
  if (hit != null) return hit;
  final value = decodeJsonString(json);
  final props =
      (value is Map<String, Object?>
          ? decodeOrSkip(value, AgentPostProps.fromJson)
          : null) ??
      const AgentPostProps();
  if (_props.length > 200) _props.remove(_props.keys.first);
  return _props[key] = props;
}

/// The words for a failed request to the plugin: the server's own message
/// when it sent one.
String agentProblemText(Object error, String url) => switch (error) {
  ServerError(:final message?) when message.isNotEmpty => message,
  _ => requestProblemText(error, Uri.parse(url).host),
};

/// The body of an agent's answer: streamed text, reasoning, tools, sources
/// and, for the person who asked, Stop and Regenerate.
class AgentPostBody extends ConsumerWidget {
  const AgentPostBody({required this.post, super.key});

  final PostItem post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = PostEnvironment.maybeOf(context);
    if (env == null) return _Text(post.id, post.message);
    final url = env.server.toString();
    final props = agentPropsOf(post);
    final stream = ref.watch(agentStreamProvider(url, post.id)).value;
    final conversationId = props.conversationId;
    final AgentConversationState? state = conversationId == null
        ? null
        : ref
              .watch(agentConversationProvider(url, conversationId, post.id))
              .value;
    final conversation = state?.conversation;
    final me = ref.watch(currentUserProvider(url)).value?.id;
    final requester = isAgentRequester(
      me: me,
      props: props,
      conversation: conversation,
    );
    final streamed =
        stream != null && (stream.live != null || stream.rounds.isNotEmpty);
    final stored = conversation != null
        ? roundsFromConversation(conversation, post.id)
        : conversationId != null || streamed
        ? const <AgentRound>[]
        : [
            // Legacy plugins keep the answer in the post and its props.
            AgentRound(
              id: 'legacy',
              text: post.message,
              reasoning: props.reasoningSummary ?? '',
              toolCalls: props.pendingToolCall ?? const [],
              citations: props.annotations ?? const [],
            ),
          ].where((r) => !r.isEmpty).toList();
    final rounds = agentRoundsToShow(
      stored: stored,
      stream: stream,
      message: post.message,
      loading: state?.loading ?? false,
    );
    final stage = conversation != null
        ? toolStageOf(conversation, post.id)
        : props.pendingToolResult == true
        ? ToolStage.result
        : (props.pendingToolCall ?? const []).any(
            (c) => c.status == AgentToolStatus.pending,
          )
        ? ToolStage.call
        : ToolStage.done;
    // While the server isn't live nothing streams in, and a Stop could not
    // reach it; the answer waits instead of seeming to be written.
    final live = ref.watch(serverLiveProvider(url));
    final streaming = stream?.busy ?? false;
    final busy = streaming && live;
    final waiting = streaming && !live;
    final citations = citationsOf(rounds);
    final tokens = context.tokens;
    final muted = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: tokens.muted, fontStyle: FontStyle.italic);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state != null && state.failed && !streaming && rounds.isEmpty)
          Text("Couldn't load this answer.", style: muted),
        for (final (i, round) in rounds.indexed)
          _RoundView(
            key: ValueKey(round.id),
            postId: post.id,
            round: round,
            reasoningLoading:
                live &&
                round.id == 'live' &&
                (stream?.reasoningLoading ?? false),
            writing:
                live && round.id == 'live' && (stream?.generating ?? false),
            // Only the stored anchor step can wait for a decision.
            stage: i == rounds.length - 1 && i < stored.length
                ? stage
                : ToolStage.done,
            canDecide: requester,
            onDecided: conversationId == null
                ? null
                : () => ref
                      .read(serverSessionProvider(url).future)
                      .then((s) => s.connection.agents.refresh(conversationId)),
          ),
        if (waiting)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
            child: Text('Waiting for the server…', style: muted),
          )
        else if (stream?.precontent ?? false)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
            child: Row(
              children: [
                const SizedBox.square(
                  dimension: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: Spacing.sm),
                Text('Generating response…', style: muted),
              ],
            ),
          ),
        if (citations.isNotEmpty)
          _Sources(postId: post.id, citations: citations),
        if (requester && busy)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: OutlinedButton.icon(
              onPressed: () => _run(context, ref, url, (a) => a.stop(post.id)),
              icon: const Icon(Icons.stop_circle_outlined, size: 18),
              label: const Text('Stop'),
            ),
          )
        else if (requester &&
            !waiting &&
            rounds.isNotEmpty &&
            props.noRegen != true &&
            // A summary that starts a thread has no question to answer
            // again; the plugin refuses it.
            post.isReply &&
            post.sendState == null)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: TextButton.icon(
              onPressed: () =>
                  _run(context, ref, url, (a) => a.regenerate(post.id)),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Regenerate'),
            ),
          ),
      ],
    );
  }
}

Future<void> _run(
  BuildContext context,
  WidgetRef ref,
  String url,
  Future<void> Function(AgentActions actions) action,
) async {
  final messenger = ScaffoldMessenger.of(context);
  try {
    await action(await ref.read(agentActionsProvider(url).future));
  } on Object catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(agentProblemText(e, url))));
  }
}

class _Text extends StatelessWidget {
  const _Text(this.postId, this.text);

  final String postId;
  final String text;

  @override
  Widget build(BuildContext context) =>
      PostBody(postId: postId, message: text, collapsible: false);
}

class _RoundView extends StatelessWidget {
  const _RoundView({
    required this.postId,
    required this.round,
    required this.reasoningLoading,
    required this.writing,
    required this.stage,
    required this.canDecide,
    required this.onDecided,
    super.key,
  });

  final String postId;
  final AgentRound round;
  final bool reasoningLoading;
  final bool writing;
  final ToolStage stage;
  final bool canDecide;
  final VoidCallback? onDecided;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (round.reasoning.isNotEmpty)
        _Reasoning(text: round.reasoning, loading: reasoningLoading),
      if (round.text.isNotEmpty)
        // Text that is still being written isn't folded behind "Show more".
        PostBody(
          postId: '$postId:${round.id}',
          message: round.text,
          collapsible: !writing,
        ),
      if (round.toolCalls.isNotEmpty)
        AgentToolSet(
          postId: postId,
          calls: round.toolCalls,
          stage: stage,
          canDecide: canDecide,
          onDecided: onDecided,
        ),
    ],
  );
}

class _Reasoning extends StatefulWidget {
  const _Reasoning({required this.text, required this.loading});

  final String text;
  final bool loading;

  @override
  State<_Reasoning> createState() => _ReasoningState();
}

class _ReasoningState extends State<_Reasoning> {
  var _open = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final style = Theme.of(context).textTheme.bodySmall
        ?.copyWith(color: tokens.muted);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          mouseCursor: clickCursor,
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
            child: Row(
              children: [
                Icon(
                  _open ? Icons.expand_more : Icons.chevron_right,
                  size: 18,
                  color: tokens.muted,
                ),
                Text(widget.loading ? 'Thinking…' : 'Reasoning', style: style),
              ],
            ),
          ),
        ),
        if (_open)
          Container(
            margin: const EdgeInsets.only(bottom: Spacing.xs),
            padding: const EdgeInsetsDirectional.only(start: Spacing.md),
            decoration: BoxDecoration(
              border: BorderDirectional(
                start: BorderSide(color: tokens.hairline, width: 2),
              ),
            ),
            child: Text(widget.text, style: style),
          ),
      ],
    );
  }
}

class _Sources extends StatelessWidget {
  const _Sources({required this.postId, required this.citations});

  final String postId;
  final List<AgentCitation> citations;

  @override
  Widget build(BuildContext context) {
    final lines = [
      '**Sources**',
      for (final (i, c) in citations.indexed)
        if (c.url.isNotEmpty)
          '${i + 1}. [${_escape(c.title.isNotEmpty ? c.title : c.url)}](${c.url})'
        else
          '${i + 1}. ${_escape(c.title)}',
    ];
    return PostBody(
      postId: '$postId:sources',
      message: lines.join('\n'),
      collapsible: false,
    );
  }

  static String _escape(String s) =>
      s.replaceAll(RegExp(r'([\[\]\\*_`])'), r'\$1');
}

/// The tools of one step: what each does, its status, and, for the person
/// who asked, the decisions still open. The batch is sent once every open
/// tool has a decision.
class AgentToolSet extends ConsumerStatefulWidget {
  const AgentToolSet({
    required this.postId,
    required this.calls,
    required this.stage,
    required this.canDecide,
    this.onDecided,
    super.key,
  });

  final String postId;
  final List<AgentToolCall> calls;
  final ToolStage stage;
  final bool canDecide;
  final VoidCallback? onDecided;

  @override
  ConsumerState<AgentToolSet> createState() => _AgentToolSetState();
}

class _AgentToolSetState extends ConsumerState<AgentToolSet> {
  final _decisions = <String, bool>{};
  final _answers = <String, AgentToolAnswer>{};
  var _sending = false;

  List<AgentToolCall> get _open => widget.canDecide
      ? [
          for (final c in widget.calls)
            if (needsDecision(c, widget.stage)) c,
        ]
      : const [];

  @override
  void didUpdateWidget(AgentToolSet old) {
    super.didUpdateWidget(old);
    if (old.stage != widget.stage) {
      _decisions.clear();
      _answers.clear();
    }
  }

  Future<void> _decide(
    AgentToolCall call,
    bool yes, [
    AgentToolAnswer? answer,
  ]) async {
    if (_sending) return;
    setState(() {
      _decisions[call.id] = yes;
      if (answer != null) _answers[call.id] = answer;
    });
    final open = _open;
    if (!open.every((c) => _decisions.containsKey(c.id))) return;
    final accepted = [
      for (final c in open)
        if (_decisions[c.id] ?? false) c.id,
    ];
    final env = PostEnvironment.maybeOf(context);
    if (env == null) return;
    final url = env.server.toString();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    try {
      final actions = await ref.read(agentActionsProvider(url).future);
      if (widget.stage == ToolStage.result) {
        await actions.decideToolResults(widget.postId, accepted);
      } else {
        await actions.decideToolCalls(
          widget.postId,
          accepted,
          answers: {for (final id in accepted) id: ?_answers[id]},
        );
      }
    } on Object catch (e) {
      _decisions.clear();
      _answers.clear();
      messenger.showSnackBar(SnackBar(content: Text(agentProblemText(e, url))));
    } finally {
      if (mounted) setState(() => _sending = false);
      widget.onDecided?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final open = {for (final c in _open) c.id};
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.sm,
        children: [
          for (final call in widget.calls)
            _ToolCard(
              call: call,
              stage: widget.stage,
              decided: _decisions[call.id],
              actionable: open.contains(call.id) && !_sending,
              onDecide: (yes, [answer]) => _decide(call, yes, answer),
            ),
        ],
      ),
    );
  }
}

class _ToolCard extends StatefulWidget {
  const _ToolCard({
    required this.call,
    required this.stage,
    required this.decided,
    required this.actionable,
    required this.onDecide,
  });

  final AgentToolCall call;
  final ToolStage stage;
  final bool? decided;
  final bool actionable;
  final void Function(bool yes, [AgentToolAnswer? answer]) onDecide;

  @override
  State<_ToolCard> createState() => _ToolCardState();
}

class _ToolCardState extends State<_ToolCard> {
  late var _open =
      widget.actionable && widget.call.status != AgentToolStatus.autoApproved;
  final _picked = <String>{};

  @override
  Widget build(BuildContext context) {
    final call = widget.call;
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final small = theme.textTheme.bodySmall?.copyWith(color: tokens.muted);
    final question = call.question;
    final asking =
        question != null && widget.stage == ToolStage.call && widget.actionable;
    final status = switch ((widget.decided, call.status)) {
      (true, _) when widget.stage == ToolStage.result => 'Shared',
      (false, _) when widget.stage == ToolStage.result => 'Kept private',
      (true, _) => 'Accepted',
      (false, _) => 'Rejected',
      (_, AgentToolStatus.pending) =>
        call.wouldAutoExecute == true ? 'Will run' : 'Waiting for you',
      (_, AgentToolStatus.accepted) => 'Running…',
      (_, AgentToolStatus.rejected) => 'Rejected',
      (_, AgentToolStatus.error) => 'Failed',
      (_, AgentToolStatus.success) => 'Done',
      (_, AgentToolStatus.autoApproved) => 'Ran automatically',
    };
    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              mouseCursor: clickCursor,
              onTap: () => setState(() => _open = !_open),
              child: Row(
                children: [
                  Icon(
                    question != null
                        ? Icons.help_outline
                        : Icons.build_outlined,
                    size: 18,
                    color: tokens.muted,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Text(
                      question?.question ?? call.name,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  const SizedBox(width: Spacing.sm),
                  Text(status, style: small),
                  Icon(
                    _open ? Icons.expand_less : Icons.expand_more,
                    size: 18,
                    color: tokens.muted,
                  ),
                ],
              ),
            ),
            if (_open &&
                call.description != null &&
                call.description!.isNotEmpty &&
                question == null)
              Padding(
                padding: const EdgeInsets.only(top: Spacing.xs),
                child: Text(
                  call.description!,
                  style: small,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (_open && question == null && call.arguments != null)
              _Code(label: 'Input', text: call.arguments!),
            if (_open && call.result != null)
              _Code(
                label: question != null ? 'Answer' : 'Response',
                text: _answerText(call.result!),
              ),
            if (asking) ...[
              const SizedBox(height: Spacing.sm),
              if (question.multiSelect == true)
                for (final option in question.options)
                  CheckboxListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    value: _picked.contains(option.label),
                    onChanged: (v) => setState(
                      () => v == true
                          ? _picked.add(option.label)
                          : _picked.remove(option.label),
                    ),
                    title: Text(option.label),
                    subtitle: option.description == null
                        ? null
                        : Text(option.description!),
                  )
              else
                RadioGroup<String>(
                  groupValue: _picked.firstOrNull,
                  onChanged: (v) => setState(() {
                    _picked.clear();
                    if (v != null) _picked.add(v);
                  }),
                  child: Column(
                    children: [
                      for (final option in question.options)
                        RadioListTile<String>(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          value: option.label,
                          title: Text(option.label),
                          subtitle: option.description == null
                              ? null
                              : Text(option.description!),
                        ),
                    ],
                  ),
                ),
            ],
            if (widget.actionable && widget.decided == null)
              Padding(
                padding: const EdgeInsets.only(top: Spacing.sm),
                child: Wrap(
                  spacing: Spacing.sm,
                  runSpacing: Spacing.xs,
                  alignment: WrapAlignment.end,
                  children: switch (widget.stage) {
                    ToolStage.result => [
                      TextButton(
                        onPressed: () => widget.onDecide(false),
                        child: const Text('Keep private'),
                      ),
                      FilledButton.tonal(
                        onPressed: () => widget.onDecide(true),
                        child: const Text('Share'),
                      ),
                    ],
                    _ when asking => [
                      TextButton(
                        onPressed: () => widget.onDecide(false),
                        child: const Text('Skip'),
                      ),
                      FilledButton.tonal(
                        onPressed: _picked.isEmpty
                            ? null
                            : () => widget.onDecide(
                                true,
                                AgentToolAnswer(selected: [..._picked]),
                              ),
                        child: const Text('Answer'),
                      ),
                    ],
                    _ => [
                      TextButton(
                        onPressed: () => widget.onDecide(false),
                        child: const Text('Reject'),
                      ),
                      FilledButton.tonal(
                        onPressed: () => widget.onDecide(true),
                        child: const Text('Accept'),
                      ),
                    ],
                  },
                ),
              ),
            if (widget.stage == ToolStage.result &&
                widget.actionable &&
                widget.decided == null)
              Padding(
                padding: const EdgeInsets.only(top: Spacing.xs),
                child: Text(
                  'Sharing lets the agent use this response in its next '
                  'message, which everyone in the channel can see.',
                  style: small,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// A question's answer reads as the picked options.
  static String _answerText(String result) {
    final value = decodeJsonString(result);
    if (value is Map<String, Object?> && value['selected'] is List) {
      final picked = [
        for (final s in value['selected']! as List)
          if (s is String) s,
      ];
      final custom = value['custom'];
      return [
        ...picked,
        if (custom is String && custom.isNotEmpty) custom,
      ].join(', ');
    }
    return result;
  }
}

class _Code extends StatelessWidget {
  const _Code({required this.label, required this.text});

  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: Spacing.xs),
          Container(
            padding: const EdgeInsets.all(Spacing.sm),
            decoration: BoxDecoration(
              color: tokens.codeBackground,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              text.length > 2000 ? '${text.substring(0, 2000)}…' : text,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A hint that an agent mentioned in a thread isn't in it, with a link to
/// bring it in.
class AgentMentionReminder extends ConsumerStatefulWidget {
  const AgentMentionReminder({required this.post, super.key});

  final PostItem post;

  @override
  ConsumerState<AgentMentionReminder> createState() =>
      _AgentMentionReminderState();
}

/// Posts whose agent was looped in this session, so a row scrolled away
/// and back keeps saying so.
final _loopedIn = <String>{};

class _AgentMentionReminderState extends ConsumerState<AgentMentionReminder> {
  var _pending = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final props = agentPropsOf(widget.post);
    final bot = props.botUsername ?? '';
    final target = props.targetPostId ?? '';
    final shown = (props.botDisplayName?.trim().isNotEmpty ?? false)
        ? props.botDisplayName!.trim()
        : bot;
    final tokens = context.tokens;
    final style = Theme.of(context).textTheme.bodyMedium
        ?.copyWith(color: tokens.muted);
    if (bot.isEmpty || target.isEmpty) {
      return _Text(widget.post.id, widget.post.message);
    }
    final env = PostEnvironment.maybeOf(context);
    if (_loopedIn.contains(target)) {
      return Text('Looped in @$shown.', style: style);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('@$shown isn\'t following this thread.', style: style),
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: _pending || env == null
              ? null
              : () async {
                  final url = env.server.toString();
                  setState(() {
                    _pending = true;
                    _error = null;
                  });
                  try {
                    final actions = await ref.read(
                      agentActionsProvider(url).future,
                    );
                    await actions.loopIn(target, bot);
                    _loopedIn.add(target);
                  } on Object catch (e) {
                    _error = agentProblemText(e, url);
                  }
                  if (mounted) setState(() => _pending = false);
                },
          child: Text('Loop in @$shown'),
        ),
        if (_error case final error?)
          Text(
            error,
            style: style?.copyWith(color: Theme.of(context).colorScheme.error),
          ),
      ],
    );
  }
}
