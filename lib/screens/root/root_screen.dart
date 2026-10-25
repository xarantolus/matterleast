import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/data/sync/sync_runner.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/channel_list/channel_list_pane.dart';
import 'package:matterleast/screens/channel_list/channel_list_state.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/root/team_rail.dart';
import 'package:matterleast/ui/empty_state.dart';
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
        title: const Text('Home'),
        pane: const EmptyState(
          icon: Icons.done_all,
          title: "You're all caught up",
          body:
              'Unread messages, mentions and threads from all your servers '
              'will show up here.',
        ),
      );
    }
    final teams = ref.watch(railTeamsProvider(server.url)).value ?? const [];
    final teamId = target?.teamId ?? teams.firstOrNull?.id;
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
    final notice = switch (state) {
      ChannelListReady(:final notice?) => notice,
      _ => server.displayName,
    };
    return _RootLayout(
      servers: servers,
      teamId: teamId,
      title: _TwoLineTitle(
        title: team?.displayName ?? server.displayName,
        subtitle: notice,
      ),
      refreshing: status is SyncRefreshing,
      actions: const [_NewMenu()],
      pane: teamId == null && state is! ChannelListFailed
          ? const Center(child: CircularProgressIndicator())
          : ChannelListPane(
              url: server.url,
              teamId: teamId ?? '',
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
  final Widget title;
  final Widget pane;
  final String? teamId;
  final bool refreshing;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(
      title: title,
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

class _TwoLineTitle extends StatelessWidget {
  const _TwoLineTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        Text(
          subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style.copyWith(fontSize: 13, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
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
