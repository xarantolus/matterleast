import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/incoming_links.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/screens/add_server/add_server_screen.dart';
import 'package:matterleast/screens/root/root_screen.dart';
import 'package:matterleast/screens/share/share_screen.dart';
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
      void open(List<SharedMediaFile> media) {
        final shared = sharedContentOf(media);
        if (shared == null || !navigator.mounted) return;
        unawaited(
          navigator.push(
            MaterialPageRoute<void>(
              builder: (_) => ShareScreen(shared: shared),
            ),
          ),
        );
      }

      _shares = shares.getMediaStream().listen(open);
      unawaited(
        shares.getInitialMedia().then((media) {
          open(media);
          return shares.reset();
        }),
      );
    });
    _lifecycle = AppLifecycleListener(
      onShow: () => unawaited(manager.setForeground(true)),
      onHide: () => unawaited(manager.setForeground(false)),
    );
  }

  @override
  void dispose() {
    unawaited(_links?.cancel());
    unawaited(_shares?.cancel());
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
