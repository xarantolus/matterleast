import 'dart:async';

import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/rail_order.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/add_server/add_server_screen.dart';
import 'package:matterleast/screens/root/rail_switch.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/root/team_screens.dart';
import 'package:matterleast/screens/settings/settings_providers.dart';
import 'package:matterleast/screens/you/you_page.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/context_menu.dart';
import 'package:matterleast/ui/focus_region.dart';
import 'package:matterleast/ui/initials_badge.dart';
import 'package:matterleast/ui/mention_badge.dart';
import 'package:matterleast/ui/slide_route.dart';
import 'package:matterleast/ui/team_icon.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/try_action.dart';
import 'package:matterleast/ui/user_avatar.dart';

/// Home, then one icon per team grouped by server, then Add server and the
/// user's avatar. Servers and teams can be dragged into the user's order: on
/// a computer at once, on a phone after choosing Reorder.
class TeamRail extends ConsumerStatefulWidget {
  const TeamRail({
    required this.servers,
    required this.target,
    required this.teamId,
    super.key,
  });

  /// Signed-in servers, in rail order.
  final List<ServerEntry> servers;
  final RailTarget? target;

  /// The team shown, which may differ from [target] while it names only a
  /// server.
  final String? teamId;

  @override
  ConsumerState<TeamRail> createState() => _TeamRailState();
}

class _TeamRailState extends ConsumerState<TeamRail> {
  var _reordering = false;

  /// The dropped order of the servers until the stored one catches up.
  List<String>? _pending;

  void _setReordering(bool on) => setState(() => _reordering = on);

