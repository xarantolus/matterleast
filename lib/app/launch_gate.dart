import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/incoming_links.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/shortcuts.dart';
import 'package:matterleast/data/files/local_copies.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/add_server/add_server_screen.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/root_screen.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/screens/settings/settings_providers.dart';
import 'package:matterleast/screens/share/share_screen.dart';
import 'package:quick_actions/quick_actions.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';

/// Picks the first screen from the server list on disk: the root with the
/// rail when any server is signed in, else Add server. Also tells the user
/// when a server ended their session.
class LaunchGate extends ConsumerStatefulWidget {
  const LaunchGate({super.key});

  @override
  ConsumerState<LaunchGate> createState() => _LaunchGateState();
}

class _LaunchGateState extends ConsumerState<LaunchGate> {
  late final AppLifecycleListener _lifecycle;
  StreamSubscription<Uri>? _links;
  StreamSubscription<List<SharedMediaFile>>? _shares;
  final _quickActions = const QuickActions();
  String? _shortcutsShown;
  ProviderSubscription<AsyncValue<List<SwitchItem>>>? _shortcutSource;

  void _followShortcuts(String? url) {
    _shortcutSource?.close();
    _shortcutSource = null;
    if (url == null) {
      _showShortcuts(const []);
      return;
    }
    _shortcutSource = ref.listenManual(switchItemsProvider(url), (_, next) {
      if (next case AsyncData(:final value)) _showShortcuts(value);
    }, fireImmediately: true);
  }

  Future<void> _openShortcut(NavigatorState navigator, String type) async {
    final target = parseShortcutType(type);
    if (target == null) return;
    final servers = await ref.read(serversProvider.future);
    if (!servers.any((s) => s.signedIn && s.url == target.url)) return;
    final items = await ref.read(switchItemsProvider(target.url).future);
    final channel = items.where((i) => i.id == target.channelId).firstOrNull;
    if (channel == null || !navigator.mounted) return;
    navigator.popUntil((route) => route.isFirst);
    await openConversation(
      navigator,
      url: target.url,
      channelId: channel.id,
      title: channel.title,
      teamId: channel.teamId,
    );
  }

  void _showShortcuts(List<SwitchItem> items) {
    final recent = recentConversations(items);
    final key = [for (final i in recent) '${shortcutType(i)}\t${i.title}']
        .join('\n');
    if (key == _shortcutsShown) return;
    _shortcutsShown = key;
    unawaited(
      _quickActions.setShortcutItems([
        for (final item in recent)
          ShortcutItem(type: shortcutType(item), localizedTitle: item.title),
      ]),
    );
  }

  @override
  void initState() {
    super.initState();
    final manager = ref.read(serverManagerProvider);
    // After the first frame, so the token read never delays painting.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(manager.checkTokens().then((_) => manager.setForeground(true)));
      if (!mounted) return;
      final navigator = Navigator.of(context);
      _links = AppLinks().uriLinkStream.listen(
        (uri) => unawaited(openIncomingLink(navigator, ref, uri)),
      );
      final shares = ReceiveSharingIntent.instance;
      final cacheDir = LocalCopies.cacheDirectory();
      unawaited(cacheDir.then((dir) => LocalCopies.sweep(dir, DateTime.now())));
      Future<void> open(List<SharedMediaFile> media) async {
        final shared = sharedContentOf(
          media,
          cacheDir: LocalCopies.resolveDirectory(await cacheDir),
          resolve: LocalCopies.resolveFile,
        );
        if (shared == null || !navigator.mounted) return;
        unawaited(
          navigator.push(
            MaterialPageRoute<void>(
              builder: (_) => ShareScreen(shared: shared),
            ),
          ),
        );
      }

      unawaited(
        _quickActions.initialize(
          (type) => unawaited(_openShortcut(navigator, type)),
        ),
      );
      _shares = shares.getMediaStream().listen((m) => unawaited(open(m)));
      unawaited(
        shares.getInitialMedia().then((media) async {
          await open(media);
          return shares.reset();
        }),
      );
    });
    ref.listenManual(
      settingsServerProvider.select((s) => s?.url),
      (_, url) => _followShortcuts(url),
      fireImmediately: true,
    );
    _lifecycle = AppLifecycleListener(
      onShow: () => unawaited(manager.setForeground(true)),
      onHide: () => unawaited(manager.setForeground(false)),
    );
  }

  @override
  void dispose() {
    unawaited(_links?.cancel());
    unawaited(_shares?.cancel());
    _shortcutSource?.close();
    _lifecycle.dispose();
    super.dispose();
  }

  void _showSignedOut(ServerEntry server) {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    messenger
      ..clearMaterialBanners()
      ..showMaterialBanner(
        MaterialBanner(
          leading: const Icon(Icons.logout),
          content: Text('Signed out of ${server.displayName}. Sign in again.'),
          actions: [
            TextButton(
              onPressed: messenger.hideCurrentMaterialBanner,
              child: const Text('Dismiss'),
            ),
            TextButton(
              onPressed: () {
                messenger.hideCurrentMaterialBanner();
                navigator.push(
                  MaterialPageRoute<void>(
                    builder: (_) => AddServerScreen(
                      initialUrl: server.url,
                      initialName: server.displayName,
                    ),
                  ),
                );
              },
              child: const Text('Sign in'),
            ),
          ],
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionEndedProvider, (_, next) {
      if (next case AsyncData(:final value)) _showSignedOut(value);
    });
    final servers = ref.watch(serversProvider).value;
    final saved = ref.watch(savedRailTargetProvider);
    if (servers == null || saved.isLoading) return const Scaffold();
    final signedIn = [
      for (final s in servers)
        if (s.signedIn) s,
    ];
    return signedIn.isEmpty
        ? const AddServerScreen(isRoot: true)
        : RootScreen(servers: signedIn);
  }
}
