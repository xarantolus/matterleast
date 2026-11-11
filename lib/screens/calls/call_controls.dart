import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/call_providers.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/data/emoji/emoji.dart';
import 'package:matterleast/domain/call_connection.dart';
import 'package:matterleast/domain/call_controller.dart';
import 'package:matterleast/domain/call_presentation.dart';
import 'package:matterleast/ui/app_sheet.dart';
import 'package:matterleast/ui/call_end_button.dart';
import 'package:matterleast/ui/emoji_glyph.dart';
import 'package:matterleast/ui/emoji_picker.dart';
import 'package:matterleast/ui/tokens.dart';

const _quickReactions = [
  ('+1', 'Thumbs up'),
  ('clap', 'Clap'),
  ('joy', 'Laughing'),
  ('heart', 'Heart'),
];

/// Every control is this big, however its neighbours come and go.
const _control = 56.0;

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
                  if (isDesktop)
                    _DeviceControl(controller: controller, state: connection)
                  else
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
                  _Labelled(
                    label: 'Leave',
                    child: CallEndButton(
                      tooltip: 'Leave call',
                      size: 28,
                      dimension: _control,
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        await controller.leave();
                        if (navigator.mounted) navigator.pop();
                      },
                    ),
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
              for (final (name, label) in _quickReactions)
                IconButton(
                  tooltip: label,
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
    if (picked != null) {
      // A custom emoji has no character; the plugin takes its name alone.
      await controller.react(picked, unicodeForName(picked) ?? '');
    }
  }
}

class _Labelled extends StatelessWidget {
  const _Labelled({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox.square(dimension: _control, child: child),
      Text(label, style: Theme.of(context).textTheme.labelLarge),
    ],
  );
}

class _Control extends StatelessWidget {
  const _Control({
    required this.label,
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.selected = false,
  });

  final String label;
  final String tooltip;
  final IconData icon;
  final bool selected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => _Labelled(
    label: label,
    child: IconButton.filledTonal(
      tooltip: tooltip,
      isSelected: selected,
      style: _style,
      icon: Icon(icon),
      onPressed: onPressed,
    ),
  );
}

final _style = IconButton.styleFrom(
  minimumSize: const Size.square(_control),
  fixedSize: const Size.square(_control),
  iconSize: 28,
);

ButtonStyle _menuStyle(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  return _style.copyWith(
    backgroundColor: WidgetStatePropertyAll(scheme.secondaryContainer),
    foregroundColor: WidgetStatePropertyAll(scheme.onSecondaryContainer),
  );
}

class _RouteControl extends StatelessWidget {
  const _RouteControl({required this.controller, required this.state});

  final CallController controller;
  final CallConnection state;

  @override
  Widget build(BuildContext context) => _Labelled(
    label: 'Audio',
    child: PopupMenuButton<AudioRoute>(
      tooltip: 'Audio output',
      enabled: state.routes.length > 1,
      style: _menuStyle(context),
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
  );
}

/// The desktop's microphones and speakers, one menu for both. Its place is
/// kept while the devices are listed, so the other controls stay put.
class _DeviceControl extends StatelessWidget {
  const _DeviceControl({required this.controller, required this.state});

  final CallController controller;
  final CallConnection state;

  @override
  Widget build(BuildContext context) {
    final heading = Theme.of(context).textTheme.labelMedium;
    final inputs = friendlyDevices(state.inputs);
    final outputs = friendlyDevices(state.outputs);
    PopupMenuEntry<({bool input, String id})> title(String text) =>
        PopupMenuItem(enabled: false, child: Text(text, style: heading));
    PopupMenuEntry<({bool input, String id})> item(
      AudioDevice device, {
      required bool input,
      required AudioDevice? chosen,
    }) => CheckedPopupMenuItem(
      value: (input: input, id: device.id),
      checked: chosen != null && friendlyDevices([chosen]).single == device,
      child: Text(device.label),
    );
    return _Labelled(
      label: 'Devices',
      child: PopupMenuButton<({bool input, String id})>(
        tooltip: 'Microphone and speaker',
        enabled: inputs.length > 1 || outputs.length > 1,
        style: _menuStyle(context),
        icon: const Icon(Icons.headset_mic),
        onSelected: (pick) =>
            controller.setDevice(input: pick.input, id: pick.id),
        itemBuilder: (_) => [
          if (inputs.isNotEmpty) title('Microphone'),
          for (final d in inputs) item(d, input: true, chosen: state.input),
          if (outputs.isNotEmpty) title('Speaker'),
          for (final d in outputs) item(d, input: false, chosen: state.output),
        ],
      ),
    );
  }
}
