import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/data/actions/channel_actions.dart';
import 'package:matterleast/domain/channel_info.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/channel_info/channel_missing.dart';
import 'package:matterleast/screens/channel_info/channel_providers.dart';
import 'package:matterleast/screens/root/root_providers.dart';
import 'package:matterleast/ui/pane_label.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/window_bar.dart';

/// How the user is notified about one channel. Each change is saved at
/// once and shown before the server confirms it.
class NotificationPrefsScreen extends ConsumerWidget {
  const NotificationPrefsScreen({
    required this.url,
    required this.channelId,
    super.key,
  });

  final String url;
  final String channelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final infoState = ref.watch(channelInfoProvider(url, channelId));
    final info = infoState.value;
    final bottom = MediaQuery.paddingOf(context).bottom;
    Future<void> save(Future<void> Function(ChannelActions) change) async {
      final messenger = ScaffoldMessenger.of(context);
      try {
        await change(await ref.read(channelActionsProvider(url).future));
      } on Object catch (e) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              "Couldn't save. ${requestProblemText(e, Uri.parse(url).host)}",
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: WindowAppBar(title: const Text('Notifications')),
      body: info == null
          ? ChannelMissing(
              state: infoState,
              host: Uri.parse(url).host,
              onRetry: () =>
                  ref.invalidate(channelInfoProvider(url, channelId)),
            )
          : ListView(
              padding: EdgeInsets.only(bottom: bottom + Spacing.lg),
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_off_outlined),
                  title: const Text('Mute channel'),
                  subtitle: const Text(
                    'Only mentions mark it unread, and it moves to the '
                    'bottom of its category.',
                  ),
                  value: info.muted,
                  onChanged: (muted) =>
                      save((a) => a.setMuted(channelId, muted: muted)),
                ),
                if (!info.conversation)
                  SwitchListTile(
                    secondary: const Icon(Icons.campaign_outlined),
                    title: const Text('Ignore @channel, @here and @all'),
                    subtitle: const Text(
                      'Messages to everyone in the channel no longer count '
                      'as mentions of you.',
                    ),
                    value: info.notify.ignoreChannelMentions == 'on',
                    onChanged: (ignore) => save(
                      (a) => a.updateNotifyProps(
                        channelId,
                        ignoreChannelMentions: ignore ? 'on' : 'off',
                      ),
                    ),
                  ),
                const PaneLabel('Mobile notifications'),
                _Levels(
                  value: info.notify.push,
                  account: info.notify.accountPush,
                  onChanged: (level) =>
                      save((a) => a.updateNotifyProps(channelId, push: level)),
                ),
                const PaneLabel('Desktop and web notifications'),
                _Levels(
                  value: info.notify.desktop,
                  account: info.notify.accountDesktop,
                  onChanged: (level) => save(
                    (a) => a.updateNotifyProps(channelId, desktop: level),
                  ),
                ),
              ],
            ),
    );
  }
}

class _Levels extends StatelessWidget {
  const _Levels({
    required this.value,
    required this.account,
    required this.onChanged,
  });

  final String value;
  final String account;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => RadioGroup<String>(
    groupValue: value,
    onChanged: (level) {
      if (level != null && level != value) onChanged(level);
    },
    child: Column(
      children: [
        for (final level in const ['default', 'all', 'mention', 'none'])
          RadioListTile<String>(
            value: level,
            title: Text(
              level == 'default'
                  ? effectiveLevel(level, account)
                  : notifyLevelLabel(level),
            ),
          ),
      ],
    ),
  );
}
