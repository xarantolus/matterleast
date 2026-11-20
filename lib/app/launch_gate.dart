import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:conversation_shortcuts/conversation_shortcuts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/data_saver.dart';
import 'package:matterleast/app/dev_sign_in.dart';
import 'package:matterleast/app/image_memory.dart';
import 'package:matterleast/app/image_providers.dart';
import 'package:matterleast/app/incoming_links.dart';
import 'package:matterleast/app/incoming_shares.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/app/restore_conversation.dart';
import 'package:matterleast/app/share_receiver.dart';
import 'package:matterleast/app/shortcut_follower.dart';
import 'package:matterleast/app/shortcuts.dart';
import 'package:matterleast/app/sso_resume.dart';
import 'package:matterleast/data/files/local_copies.dart';
import 'package:matterleast/data/images/image_rules.dart';
import 'package:matterleast/domain/quick_switch.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/sso_callback.dart';
import 'package:matterleast/log.dart';
import 'package:matterleast/notifications/app_visibility.dart';
import 'package:matterleast/notifications/in_app_notifications.dart';
import 'package:matterleast/notifications/notification_launch.dart';
import 'package:matterleast/screens/add_server/add_server_screen.dart';
import 'package:matterleast/screens/open_channel.dart';
import 'package:matterleast/screens/root/gone_channels.dart';
import 'package:matterleast/screens/root/place_reconciler.dart';
import 'package:matterleast/screens/root/root_screen.dart';
import 'package:matterleast/screens/search/search_providers.dart';
import 'package:matterleast/screens/settings/settings_providers.dart';
import 'package:matterleast/screens/terms/terms_gate.dart';
import 'package:matterleast/ui/slide_route.dart';
import 'package:matterleast/ui/tokens.dart';

/// Picks the first screen from the server list on disk: the root with the
/// rail when any server is signed in, else Add server. Also tells the user
/// when a server ended their session.
class LaunchGate extends ConsumerStatefulWidget {
  const LaunchGate({super.key, this.stallAfter = const Duration(seconds: 10)});

  /// How long the start-up inputs may take before Retry is offered.
  final Duration stallAfter;

  @override
  ConsumerState<LaunchGate> createState() => _LaunchGateState();
}

class _LaunchGateState extends ConsumerState<LaunchGate> {
  late final AppLifecycleListener _lifecycle;
  final _imageMemory = ReleaseImagesWhenHidden();
  StreamSubscription<Uri>? _links;
  ShareReceiver? _shares;
  GoneChannels? _gone;
  final _shortcuts = const ConversationShortcuts();
  late final _shortcutFollower = ShortcutFollower(ref);
  Timer? _stallTimer;
  var _stalled = false;

  /// The conversation of a shortcut id, if it is one of the user's.
  Future<SwitchItem?> _shortcutTarget(String? id) async {
    final target = id == null ? null : parseShortcutType(id);
    if (target == null) return null;
    final servers = await readOnce(ref, serversProvider.future);
    final signedIn = {
      for (final s in servers)
        if (s.signedIn) s.url,
    };
    if (!signedIn.contains(target.url)) return null;
    return shortcutItem(
      id,
      signedIn: signedIn,
      items: await readOnce(ref, switchItemsProvider(target.url).future),
    );
  }

  Future<void> _openShortcut(NavigatorState navigator) async {
    final channel = await _shortcutTarget(await _shortcuts.takeLaunch());
    if (channel == null || !navigator.mounted) return;
    await openConversation(
      navigator,
      url: channel.serverUrl,
      channelId: channel.id,
      title: channel.title,
      teamId: channel.teamId,
      fromOutside: true,
    );
  }

