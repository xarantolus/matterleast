import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/add_server/add_server_screen.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/you/you_page.dart';
import 'package:matterleast/ui/initials_badge.dart';
import 'package:matterleast/ui/progress_slot.dart';
import 'package:matterleast/ui/tokens.dart';

/// The rail of servers beside Home or the picked server.
class RootScreen extends ConsumerWidget {
  const RootScreen({required this.servers, super.key});

  /// Signed-in servers, in rail order; never empty.
  final List<ServerEntry> servers;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final picked = ref.watch(railSelectionProvider);
    final selected = servers.where((s) => s.url == picked).firstOrNull;
    final title = selected?.displayName ?? 'Home';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        bottom: const ProgressSlot(active: false),
      ),
      body: SafeArea(
        top: false,
        child: Row(
          children: [
            _ServerRail(servers: servers, selected: selected),
            const VerticalDivider(width: 1),
            Expanded(
              child: selected == null
                  ? const _HomePane()
                  : _ServerPane(server: selected),
            ),
          ],
        ),
      ),
    );
  }
}

class _ServerRail extends ConsumerWidget {
  const _ServerRail({required this.servers, required this.selected});

  final List<ServerEntry> servers;
  final ServerEntry? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.read(railSelectionProvider.notifier);
    final index = selected == null ? 0 : servers.indexOf(selected!) + 1;
    return NavigationRail(
      scrollable: true,
      trailingAtBottom: true,
      labelType: NavigationRailLabelType.none,
      // The tiles fill when selected, which reads better than a pill
      // behind a square.
      useIndicator: false,
      selectedIndex: index,
      onDestinationSelected: (i) =>
          selection.select(i == 0 ? null : servers[i - 1].url),
      destinations: [
        const NavigationRailDestination(
          icon: Tooltip(
            message: 'Home',
            child: InitialsBadge(name: 'Home', icon: Icons.home_outlined),
          ),
          selectedIcon: InitialsBadge(
            name: 'Home',
            icon: Icons.home,
            selected: true,
          ),
          label: Text('Home'),
        ),
        for (final server in servers)
          NavigationRailDestination(
            icon: Tooltip(
              message: server.displayName,
              child: InitialsBadge(name: server.displayName),
            ),
            selectedIcon: InitialsBadge(
              name: server.displayName,
              selected: true,
            ),
            label: Text(server.displayName),
          ),
      ],
      trailing: Padding(
        padding: const EdgeInsets.only(bottom: Spacing.md),
        child: Column(
          children: [
            IconButton(
              tooltip: 'Add a server',
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const AddServerScreen(),
                ),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            _YouButton(url: (selected ?? _mostRecent(servers)).url),
          ],
        ),
      ),
    );
  }
}

ServerEntry _mostRecent(List<ServerEntry> servers) =>
    servers.reduce((a, b) => b.lastActiveAt!.isAfter(a.lastActiveAt!) ? b : a);

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

class _HomePane extends StatelessWidget {
  const _HomePane();

  @override
  Widget build(BuildContext context) => const _EmptyState(
    icon: Icons.done_all,
    title: "You're all caught up",
    body:
        'Unread messages, mentions and threads from all your servers will '
        'show up here.',
  );
}

class _ServerPane extends StatelessWidget {
  const _ServerPane({required this.server});

  final ServerEntry server;

  @override
  Widget build(BuildContext context) => _EmptyState(
    icon: Icons.forum_outlined,
    title: server.siteName ?? server.displayName,
    body:
        '${server.address}\n\nChannels for this server arrive in the next '
        'version of the app.',
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(Spacing.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: context.tokens.accent),
              const SizedBox(height: Spacing.lg),
              Text(title, style: text.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: Spacing.sm),
              Text(
                body,
                style: text.bodyMedium?.copyWith(color: context.tokens.muted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
