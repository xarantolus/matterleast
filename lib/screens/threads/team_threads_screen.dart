import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/home/home_providers.dart';
import 'package:matterleast/screens/home/open_item.dart';
import 'package:matterleast/screens/root/root_providers.dart';
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
  var _unreadOnly = false;
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

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(teamThreadsProvider(widget.url, widget.teamId)).value;
    final refreshing =
        ref.watch(syncStatusProvider(widget.url)).value is SyncRefreshing;
    final items = all == null
        ? null
        : [
            for (final item in all)
              if (!_unreadOnly || item.unread) item,
          ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Threads · ${widget.teamName}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        bottom: ProgressSlot(active: refreshing),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(Spacing.md),
            sliver: SliverToBoxAdapter(
              child: SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: false, label: Text('All')),
                  ButtonSegment(value: true, label: Text('Unread')),
                ],
                selected: {_unreadOnly},
                onSelectionChanged: (s) =>
                    setState(() => _unreadOnly = s.single),
              ),
            ),
          ),
          if (items == null || (items.isEmpty && all!.isEmpty && refreshing))
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (items.isEmpty && all!.isEmpty && _failure != null)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.cloud_off,
                title: "Couldn't load threads",
                body: connectionProblemText(
                  _failure!,
                  Uri.parse(widget.url).host,
                ),
                action: FilledButton.tonal(
                  onPressed: _refresh,
                  child: const Text('Retry'),
                ),
              ),
            )
          else if (items.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _unreadOnly
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
                onTap: () => openInboxItem(context, ref, items[i]),
              ),
            ),
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
