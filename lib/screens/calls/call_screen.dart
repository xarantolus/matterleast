import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/call_providers.dart';
import 'package:matterleast/app/permission_providers.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/call_connection.dart';
import 'package:matterleast/domain/call_presentation.dart';
import 'package:matterleast/domain/call_ui_rules.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/calls/call_controls.dart';
import 'package:matterleast/screens/calls/participant_row.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/open_page.dart';
import 'package:matterleast/ui/confirm_dialog.dart';
import 'package:matterleast/ui/content_page.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/try_action.dart';

/// Opens the screen of the call in [channelId] as a page.
Future<void> openCallScreen(
  NavigatorState navigator,
  String url,
  String channelId,
) => openPage(navigator, CallScreen(url: url, channelId: channelId));

/// The call the user is in: who is there, what they do, and the user's own
/// controls. Leaving the screen keeps the call; Leave ends it.
class CallScreen extends ConsumerStatefulWidget {
  const CallScreen({required this.url, required this.channelId, super.key});

  final String url;
  final String channelId;

  @override
  ConsumerState<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends ConsumerState<CallScreen> {
  late final CallScreenOpen _open;

  @override
  void initState() {
    super.initState();
    _open = ref.read(callScreenOpenProvider.notifier);
    WidgetsBinding.instance.addPostFrameCallback((_) => _open.opened());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _open.closed());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.url;
    final channelId = widget.channelId;
    final controller = ref.watch(callControllerProvider);
    final title =
        ref.watch(channelInfoProvider(url, channelId)).value?.title ?? 'Call';
    final selfId = ref.watch(currentUserProvider(url)).value?.id;
    final hostOpen = hostControlsOpen(
      config: ref.watch(callsConfigProvider(url)),
      hostId: ref.watch(callHostProvider(url, channelId)),
      selfId: selfId,
      admin: ref.watch(systemAdminProvider(url)).value ?? false,
    );
    return ValueListenableBuilder(
      valueListenable: controller.connection,
      builder: (context, state, _) {
        final here = state.url == url && state.channelId == channelId;
        final connection = here ? state : const CallConnection();
        return ContentPage(
          title: Text(title),
          actions: [
            if (hostOpen && connection.active)
              _HostMenu(url: url, channelId: channelId),
          ],
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                children: [
                  _StatusLine(
                    connection: connection,
                    onRetry: () => controller.join(url, channelId),
                  ),
                  Expanded(
                    child: _Participants(
                      url: url,
                      channelId: channelId,
                      selfId: selfId,
                      hostOpen: hostOpen,
                    ),
                  ),
                  CallControls(
                    controller: controller,
                    connection: connection,
                    url: url,
                    channelId: channelId,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A line of room for what happened to the connection, kept even when
/// there is nothing to say so the list below doesn't move.
class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.connection, required this.onRetry});

  final CallConnection connection;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final text = callConnectionText(connection);
    final failed = connection.phase == CallPhase.failed;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.sm,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: context.tokens.muted),
              ),
            ),
            if (failed)
              TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class _Participants extends ConsumerWidget {
  const _Participants({
    required this.url,
    required this.channelId,
    required this.selfId,
    required this.hostOpen,
  });

  final String url;
  final String channelId;
  final String? selfId;
  final bool hostOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = ref.watch(callSessionIdsProvider(url, channelId)).ids;
    final sharer = ref.watch(callScreenSharerProvider(url, channelId));
    final hands = ref.watch(callHandsUpProvider(url, channelId));
    Widget row(String id) => ParticipantRow(
      key: ValueKey(id),
      url: url,
      channelId: channelId,
      sessionId: id,
      selfId: selfId,
      hostOpen: hostOpen,
      sharing: id == sharer,
    );
    return Column(
      children: [
        if (hands > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                hands == 1 ? '1 hand raised' : '$hands hands raised',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: ids.length + (ids.length < 2 ? 1 : 0),
            itemBuilder: (context, i) => i < ids.length
                ? row(ids[i])
                : Padding(
                    padding: const EdgeInsets.all(Spacing.xl),
                    child: Text(
                      'Nobody else is here yet.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: context.tokens.muted),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _HostMenu extends ConsumerWidget {
  const _HostMenu({required this.url, required this.channelId});

  final String url;
  final String channelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => PopupMenuButton<bool>(
    tooltip: 'Host controls',
    onSelected: (end) async {
      final session = await ref.read(serverSessionProvider(url).future);
      if (!context.mounted) return;
      final host = hostOf(url);
      if (!end) {
        await tryAction(
          context,
          host,
          () => session.calls.hostMuteOthers(channelId),
        );
        return;
      }
      final sure = await confirm(
        context,
        title: 'End the call for everyone?',
        body: 'Everyone in the call is disconnected.',
        action: 'End call',
        destructive: true,
      );
      if (!sure || !context.mounted) return;
      await tryAction(context, host, () => session.calls.endForAll(channelId));
    },
    itemBuilder: (_) => const [
      PopupMenuItem(value: false, child: Text('Mute everyone else')),
      PopupMenuItem(value: true, child: Text('End call for everyone')),
    ],
  );
}
