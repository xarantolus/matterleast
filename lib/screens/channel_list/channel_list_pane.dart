import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/agent_providers.dart';
import 'package:matterleast/domain/channel_list.dart';
import 'package:matterleast/screens/agents/agents_screen.dart';
import 'package:matterleast/screens/channel_info/browse_channels_screen.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/channel_list/category_menu.dart';
import 'package:matterleast/screens/channel_list/channel_actions_sheet.dart';
import 'package:matterleast/screens/channel_list/channel_list_state.dart';
import 'package:matterleast/screens/channel_list/channel_tile.dart';
import 'package:matterleast/screens/channel_list/reorder_view.dart';
import 'package:matterleast/screens/drafts/drafts_providers.dart';
import 'package:matterleast/screens/drafts/drafts_screen.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/reopen_swipe.dart';
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
        onPressed: () => _retry(ref),
        child: const Text('Retry'),
      ),
    ),
    ChannelListReady(:final list, :final notice) => _ChannelListView(
      key: ValueKey('$url/$teamId'),
      url: url,
      teamId: teamId,
      label: [serverLabel, ?notice].join(' · '),
      onRetry: notice == null ? null : () => _retry(ref),
      list: list,
      onFind: onFind,
    ),
  };

  Future<void> _retry(WidgetRef ref) async =>
      (await ref.read(serverRefreshProvider(url).future))();
}

class _ChannelListView extends ConsumerStatefulWidget {
  const _ChannelListView({
    required this.url,
    required this.teamId,
    required this.label,
    required this.list,
    this.onFind,
    this.onRetry,
    super.key,
  });

  final String url;
  final String teamId;
  final String label;
  final ChannelList list;
  final VoidCallback? onFind;

  /// Set while the label says a refresh failed; tapping the label retries.
  final VoidCallback? onRetry;

  @override
  ConsumerState<_ChannelListView> createState() => _ChannelListViewState();
}

class _ChannelListViewState extends ConsumerState<_ChannelListView> {
  late List<CategorySection> _shown = _sections;
  var _atRest = true;
  var _unreadsOnly = false;
  var _reordering = false;

  final _scroll = ScrollController();
  final _rows = <String, BuildContext>{};
  final _unread = ValueNotifier<({String? above, String? below})>((
    above: null,
    below: null,
  ));
  var _checkPending = false;

  @override
  void initState() {
    super.initState();
    _checkUnread();
  }

  @override
  void dispose() {
    _scroll.dispose();
    _unread.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(_ChannelListView old) {
    super.didUpdateWidget(old);
    if (old.list.sections != widget.list.sections) {
      _refreshShown();
      _checkUnread();
    }
  }

  List<CategorySection> get _sections =>
      _unreadsOnly ? unreadsOnly(widget.list.sections) : widget.list.sections;

  /// Rows only move while the list rests at the top; otherwise they keep
  /// their places and just update.
  void _refreshShown() {
    _shown = _atRest ? _sections : keepOrder(_sections, _shown);
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0) return false;
    _checkUnread();
    final atRest = n is ScrollEndNotification && n.metrics.pixels <= 0;
    if (atRest != _atRest) {
      _atRest = atRest;
      if (atRest && _shown != _sections) {
        setState(_refreshShown);
      }
    }
    return false;
  }

