import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/home/home_providers.dart';
import 'package:matterleast/screens/home/home_state.dart';
import 'package:matterleast/screens/home/open_item.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/message_preview_tile.dart';
import 'package:matterleast/ui/pane_label.dart';
import 'package:matterleast/ui/tokens.dart';

/// Unread conversations, mentions, followed threads and saved messages
/// from every signed-in server, newest first.
class HomePane extends ConsumerStatefulWidget {
  const HomePane({required this.servers, super.key});

  /// Signed-in servers, never empty.
  final List<ServerEntry> servers;

  @override
  ConsumerState<HomePane> createState() => _HomePaneState();
}

class _HomePaneState extends ConsumerState<HomePane> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(_refresh(force: false));
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
    return RefreshIndicator(
      onRefresh: _pull,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (state case HomeReady(:final notice?))
            SliverToBoxAdapter(child: PaneLabel(notice)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.sm,
              Spacing.md,
              Spacing.sm,
            ),
            sliver: SliverToBoxAdapter(
              child: _FilterChips(
                selected: filter,
                onSelected: ref
                    .read(homeFilterSelectionProvider.notifier)
                    .select,
              ),
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
                child: _Empty(filter: filter),
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
                    onTap: () => openInboxItem(context, ref, item),
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
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({required this.selected, required this.onSelected});

  final InboxFilter selected;
  final ValueChanged<InboxFilter> onSelected;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: Spacing.sm,
    runSpacing: Spacing.xs,
    children: [
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
  );
}

class _Empty extends StatelessWidget {
  const _Empty({required this.filter});

  final InboxFilter filter;

  @override
  Widget build(BuildContext context) => switch (filter) {
    InboxFilter.unread => const EmptyState(
      icon: Icons.done_all,
      title: "You're all caught up",
      body:
          'New direct messages, mentions and thread replies show up here. '
          'Open a team from the rail, or search, to read more.',
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
