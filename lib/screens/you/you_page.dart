import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/inbox.dart';
import 'package:matterleast/domain/rail.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/add_server/add_server_screen.dart';
import 'package:matterleast/screens/home/home_providers.dart';
import 'package:matterleast/screens/root/rail_selection.dart';
import 'package:matterleast/screens/settings/settings_page.dart';
import 'package:matterleast/screens/you/custom_status_screen.dart';
import 'package:matterleast/screens/you/edit_profile_screen.dart';
import 'package:matterleast/screens/you/profile_providers.dart';
import 'package:matterleast/screens/you/status_sheet.dart';
import 'package:matterleast/screens/you/user_profile_sheet.dart';
import 'package:matterleast/ui/initials_badge.dart';
import 'package:matterleast/ui/presence_dot.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/user_avatar.dart';

/// The user's own page: who they are on the server picked in the rail,
/// their saved messages, settings, about, and the servers with sign in,
/// sign out and remove.
class YouPage extends ConsumerWidget {
  const YouPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servers = ref.watch(serversProvider).value ?? const <ServerEntry>[];
    final signedIn = [
      for (final s in servers)
        if (s.signedIn) s,
    ];
    final picked = ref.watch(railSelectionProvider)?.url;
    final current =
        signedIn.where((s) => s.url == picked).firstOrNull ??
        (signedIn.isEmpty
            ? null
            : signedIn.reduce(
                (a, b) => b.lastActiveAt!.isAfter(a.lastActiveAt!) ? b : a,
              ));
    final version = ref.watch(appVersionProvider).value;
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Scaffold(
      appBar: AppBar(title: const Text('You')),
      body: ListView(
        padding: EdgeInsets.only(top: Spacing.lg, bottom: bottom + Spacing.lg),
        children: [
          if (current != null) _Profile(server: current),
          ListTile(
            leading: const SizedBox(
              width: 40,
              child: Icon(Icons.bookmark_outline),
            ),
            title: const Text('Saved messages'),
            onTap: () {
              ref.read(railSelectionProvider.notifier).select(null);
              ref
                  .read(homeFilterSelectionProvider.notifier)
                  .select(InboxFilter.saved);
              Navigator.of(context).pop();
            },
          ),
          ListTile(
            leading: const SizedBox(
              width: 40,
              child: Icon(Icons.settings_outlined),
            ),
            title: const Text('Settings'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
            ),
          ),
          ListTile(
            leading: const SizedBox(width: 40, child: Icon(Icons.info_outline)),
            title: const Text('About Matterleast'),
            subtitle: version == null ? null : Text('Version $version'),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Matterleast',
              applicationVersion: version,
            ),
          ),
          const SizedBox(height: Spacing.lg),
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

class _Profile extends ConsumerWidget {
  const _Profile({required this.server});

  final ServerEntry server;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserProvider(server.url)).value;
    final profile = me == null
        ? null
        : ref.watch(userProfileProvider(server.url, me.id)).value;
    final name = profile?.name ?? me?.displayName ?? '';
    final status = profile?.status ?? me?.status;
    final custom = profile?.customStatus;
    final customStatusOn =
        ref.watch(featuresProvider(server.url)).value?.customStatus ?? true;
    final text = Theme.of(context).textTheme;
    final tokens = context.tokens;
    void push(Widget screen) =>
        Navigator.of(context)
            .push(MaterialPageRoute<void>(builder: (_) => screen));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            0,
            Spacing.lg,
            Spacing.md,
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  if (me == null)
                    const InitialsBadge(name: '', size: 64, round: true)
                  else
                    UserAvatar(
                      serverUrl: server.url,
                      userId: me.id,
                      name: name,
                      lastPictureUpdate: me.lastPictureUpdate,
                      size: 64,
                    ),
                  PositionedDirectional(
                    end: 0,
                    bottom: 0,
                    child: PresenceDot(status: status, size: 18),
                  ),
                ],
              ),
              const SizedBox(width: Spacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: text.titleLarge),
                    Text(
                      [
                        if (me != null) '@${me.username}',
                        server.displayName,
                      ].join(' · '),
                      style: text.bodyMedium?.copyWith(color: tokens.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (me != null) ...[
          ListTile(
            leading: SizedBox(
              width: 40,
              child: Center(child: PresenceDot(status: status, size: 16)),
            ),
            title: Text(presenceLabel(status)),
            subtitle: const Text('Tap to change'),
            onTap: () => showStatusSheet(
              context,
              ref,
              url: server.url,
              current: status ?? 'offline',
            ),
          ),
          if (customStatusOn)
            ListTile(
              leading: SizedBox(
                width: 40,
                child: Center(
                  child: custom == null
                      ? const Icon(Icons.add_reaction_outlined)
                      : Text(
                          emojiText(custom.emoji),
                          style: const TextStyle(fontSize: 22),
                        ),
                ),
              ),
              title: custom == null
                  ? const Text('Set a custom status')
                  : CustomStatusLine(
                      status: custom.copyWith(emoji: ''),
                      textAlign: TextAlign.start,
                    ),
              trailing: custom == null
                  ? null
                  : IconButton(
                      tooltip: 'Clear custom status',
                      icon: const Icon(Icons.close),
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          final actions = await ref.read(
                            profileActionsProvider(server.url).future,
                          );
                          await actions.setCustomStatus(null);
                        } on Object catch (e) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                "Couldn't clear your status. "
                                '${requestProblemText(e, Uri.parse(server.url).host)}',
                              ),
                            ),
                          );
                        }
                      },
                    ),
              onTap: () =>
                  push(CustomStatusScreen(url: server.url, current: custom)),
            ),
          if (profile != null)
            ListTile(
              leading: const SizedBox(
                width: 40,
                child: Icon(Icons.manage_accounts_outlined),
              ),
              title: const Text('Edit profile'),
              subtitle: const Text('Picture, names, username and password'),
              onTap: () =>
                  push(EditProfileScreen(url: server.url, profile: profile)),
            ),
        ],
      ],
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
        title: "Couldn't sign out on ${server.address}",
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
