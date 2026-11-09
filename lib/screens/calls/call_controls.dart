import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/call_providers.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/domain/call_connection.dart';
import 'package:matterleast/domain/call_controller.dart';
import 'package:matterleast/domain/call_presentation.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/emoji_picker.dart';
import 'package:matterleast/ui/tokens.dart';

const _quickReactions = ['+1', 'clap', 'joy', 'heart'];

/// The user's own controls in the call. Once the call is over they give way
/// to Close.
class CallControls extends ConsumerWidget {
  const CallControls({
    required this.controller,
    required this.connection,
    required this.url,
    required this.channelId,
    super.key,
  });

  final CallController controller;
  final CallConnection connection;
  final String url;
  final String channelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final over = !connection.active;
    final own = ref.watch(
      callSessionOfProvider(url, channelId, connection.sessionId),
    );
    final handUp = (own?.raisedHand ?? 0) > 0;
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: over
            ? Center(
                child: FilledButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    await controller.leave();
                    if (navigator.mounted) navigator.pop();
                  },
                  child: const Text('Close'),
                ),
              )
            : Wrap(
                alignment: WrapAlignment.center,
                spacing: Spacing.lg,
                runSpacing: Spacing.md,
                children: [
                  _Control(
                    label: connection.muted ? 'Unmute' : 'Mute',
                    tooltip: connection.listenOnly
                        ? 'No microphone access'
                        : (connection.muted ? 'Unmute' : 'Mute'),
                    icon: connection.muted ? Icons.mic_off : Icons.mic,
                    selected: !connection.muted,
                    onPressed: connection.listenOnly
                        ? null
                        : () => controller.setMuted(muted: !connection.muted),
                  ),
                  if (connection.routes.length > 1)
                    _RouteControl(controller: controller, state: connection),
                  _Control(
                    label: handUp ? 'Lower hand' : 'Raise hand',
                    tooltip: handUp ? 'Lower hand' : 'Raise hand',
                    icon: Icons.back_hand_outlined,
                    selected: handUp,
                    onPressed: () => controller.setHandRaised(raised: !handUp),
                  ),
                  Builder(
                    builder: (context) => _Control(
                      label: 'React',
                      tooltip: 'React',
                      icon: Icons.add_reaction_outlined,
                      onPressed: () => _react(context),
                    ),
                  ),
                  _Control(
                    label: 'Leave',
                    tooltip: 'Leave call',
                    icon: Icons.call_end,
                    background: scheme.error,
                    foreground: scheme.onError,
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      await controller.leave();
                      if (navigator.mounted) navigator.pop();
                    },
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _react(BuildContext context) async {
    final picked = await showAppSheet<String>(
      context: context,
      builder: (sheet) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(Spacing.lg),
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: Spacing.md,
            children: [
              for (final name in _quickReactions)
                IconButton(
                  tooltip: name,
                  iconSize: 32,
                  icon: EmojiGlyph(name: name, size: 32),
                  onPressed: () => Navigator.pop(sheet, name),
                ),
              IconButton(
                tooltip: 'More emoji',
                iconSize: 32,
                icon: const Icon(Icons.more_horiz),
                onPressed: () async {
                  final name = await showEmojiPicker(sheet, url);
                  if (sheet.mounted) Navigator.pop(sheet, name);
                },
              ),
            ],
          ),
        ),
      ),
    );
    final character = picked == null ? null : unicodeForName(picked);
    if (picked != null && character != null) {
      await controller.react(picked, character);
    }
  }
}

class _Control extends StatelessWidget {
  const _Control({
    required this.label,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.selected = false,
    this.background,
    this.foreground,
  });

  final String label;
  final String tooltip;
  final IconData icon;
  final bool selected;
  final Color? background;
  final Color? foreground;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      IconButton.filledTonal(
        tooltip: tooltip,
        isSelected: selected,
        style: background == null
            ? null
            : IconButton.styleFrom(
                backgroundColor: background,
                foregroundColor: foreground,
              ),
        icon: Icon(icon),
        onPressed: onPressed,
      ),
      Text(label, style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}

class _RouteControl extends StatelessWidget {
  const _RouteControl({required this.controller, required this.state});

  final CallController controller;
  final CallConnection state;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      PopupMenuButton<AudioRoute>(
        tooltip: 'Audio output',
        icon: Icon(switch (state.route) {
          AudioRoute.speaker => Icons.volume_up,
          AudioRoute.bluetooth => Icons.bluetooth_audio,
          AudioRoute.wired => Icons.headset,
          _ => Icons.phone_in_talk,
        }),
        onSelected: controller.setRoute,
        itemBuilder: (_) => [
          for (final route in state.routes)
            CheckedPopupMenuItem(
              value: route,
              checked: route == state.route,
              child: Text(audioRouteLabel(route)),
            ),
        ],
      ),
      Text('Audio', style: Theme.of(context).textTheme.labelSmall),
    ],
  );
}
