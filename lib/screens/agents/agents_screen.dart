import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/ui/context_menu.dart';
import 'package:matterleast/api/json/agents.dart';
import 'package:matterleast/app/agent_providers.dart';
import 'package:matterleast/app/today_provider.dart';
import 'package:matterleast/data/actions/message_links.dart';
import 'package:matterleast/domain/agent_stream.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/screens/channel/message_environment.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/ui/agent_post.dart';
import 'package:matterleast/ui/content_page.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/refresh_area.dart';
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
  var _opening = false;

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
      // Coming back must not bring the keyboard up again.
      FocusManager.instance.primaryFocus?.unfocus();
      unawaited(
        openConversation(
          navigator,
          url: widget.url,
          channelId: asked.channelId,
          rootId: asked.postId,
          title: bot.name,
        ).then((_) => _refreshThreads()),
      );
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(agentProblemText(e, widget.url))),
      );
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  // A new conversation, or its title, which is written after the first
  // answer, shows when the reader comes back.
  void _refreshThreads() {
    if (mounted) ref.invalidate(agentThreadsProvider(widget.url));
  }

  /// Opens [thread] in the channel its first post is in, which a channel
  /// summary's row does not name.
  Future<void> _open(AgentThread thread, AgentBot? bot) async {
    if (_opening) return;
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _opening = true);
    try {
      final links = await ref.read(messageLinksProvider(widget.url).future);
      final located = await links.locatePost(thread.root);
      if (located is! LinkedPostFound) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text(
              "This conversation is gone, or it's in a channel you're no "
              'longer in.',
            ),
          ),
        );
        return;
      }
      unawaited(
        openConversation(
          navigator,
          url: widget.url,
          channelId: located.channelId,
          rootId: thread.root,
          teamId: located.teamId,
          title: located.channelName.isNotEmpty
              ? located.channelName
              : bot?.name ?? 'Agents',
        ).then((_) => _refreshThreads()),
      );
    } on Object catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(agentProblemText(e, widget.url))),
      );
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final botsValue = ref.watch(agentBotsProvider(widget.url));
    final threadsValue = ref.watch(agentThreadsProvider(widget.url));
    final bots = botsValue.value;
    final bot = bots == null ? null : pickAgent(bots, saved: _botId);
    final busy = _opening || botsValue.isLoading || threadsValue.isLoading;
    return ContentPage(
      title: const Text('Agents'),
      progress: busy && bots != null,
      actions: [
        if (bots != null && bots.length > 1 && bot != null)
          PopupMenuButton<String>(
            tooltip: 'Choose agent',
            initialValue: bot.id,
            onSelected: (id) => setState(() => _botId = id),
            itemBuilder: (_) => [
              for (final b in bots)
                MenuItem(value: b.id, child: Text(b.name)),
            ],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
              child: Row(
                children: [Text(bot.name), const Icon(Icons.arrow_drop_down)],
              ),
            ),
          ),
      ],
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
              child: _History(
                url: widget.url,
                bot: bot,
                bots: bots ?? const [],
                threads: threadsValue,
                onOpen: _open,
              ),
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
  const _History({
    required this.url,
    required this.bot,
    required this.bots,
    required this.threads,
    required this.onOpen,
  });

  final String url;
  final AgentBot bot;
  final List<AgentBot> bots;
  final AsyncValue<List<AgentThread>> threads;
  final void Function(AgentThread thread, AgentBot? agent) onOpen;

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
    if (list.isEmpty) {
      return EmptyState(
        icon: Icons.smart_toy_outlined,
        title: 'Ask ${bot.name}',
        body:
            'Write a question below. Your conversations with agents, and '
            'the channel summaries they write for you, are listed here.',
      );
    }
    final today = ref.watch(todayProvider);
    final tokens = context.tokens;
    final text = Theme.of(context).textTheme;
    return RefreshArea(
      onRefresh: () => ref.refresh(agentThreadsProvider(url).future),
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, i) {
          final thread = list[i];
          final agent = agentOfThread(thread, bots);
          final message = thread.message ?? '';
          final title = thread.title?.isNotEmpty ?? false
              ? thread.title!
              : message.isNotEmpty
              ? message
              : 'Conversation';
          final subtitle = message.isNotEmpty && message != title
              ? message
              : bots.length > 1
              ? agent?.name
              : null;
          return ListTile(
            leading: agent == null
                ? const CircleAvatar(
                    radius: 18,
                    child: Icon(Icons.smart_toy_outlined, size: 20),
                  )
                : UserAvatar(
                    serverUrl: url,
                    userId: agent.id,
                    name: agent.name,
                    lastPictureUpdate: agent.lastIconUpdate,
                    size: 36,
                  ),
            title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: subtitle == null
                ? null
                : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
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
            onTap: () => onOpen(thread, agent),
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
