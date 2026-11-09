import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/call_providers.dart';
import 'package:matterleast/domain/call_connection.dart';
import 'package:matterleast/domain/call_controller.dart';
import 'package:matterleast/domain/call_presentation.dart';
import 'package:matterleast/domain/calls.dart';
import 'package:matterleast/ui/call_participants.dart';
import 'package:matterleast/ui/call_post_card.dart';
import 'package:matterleast/ui/tokens.dart';

/// Under a channel's app bar while a call runs in it: who is in it, and
/// Join when the app can join calls. Takes no room otherwise.
class CallJoinBanner extends ConsumerWidget {
  const CallJoinBanner({
    required this.url,
    required this.channelId,
    required this.channelType,
    super.key,
  });

  final String url;
  final String channelId;
  final String channelType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final action = ref.watch(callActionInProvider(url, channelId, channelType));
    final call = ref.watch(callInChannelProvider(url, channelId));
    final controller = ref.watch(callControllerProvider);
    return Column(
      children: [
        if (action == CallAction.join && call != null)
          _banner(context, call.participantUserIds, controller),
        if (controller != null)
          CallConnectionStrip(
            controller: controller,
            url: url,
            channelId: channelId,
          ),
      ],
    );
  }

  Widget _banner(
    BuildContext context,
    List<String> people,
    CallController? controller,
  ) {
    final tokens = context.tokens;
    return ColoredBox(
      color: tokens.accentWash,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.sm,
        ),
        child: Row(
          spacing: Spacing.md,
          children: [
            Icon(Icons.call, size: 20, color: tokens.accent),
            Expanded(
              child: Text(
                people.isEmpty
                    ? 'Call in progress'
                    : 'Call in progress · ${people.length}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            CallParticipants(url: url, userIds: people),
            if (controller != null)
              CallJoinButton(
                controller: controller,
                url: url,
                channelId: channelId,
              ),
          ],
        ),
      ),
    );
  }
}

/// What the call's connection is doing, with Mute and Leave; the call
/// screen replaces it. Takes no room unless the user is in this call or
/// the last one ended here.
class CallConnectionStrip extends StatelessWidget {
  const CallConnectionStrip({
    required this.controller,
    required this.url,
    required this.channelId,
    super.key,
  });

  final CallController controller;
  final String url;
  final String channelId;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: controller.connection,
    builder: (context, state, _) {
      final text = callConnectionText(state);
      if (state.url != url || state.channelId != channelId || text.isEmpty) {
        return const SizedBox.shrink();
      }
      final tokens = context.tokens;
      final over =
          state.phase == CallPhase.ended || state.phase == CallPhase.failed;
      return ColoredBox(
        color: tokens.accentWash,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: Row(
            spacing: Spacing.sm,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              if (!over && !state.listenOnly)
                IconButton(
                  tooltip: state.muted ? 'Unmute' : 'Mute',
                  icon: Icon(state.muted ? Icons.mic_off : Icons.mic),
                  onPressed: () => controller.setMuted(muted: !state.muted),
                ),
              IconButton(
                tooltip: over ? 'Dismiss' : 'Leave call',
                icon: Icon(over ? Icons.close : Icons.call_end),
                onPressed: controller.leave,
              ),
            ],
          ),
        ),
      );
    },
  );
}
