import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/app/platform.dart';

/// A button of an adaptive dialog: Material's text button, an iOS dialog
/// action on iOS. A [primary] one is the answer the dialog hopes for
/// (filled on Material, bold on iOS); a [destructive] one is drawn in the
/// error colour.
class DialogAction extends StatelessWidget {
  const DialogAction({
    required this.onPressed,
    required this.child,
    this.primary = false,
    this.destructive = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final bool primary;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    if (usesCupertinoDialogs) {
      return CupertinoDialogAction(
        onPressed: onPressed,
        isDefaultAction: primary,
        isDestructiveAction: destructive,
        child: child,
      );
    }
    if (primary) return FilledButton(onPressed: onPressed, child: child);
    return TextButton(
      style: destructive
          ? TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            )
          : null,
      onPressed: onPressed,
      child: child,
    );
  }
}

/// Asks before something that is hard to undo; true when confirmed. A
/// [destructive] action is drawn in the error colour.
Future<bool> confirm(
  BuildContext context, {
  required String title,
  required String body,
  required String action,
  bool destructive = false,
}) async =>
    await showAdaptiveDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: Text(title),
        content: Text(body),
        actions: [
          DialogAction(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          DialogAction(
            destructive: destructive,
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

/// Tells the user something; there is nothing to decide.
Future<void> inform(
  BuildContext context, {
  required String title,
  required String body,
}) => showAdaptiveDialog<void>(
  context: context,
  builder: (context) => AlertDialog.adaptive(
    title: Text(title),
    content: Text(body),
    actions: [
      DialogAction(
        onPressed: () => Navigator.pop(context),
        child: const Text('OK'),
      ),
    ],
  ),
);

/// Asks for some text; the trimmed answer, or null on Cancel. A [required]
/// answer can't be blank; [problem] may refuse one and say why.
Future<String?> promptText(
  BuildContext context, {
  required String title,
  String initial = '',
  String action = 'Save',
  String? label,
  String? helper,
  int minLines = 1,
  int maxLines = 1,
  bool required = false,
  TextCapitalization capitalization = TextCapitalization.sentences,
  String? Function(String text)? problem,
}) => showDialog<String>(
  context: context,
  builder: (_) => _PromptDialog(
    title: title,
    initial: initial,
    action: action,
    label: label,
    helper: helper,
    minLines: minLines,
    maxLines: maxLines,
    required: required,
    capitalization: capitalization,
    problem: problem,
  ),
);

class _PromptDialog extends StatefulWidget {
  const _PromptDialog({
    required this.title,
    required this.initial,
    required this.action,
    required this.label,
    required this.helper,
    required this.minLines,
    required this.maxLines,
    required this.required,
    required this.capitalization,
    required this.problem,
  });

  final String title;
  final String initial;
  final String action;
  final String? label;
  final String? helper;
  final int minLines;
  final int maxLines;
  final bool required;
  final TextCapitalization capitalization;
  final String? Function(String text)? problem;

  @override
  State<_PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<_PromptDialog> {
  late final _text = TextEditingController(text: widget.initial);
  String? _error;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _submit() {
    final error = widget.problem?.call(_text.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    if (widget.required && _text.text.trim().isEmpty) return;
    Navigator.pop(context, _text.text.trim());
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.title),
    content: TextField(
      controller: _text,
      autofocus: true,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      textCapitalization: widget.capitalization,
      decoration: InputDecoration(
        labelText: widget.label,
        helperText: widget.helper,
        helperMaxLines: 2,
        errorText: _error,
      ),
      onSubmitted: widget.maxLines == 1 ? (_) => _submit() : null,
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ListenableBuilder(
        listenable: _text,
        builder: (context, _) => TextButton(
          onPressed: widget.required && _text.text.trim().isEmpty
              ? null
              : _submit,
          child: Text(widget.action),
        ),
      ),
    ],
  );
}