  void _moveServer(int from, int to, List<ServerEntry> shown) {
    final order = moveItem([for (final s in shown) s.url], from, to);
    setState(() => _pending = order);
    unawaited(
      tryAction(
        context,
        hostOf(shown[from].url),
        failure: "Couldn't move the server.",
        () => ref.read(serverManagerProvider).reorderServers(order),
      ).then((saved) {
        if (!saved) setState(() => _pending = null);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(serversProvider, (_, next) {
      final stored = [
        for (final s in next.value ?? const <ServerEntry>[])
          if (s.signedIn) s.url,
      ];
      if (_pending != null && listEquals(stored, _pending)) {
        setState(() => _pending = null);
      }
    });
    final servers = arrangedBy(
      widget.servers,
      _pending,
      (ServerEntry s) => s.url,
    );
    final target = widget.target;
    final current = servers.where((s) => s.url == target?.url).firstOrNull;
    final dragging = isDesktop || _reordering;
    final moveServers = dragging && servers.length > 1;
    return FocusRegion(
      child: SizedBox(
        width: railWidth,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: _RailButton(
                tooltip: 'Home',
                selected: target == null,
                onPressed: () => showPlace(Navigator.of(context), null),
                child: InitialsBadge(
                  name: 'Home',
                  icon: target == null ? Icons.home : Icons.home_outlined,
                  selected: target == null,
                ),
              ),
            ),
            Expanded(
              child: _ReorderOrList(
                reorderable: moveServers,
                shrink: false,
                onMove: (from, to) => _moveServer(from, to, servers),
                children: [
                  for (final (i, server) in servers.indexed)
                    Column(
                      key: ValueKey(server.url),
                      children: [
                        _ServerHandle(
                          index: i,
                          enabled: moveServers,
                          grip: _reordering,
                        ),
                        _ServerTeams(
                          server: server,
                          selectedTeam: server.url == target?.url
                              ? widget.teamId
                              : null,
                          serverSelected: server.url == target?.url,
                          reordering: _reordering,
                          dragging: dragging,
                          canReorder: !isDesktop && servers.length > 1,
                          onReorder: () => _setReordering(true),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (_reordering)
              IconButton(
                tooltip: 'Done',
                icon: const Icon(Icons.check),
                onPressed: () => _setReordering(false),
              )
            else
              IconButton(
                tooltip: 'Add a server',
                icon: const Icon(Icons.add),
                onPressed: () => Navigator.of(context).push(
                  SlideRoute<void>.page(
                    builder: (_) => const AddServerScreen(),
                  ),
                ),
              ),
            const SizedBox(height: Spacing.sm),
            _YouButton(url: (current ?? _mostRecent(servers)).url),
            const SizedBox(height: Spacing.md),
          ],
        ),
      ),
    );
  }
}

ServerEntry _mostRecent(List<ServerEntry> servers) =>
    servers.reduce((a, b) => b.lastActiveAt!.isAfter(a.lastActiveAt!) ? b : a);

/// A list whose keyed [children] can be dragged when [reorderable]; each
/// child that starts a drag wraps itself in a drag listener.
class _ReorderOrList extends StatelessWidget {
  const _ReorderOrList({
    required this.reorderable,
    required this.shrink,
    required this.onMove,
    required this.children,
  });

  final bool reorderable;

  /// Whether the list is as tall as its children and leaves scrolling to
  /// its parent.
  final bool shrink;
  final void Function(int from, int to) onMove;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (reorderable) {
      return ReorderableListView(
        buildDefaultDragHandles: false,
        shrinkWrap: shrink,
        physics: shrink ? const NeverScrollableScrollPhysics() : null,
        onReorderItem: onMove,
        children: children,
      );
    }
    return shrink ? Column(children: children) : ListView(children: children);
  }
}

/// The line above a server's teams; where the whole group is grabbed.
class _ServerHandle extends StatelessWidget {
  const _ServerHandle({
    required this.index,
    required this.enabled,
    required this.grip,
  });

  final int index;
  final bool enabled;
  final bool grip;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return const Divider(indent: Spacing.lg, endIndent: Spacing.lg);
    }
    return ReorderableDragStartListener(
      index: index,
      child: Tooltip(
        message: 'Drag to move this server',
        child: MouseRegion(
          cursor: SystemMouseCursors.grab,
          child: SizedBox(
            height: Spacing.xl,
            child: Center(
              child: grip
                  ? const Icon(Icons.drag_handle)
                  : const Divider(indent: Spacing.lg, endIndent: Spacing.lg),
            ),
          ),
        ),
      ),
    );
  }
}

class _ServerTeams extends ConsumerStatefulWidget {
  const _ServerTeams({
    required this.server,
    required this.selectedTeam,
    required this.serverSelected,
    required this.reordering,
    required this.dragging,
    required this.canReorder,
    required this.onReorder,
  });

  final ServerEntry server;
  final String? selectedTeam;
  final bool serverSelected;

  /// The phone's reorder mode is on: taps do nothing, icons drag.
  final bool reordering;

  /// Icons can be dragged now.
  final bool dragging;

  /// The menu offers Reorder because the server has company.
  final bool canReorder;
  final VoidCallback onReorder;

  @override
  ConsumerState<_ServerTeams> createState() => _ServerTeamsState();
}

class _ServerTeamsState extends ConsumerState<_ServerTeams> {
  /// The dropped order of the teams until the stored one catches up.
  List<String>? _pending;

  void _move(int from, int to, List<RailTeam> shown) {
    final order = moveItem([for (final t in shown) t.id], from, to);
    setState(() => _pending = order);
    unawaited(
      tryAction(
        context,
        hostOf(widget.server.url),
        failure: "Couldn't move the team.",
        () async =>
            (await ref.read(settingsActionsProvider(widget.server.url).future))
                .saveTeamsOrder(order),
      ).then((saved) {
        if (!saved) setState(() => _pending = null);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final server = widget.server;
    ref.listen(railTeamsProvider(server.url), (_, next) {
      final stored = [for (final t in next.value ?? const <RailTeam>[]) t.id];
      if (_pending != null && listEquals(stored, _pending)) {
        setState(() => _pending = null);
      }
    });
    final teams = arrangedBy(
      ref.watch(railTeamsProvider(server.url)).value ?? const <RailTeam>[],
      _pending,
      (RailTeam t) => t.id,
    );
    final selectedTeam = widget.selectedTeam;
    if (teams.isEmpty) {
      // Teams arrive with the first sync; until then the server stands in.
      return _RailButton(
        tooltip: server.displayName,
        selected: widget.serverSelected,
        onPressed: widget.reordering
            ? () {}
            : () =>
                  showPlace(Navigator.of(context), RailTarget(url: server.url)),
        onMenu: widget.canReorder && !widget.reordering
            ? (at) => _menu(context, at, teamId: null, unread: false)
            : null,
        child: InitialsBadge(
          name: server.displayName,
          selected: widget.serverSelected,
        ),
      );
    }
    final moveTeams = widget.dragging && teams.length > 1;
    final canReorder = !isDesktop && (widget.canReorder || teams.length > 1);
    return _ReorderOrList(
      reorderable: moveTeams,
      shrink: true,
      onMove: (from, to) => _move(from, to, teams),
      children: [
        for (final (i, team) in teams.indexed)
          ReorderableDragStartListener(
            key: ValueKey(team.id),
            index: i,
            enabled: moveTeams,
            child: _RailButton(
              tooltip: team.displayName,
              details: [
                server.displayName,
                if (team.id != selectedTeam && team.mentions > 0)
                  [
                    team.mentions == 1
                        ? '1 mention'
                        : '${team.mentions} mentions',
                    if (team.urgent) 'urgent',
                  ].join(', ')
                else if (team.id != selectedTeam && team.unread)
                  'unread',
              ].join(' · '),
              selected: team.id == selectedTeam,
              onMenu:
                  !widget.reordering &&
                      (team.unread || team.mentions > 0 || canReorder)
                  ? (at) => _menu(
                      context,
                      at,
                      teamId: team.id,
                      unread: team.unread || team.mentions > 0,
                      canReorder: canReorder,
                    )
                  : null,
              onPressed: widget.reordering
                  ? () {}
                  : () => showPlace(
                      Navigator.of(context),
                      RailTarget(url: server.url, teamId: team.id),
                    ),
              child: _TeamBadge(
                serverUrl: server.url,
                team: team,
                selected: team.id == selectedTeam,
              ),
            ),
          ),
      ],
    );
  }

  Future<void> _menu(
    BuildContext context,
    Offset at, {
    required String? teamId,
    required bool unread,
    bool canReorder = true,
  }) async {
    final choice = await showMenuAt<_RailChoice>(context, at, [
      if (unread && teamId != null)
        const MenuItem(
          value: _RailChoice.markRead,
          child: MenuEntry(icon: Icons.done_all, label: 'Mark all as read'),
        ),
      if (canReorder)
        const MenuItem(
          value: _RailChoice.reorder,
          child: MenuEntry(icon: Icons.swap_vert, label: 'Reorder'),
        ),
    ]);
    switch (choice) {
      case _RailChoice.markRead when context.mounted && teamId != null:
        await markTeamRead(context, ref, widget.server.url, teamId);
      case _RailChoice.reorder:
        widget.onReorder();
      case _RailChoice.markRead || null:
    }
  }
}

enum _RailChoice { markRead, reorder }

class _TeamBadge extends StatelessWidget {
  const _TeamBadge({
    required this.serverUrl,
    required this.team,
    required this.selected,
  });

  final String serverUrl;
  final RailTeam team;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final icon = TeamIcon(
      serverUrl: serverUrl,
      teamId: team.id,
      name: team.displayName,
      iconUpdate: team.iconUpdate,
      selected: selected,
    );
    // The open team's counts are in its list already.
    if (selected) return icon;
    // The button's tooltip says the count in words; a bare "1" would
    // replace it.
    if (team.mentions > 0) {
      return ExcludeSemantics(
        child: MentionBadge(
          count: team.mentions,
          urgent: team.urgent,
          child: icon,
        ),
      );
    }
    if (team.unread) {
      return Badge(
        smallSize: 10,
        backgroundColor: context.tokens.unread,
        child: icon,
      );
    }
    return icon;
  }
}

class _RailButton extends StatelessWidget {
  const _RailButton({
    required this.tooltip,
    required this.selected,
    required this.onPressed,
    required this.child,
    this.details,
    this.onMenu,
  });

  /// Opens a menu at the given global position, on right click or long
  /// press.
  final void Function(Offset)? onMenu;

  final String tooltip;

  /// A second tooltip line, such as the server.
  final String? details;
  final bool selected;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final details = this.details;
    final menu = onMenu;
    final label = details == null ? tooltip : '$tooltip · $details';
    // A long press opens the menu, so the tooltip must not claim it.
    final button = IconButton(
      tooltip: isDesktop || menu != null ? null : label,
      onPressed: onPressed,
      icon: child,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
      child: GestureDetector(
        onSecondaryTapUp: menu == null ? null : (d) => menu(d.globalPosition),
        onLongPressStart: menu == null ? null : (d) => menu(d.globalPosition),
        // Merged, so the button itself is the selected one.
        child: MergeSemantics(
          child: Semantics(
            selected: selected,
            child: isDesktop
                ? Tooltip(
                    richMessage: TextSpan(
                      children: [
                        TextSpan(
                          text: tooltip,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        if (details != null) TextSpan(text: '\n$details'),
                      ],
                    ),
                    positionDelegate: besideTarget,
                    child: button,
                  )
                : menu != null
                ? Tooltip(
                    message: label,
                    triggerMode: TooltipTriggerMode.manual,
                    child: button,
                  )
                : button,
          ),
        ),
      ),
    );
  }
}

/// Places a tooltip to the right of its target.
Offset besideTarget(TooltipPositionContext at) => Offset(
  at.target.dx + at.targetSize.width / 2 + Spacing.sm,
  at.target.dy - at.tooltipSize.height / 2,
);

class _YouButton extends ConsumerWidget {
  const _YouButton({required this.url});

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserProvider(url)).value;
    return IconButton(
      tooltip: 'You',
      onPressed: () => openYou(context, anchor: globalRectOf(context)),
      icon: me == null
          ? const InitialsBadge(
              name: '',
              icon: Icons.person_outline,
              size: 36,
              round: true,
            )
          : UserAvatar(
              serverUrl: url,
              userId: me.id,
              name: me.displayName,
              lastPictureUpdate: me.lastPictureUpdate,
              size: 36,
            ),
    );
  }
}
