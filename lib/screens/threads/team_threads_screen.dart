import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/conversation_actions.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/home/home_providers.dart';
import 'package:matterleast/screens/home/open_item.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/threads/thread_options_sheet.dart';
import 'package:matterleast/ui/bar_tabs.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/content_page.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/message_preview_tile.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/tokens.dart';

/// The threads the user follows in one team.
class TeamThreadsScreen extends ConsumerStatefulWidget {
  const TeamThreadsScreen({
    required this.url,
    required this.teamId,
    required this.teamName,
    super.key,
  });

  final String url;
  final String teamId;
  final String teamName;

  @override
  ConsumerState<TeamThreadsScreen> createState() => _TeamThreadsScreenState();
}

class _TeamThreadsScreenState extends ConsumerState<TeamThreadsScreen> {
  ApiError? _failure;

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
  }

  Future<void> _refresh() async {
    try {
      final session = await ref.read(serverSessionProvider(widget.url).future);
      await session.connection.inbox.refreshTeamThreads(widget.teamId);
      if (mounted) setState(() => _failure = null);
    } on ApiError catch (e) {
      if (mounted) setState(() => _failure = e);
    }
  }

  Future<void> _markAllRead() async {
    final messenger = ScaffoldMessenger.of(context);
    final sure = await confirm(
      context,
      title: 'Mark all as read?',
      body: 'Every thread you follow in ${widget.teamName} counts as read.',
      action: 'Mark read',
    );
    if (!sure) return;
    try {
      final session = await ref.read(serverSessionProvider(widget.url).future);
      await ConversationActions(session).markAllThreadsRead(widget.teamId);
    } on ApiError catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            "Couldn't mark the threads as read. "
            '${requestProblemText(e, Uri.parse(widget.url).host)}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(teamThreadsProvider(widget.url, widget.teamId)).value;
    final refreshing =
        ref.watch(syncStatusProvider(widget.url)).value is SyncRefreshing;
    const tabs = BarTabs(
      tabs: [
        Tab(text: 'All'),
        Tab(text: 'Unread'),
      ],
    );
    Widget list({required bool unreadOnly}) => _ThreadList(
      key: PageStorageKey(unreadOnly),
      url: widget.url,
      all: all,
      unreadOnly: unreadOnly,
      refreshing: refreshing,
      failure: _failure,
      onRetry: _refresh,
    );
    return DefaultTabController(
      length: 2,
      child: ContentPage(
        title: Text(
          'Threads · ${widget.teamName}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            onPressed: (all?.any((t) => t.unread) ?? false)
                ? _markAllRead
                : null,
            icon: const Icon(Icons.done_all),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(tabs.preferredSize.height + 3),
          child: Column(
            children: [
              tabs,
              ProgressSlot(active: refreshing),
            ],
          ),
        ),
        body: TabBarView(
          children: [list(unreadOnly: false), list(unreadOnly: true)],
        ),
      ),
    );
  }
}

/// All followed threads, or only the unread ones; each tab keeps its own
/// scroll position.
class _ThreadList extends StatelessWidget {
  const _ThreadList({
    required this.url,
    required this.all,
    required this.unreadOnly,
    required this.refreshing,
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final String url;
  final List<InboxItem>? all;
  final bool unreadOnly;
  final bool refreshing;
  final ApiError? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final all = this.all;
    final failure = this.failure;
    final items = all == null
        ? null
        : [
            for (final item in all)
              if (!unreadOnly || item.unread) item,
          ];
    return CustomScrollView(
      slivers: [
        if (all == null || items == null || (all.isEmpty && refreshing))
          const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (all.isEmpty && failure != null)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              icon: Icons.cloud_off,
              title: "Couldn't load threads",
              body: connectionProblemText(failure, Uri.parse(url).host),
              action: FilledButton.tonal(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ),
          )
        else if (items.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: unreadOnly
                ? const EmptyState(
                    icon: Icons.done_all,
                    title: 'No unread threads',
                    body: 'New replies in threads you follow show up here.',
                  )
                : const EmptyState(
                    icon: Icons.forum_outlined,
                    title: 'No threads',
                    body: 'Follow a thread to see its replies here.',
                  ),
          )
        else
          SliverList.builder(
            itemCount: items.length,
            itemBuilder: (context, i) => MessagePreviewTile(
              key: ValueKey(items[i].key),
              item: items[i],
              onTap: () => openInboxItem(context, items[i]),
              onLongPress: () => showThreadOptions(context, items[i]),
            ),
          ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: MediaQuery.paddingOf(context).bottom + Spacing.lg,
          ),
        ),
      ],
    );
  }
}
