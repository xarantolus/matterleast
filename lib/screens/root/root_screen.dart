import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/channel_list/channel_list_pane.dart';
import 'package:matterleast/screens/channel_list/channel_list_state.dart';
import 'package:matterleast/screens/home/home_pane.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/root/team_rail.dart';
import 'package:matterleast/ui/progress_slot.dart';

/// The rail of teams beside Home or the picked team's channel list.
class RootScreen extends ConsumerWidget {
  const RootScreen({required this.servers, super.key});

  /// Signed-in servers, in rail order; never empty.
  final List<ServerEntry> servers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final target = ref.watch(railSelectionProvider);
    final server = servers.where((s) => s.url == target?.url).firstOrNull;
    if (server == null) {
      return _RootLayout(
        servers: servers,
        title: 'Home',
        refreshing: servers.any(
          (s) => ref.watch(syncStatusProvider(s.url)).value is SyncRefreshing,
        ),
        actions: const [_SearchButton()],
        pane: HomePane(servers: servers),
      );
    }
    final teams = ref.watch(railTeamsProvider(server.url)).value ?? const [];
    final teamId = shownTeam(target, teams);
    final team = teams.where((t) => t.id == teamId).firstOrNull;
    final status = ref.watch(syncStatusProvider(server.url)).value;
    final list = teamId == null
        ? null
        : ref.watch(channelListProvider(server.url, teamId)).value;
    final state = channelListState(
      list: list,
      status: status,
      serverName: server.displayName,
      host: Uri.parse(server.url).host,
    );
    return _RootLayout(
      servers: servers,
      teamId: teamId,
      title: team?.displayName ?? server.displayName,
      refreshing: status is SyncRefreshing,
      actions: const [_SearchButton(), _NewMenu()],
      pane: teamId == null && state is! ChannelListFailed
          ? const Center(child: CircularProgressIndicator())
          : ChannelListPane(
              url: server.url,
              teamId: teamId ?? '',
              serverLabel: '${server.displayName} · ${server.address}',
              state: state,
            ),
    );
  }
}

class _RootLayout extends ConsumerWidget {
  const _RootLayout({
    required this.servers,
    required this.title,
    required this.pane,
    this.teamId,
    this.refreshing = false,
    this.actions = const [],
  });

  final List<ServerEntry> servers;
  final String title;
  final Widget pane;
  final String? teamId;
  final bool refreshing;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      actions: actions,
      bottom: ProgressSlot(active: refreshing),
    ),
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
  );
}

/// Opens the quick switcher once it exists; shown now so the bar holds.
class _SearchButton extends StatelessWidget {
  const _SearchButton();

  @override
  Widget build(BuildContext context) => const IconButton(
    tooltip: 'Search',
    onPressed: null,
    icon: Icon(Icons.search),
  );
}

/// Starting points for new conversations; they arrive with channel
/// management.
class _NewMenu extends StatelessWidget {
  const _NewMenu();

  @override
  Widget build(BuildContext context) => MenuAnchor(
    menuChildren: const [
      MenuItemButton(
        leadingIcon: Icon(Icons.travel_explore),
        child: Text('Browse channels'),
      ),
      MenuItemButton(
        leadingIcon: Icon(Icons.add_circle_outline),
        child: Text('Create channel'),
      ),
      MenuItemButton(
        leadingIcon: Icon(Icons.edit_outlined),
        child: Text('New message'),
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
