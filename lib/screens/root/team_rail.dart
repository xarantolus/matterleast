import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/add_server/add_server_screen.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/you/you_page.dart';
import 'package:matterleast/ui/initials_badge.dart';
import 'package:matterleast/ui/tokens.dart';

/// Home, then one icon per team grouped by server, then Add server and the
/// user's avatar.
class TeamRail extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.read(railSelectionProvider.notifier);
    final current = servers.where((s) => s.url == target?.url).firstOrNull;
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
              children: [
                _RailButton(
                  tooltip: 'Home',
                  selected: target == null,
                  onPressed: () => selection.select(null),
                  child: InitialsBadge(
                    name: 'Home',
                    icon: target == null ? Icons.home : Icons.home_outlined,
                    selected: target == null,
                  ),
                ),
                for (final server in servers) ...[
                  const Divider(indent: Spacing.lg, endIndent: Spacing.lg),
                  _ServerTeams(
                    server: server,
                    selectedTeam: server.url == target?.url ? teamId : null,
                    serverSelected: server.url == target?.url,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            tooltip: 'Add a server',
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AddServerScreen()),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          _YouButton(url: (current ?? _mostRecent(servers)).url),
          const SizedBox(height: Spacing.md),
        ],
      ),
    );
  }
}

ServerEntry _mostRecent(List<ServerEntry> servers) =>
    servers.reduce((a, b) => b.lastActiveAt!.isAfter(a.lastActiveAt!) ? b : a);

class _ServerTeams extends ConsumerWidget {
  const _ServerTeams({
    required this.server,
    required this.selectedTeam,
    required this.serverSelected,
  });

  final ServerEntry server;
  final String? selectedTeam;
  final bool serverSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.read(railSelectionProvider.notifier);
    final teams = ref.watch(railTeamsProvider(server.url)).value ?? const [];
    if (teams.isEmpty) {
      // Teams arrive with the first sync; until then the server stands in.
      return _RailButton(
        tooltip: server.displayName,
        selected: serverSelected,
        onPressed: () => selection.select(RailTarget(url: server.url)),
        child: InitialsBadge(
          name: server.displayName,
          selected: serverSelected,
        ),
      );
    }
    return Column(
      children: [
        for (final team in teams)
          _RailButton(
            tooltip: '${team.displayName} · ${server.displayName}',
            selected: team.id == selectedTeam,
            onPressed: () =>
                selection.select(RailTarget(url: server.url, teamId: team.id)),
            child: _TeamBadge(team: team, selected: team.id == selectedTeam),
          ),
      ],
    );
  }
}

class _TeamBadge extends StatelessWidget {
  const _TeamBadge({required this.team, required this.selected});

  final RailTeam team;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final icon = InitialsBadge(name: team.displayName, selected: selected);
    // The open team's counts are in its list already.
    if (selected) return icon;
    if (team.mentions > 0) {
      return Badge.count(count: team.mentions, child: icon);
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
  });

  final String tooltip;
  final bool selected;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
    child: Semantics(
      selected: selected,
      child: IconButton(tooltip: tooltip, onPressed: onPressed, icon: child),
    ),
  );
}

class _YouButton extends ConsumerWidget {
  const _YouButton({required this.url});

  final String url;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserProvider(url)).value;
    return IconButton(
      tooltip: 'You',
      onPressed: () =>
          Navigator.of(context)
              .push(MaterialPageRoute<void>(builder: (_) => const YouPage())),
      icon: InitialsBadge(
        name: me?.displayName ?? '',
        icon: me == null ? Icons.person_outline : null,
        size: 36,
        round: true,
      ),
    );
  }
}