  /// Works out after the next frame whether unread channels lie above or
  /// below the visible part, once per frame however often it is asked.
  void _checkUnread() {
    if (_checkPending) return;
    _checkPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPending = false;
      if (!mounted || _reordering) return;
      final viewport = context.findRenderObject();
      if (viewport is! RenderBox || !viewport.hasSize) return;
      final placed = <String, ({double top, double bottom})>{};
      for (final MapEntry(key: id, value: row) in _rows.entries) {
        final box = row.findRenderObject();
        if (box is! RenderBox || !box.attached || !box.hasSize) continue;
        final top = box.localToGlobal(Offset.zero, ancestor: viewport).dy;
        placed[id] = (top: top, bottom: top + box.size.height);
      }
      final next = unreadOutside(
        rows: [
          for (final section in _shown)
            for (final row in section.shown)
              (id: row.id, unread: row.unread || row.mentions > 0),
        ],
        placed: placed,
        height: viewport.size.height,
      );
      if (next != _unread.value) _unread.value = next;
    });
  }

  /// Brings the channel [id] into view: at once when its row is laid out,
  /// else first close by, from the rows' average height.
  Future<void> _reveal(String id) async {
    final row = _rows[id];
    if (row != null && row.mounted) {
      await Scrollable.ensureVisible(
        row,
        alignment: 0.3,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
      return;
    }
    final order = [
      for (final section in _shown)
        for (final r in section.shown) r.id,
    ];
    final known = _rows.entries.where((e) => e.value.mounted).toList();
    if (known.isEmpty || !_scroll.hasClients) return;
    final anchor = known.first;
    final box = anchor.value.findRenderObject();
    if (box is! RenderBox || !box.hasSize) return;
    final rows = order.indexOf(id) - order.indexOf(anchor.key);
    final position = _scroll.position;
    final target = (position.pixels + rows * box.size.height).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    await _scroll.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
    if (!mounted) return;
    final now = _rows[id];
    if (now != null && now.mounted) {
      await Scrollable.ensureVisible(
        now,
        alignment: 0.3,
        duration: const Duration(milliseconds: 150),
      );
    }
  }

  Future<void> _open(ChannelItem item) => openConversation(
    Navigator.of(context),
    url: widget.url,
    channelId: item.id,
    title: item.title,
    teamId: widget.teamId,
  );

  void _setReordering(bool on) {
    setState(() => _reordering = on);
    if (!on) _checkUnread();
  }

  Future<void> _showMenu(CategorySection section) => showCategoryMenu(
    context,
    url: widget.url,
    teamId: widget.teamId,
    section: section,
    onReorder: () => _setReordering(true),
  );

  @override
  Widget build(BuildContext context) {
    if (_reordering) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _setReordering(false);
        },
        child: ReorderView(
          url: widget.url,
          teamId: widget.teamId,
          sections: widget.list.sections,
          onDone: () => _setReordering(false),
        ),
      );
    }
    final list = widget.list;
    final scheduled =
        ref
            .watch(teamScheduledProvider(widget.url, widget.teamId))
            .value
            ?.length ??
        0;
    final scrollView = NotificationListener<ScrollNotification>(
      onNotification: _onScroll,
      child: CustomScrollView(
        controller: _scroll,
        slivers: [
          SliverToBoxAdapter(
            child: widget.onRetry == null
                ? PaneLabel(widget.label)
                : Semantics(
                    button: true,
                    onTapHint: 'Retry',
                    child: InkWell(
                      onTap: widget.onRetry,
                      child: PaneLabel(widget.label),
                    ),
                  ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              Spacing.md,
              Spacing.xs,
              Spacing.md,
              Spacing.xs,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(child: _FindChannels(onTap: widget.onFind)),
                  const SizedBox(width: Spacing.xs),
                  IconButton(
                    tooltip: _unreadsOnly
                        ? 'Show all channels'
                        : 'Show unread channels only',
                    isSelected: _unreadsOnly,
                    icon: const Icon(Icons.mark_chat_unread_outlined),
                    selectedIcon: const Icon(Icons.mark_chat_unread),
                    onPressed: () => setState(() {
                      _unreadsOnly = !_unreadsOnly;
                      _shown = _sections;
                      _checkUnread();
                    }),
                  ),
                ],
              ),
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
          if (list.drafts > 0 || scheduled > 0)
            SliverToBoxAdapter(
              child: _ShortcutTile(
                icon: Icons.edit_note,
                title: 'Drafts',
                count: list.drafts + scheduled,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => DraftsScreen(
                      url: widget.url,
                      teamId: widget.teamId,
                      teamName: list.teamName,
                    ),
                  ),
                ),
              ),
            ),
          if (ref.watch(agentsAvailableProvider(widget.url)))
            SliverToBoxAdapter(
              child: _ShortcutTile(
                icon: Icons.smart_toy_outlined,
                title: 'Agents',
                count: 0,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => AgentsScreen(url: widget.url),
                  ),
                ),
              ),
            ),
          if (list.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.tag,
                title: 'No channels yet',
                body:
                    'Channels you join or create in this team, and your '
                    'direct messages, show up here.',
                action:
                    ref
                            .watch(
                              teamRightsProvider(widget.url, widget.teamId),
                            )
                            .value
                            ?.join ??
                        true
                    ? FilledButton.tonal(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BrowseChannelsScreen(
                              url: widget.url,
                              teamId: widget.teamId,
                            ),
                          ),
                        ),
                        child: const Text('Browse channels'),
                      )
                    : null,
              ),
            ),
          if (_unreadsOnly && _shown.isEmpty && !list.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.mark_chat_read_outlined,
                title: 'All caught up',
                body:
                    'Channels with new messages show up here. Turn off the '
                    'unreads filter to see every channel.',
              ),
            ),
          for (final section in _shown) _section(section),
          const SliverToBoxAdapter(child: SizedBox(height: Spacing.lg)),
        ],
      ),
    );
    return ReopenSwipe(
      child: Stack(
        children: [
          // A resized viewport moves rows without scrolling.
          NotificationListener<ScrollMetricsNotification>(
            onNotification: (n) {
              if (n.depth == 0) _checkUnread();
              return false;
            },
            child: scrollView,
          ),
          _UnreadChips(unread: _unread, onJump: (id) => unawaited(_reveal(id))),
        ],
      ),
    );
  }

  Widget _section(CategorySection section) {
    final rows = section.shown;
    return SliverMainAxisGroup(
      key: ValueKey(section.id),
      slivers: [
        PinnedHeaderSliver(
          child: section.id == unreadsSectionId
              ? Material(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  child: PaneLabel(section.title),
                )
              : _CategoryHeader(
                  section: section,
                  onMenu: () => unawaited(_showMenu(section)),
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
          itemCount: rows.length,
          findChildIndexCallback: (key) {
            final id = (key as ValueKey<String>).value;
            final i = rows.indexWhere((r) => r.id == id);
            return i < 0 ? null : i;
          },
          itemBuilder: (context, i) {
            final item = rows[i];
            return _PlacedRow(
              key: ValueKey(item.id),
              id: item.id,
              rows: _rows,
              child: ChannelTile(
                serverUrl: widget.url,
                item: item,
                onTap: () => _open(item),
                onLongPress: () => showChannelActions(
                  context,
                  url: widget.url,
                  teamId: widget.teamId,
                  item: item,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Keeps its row's context in [rows] while it is built, so the list can
/// tell where the row is.
class _PlacedRow extends StatefulWidget {
  const _PlacedRow({
    required this.id,
    required this.rows,
    required this.child,
    super.key,
  });

  final String id;
  final Map<String, BuildContext> rows;
  final Widget child;

  @override
  State<_PlacedRow> createState() => _PlacedRowState();
}

class _PlacedRowState extends State<_PlacedRow> {
  @override
  void initState() {
    super.initState();
    widget.rows[widget.id] = context;
  }

  @override
  void dispose() {
    if (widget.rows[widget.id] == context) widget.rows.remove(widget.id);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// "Unread" chips at the top and bottom edge while unread channels are
/// out of view there; a tap brings the nearest one into view.
class _UnreadChips extends StatelessWidget {
  const _UnreadChips({required this.unread, required this.onJump});

  final ValueListenable<({String? above, String? below})> unread;
  final ValueChanged<String> onJump;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: unread,
    builder: (context, value, _) => Stack(
      children: [
        if (value.above case final id?)
          Positioned(
            top: Spacing.sm,
            left: 0,
            right: 0,
            child: Center(
              child: _UnreadChip(
                icon: Icons.arrow_upward,
                label: 'Unread above',
                onPressed: () => onJump(id),
              ),
            ),
          ),
        if (value.below case final id?)
          Positioned(
            bottom: Spacing.md,
            left: 0,
            right: 0,
            child: Center(
              child: _UnreadChip(
                icon: Icons.arrow_downward,
                label: 'Unread below',
                onPressed: () => onJump(id),
              ),
            ),
          ),
      ],
    ),
  );
}

class _UnreadChip extends StatelessWidget {
  const _UnreadChip({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: label,
      button: true,
      excludeSemantics: true,
      child: ActionChip(
        avatar: Icon(icon, size: 18, color: scheme.onPrimaryContainer),
        label: const Text('Unread'),
        labelStyle: TextStyle(
          color: scheme.onPrimaryContainer,
          fontWeight: FontWeight.w600,
        ),
        backgroundColor: scheme.primaryContainer,
        side: BorderSide.none,
        elevation: 3,
        shape: const StadiumBorder(),
        onPressed: onPressed,
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
    // InkWell rather than a gesture detector, so keyboard and switch
    // access can focus it.
    child: InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
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
  Widget build(BuildContext context) {
    final color = context.tokens.text;
    // Same metrics as ChannelTile: these are rows of the same list.
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(
        left: Spacing.lg,
        right: Spacing.md,
      ),
      minLeadingWidth: 28,
      leading: SizedBox(width: 28, child: Icon(icon, size: 20, color: color)),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 15,
          color: color,
          fontWeight: count > 0 ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
      trailing: count > 0 ? Text('$count') : null,
      onTap: onTap,
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.section,
    required this.onToggle,
    required this.onMenu,
  });

  final CategorySection section;
  final VoidCallback onToggle;
  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: InkWell(
        onTap: onToggle,
        onLongPress: onMenu,
        child: Semantics(
          expanded: !section.collapsed,
          button: true,
          header: true,
          label: section.title,
          child: Padding(
            padding: const EdgeInsets.only(left: Spacing.md, top: Spacing.xs),
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
                  // The label above reads the name as written; capitals
                  // may be spelled out letter by letter.
                  child: ExcludeSemantics(
                    child: Text(
                      section.title.toUpperCase(),
                      style: tokens.smallCaps,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: '${section.title} options',
                  iconSize: 18,
                  color: tokens.muted,
                  icon: const Icon(Icons.more_horiz),
                  onPressed: onMenu,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
