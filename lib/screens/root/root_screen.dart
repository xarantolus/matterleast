import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/live_providers.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/channel_info/browse_channels_screen.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/channel_info/edit_channel_screen.dart';
import 'package:matterleast/screens/channel_info/people_picker_screen.dart';
import 'package:matterleast/screens/channel_list/channel_list_pane.dart';
import 'package:matterleast/screens/channel_list/channel_list_state.dart';
import 'package:matterleast/screens/home/home_pane.dart';
import 'package:matterleast/screens/open_page.dart';
import 'package:matterleast/screens/root/pane_layout.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/root/root_shortcuts.dart';
import 'package:matterleast/screens/root/team_rail.dart';
import 'package:matterleast/screens/root/team_screens.dart';
import 'package:matterleast/screens/search/quick_search.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/screens/search/search_results_screen.dart';
import 'package:matterleast/screens/status/status_providers.dart';
import 'package:matterleast/ui/content_page.dart';
import 'package:matterleast/ui/delayed_spinner.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/progress_slot.dart';

/// The rail of teams beside Home or the picked team's channel list.
class RootScreen extends ConsumerStatefulWidget {
  const RootScreen({required this.servers, super.key});

  /// Signed-in servers, in rail order; never empty.
  final List<ServerEntry> servers;

  @override
  ConsumerState<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends ConsumerState<RootScreen> {
  final _search = QuickSearchOpener();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openSearch() {
    _search.open();
  }

  @override
  Widget build(BuildContext context) =>
      RootShortcuts(onSwitcher: _openSearch, child: _layout(context));

  Widget _layout(BuildContext context) {
    final servers = widget.servers;
    for (final s in servers) {
      ref.listen(serverNoticesProvider(s.url), (_, next) {
        if (next.value case final notice?) {
          ScaffoldMessenger.maybeOf(context)
              ?.showSnackBar(SnackBar(content: Text(notice.message)));
        }
      });
    }
    final target = ref.watch(railSelectionProvider);
    final server = servers.where((s) => s.url == target?.url).firstOrNull;
    if (server == null) {
      final recent = servers.reduce(
        (a, b) =>
            (b.lastActiveAt?.isAfter(a.lastActiveAt ?? DateTime(0)) ?? false)
            ? b
            : a,
      );
      final team = ref.watch(currentTeamProvider(recent.url)).value;
      return _RootLayout(
        servers: servers,
        title: 'Home',
        refreshingUrls: [for (final s in servers) s.url],
        actions: [
          const MessageSearchButton(),
          QuickSearchAnchor(
            opener: _search,
            servers: servers,
            target: team == null ? null : (url: recent.url, teamId: team),
            showButton: true,
          ),
        ],
        pane: HomePane(servers: servers, onSearch: _openSearch),
      );
    }
    // Only what this screen shows itself, so unread counts and a changed
    // channel list rebuild the list pane, not the whole window.
    final team = ref.watch(
      railTeamsProvider(server.url).select((teams) {
        final all = teams.value ?? const <RailTeam>[];
        final id = shownTeam(target, all);
        return (
          id: id,
          name: all.where((t) => t.id == id).firstOrNull?.displayName,
        );
      }),
    );
    final teamId = team.id;
    return _RootLayout(
      servers: servers,
      teamId: teamId,
      title: team.name ?? server.displayName,
      refreshingUrls: [server.url],
      actions: [
        MessageSearchButton(url: server.url, teamId: teamId ?? ''),
        QuickSearchAnchor(
          opener: _search,
          servers: servers,
          target: teamId == null ? null : (url: server.url, teamId: teamId),
        ),
        if (teamId != null) _NewMenu(url: server.url, teamId: teamId),
        if (teamId != null)
          TeamMenu(url: server.url, teamId: teamId, teamName: team.name ?? ''),
      ],
      pane: _ChannelListSlot(
        server: server,
        teamId: teamId,
        onFind: _openSearch,
      ),
    );
  }
}

/// The picked team's channel list, or what stands in for it while there is
/// none.
class _ChannelListSlot extends ConsumerWidget {
  const _ChannelListSlot({
    required this.server,
    required this.teamId,
    required this.onFind,
  });

  final ServerEntry server;
  final String? teamId;
  final VoidCallback onFind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final teamId = this.teamId;
    final status = ref.watch(syncStatusProvider(server.url)).value;
    final list = teamId == null
        ? null
        : ref.watch(channelListProvider(server.url, teamId)).value;
    final state = channelListState(
      list: list,
      status: status,
      serverName: server.displayName,
      host: hostOf(server.url),
      liveNotice: ref.watch(serverLiveNoticeProvider(server.url)),
    );
    if (teamId == null && state is! ChannelListFailed) {
      return status is SyncIdle && status.lastSuccess != null
          ? _NoTeam(url: server.url, serverName: server.displayName)
          : const DelayedSpinner();
    }
    return ChannelListPane(
      url: server.url,
      teamId: teamId ?? '',
      serverLabel: {server.displayName, server.address}.join(' · '),
      state: state,
      onFind: onFind,
    );
  }
}

