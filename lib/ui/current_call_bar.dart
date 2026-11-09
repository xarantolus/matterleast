import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/call_providers.dart';
import 'package:matterleast/domain/call_connection.dart';
import 'package:matterleast/domain/call_controller.dart';
import 'package:matterleast/domain/call_presentation.dart';
import 'package:matterleast/screens/calls/call_screen.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/ui/tokens.dart';

/// Shows the call the user is in above every screen: where it is and what
/// it is doing, with Mute and Leave; a tap opens the call screen. It
/// appears only when the user joins or starts a call, and stays until the
/// call is left or its end is dismissed. Everything below it moves down as
/// one, and the status bar's room goes with it.
class CurrentCallBar extends ConsumerWidget {
  const CurrentCallBar({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(callControllerProvider);
    if (controller == null) return child;
    final onScreen = ref.watch(callScreenOpenProvider) > 0;
    return ValueListenableBuilder(
      valueListenable: controller.connection,
      builder: (context, state, _) {
        final show =
            !onScreen && state.phase != CallPhase.idle && _text(state) != '';
        return Column(
          children: [
            show
                ? _Bar(controller: controller, state: state)
                : const SizedBox.shrink(),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: show,
                child: child,
              ),
            ),
          ],
        );
      },
    );
  }

  static String _text(CallConnection state) => callConnectionText(state);
}

class _Bar extends ConsumerWidget {
  const _Bar({required this.controller, required this.state});

  final CallController controller;
  final CallConnection state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final top = MediaQuery.paddingOf(context).top;
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);
    return SizedBox(
      height: top + 56 * scale,
      // Buttons with tooltips need an overlay, which only exists inside the
      // navigator below.
      child: Overlay(
        initialEntries: [
          OverlayEntry(
            builder: (_) => _BarContent(controller: controller, top: top),
          ),
        ],
      ),
    );
  }
}

class _BarContent extends ConsumerWidget {
  const _BarContent({required this.controller, required this.top});

  final CallController controller;
  final double top;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder(
      valueListenable: controller.connection,
      builder: (context, state, _) {
        final over = !state.active;
        final failed = state.phase == CallPhase.failed;
        final title = ref
            .watch(channelInfoProvider(state.url, state.channelId))
            .value
            ?.title;
        void open() {
          final navigator = ref.read(conversationRoutesProvider).navigator;
          if (navigator != null) {
            unawaited(openCallScreen(navigator, state.url, state.channelId));
          }
        }

        // Dark, like the app bar, so the status bar's light icons stay legible.
        final fg = over ? scheme.onInverseSurface : scheme.onPrimary;
        final button = IconButton.styleFrom(foregroundColor: fg);
        return Material(
          color: over ? scheme.inverseSurface : scheme.primary,
          child: Padding(
            padding: EdgeInsets.only(top: top),
            child: InkWell(
              onTap: over ? null : open,
              child: Padding(
                padding: const EdgeInsets.only(left: Spacing.lg),
                child: Row(
                  spacing: Spacing.sm,
                  children: [
                    Icon(
                      over ? Icons.call_end : Icons.call,
                      size: 20,
                      color: fg,
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null)
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(color: fg),
                            ),
                          Text(
                            callConnectionText(state),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: fg),
                          ),
                        ],
                      ),
                    ),
                    if (failed)
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: fg),
                        onPressed: () =>
                            controller.join(state.url, state.channelId),
                        child: const Text('Retry'),
                      ),
                    if (!over && !state.listenOnly)
                      IconButton(
                        style: button,
                        tooltip: state.muted ? 'Unmute' : 'Mute',
                        icon: Icon(state.muted ? Icons.mic_off : Icons.mic),
                        onPressed: () =>
                            controller.setMuted(muted: !state.muted),
                      ),
                    IconButton(
                      style: button,
                      tooltip: over ? 'Dismiss' : 'Leave call',
                      icon: Icon(over ? Icons.close : Icons.call_end),
                      onPressed: controller.leave,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
