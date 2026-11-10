import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/call_providers.dart';
import 'package:matterleast/domain/call_controller.dart';
import 'package:matterleast/domain/calls.dart';
import 'package:matterleast/ui/call_participants.dart';
import 'package:matterleast/ui/call_post_card.dart';
import 'package:matterleast/ui/tokens.dart';

/// Under a channel's app bar while a call runs in it that the user is not
/// in: who is in it, and Join when the app can join calls. Takes no room
/// otherwise; the user's own call shows in the bar or the dock.
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
    return ValueListenableBuilder(
      valueListenable: controller.current,
      builder: (context, current, _) {
        final here = current?.url == url && current?.channelId == channelId;
        return Column(
          children: [
            if (action == CallAction.join && call != null && !here)
              _banner(context, call.participantUserIds, controller),
          ],
        );
      },
    );
  }

  Widget _banner(
    BuildContext context,
    List<String> people,
    CallController controller,
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
                    : 'Call in progress · ${people.length} '
                          '${people.length == 1 ? 'person' : 'people'}',
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            CallParticipants(url: url, userIds: people),
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
