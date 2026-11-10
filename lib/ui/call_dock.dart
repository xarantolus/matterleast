import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/call_providers.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/domain/call_connection.dart';
import 'package:matterleast/domain/call_controller.dart';
import 'package:matterleast/domain/call_presentation.dart';
import 'package:matterleast/domain/call_ui_rules.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/ui/call_end_button.dart';
import 'package:matterleast/ui/call_status_line.dart';
import 'package:matterleast/ui/current_call_bar.dart';
import 'package:matterleast/ui/tokens.dart';

/// The call the user is in, at the foot of the channel list on a desktop
/// window wide enough for panes: where it is, how it is going, Mute and
/// Leave. It takes room only inside the list's pane, so nothing in the
/// conversation moves; a click opens the call screen.
class CallDock extends ConsumerWidget {
  const CallDock({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docked =
        callSurface(
          desktop: isDesktop,
          panes: windowClassOf(MediaQuery.sizeOf(context).width).showsPanes,
        ) ==
        CallSurface.dock;
    if (!docked) return const SizedBox.shrink();
    final controller = ref.watch(callControllerProvider);
    return ValueListenableBuilder(
      valueListenable: controller.connection,
      builder: (context, state, _) =>
          state.phase == CallPhase.idle || callConnectionText(state) == ''
          ? const SizedBox.shrink()
          : _Dock(state: state, controller: controller),
    );
  }
}

class _Dock extends ConsumerWidget {
  const _Dock({required this.state, required this.controller});

  final CallConnection state;
  final CallController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokens = context.tokens;
    final over = !state.active;
    final failed = state.phase == CallPhase.failed;
    final title = ref
        .watch(channelInfoProvider(state.url, state.channelId))
        .value
        ?.title;
    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: tokens.hairline)),
        ),
        child: InkWell(
          onTap: over
              ? null
              : () => openCurrentCall(ref, state.url, state.channelId),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            child: Row(
              spacing: Spacing.sm,
              children: [
                Icon(
                  over ? Icons.call_end : Icons.call,
                  size: 18,
                  color: over ? tokens.muted : tokens.online,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall,
                        ),
                      CallStatusLine(
                        state: state,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: tokens.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                if (failed)
                  TextButton(
                    onPressed: () =>
                        controller.join(state.url, state.channelId),
                    child: const Text('Retry'),
                  ),
                if (!over && !state.listenOnly)
                  IconButton(
                    tooltip: state.muted ? 'Unmute' : 'Mute',
                    icon: Icon(state.muted ? Icons.mic_off : Icons.mic),
                    onPressed: () => controller.setMuted(muted: !state.muted),
                  ),
                if (over)
                  IconButton(
                    tooltip: 'Dismiss',
                    icon: const Icon(Icons.close),
                    onPressed: controller.leave,
                  )
                else
                  CallEndButton(
                    tooltip: 'Leave call',
                    size: 18,
                    onPressed: controller.leave,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
