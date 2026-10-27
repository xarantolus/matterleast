import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/json/agents.dart';
import 'package:matterleast/app/agent_providers.dart';
import 'package:matterleast/domain/agent_stream.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/ui/agent_post.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/tokens.dart';

/// "Ask Agents" for a channel: an agent writes a summary into its direct
/// message, which opens once it has started.
Future<void> showAskAgentsSheet(
  BuildContext context, {
  required String url,
  required String channelId,
  DateTime? unreadSince,
}) => showAppSheet<void>(
  context: context,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => _AskAgentsSheet(
    url: url,
    channelId: channelId,
    unreadSince: unreadSince,
    navigator: Navigator.of(context),
  ),
);

class _AskAgentsSheet extends ConsumerStatefulWidget {
  const _AskAgentsSheet({
    required this.url,
    required this.channelId,
    required this.unreadSince,
    required this.navigator,
  });

  final String url;
  final String channelId;
  final DateTime? unreadSince;
  final NavigatorState navigator;

  @override
  ConsumerState<_AskAgentsSheet> createState() => _AskAgentsSheetState();
}

class _AskAgentsSheetState extends ConsumerState<_AskAgentsSheet> {
  String? _botId;
  var _running = false;

  Future<void> _summarize(
    AgentBot bot, {
    int? days,
    DateTime? unreadsSince,
  }) async {
    final messenger = ScaffoldMessenger.of(context);
    final sheet = Navigator.of(context);
    setState(() => _running = true);
    try {
      final actions = await ref.read(agentActionsProvider(widget.url).future);
      final answer = await actions.summarize(
        widget.channelId,
        bot,
        days: days,
        unreadsSince: unreadsSince,
      );
      sheet.pop();
      final channelId = answer.channelId;
      final postId = answer.postId;
      if (channelId == null || channelId.isEmpty || postId == null) return;
      await openConversation(
        widget.navigator,
        url: widget.url,
        channelId: channelId,
        rootId: postId,
        title: bot.name,
      );
    } on Object catch (e) {
      if (mounted) setState(() => _running = false);
      messenger.showSnackBar(
        SnackBar(content: Text(agentProblemText(e, widget.url))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bots = ref.watch(agentBotsProvider(widget.url));
    final list = bots.value ?? const <AgentBot>[];
    final bot = pickAgent(list, saved: _botId);
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.lg,
              0,
              Spacing.lg,
              Spacing.sm,
            ),
            child: Text('Ask Agents', style: text.titleLarge),
          ),
          SizedBox(
            height: 3,
            child: _running || bots.isLoading
                ? const LinearProgressIndicator(minHeight: 3)
                : null,
          ),
          if (bots.hasError && bots.value == null)
            ListTile(
              leading: const Icon(Icons.error_outline),
              title: Text(agentProblemText(bots.error!, widget.url)),
              trailing: TextButton(
                onPressed: () => ref.invalidate(agentBotsProvider(widget.url)),
                child: const Text('Retry'),
              ),
            )
          else if (bot == null && bots.hasValue)
            const ListTile(
              leading: Icon(Icons.smart_toy_outlined),
              title: Text('No agents are available to you.'),
            )
          else if (bot != null) ...[
            if (list.length > 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
                child: Wrap(
                  spacing: Spacing.sm,
                  children: [
                    for (final b in list)
                      ChoiceChip(
                        label: Text(b.name),
                        selected: b.id == bot.id,
                        onSelected: _running
                            ? null
                            : (_) => setState(() => _botId = b.id),
                      ),
                  ],
                ),
              ),
            for (final (label, days, since) in [
              if (widget.unreadSince != null)
                ('Summarize unreads', null, widget.unreadSince),
              ('Summarize the last 7 days', 7, null),
              ('Summarize the last 14 days', 14, null),
            ])
              ListTile(
                leading: const Icon(Icons.auto_awesome_outlined),
                title: Text(label),
                enabled: !_running,
                onTap: () => _summarize(bot, days: days, unreadsSince: since),
              ),
          ],
        ],
      ),
    );
  }
}
