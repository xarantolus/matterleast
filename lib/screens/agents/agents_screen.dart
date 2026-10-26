import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/json/agents.dart';
import 'package:matterleast/app/agent_providers.dart';
import 'package:matterleast/app/today_provider.dart';
import 'package:matterleast/domain/agent_stream.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/ui/agent_post.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/user_avatar.dart';

/// Talk to an agent: pick one, ask, and find earlier conversations. Each
/// conversation is a thread in the direct message with the agent.
class AgentsScreen extends ConsumerStatefulWidget {
  const AgentsScreen({required this.url, super.key});

  final String url;

  @override
  ConsumerState<AgentsScreen> createState() => _AgentsScreenState();
}

class _AgentsScreenState extends ConsumerState<AgentsScreen> {
  final _text = TextEditingController();
  String? _botId;
  var _sending = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _ask(AgentBot bot) async {
    final message = _text.text.trim();
    if (message.isEmpty || _sending) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    try {
      final actions = await ref.read(agentActionsProvider(widget.url).future);
      final asked = await actions.ask(bot, message);
      _text.clear();
      ref.invalidate(agentThreadsProvider(widget.url));
      await openConversation(
        navigator,
        url: widget.url,
        channelId: asked.channelId,
        rootId: asked.postId,
        title: bot.name,
      );
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(agentProblemText(e, widget.url))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final botsValue = ref.watch(agentBotsProvider(widget.url));
    final threadsValue = ref.watch(agentThreadsProvider(widget.url));
    final bots = botsValue.value;
    final bot = bots == null ? null : pickAgent(bots, saved: _botId);
    final refreshing = botsValue.isLoading || threadsValue.isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agents'),
        bottom: ProgressSlot(active: refreshing && bots != null),
        actions: [
          if (bots != null && bots.length > 1 && bot != null)
            PopupMenuButton<String>(
              tooltip: 'Choose agent',
              initialValue: bot.id,
              onSelected: (id) => setState(() => _botId = id),
              itemBuilder: (_) => [
                for (final b in bots)
                  PopupMenuItem(value: b.id, child: Text(b.name)),
              ],
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                child: Row(
                  children: [Text(bot.name), const Icon(Icons.arrow_drop_down)],
                ),
              ),
            ),
        ],
      ),
      body: switch (botsValue) {
        AsyncValue(value: null, :final error?) => EmptyState(
          icon: Icons.error_outline,
          title: "Couldn't load the agents",
          body: agentProblemText(error, widget.url),
          action: FilledButton.tonal(
            onPressed: () => ref.invalidate(agentBotsProvider(widget.url)),
            child: const Text('Retry'),
          ),
        ),
        AsyncValue(value: null) => const Center(
          child: CircularProgressIndicator(),
        ),
        _ when bot == null => const EmptyState(
          icon: Icons.smart_toy_outlined,
          title: 'No agents for you',
          body:
              'An administrator can add agents, or give you access to one, '
              'in the Agents plugin settings.',
        ),
        _ => Column(
          children: [
            Expanded(
              child: _History(url: widget.url, bot: bot, threads: threadsValue),
            ),
            _AskField(
              controller: _text,
              bot: bot,
              sending: _sending,
              onSend: () => _ask(bot),
            ),
          ],
        ),
      },
    );
  }
}

class _History extends ConsumerWidget {
  const _History({required this.url, required this.bot, required this.threads});

  final String url;
  final AgentBot bot;
  final AsyncValue<List<AgentThread>> threads;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = threads.value;
    if (list == null) {
      if (threads.error case final error?) {
        return EmptyState(
          icon: Icons.error_outline,
          title: "Couldn't load your conversations",
          body: agentProblemText(error, url),
          action: FilledButton.tonal(
            onPressed: () => ref.invalidate(agentThreadsProvider(url)),
            child: const Text('Retry'),
          ),
        );
      }
      return const Center(child: CircularProgressIndicator());
    }
    final mine = [
      for (final t in list)
        if (t.botId == null || t.botId!.isEmpty || t.botId == bot.id) t,
    ];
    if (mine.isEmpty) {
      return EmptyState(
        icon: Icons.smart_toy_outlined,
        title: 'Ask ${bot.name}',
        body:
            'Write a question below. Your conversations with the agent are '
            'listed here.',
      );
    }
    final today = ref.watch(todayProvider);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    return RefreshIndicator(
      onRefresh: () => ref.refresh(agentThreadsProvider(url).future),
      child: ListView.builder(
        itemCount: mine.length,
        itemBuilder: (context, i) {
          final thread = mine[i];
          final title = thread.title?.isNotEmpty ?? false
              ? thread.title!
              : thread.message?.isNotEmpty ?? false
              ? thread.message!
              : 'Conversation';
          return ListTile(
            leading: UserAvatar(
              serverUrl: url,
              userId: bot.id,
              name: bot.name,
              lastPictureUpdate: bot.lastIconUpdate,
              size: 36,
            ),
            title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: thread.message?.isNotEmpty ?? false
                ? Text(
                    thread.message!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  )
                : null,
            trailing: thread.updateAt == null
                ? null
                : Text(
                    shortWhen(
                      thread.updateAt!.toLocal(),
                      today,
                      use24: MediaQuery.alwaysUse24HourFormatOf(context),
                    ),
                    style: text.bodySmall?.copyWith(color: tokens.muted),
                  ),
            onTap: thread.channelId == null || thread.channelId!.isEmpty
                ? null
                : () => openConversation(
                    Navigator.of(context),
                    url: url,
                    channelId: thread.channelId!,
                    rootId: thread.root,
                    title: bot.name,
                  ),
          );
        },
      ),
    );
  }
}

class _AskField extends StatelessWidget {
  const _AskField({
    required this.controller,
    required this.bot,
    required this.sending,
    required this.onSend,
  });

  final TextEditingController controller;
  final AgentBot bot;
  final bool sending;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) => Material(
    color: context.tokens.panel,
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          Spacing.lg,
          Spacing.sm,
          Spacing.sm,
          Spacing.sm,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Ask ${bot.name}',
                  border: InputBorder.none,
                ),
              ),
            ),
            ListenableBuilder(
              listenable: controller,
              builder: (context, _) => IconButton.filled(
                tooltip: 'Send',
                onPressed: sending || controller.text.trim().isEmpty
                    ? null
                    : onSend,
                icon: const Icon(Icons.send),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
