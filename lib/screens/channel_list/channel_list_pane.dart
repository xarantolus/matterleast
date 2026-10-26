import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/screens/channel_list/channel_actions_sheet.dart';
import 'package:matterleast/screens/channel_list/channel_list_state.dart';
import 'package:matterleast/screens/channel_list/channel_tile.dart';
import 'package:matterleast/screens/drafts/drafts_screen.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/threads/team_threads_screen.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/pane_label.dart';
import 'package:matterleast/ui/tokens.dart';

/// One team's channels by category, with Threads and Drafts on top.
class ChannelListPane extends ConsumerWidget {
  const ChannelListPane({
    required this.url,
    required this.teamId,
    required this.serverLabel,
    required this.state,
    this.onFind,
    super.key,
  });

  final String url;
  final String teamId;

  /// Opens the search view.
  final VoidCallback? onFind;

  /// Which server the team is on, shown above the list.
  final String serverLabel;
  final ChannelListState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) => switch (state) {
    ChannelListLoading() => const Center(child: CircularProgressIndicator()),
    ChannelListFailed(:final title, :final detail) => EmptyState(
      icon: Icons.cloud_off,
      title: title,
      body: detail,
      action: FilledButton.tonal(
        onPressed: () async {
          final session = await ref.read(serverSessionProvider(url).future);
          await session.connection.entry.run().catchError((Object _) {});
        },
        child: const Text('Retry'),
      ),
    ),
    ChannelListReady(:final list, :final notice) => _ChannelListView(
      key: ValueKey('$url/$teamId'),
      url: url,
      teamId: teamId,
      label: [serverLabel, ?notice].join(' · '),
      list: list,
      onFind: onFind,
    ),
  };
}

class _ChannelListView extends ConsumerStatefulWidget {
  const _ChannelListView({
    required this.url,
    required this.teamId,
    required this.label,
    required this.list,
    this.onFind,
    super.key,
  });

  final String url;
  final String teamId;
  final String label;
  final ChannelList list;
  final VoidCallback? onFind;

  @override
  ConsumerState<_ChannelListView> createState() => _ChannelListViewState();
}

class _ChannelListViewState extends ConsumerState<_ChannelListView> {
  late List<CategorySection> _shown = widget.list.sections;
  var _atRest = true;

  @override
  void didUpdateWidget(_ChannelListView old) {
    super.didUpdateWidget(old);
    if (old.list.sections != widget.list.sections) _refreshShown();
  }

  /// Rows only move while the list rests at the top; otherwise they keep
  /// their places and just update.
  void _refreshShown() {
    _shown = _atRest
        ? widget.list.sections
        : keepOrder(widget.list.sections, _shown);
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0) return false;
    final atRest = n is ScrollEndNotification && n.metrics.pixels <= 0;
    if (atRest != _atRest) {
      _atRest = atRest;
      if (atRest && _shown != widget.list.sections) {
        setState(_refreshShown);
      }
    }
    return false;
  }

  Future<void> _open(ChannelItem item) => openConversation(
    Navigator.of(context),
    url: widget.url,
    channelId: item.id,
    title: item.title,
    teamId: widget.teamId,
  );

  @override
  Widget build(BuildContext context) {
    final list = widget.list;
    return NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: PaneLabel(widget.label)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.xs,
              Spacing.md,
              Spacing.xs,
            ),
            sliver: SliverToBoxAdapter(
              child: _FindChannels(onTap: widget.onFind),
            ),
          ),
          if (list.unreadThreads case final unread?)
            SliverToBoxAdapter(
              child: _ShortcutTile(
                icon: Icons.forum_outlined,
                title: 'Threads',
                count: unread,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => TeamThreadsScreen(
                      url: widget.url,
                      teamId: widget.teamId,
                      teamName: list.teamName,
                    ),
                  ),
                ),
              ),
            ),
          if (list.drafts > 0)
            SliverToBoxAdapter(
              child: _ShortcutTile(
                icon: Icons.edit_note,
                title: 'Drafts',
                count: list.drafts,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DraftsScreen(teamName: list.teamName),
                  ),
                ),
              ),
            ),
          if (list.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.tag,
                title: 'No channels yet',
                body:
                    'Channels you join or create in this team, and your '
                    'direct messages, show up here.',
              ),
            ),
          for (final section in _shown)
            SliverMainAxisGroup(
              key: ValueKey(section.id),
              slivers: [
                PinnedHeaderSliver(
                  child: _CategoryHeader(
                    section: section,
                    onToggle: () async {
                      final actions = await ref.read(
                        channelActionsProvider(widget.url).future,
                      );
                      await actions.setCollapsed(
                        section.id,
                        collapsed: !section.collapsed,
                      );
                    },
                  ),
                ),
                SliverList.builder(
                  itemCount: section.rows.length,
                  findChildIndexCallback: (key) {
                    final id = (key as ValueKey<String>).value;
                    final i = section.rows.indexWhere((r) => r.id == id);
                    return i < 0 ? null : i;
                  },
                  itemBuilder: (context, i) {
                    final item = section.rows[i];
                    return ChannelTile(
                      key: ValueKey(item.id),
                      serverUrl: widget.url,
                      item: item,
                      onTap: () => _open(item),
                      onLongPress: () => showChannelActions(
                        context,
                        url: widget.url,
                        teamId: widget.teamId,
                        item: item,
                      ),
                    );
                  },
                ),
              ],
            ),
          const SliverToBoxAdapter(child: SizedBox(height: Spacing.lg)),
        ],
      ),
    );
  }
}

/// Looks like a search field; tapping it opens the search view.
class _FindChannels extends StatelessWidget {
  const _FindChannels({required this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Find channels',
    child: GestureDetector(
      onTap: onTap,
      child: const AbsorbPointer(
        child: ExcludeSemantics(
          child: SearchBar(
            hintText: 'Find channels',
            leading: Icon(Icons.search),
            elevation: WidgetStatePropertyAll(0),
          ),
        ),
      ),
    ),
  );
}

class _ShortcutTile extends StatelessWidget {
  const _ShortcutTile({
    required this.icon,
    required this.title,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    visualDensity: VisualDensity.compact,
    leading: Icon(icon, size: 22),
    title: Text(
      title,
      style: count > 0 ? const TextStyle(fontWeight: FontWeight.w700) : null,
    ),
    trailing: count > 0 ? Text('$count') : null,
    onTap: onTap,
  );
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.section, required this.onToggle});

  final CategorySection section;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: InkWell(
        onTap: onToggle,
        child: Semantics(
          expanded: !section.collapsed,
          button: true,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.md,
              Spacing.lg,
              Spacing.xs,
            ),
            child: Row(
              children: [
                AnimatedRotation(
                  turns: section.collapsed ? -0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Icon(Icons.expand_more, size: 18, color: tokens.muted),
                ),
                const SizedBox(width: Spacing.xs),
                Expanded(
                  child: Text(
                    section.title.toUpperCase(),
                    style: tokens.smallCaps,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
