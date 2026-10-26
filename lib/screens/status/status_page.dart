import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/today_provider.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/server_status.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/screens/status/status_providers.dart';
import 'package:matterleast/ui/tokens.dart';

/// Per signed-in server: the connection, the last refresh, what is stored,
/// and a way to refresh now.
class StatusPage extends ConsumerWidget {
  const StatusPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = [
      for (final s in ref.watch(serversProvider).value ?? const <ServerEntry>[])
        if (s.signedIn) s,
    ];
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      appBar: AppBar(title: const Text('Status')),
      body: ListView(
        padding: EdgeInsets.only(top: Spacing.sm, bottom: bottom + Spacing.lg),
        children: [
          if (servers.isEmpty)
            const ListTile(title: Text('No server is signed in.')),
          for (final server in servers) _ServerStatus(server: server),
        ],
      ),
    );
  }
}

class _ServerStatus extends ConsumerWidget {
  const _ServerStatus({required this.server});

  final ServerEntry server;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final today = ref.watch(todayProvider);
    final view = serverStatusView(
      socket: ref.watch(socketStateProvider(server.url)).value,
      sync: ref.watch(syncStatusProvider(server.url)).value,
      stored: ref.watch(serverStorageProvider(server.url)).value,
      host: Uri.parse(server.url).host,
      time: (at) => whenLabel(at, today, use24: use24),
    );
    final tokens = context.tokens;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.lg,
            Spacing.lg,
            Spacing.xs,
          ),
          child: Text(
            {server.displayName, server.address}.join(' · ').toUpperCase(),
            style: tokens.smallCaps,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.wifi_tethering),
          title: const Text('Connection'),
          subtitle: Text(view.connection),
        ),
        ListTile(
          leading: Icon(
            view.problem ? Icons.sync_problem : Icons.sync,
            color: view.problem ? Theme.of(context).colorScheme.error : null,
          ),
          title: const Text('Refresh'),
          subtitle: Text(view.sync),
        ),
        ListTile(
          leading: const Icon(Icons.inventory_2_outlined),
          title: const Text('Saved on this device'),
          subtitle: Text('${view.stored}\n${view.size}'),
          isThreeLine: true,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: FilledButton.tonalIcon(
            onPressed: () async {
              final session = await ref.read(
                serverSessionProvider(server.url).future,
              );
              session.connection.refreshAll();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh now'),
          ),
        ),
        const SizedBox(height: Spacing.sm),
      ],
    );
  }
}
