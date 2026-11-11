import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/call_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/data/actions/calls_actions.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/try_action.dart';

/// What the host can do about one person in the call.
Future<void> showHostSheet(
  BuildContext context, {
  required String url,
  required String channelId,
  required String sessionId,
}) => showAppSheet<void>(
  context: context,
  builder: (_) =>
      _HostSheet(url: url, channelId: channelId, sessionId: sessionId),
);

class _HostSheet extends ConsumerWidget {
  const _HostSheet({
    required this.url,
    required this.channelId,
    required this.sessionId,
  });

  final String url;
  final String channelId;
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(callSessionOfProvider(url, channelId, sessionId));
    if (session == null) return const SizedBox.shrink();
    final host = ref.watch(callHostProvider(url, channelId));
    Future<void> run(
      Future<void> Function(CallsActions calls) action, {
      String? confirmTitle,
    }) async {
      final navigator = Navigator.of(context);
      final server = await ref.read(serverSessionProvider(url).future);
      if (!context.mounted) return;
      if (confirmTitle != null) {
        final sure = await confirm(
          context,
          title: confirmTitle,
          body: 'They are disconnected from the call and can join again.',
          action: 'Remove',
          destructive: true,
        );
        if (!sure || !context.mounted) return;
      }
      final done = await tryAction(
        context,
        hostOf(url),
        () => action(server.calls),
      );
      if (done && navigator.mounted) navigator.pop();
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!session.muted)
            ListTile(
              leading: const Icon(Icons.mic_off),
              title: const Text('Mute'),
              onTap: () => run((c) => c.hostMute(channelId, sessionId)),
            ),
          if (session.raisedHand > 0)
            ListTile(
              leading: const Icon(Icons.back_hand_outlined),
              title: const Text('Lower hand'),
              onTap: () => run((c) => c.hostLowerHand(channelId, sessionId)),
            ),
          if (host != session.userId)
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_outlined),
              title: const Text('Make host'),
              onTap: () => run((c) => c.makeHost(channelId, session.userId)),
            ),
          ListTile(
            leading: Icon(
              Icons.person_remove_outlined,
              color: Theme.of(context).colorScheme.error,
            ),
            title: const Text('Remove from call'),
            onTap: () => run(
              (c) => c.hostRemove(channelId, sessionId),
              confirmTitle: 'Remove from the call?',
            ),
          ),
        ],
      ),
    );
  }
}
