import 'package:material_ui/material_ui.dart';

/// Asks before something that is hard to undo; true when confirmed. A
/// [destructive] action is drawn in the error colour.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
  bool destructive = false,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: destructive
                ? TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            onPressed: () => Navigator.pop(context, true),
            child: Text(action),
          ),
        ],
      ),
    ) ??
    false;

/// Asks before joining the channel [name]; nothing is joined silently.
/// [why] says why joining is needed, when it isn't the user's own idea.
Future<bool> confirmJoin(BuildContext context, String name, {String? why}) =>
    confirm(
      context,
      title: 'Join $name?',
      body: [
        ?why,
        'You will see its messages and be able to post. You can leave it '
            'again from the channel list.',
      ].join(' '),
      action: 'Join',
    );

/// Asks before leaving the channel [name]; a [private] one needs an invite
/// to come back.
Future<bool> confirmLeave(
  BuildContext context,
  String name, {
  required bool private,
}) => confirm(
  context,
  title: 'Leave $name?',
  body: private
      ? "It's private, so you'll need an invite to come back."
      : 'You can join it again from Browse channels.',
  action: 'Leave',
  destructive: true,
);
