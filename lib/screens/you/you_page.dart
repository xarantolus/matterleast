import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/add_server/add_server_screen.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/ui/initials_badge.dart';
import 'package:matterleast/ui/tokens.dart';

/// The user's own page: for now the servers, with sign in, sign out and
/// remove.
class YouPage extends ConsumerWidget {
  const YouPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(serversProvider).value ?? const <ServerEntry>[];
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      appBar: AppBar(title: const Text('You')),
      body: ListView(
        padding: EdgeInsets.only(top: Spacing.lg, bottom: bottom + Spacing.lg),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Text('SERVERS', style: context.tokens.smallCaps),
          ),
          const SizedBox(height: Spacing.sm),
          for (final server in servers) _ServerTile(server: server),
          ListTile(
            leading: const SizedBox(width: 40, child: Icon(Icons.add)),
            title: const Text('Add a server'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AddServerScreen()),
            ),
          ),
        ],
      ),
    );
  }
}

enum _ServerAction { signIn, signOut, remove }

class _ServerTile extends ConsumerWidget {
  const _ServerTile({required this.server});

  final ServerEntry server;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = server.signedIn
        ? ref.watch(currentUserProvider(server.url)).value
        : null;
    final details = [
      server.address,
      if (server.siteName case final site? when site != server.displayName)
        site,
      if (server.serverVersion case final version? when version.isNotEmpty)
        'version $version',
    ].join(' · ');
    final state = server.signedIn
        ? (me == null ? 'Signed in' : 'Signed in as @${me.username}')
        : 'Signed out · tap to sign in';
    return ListTile(
      leading: InitialsBadge(name: server.displayName, faded: !server.signedIn),
      title: Text(server.displayName),
      subtitle: Text('$details\n$state'),
      isThreeLine: true,
      onTap: () =>
          _act(context, ref, server.signedIn ? null : _ServerAction.signIn),
      onLongPress: () => _showMenu(context, ref),
      trailing: IconButton(
        tooltip: 'More for ${server.displayName}',
        icon: const Icon(Icons.more_vert),
        onPressed: () => _showMenu(context, ref),
      ),
    );
  }

  Future<void> _showMenu(BuildContext context, WidgetRef ref) async {
    final action = await showModalBottomSheet<_ServerAction>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (server.signedIn)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign out'),
                onTap: () => Navigator.pop(context, _ServerAction.signOut),
              )
            else
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Sign in'),
                onTap: () => Navigator.pop(context, _ServerAction.signIn),
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Remove server'),
              onTap: () => Navigator.pop(context, _ServerAction.remove),
            ),
            const SizedBox(height: Spacing.sm),
          ],
        ),
      ),
    );
    if (action == null || !context.mounted) return;
    await _act(context, ref, action);
  }

  Future<void> _act(
    BuildContext context,
    WidgetRef ref,
    _ServerAction? action,
  ) async {
    final navigator = Navigator.of(context);
    switch (action) {
      case null:
        ref
            .read(railSelectionProvider.notifier)
            .select(RailTarget(url: server.url));
        navigator.pop();
      case _ServerAction.signIn:
        await navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => AddServerScreen(
              initialUrl: server.url,
              initialName: server.displayName,
            ),
          ),
        );
      case _ServerAction.signOut:
      case _ServerAction.remove:
        await _leave(context, ref, remove: action == _ServerAction.remove);
    }
  }

  Future<void> _leave(
    BuildContext context,
    WidgetRef ref, {
    required bool remove,
  }) async {
    // The tile goes away with a removed server, so nothing reads ref later.
    final manager = ref.read(serverManagerProvider);
    final db = ref.read(appDatabaseProvider);
    final navigator = Navigator.of(context);
    final confirmed = await _confirm(
      context,
      title: remove
          ? 'Remove ${server.displayName}?'
          : 'Sign out of ${server.displayName}?',
      body: remove
          ? 'The server and everything saved from it are removed from this '
                'device.'
          : 'Messages saved from this server are removed from this device. '
                'The server stays in your list.',
      action: remove ? 'Remove' : 'Sign out',
    );
    if (!confirmed) return;
    Future<bool> run({bool force = false}) => remove
        ? manager.remove(server.url, force: force)
        : manager.signOut(server.url, force: force);
    var done = await run();
    if (!done && context.mounted) {
      final anyway = await _confirm(
        context,
        title: "Couldn't reach ${server.address}",
        body:
            'Sign out on this device anyway? The session stays valid on the '
            'server until it expires.',
        action: 'Sign out anyway',
      );
      if (anyway) done = await run(force: true);
    }
    final anySignedIn = (await db.allServers()).any(
      (s) => s.lastActiveAt != null,
    );
    if (done && !anySignedIn) navigator.popUntil((route) => route.isFirst);
  }
}

Future<bool> _confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;
