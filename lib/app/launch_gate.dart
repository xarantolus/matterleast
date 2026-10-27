import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/dev_sign_in.dart';
import 'package:matterleast/app/incoming_links.dart';
import 'package:matterleast/app/incoming_shares.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/restore_conversation.dart';
import 'package:matterleast/app/shortcuts.dart';
import 'package:matterleast/data/files/local_copies.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/notifications/app_visibility.dart';
import 'package:matterleast/notifications/desktop_notifications.dart';
import 'package:matterleast/notifications/notification_launch.dart';
import 'package:matterleast/screens/add_server/add_server_screen.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/gone_channels.dart';
import 'package:matterleast/screens/root/root_screen.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/screens/settings/settings_providers.dart';
import 'package:matterleast/screens/share/share_screen.dart';
import 'package:matterleast/ui/slide_route.dart';
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
  GoneChannels? _gone;
  final _shortcuts = const LauncherShortcuts();
  String? _shortcutsShown;
  ProviderSubscription<AsyncValue<List<SwitchItem>>>? _shortcutSource;

  void _followShortcuts(String? url) {
    if (isDesktop) return;
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
    final servers = await readOnce(ref, serversProvider.future);
    if (!servers.any((s) => s.signedIn && s.url == target.url)) return;
    final items = await readOnce(ref, switchItemsProvider(target.url).future);
    final channel = items.where((i) => i.id == target.channelId).firstOrNull;
    if (channel == null || !navigator.mounted) return;
    await openConversation(
      navigator,
      url: target.url,
      channelId: channel.id,
      title: channel.title,
      teamId: channel.teamId,
      fromOutside: true,
    );
  }

  void _showShortcuts(List<SwitchItem> items) {
    final recent = recentConversations(items);
    final key = [for (final i in recent) '${shortcutType(i)}\t${i.title}']
        .join('\n');
    if (key == _shortcutsShown) return;
    _shortcutsShown = key;
    unawaited(_shortcuts.show(recent));
  }

  @override
  void initState() {
    super.initState();
    final manager = ref.read(serverManagerProvider);
    // After the first frame, so the token read never delays painting.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final servers = ref.read(serversProvider.future);
      unawaited(
        servers
            .then((all) => devSignIn(manager, [for (final s in all) s.url]))
            .then((_) => manager.checkTokens())
            .then((_) => manager.setForeground(true)),
      );
      if (!mounted) return;
      final navigator = Navigator.of(context);
      _gone = GoneChannels(ref, navigator)..start();
      final notice = startNotifications(ref, navigator);
      final links = AppLinks();
      _links = links.uriLinkStream.listen(
        (uri) => unawaited(openIncomingLink(navigator, uri)),
      );
      final initialMedia = IncomingShares.initial();
      unawaited(
        restoreConversation(
          ref,
          navigator,
          launchedByIntent: Future.wait([
            notice,
            links.getInitialLink().then((link) => link != null),
            initialMedia.then((media) => media.isNotEmpty),
          ]).then((launches) => launches.any((l) => l)),
        ),
      );
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
            SlideRoute<void>(builder: (_) => ShareScreen(shared: shared)),
          ),
        );
      }

      unawaited(
        _shortcuts.initialize(
          (type) => unawaited(_openShortcut(navigator, type)),
        ),
      );
      _shares = IncomingShares.later().listen((m) => unawaited(open(m)));
      unawaited(
        initialMedia.then((media) async {
          await open(media);
          return IncomingShares.reset();
        }),
      );
    });
    ref.listenManual(
      settingsServerProvider.select((s) => s?.url),
      (_, url) => _followShortcuts(url),
      fireImmediately: true,
    );
    _lifecycle = AppLifecycleListener(
      onShow: () {
        AppVisibility.set(visible: true);
        unawaited(manager.setForeground(true));
      },
      onHide: () => unawaited(appHidden(manager)),
    );
  }

  @override
  void dispose() {
    unawaited(_links?.cancel());
    unawaited(_shares?.cancel());
    _shortcutSource?.close();
    _gone?.dispose();
    _lifecycle.dispose();
    super.dispose();
  }

  void _retryKeyring() {
    final manager = ref.read(serverManagerProvider);
    ref.read(tokenStoreProvider).retry();
    unawaited(manager.checkTokens().then((_) => manager.setForeground(true)));
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
                  SlideRoute<void>(
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
    ref.listen(serversProvider, (_, next) {
      if (next case AsyncData(:final value)) {
        unawaited(followSignedIn(value));
        if (isDesktop) {
          unawaited(ref.read(desktopNotificationsProvider).follow(value));
        }
        if (value.any((s) => s.signedIn)) {
          unawaited(askForNotificationsOnce(context, ref));
        }
      }
    });
    final servers = ref.watch(serversProvider).value;
    final saved = ref.watch(savedRailTargetProvider);
    if (servers == null || saved.isLoading) return const Scaffold();
    final signedIn = [
      for (final s in servers)
        if (s.signedIn) s,
    ];
    return _KeyringNotice(
      shown: ref.watch(keyringUnavailableProvider).value ?? false,
      onRetry: _retryKeyring,
      child: signedIn.isEmpty
          ? const AddServerScreen(isRoot: true)
          : RootScreen(servers: signedIn),
    );
  }
}

/// One banner over the whole window while the token storage doesn't
/// answer; the saved data stays readable below it.
class _KeyringNotice extends StatelessWidget {
  const _KeyringNotice({
    required this.shown,
    required this.onRetry,
    required this.child,
  });

  final bool shown;
  final VoidCallback onRetry;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      if (shown)
        Material(
          child: SafeArea(
            bottom: false,
            child: MaterialBanner(
              leading: const Icon(Icons.key_off_outlined),
              content: const Text(keyringUnavailableText),
              actions: [
                TextButton(onPressed: onRetry, child: const Text('Try again')),
              ],
            ),
          ),
        ),
      Expanded(
        key: const ValueKey('app'),
        child: MediaQuery.removePadding(
          context: context,
          removeTop: shown,
          child: child,
        ),
      ),
    ],
  );
}
