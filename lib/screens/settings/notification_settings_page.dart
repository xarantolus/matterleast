import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/providers.dart';
import 'package:matterleast/domain/notify_props.dart';
import 'package:matterleast/domain/server_entry.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
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

  Future<void> _save(NotifyProps props) async {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(notifySettingsProvider(_url).notifier).save(props);
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
    final settings = ref.watch(notifySettingsProvider(_url));
    final me = ref.watch(currentUserProvider(_url)).value;
    final props = settings.value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        bottom: ProgressSlot(active: _saving || settings.isLoading),
      ),
      body: props != null
          ? _list(context, props, me?.username ?? '')
          : settings.hasError && !settings.isLoading
          ? EmptyState(
              icon: Icons.cloud_off_outlined,
              title: "Couldn't load your notification settings",
              body: requestProblemText(settings.error!, widget.server.address),
              action: FilledButton(
                onPressed: () => ref.invalidate(notifySettingsProvider(_url)),
                child: const Text('Retry'),
              ),
            )
          : const SizedBox.shrink(),
    );
  }

  Widget _list(BuildContext context, NotifyProps props, String username) {
    final keys = props.mentionKeys(username);
    final enabled = !_saving;
    return ListView(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      children: [
        SettingsHeader('On ${widget.server.displayName}'),
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
            if (level != null) await _save(props.withPush(level));
          },
        ),
        SwitchListTile(
          title: const Text('Replies in threads I follow'),
          value: props.threadReplies,
          onChanged: enabled
              ? (on) => _save(props.withThreadReplies(on))
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
            if (trigger != null) await _save(props.withPushTrigger(trigger));
          },
        ),
        const SettingsHeader('Mentions'),
        SwitchListTile(
          title: const Text('My first name'),
          value: props.firstName,
          onChanged: enabled ? (on) => _save(props.withFirstName(on)) : null,
        ),
        SwitchListTile(
          title: const Text('@channel, @all and @here'),
          value: props.channelWide,
          onChanged: enabled ? (on) => _save(props.withChannelWide(on)) : null,
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
              builder: (_) => _MentionKeysDialog(initial: keys.join(', ')),
            );
            if (text == null) return;
            await _save(
              props.withMentionKeys(username, parseMentionKeys(text)),
            );
          },
        ),
      ],
    );
  }
}

class _MentionKeysDialog extends StatefulWidget {
  const _MentionKeysDialog({required this.initial});

  final String initial;

  @override
  State<_MentionKeysDialog> createState() => _MentionKeysDialogState();
}

class _MentionKeysDialogState extends State<_MentionKeysDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Words that mention you'),
    content: TextField(
      controller: _controller,
      autofocus: true,
      decoration: const InputDecoration(
        helperText: 'Separate words with commas',
        helperMaxLines: 2,
      ),
      onSubmitted: (text) => Navigator.of(context).pop(text),
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
