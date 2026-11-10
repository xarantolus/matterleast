import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/call_providers.dart';
import 'package:matterleast/app/keyboard_shortcuts.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/domain/call_connection.dart';
import 'package:matterleast/domain/call_controller.dart';
import 'package:matterleast/domain/call_presentation.dart';
import 'package:matterleast/domain/call_ui_rules.dart';
import 'package:matterleast/domain/panes.dart';
import 'package:matterleast/screens/calls/call_screen.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/root/open_panes.dart';
import 'package:matterleast/ui/call_end_button.dart';
import 'package:matterleast/ui/call_status_line.dart';
import 'package:matterleast/ui/tokens.dart';

/// Opens the call screen of the call in [url]'s [channelId] over the page
/// the user looks at.
void openCurrentCall(WidgetRef ref, String url, String channelId) {
  final navigator = ref.read(conversationRoutesProvider).navigator;
  if (navigator != null) {
    unawaited(openCallScreen(navigator, url, channelId));
  }
}

/// Shows the call the user is in above every screen: where it is and what
/// it is doing, with Mute and Leave; a tap opens the call screen. It
/// appears only when the user joins or starts a call, and stays until the
/// call is left or its end is dismissed. Everything below it moves down as
/// one, and the status bar's room goes with it. A desktop window wide
/// enough for panes docks the call in the channel list instead.
class CurrentCallBar extends ConsumerStatefulWidget {
  const CurrentCallBar({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<CurrentCallBar> createState() => _CurrentCallBarState();
}

class _CurrentCallBarState extends ConsumerState<CurrentCallBar> {
  final _onScreen = ValueNotifier(false);
  final _subscriptions = <StreamSubscription<void>>[];
  late final OverlayEntry _entry;

  @override
  void initState() {
    super.initState();
    final routes = [
      ref.read(conversationRoutesProvider),
      ref.read(paneRoutesProvider),
    ];
    void update() => _onScreen.value = routes.any((r) => r.callScreenOpen);
    for (final r in routes) {
      _subscriptions.add(r.changes.listen((_) => update()));
    }
    update();
    _entry = OverlayEntry(canSizeOverlay: true, builder: _content);
  }

  @override
  void didUpdateWidget(CurrentCallBar old) {
    super.didUpdateWidget(old);
    _entry.markNeedsBuild();
  }

  @override
  void dispose() {
    for (final s in _subscriptions) {
      unawaited(s.cancel());
    }
    _onScreen.dispose();
    _entry
      ..remove()
      ..dispose();
    super.dispose();
  }

  Widget _content(BuildContext _) {
    final controller = ref.read(callControllerProvider);
    return ListenableBuilder(
      listenable: Listenable.merge([controller.connection, _onScreen]),
      builder: (context, _) {
        final state = controller.connection.value;
        final docked =
            callSurface(
              desktop: isDesktop,
              panes: windowClassOf(MediaQuery.sizeOf(context).width).showsPanes,
            ) ==
            CallSurface.dock;
        final show =
            !docked &&
            !_onScreen.value &&
            state.phase != CallPhase.idle &&
            callConnectionText(state) != '';
        return Column(
          children: [
            if (show) _Bar(controller: controller, state: state),
            Expanded(
              child: MediaQuery.removePadding(
                context: context,
                removeTop: show,
                child: widget.child,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(callControllerProvider);
    return Actions(
      actions: {
        ToggleMuteIntent: EnabledAction<ToggleMuteIntent>(
          enabled: () {
            final state = controller.connection.value;
            return state.active && !state.listenOnly;
          },
          onInvoke: (_) => unawaited(
            controller.setMuted(muted: !controller.connection.value.muted),
          ),
        ),
      },
      // The one overlay over the whole app, so the bar's tooltips are not
      // cut off at its own height.
      child: Overlay(initialEntries: [_entry]),
    );
  }
}

class _Bar extends ConsumerWidget {
  const _Bar({required this.controller, required this.state});

  final CallController controller;
  final CallConnection state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final over = !state.active;
    final failed = state.phase == CallPhase.failed;
    final title = ref
        .watch(channelInfoProvider(state.url, state.channelId))
        .value
        ?.title;
    // Dressed like the app bar below, so the status bar's icons stay
    // legible in both themes; a shade darker to set it apart.
    final bar = theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary;
    final fg = theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary;
    final text = theme.textTheme;
    return Material(
      color: Color.alphaBlend(Colors.black.withAlpha(56), bar),
      child: Padding(
        padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
        child: InkWell(
          onTap: over
              ? null
              : () => openCurrentCall(ref, state.url, state.channelId),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.only(left: Spacing.lg),
              child: Row(
                spacing: Spacing.sm,
                children: [
                  Icon(over ? Icons.call_end : Icons.call, color: fg),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: Spacing.xs),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title != null)
                            Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.titleSmall?.copyWith(color: fg),
                            ),
                          CallStatusLine(
                            state: state,
                            maxLines: 2,
                            style: text.bodySmall?.copyWith(color: fg),
                          ),
                        ],
                      ),
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
                      style: IconButton.styleFrom(foregroundColor: fg),
                      tooltip: state.muted ? 'Unmute' : 'Mute',
                      icon: Icon(state.muted ? Icons.mic_off : Icons.mic),
                      onPressed: () => controller.setMuted(muted: !state.muted),
                    ),
                  if (over)
                    IconButton(
                      style: IconButton.styleFrom(foregroundColor: fg),
                      tooltip: 'Dismiss',
                      icon: const Icon(Icons.close),
                      onPressed: controller.leave,
                    )
                  else
                    CallEndButton(
                      tooltip: 'Leave call',
                      onPressed: controller.leave,
                    ),
                  const SizedBox(width: Spacing.xs),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