class _RootLayout extends ConsumerWidget {
  const _RootLayout({
    required this.servers,
    required this.title,
    required this.pane,
    required this.refreshingUrls,
    this.teamId,
    this.actions = const [],
  });

  final List<ServerEntry> servers;
  final String title;
  final Widget pane;
  final String? teamId;

  /// The servers whose refreshing runs the progress bar.
  final List<String> refreshingUrls;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PaneLayout(
    list: _ListPage(
      refreshingUrls: refreshingUrls,
      title: title,
      actions: actions,
      body: SafeArea(
        top: false,
        child: Row(
          children: [
            TeamRail(
              servers: servers,
              target: ref.watch(railSelectionProvider),
              teamId: teamId,
            ),
            const VerticalDivider(width: 1),
            Expanded(child: pane),
          ],
        ),
      ),
    ),
  );
}

/// The list's page, with the progress bar running while one of
/// [refreshingUrls] refreshes; only this page rebuilds when that changes.
class _ListPage extends ConsumerWidget {
  const _ListPage({
    required this.refreshingUrls,
    required this.title,
    required this.actions,
    required this.body,
  });

  final List<String> refreshingUrls;
  final String title;
  final List<Widget> actions;
  final Widget body;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ContentPage(
    focusRegion: false,
    title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
    actions: actions,
    progress: refreshingUrls.any(
      (url) =>
          ref.watch(
            syncStatusProvider(url).select((s) => s.value is SyncRefreshing),
          ) ||
          ref.watch(serverCatchingUpProvider(url)),
    ),
    progressDelay: ProgressSlot.settleDelay,
    body: body,
  );
}

/// A signed-in user who is in no team on the server: nothing to list.
class _NoTeam extends ConsumerWidget {
  const _NoTeam({required this.url, required this.serverName});

  final String url;
  final String serverName;

  @override
  Widget build(BuildContext context, WidgetRef ref) => EmptyState(
    icon: Icons.groups_outlined,
    title: 'Not in a team yet',
    body:
        "You aren't a member of any team on $serverName. Join an open "
        'team, or open an invite link from a team member.',
    action: Wrap(
      spacing: 8,
      alignment: WrapAlignment.center,
      children: [
        FilledButton(
          onPressed: () => openPage(
            Navigator.of(context),
            JoinTeamScreen(url: url),
            popout: true,
          ),
          child: const Text('Join a team'),
        ),
        FilledButton.tonal(
          onPressed: () async =>
              (await ref.read(serverRefreshProvider(url).future))(),
          child: const Text('Refresh'),
        ),
      ],
    ),
  );
}

/// Starting points for new channels and conversations in the shown team.
class _NewMenu extends ConsumerWidget {
  const _NewMenu({required this.url, required this.teamId});

  final String url;
  final String teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rights = ref.watch(teamRightsProvider(url, teamId)).value;
    void open(Widget screen) =>
        openPage(Navigator.of(context), screen, popout: true);
    final choices = [
      if (rights?.join ?? true)
        (
          icon: Icons.travel_explore,
          label: 'Browse channels',
          open: () => open(BrowseChannelsScreen(url: url, teamId: teamId)),
        ),
      if ((rights?.public ?? true) || (rights?.private ?? true))
        (
          icon: Icons.add_circle_outline,
          label: 'Create channel',
          open: () => open(EditChannelScreen(url: url, teamId: teamId)),
        ),
      (
        icon: Icons.edit_outlined,
        label: 'New message',
        open: () => open(newMessageScreen(url: url, teamId: teamId)),
      ),
    ];
    // A menu of one is a button.
    if (choices case [final only]) {
      return IconButton(
        tooltip: only.label,
        icon: Icon(only.icon),
        onPressed: only.open,
      );
    }
    return MenuAnchor(
      menuChildren: [
        for (final c in choices)
          MenuItemButton(
            leadingIcon: Icon(c.icon),
            onPressed: c.open,
            child: Text(c.label),
          ),
      ],
      builder: (context, controller, _) => IconButton(
        tooltip: 'New',
        icon: const Icon(Icons.add),
        onPressed: () =>
            controller.isOpen ? controller.close() : controller.open(),
      ),
    );
  }
}
