import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/notify_props.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/server_features.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/screens/settings/phone_notifications.dart';
import 'package:matterleast/screens/settings/settings_providers.dart';
import 'package:matterleast/screens/settings/settings_widgets.dart';
import 'package:matterleast/ui/empty_state.dart';
import 'package:matterleast/ui/progress_slot.dart';

/// The account's notification settings on one server.
class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({required this.server, super.key});

  final ServerEntry server;

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  var _saving = false;

  String get _url => widget.server.url;

  Future<void> _save(NotifyProps shown, NotifyProps edited) async {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      final actions = await ref.read(settingsActionsProvider(_url).future);
      await actions.saveNotifyProps(shown, edited);
    } on Object catch (e) {
      showProblem(
        messenger,
        "Couldn't save. ${requestProblemText(e, widget.server.address)}",
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final props = ref.watch(notifySettingsProvider(_url)).value;
    final refresh = ref.watch(notifySettingsRefreshProvider(_url));
    final me = ref.watch(currentUserProvider(_url)).value;
    final features = ref.watch(featuresProvider(_url)).value;
    final shown = props != null && !props.isEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        bottom: ProgressSlot(active: _saving || (shown && refresh.isLoading)),
      ),
      body: shown
          ? _list(context, props, me?.username ?? '', features)
          : refresh.hasError && !refresh.isLoading
          ? EmptyState(
              icon: Icons.cloud_off_outlined,
              title: "Couldn't load your notification settings",
              body: requestProblemText(refresh.error!, widget.server.address),
              action: FilledButton(
                onPressed: () =>
                    ref.invalidate(notifySettingsRefreshProvider(_url)),
                child: const Text('Retry'),
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _list(
    BuildContext context,
    NotifyProps props,
    String username,
    ServerFeatures? features,
  ) {
    final keys = props.mentionKeys(username);
    final enabled = !_saving;
    return ListView(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      children: [
        if (isDesktop)
          const ComputerNotifications()
        else
          const PhoneNotifications(),
        SettingsHeader('Saved on the server · ${widget.server.displayName}'),
        ListTile(
          enabled: enabled,
          title: const Text('Notify me about'),
          subtitle: Text(props.push.label),
          onTap: () async {
            final level = await pickOne(
              context,
              title: 'Notify me about',
              options: PushLevel.values,
              current: props.push,
              label: (l) => l.label,
            );
            if (level != null) await _save(props, props.withPush(level));
          },
        ),
        SwitchListTile(
          title: const Text('Replies in threads I follow'),
          value: props.threadReplies,
          onChanged: enabled
              ? (on) => _save(props, props.withThreadReplies(on))
              : null,
        ),
        ListTile(
          enabled: enabled,
          title: const Text('Notify me while I am'),
          subtitle: Text(props.pushTrigger.label),
          onTap: () async {
            final trigger = await pickOne(
              context,
              title: 'Notify me while I am',
              options: PushTrigger.values,
              current: props.pushTrigger,
              label: (t) => t.label,
            );
            if (trigger != null) {
              await _save(props, props.withPushTrigger(trigger));
            }
          },
        ),
        const SettingsHeader('Mentions'),
        SwitchListTile(
          title: const Text('My first name'),
          value: props.firstName,
          onChanged: enabled
              ? (on) => _save(props, props.withFirstName(on))
              : null,
        ),
        SwitchListTile(
          title: const Text('@channel, @all and @here'),
          value: props.channelWide,
          onChanged: enabled
              ? (on) => _save(props, props.withChannelWide(on))
              : null,
        ),
        ListTile(
          enabled: enabled,
          title: const Text('Other words'),
          subtitle: Text(
            keys.isEmpty ? 'None. @$username always counts.' : keys.join(', '),
          ),
          onTap: () async {
            final text = await showDialog<String>(
              context: context,
              builder: (_) => _TextDialog(
                title: 'Words that mention you',
                initial: keys.join(', '),
                helper: 'Separate words with commas',
              ),
            );
            if (text == null) return;
            await _save(
              props,
              props.withMentionKeys(username, parseMentionKeys(text)),
            );
          },
        ),
        if (features?.emailNotifications ?? false) ...[
          const SettingsHeader('Email'),
          SwitchListTile(
            title: const Text('Email notifications'),
            subtitle: const Text(
              'Mentions and direct messages while you are away or offline',
            ),
            value: props.email,
            onChanged: enabled
                ? (on) => _save(props, props.withEmail(on))
                : null,
          ),
        ],
        if (features?.automaticReplies ?? false) ...[
          const SettingsHeader('Automatic replies'),
          SwitchListTile(
            title: const Text('Reply automatically'),
            subtitle: const Text(
              'Answers direct messages for you and sets your status to out '
              'of office',
            ),
            value: props.autoReply,
            onChanged: enabled
                ? (on) => _save(props, props.withAutoReply(on))
                : null,
          ),
          ListTile(
            enabled: enabled,
            title: const Text('Message'),
            subtitle: Text(props.autoReplyMessage),
            onTap: () async {
              final text = await showDialog<String>(
                context: context,
                builder: (_) => _TextDialog(
                  title: 'Automatic reply',
                  initial: props.autoReplyMessage,
                  multiline: true,
                ),
              );
              if (text == null) return;
              await _save(props, props.withAutoReply(props.autoReply, text));
            },
          ),
        ],
      ],
    );
  }
}

class _TextDialog extends StatefulWidget {
  const _TextDialog({
    required this.title,
    required this.initial,
    this.helper,
    this.multiline = false,
  });

  final String title;
  final String initial;
  final String? helper;
  final bool multiline;

  @override
  State<_TextDialog> createState() => _TextDialogState();
}

class _TextDialogState extends State<_TextDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _controller,
      autofocus: true,
      minLines: widget.multiline ? 3 : 1,
      maxLines: widget.multiline ? 6 : 1,
      textCapitalization: widget.multiline
          ? TextCapitalization.sentences
          : TextCapitalization.none,
      decoration: InputDecoration(helperText: widget.helper, helperMaxLines: 2),
      onSubmitted: widget.multiline
          ? null
          : (text) => Navigator.of(context).pop(text),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.of(context).pop(),
        child: const Text('Cancel'),
      ),
      TextButton(
        onPressed: () => Navigator.of(context).pop(_controller.text),
        child: const Text('Save'),
      ),
    ],
  );
}
