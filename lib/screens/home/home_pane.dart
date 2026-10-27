import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/conversation_actions.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/home/home_providers.dart';
import 'package:matterleast/screens/home/home_state.dart';
import 'package:matterleast/screens/home/open_item.dart';
import 'package:matterleast/screens/reopen_swipe.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/message_preview_tile.dart';
import 'package:matterleast/ui/tokens.dart';

/// Unread conversations, mentions, followed threads and saved messages
/// from every signed-in server, newest first.
class HomePane extends ConsumerStatefulWidget {
  const HomePane({required this.servers, this.onSearch, super.key});

  /// Signed-in servers, never empty.
  final List<ServerEntry> servers;

  /// Opens the search view.
  final VoidCallback? onSearch;

  @override
  ConsumerState<HomePane> createState() => _HomePaneState();
}

class _HomePaneState extends ConsumerState<HomePane> {
  /// Conversations already asked for their newest messages, per server.
  final _previewed = <String, Set<String>>{};

  /// Fetches the newest messages of unread conversations that only have a
  /// count to show, the same way opening them would.
  Future<void> _fillPreviews(String url, ServerInbox? inbox) async {
    if (inbox == null) return;
    final asked = _previewed.putIfAbsent(url, () => {});
    final ids = conversationsWithoutPreview(inbox).where(asked.add).toList();
    if (ids.isEmpty) return;
    final actions = ConversationActions(
      await ref.read(serverSessionProvider(url).future),
    );
    for (final id in ids) {
      try {
        await actions.refreshChannel(id);
      } on ApiError {
        // The row keeps its count.
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_refresh(force: false));
      for (final s in widget.servers) {
        final inbox = ref.read(serverInboxProvider(s.url)).value;
        unawaited(_fillPreviews(s.url, inbox));
      }
    });
  }

  /// Refreshes every server's lists; returns the first failure.
  Future<(ServerEntry, ApiError)?> _refresh({required bool force}) async {
    final failures = await Future.wait([
      for (final server in widget.servers)
        () async {
          try {
            final session = await ref.read(
              serverSessionProvider(server.url).future,
            );
            await session.connection.inbox.refresh(
              force: force,
              priority: force ? SyncPriority.p1 : SyncPriority.p2,
            );
            return null;
          } on ApiError catch (e) {
            return (server, e);
          }
        }(),
    ]);
    return failures.nonNulls.firstOrNull;
  }

  Future<void> _pull() async {
    final messenger = ScaffoldMessenger.of(context);
    final failure = await _refresh(force: true);
    if (failure case (final server, final error)) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            connectionProblemText(error, Uri.parse(server.url).host),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(homeFilterSelectionProvider);
    final servers = widget.servers;
    for (final s in servers) {
      ref.listen(
        serverInboxProvider(s.url),
        (_, next) => unawaited(_fillPreviews(s.url, next.value)),
      );
    }
    final state = homeState(filter, [
      for (final s in servers)
        (
          name: s.displayName,
          host: Uri.parse(s.url).host,
          inbox: ref.watch(serverInboxProvider(s.url)).value,
          status: ref.watch(syncStatusProvider(s.url)).value,
        ),
    ]);
    final names = {
      if (servers.length > 1)
        for (final s in servers) s.url: s.displayName,
    };
    return ReopenSwipe(
      child: RefreshIndicator(
        onRefresh: _pull,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _FilterChips(
                selected: filter,
                onSelected: ref
                    .read(homeFilterSelectionProvider.notifier)
                    .select,
                notice: switch (state) {
                  HomeReady(:final notice) => notice,
                  _ => null,
                },
                onRetry: () => unawaited(_pull()),
              ),
            ),
            ...switch (state) {
              HomeLoading() => const [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: CircularProgressIndicator()),
                ),
              ],
              HomeFailed(:final title, :final detail) => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.cloud_off,
                    title: title,
                    body: detail,
                    action: FilledButton.tonal(
                      onPressed: () => unawaited(_refresh(force: true)),
                      child: const Text('Retry'),
                    ),
                  ),
                ),
              ],
              HomeReady(:final items) when items.isEmpty => [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _Empty(filter: filter, onSearch: widget.onSearch),
                ),
              ],
              HomeReady(:final items) => [
                SliverList.builder(
                  itemCount: items.length,
                  findChildIndexCallback: (key) {
                    final id = (key as ValueKey<String>).value;
                    final i = items.indexWhere((item) => item.key == id);
                    return i < 0 ? null : i;
                  },
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return MessagePreviewTile(
                      key: ValueKey(item.key),
                      item: item,
                      serverName: names[item.serverUrl],
                      onTap: () => openInboxItem(context, item),
                    );
                  },
                ),
              ],
            },
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.paddingOf(context).bottom + Spacing.lg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The filter chips, led by the failed-refresh notice as a chip that
/// retries, so the notice never pushes the list down.
class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.onSelected,
    required this.onRetry,
    this.notice,
  });

  final InboxFilter selected;
  final ValueChanged<InboxFilter> onSelected;
  final String? notice;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    padding: const EdgeInsets.symmetric(
      horizontal: Spacing.md,
      vertical: Spacing.sm,
    ),
    child: Row(
      spacing: Spacing.sm,
      children: [
        if (notice case final notice?)
          ActionChip(
            avatar: const Icon(Icons.cloud_off),
            label: Text(notice),
            tooltip: 'Retry',
            onPressed: onRetry,
          ),
        for (final filter in InboxFilter.values)
          ChoiceChip(
            label: Text(switch (filter) {
              InboxFilter.unread => 'Unread',
              InboxFilter.mentions => 'Mentions',
              InboxFilter.threads => 'Threads',
              InboxFilter.saved => 'Saved',
            }),
            selected: filter == selected,
            onSelected: (_) => onSelected(filter),
          ),
      ],
    ),
  );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.filter, this.onSearch});

  final InboxFilter filter;
  final VoidCallback? onSearch;

  @override
  Widget build(BuildContext context) => switch (filter) {
    InboxFilter.unread => EmptyState(
      icon: Icons.done_all,
      title: "You're all caught up",
      body:
          'New direct messages, mentions and thread replies show up here. '
          'Open a team from the rail, or search, to read more.',
      action: onSearch == null
          ? null
          : FilledButton.tonalIcon(
              onPressed: onSearch,
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),
    ),
    InboxFilter.mentions => const EmptyState(
      icon: Icons.alternate_email,
      title: 'No mentions',
      body: 'Nobody has mentioned you yet.',
    ),
    InboxFilter.threads => const EmptyState(
      icon: Icons.forum_outlined,
      title: 'No threads',
      body: 'Follow a thread to see its replies here.',
    ),
    InboxFilter.saved => const EmptyState(
      icon: Icons.bookmark_outline,
      title: 'No saved messages',
      body: 'Save a message from its menu to keep it here.',
    ),
  };
}