  @override
  void initState() {
    super.initState();
    final manager = ref.read(serverManagerProvider);
    // After the first frame, so the token read never delays painting.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_startServers());
      if (!mounted) return;
      final navigator = Navigator.of(context);
      ref.read(placeReconcilerProvider);
      _gone = GoneChannels(ref, navigator)..start();
      final notice = startNotifications(ref, navigator);
      final links = AppLinks();
      final authSession = ref.read(browserAuthSessionProvider);
      final resume = ref.read(ssoResumeProvider);
      _links = links.uriLinkStream.listen((uri) {
        if (isShareWakeLink(uri)) return;
        if (!isSsoCallbackLink(uri)) {
          unawaited(openIncomingLink(navigator, uri));
        } else if (!authSession.deliver(uri)) {
          unawaited(resume.resume(uri));
        }
      });
      final cacheDir = LocalCopies.cacheDirectory();
      unawaited(cacheDir.then((dir) => LocalCopies.sweep(dir, DateTime.now())));
      final shares = _shares = ShareReceiver(
        navigator,
        target: _shortcutTarget,
      );
      final sharedAtLaunch = shares.start(cacheDir);
      unawaited(
        restoreConversation(
          ref,
          navigator,
          launchedByIntent: Future.wait([
            notice,
            links.getInitialLink().then(
              (link) =>
                  link != null &&
                  !isSsoCallbackLink(link) &&
                  !isShareWakeLink(link),
            ),
            sharedAtLaunch,
          ]).then((launches) => launches.any((l) => l)),
        ),
      );
      _shortcuts.listen(() => unawaited(_openShortcut(navigator)));
      unawaited(_openShortcut(navigator));
    });
    _shortcutFollower.start();
    _startStallTimer();
    _lifecycle = AppLifecycleListener(
      onShow: () => unawaited(
        AppVisibility.shown().then((_) {
          if (AppVisibility.visible) return manager.setForeground(true);
        }),
      ),
      onHide: () {
        if (!isDesktop) ref.read(inAppNotificationsProvider).rearmAll();
        unawaited(appHidden(manager));
      },
    );
  }

  @override
  void dispose() {
    _stallTimer?.cancel();
    unawaited(_links?.cancel());
    _shares?.dispose();
    _shortcutFollower.dispose();
    _gone?.dispose();
    _lifecycle.dispose();
    _imageMemory.dispose();
    super.dispose();
  }

  Future<void> _startServers() async {
    final manager = ref.read(serverManagerProvider);
    try {
      final all = await ref.read(serversProvider.future);
      await devSignIn(manager, [for (final s in all) s.url]);
      await manager.checkTokens();
      await AppVisibility.shown();
      await manager.setForeground(true);
    } on Object catch (e) {
      Log.warn('start', 'Starting the servers failed', e);
    }
  }

  void _startStallTimer() {
    _stallTimer?.cancel();
    _stallTimer = Timer(widget.stallAfter, () {
      final missing = _missingInputs();
      if (missing.isEmpty || !mounted) return;
      Log.warn('start', 'Still waiting for ${missing.join(', ')}');
      setState(() => _stalled = true);
    });
  }

  List<String> _missingInputs() => [
    if (ref.read(serversProvider).value == null) 'servers',
    if (ref.read(savedRailTargetProvider).isLoading) 'saved place',
    if (ref.read(homeFilterSettingProvider).isLoading) 'home filter',
    if (ref.read(searchTabProvider).isLoading) 'search tab',
    if (ref.read(threadsTabProvider).isLoading) 'threads tab',
    if (ref.read(autoLoadProvider(DataKind.linkPicture)) == null)
      'picture loading',
  ];

  void _retryStart() {
    ref
      ..invalidate(appDatabaseProvider)
      ..invalidate(serversProvider)
      ..invalidate(networkStateProvider)
      ..invalidate(dataSaverProvider);
    setState(() => _stalled = false);
    _startStallTimer();
    unawaited(_startServers());
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
                  SlideRoute<void>.page(
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
        unawaited(ref.read(inAppNotificationsProvider).follow(value));
        if (value.any((s) => s.signedIn)) {
          unawaited(askForNotificationsOnce(context, ref));
        }
      }
    });
    final serversState = ref.watch(serversProvider);
    final servers = serversState.value;
    final saved = ref.watch(savedRailTargetProvider);
    // Saved choices are known before the first frame, so none shows its
    // default and then switches.
    final choices = [
      ref.watch(homeFilterSettingProvider),
      ref.watch(searchTabProvider),
      ref.watch(threadsTabProvider),
    ];
    // Whether pictures load is known too, so a link card never adds or drops
    // its picture after it was shown.
    final loadsPictures = ref.watch(autoLoadProvider(DataKind.linkPicture));
    if (servers == null ||
        saved.isLoading ||
        choices.any((c) => c.isLoading) ||
        loadsPictures == null) {
      return StartupWait(
        problem: serversState.error,
        stalled: _stalled,
        onRetry: _retryStart,
      );
    }
    final signedIn = [
      for (final s in servers)
        if (s.signedIn) s,
    ];
    return KeyringNotice(
      shown: ref.watch(keyringUnavailableProvider).value ?? false,
      onRetry: _retryKeyring,
      child: signedIn.isEmpty
          ? const AddServerScreen(isRoot: true)
          : TermsGate(
              url:
                  ref.watch(settingsServerProvider.select((s) => s?.url)) ??
                  signedIn.first.url,
              child: RootScreen(servers: signedIn),
            ),
    );
  }
}

/// Blank for the brief normal start-up; when it fails or takes too long,
/// says so and offers Retry.
class StartupWait extends StatelessWidget {
  const StartupWait({
    super.key,
    required this.problem,
    required this.stalled,
    required this.onRetry,
  });

  final Object? problem;
  final bool stalled;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final failure = problem;
    if (failure == null && !stalled) return const Scaffold();
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                failure == null
                    ? 'Still starting…'
                    : startupProblemText(failure),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: Spacing.lg),
              FilledButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ),
      ),
    );
  }
}

/// One banner over the whole window while the token storage doesn't
/// answer; the saved data stays readable below it.
class KeyringNotice extends StatelessWidget {
  const KeyringNotice({
    super.key,
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
