import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/websocket/dialog.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/data/actions/composer_actions.dart';
import 'package:matterleast/domain/dialog_rules.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/ui/narrow_page.dart';
import 'package:matterleast/ui/tokens.dart';

/// Shows the dialogs integrations open for this device while the screen
/// that calls it is visible.
void listenForDialogs(
  BuildContext context,
  WidgetRef ref, {
  required String url,
  required String channelId,
  required String teamId,
}) => ref.listen(openDialogsProvider(url), (_, next) {
  final dialog = next.value;
  if (dialog == null || !(ModalRoute.of(context)?.isCurrent ?? false)) return;
  unawaited(
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => DialogScreen(
          url: url,
          dialog: dialog,
          channelId: channelId,
          teamId: teamId,
        ),
      ),
    ),
  );
});

/// An integration's form: its fields, checked before sending, with the
/// integration's own complaints shown under them.
class DialogScreen extends ConsumerStatefulWidget {
  const DialogScreen({
    required this.url,
    required this.dialog,
    required this.channelId,
    required this.teamId,
    super.key,
  });

  final String url;
  final OpenDialog dialog;
  final String channelId;
  final String teamId;

  @override
  ConsumerState<DialogScreen> createState() => _DialogScreenState();
}

class _DialogScreenState extends ConsumerState<DialogScreen> {
  late final Map<String, Object?> _values = {
    for (final e in widget.dialog.dialog.elements)
      e.name: e.type == DialogElementType.bool
          ? e.defaultValue == 'true'
          : (e.defaultValue ?? ''),
  };
  var _errors = const <String, String>{};
  String? _error;
  var _sending = false;

  DialogForm get _form => widget.dialog.dialog;

  Future<void> _submit({bool cancelled = false}) async {
    final navigator = Navigator.of(context);
    if (!cancelled) {
      final errors = dialogErrors(_form, _values);
      if (errors.isNotEmpty) {
        setState(() => _errors = errors);
        return;
      }
    }
    setState(() => _sending = true);
    try {
      final actions = await ref.read(
        composerActionsProvider(widget.url).future,
      );
      final outcome = await actions.submitDialog(
        widget.dialog,
        channelId: widget.channelId,
        teamId: widget.teamId,
        values: _values,
        cancelled: cancelled,
      );
      if (!mounted) return;
      switch (outcome) {
        case DialogSubmitted():
          navigator.pop();
        case DialogRejected(:final error, :final fieldErrors):
          if (cancelled) {
            navigator.pop();
            return;
          }
          setState(() {
            _sending = false;
            _error = error;
            _errors = fieldErrors;
          });
      }
    } on ApiError catch (e) {
      if (cancelled) {
        navigator.pop();
        return;
      }
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = switch (e) {
          ServerError(:final message?) when message.isNotEmpty => message,
          _ => connectionProblemText(e, Uri.parse(widget.url).host),
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final intro = _form.introductionText ?? '';
    return PopScope(
      canPop: !(_form.notifyOnCancel ?? false),
      onPopInvokedWithResult: (popped, _) {
        if (!popped && !_sending) unawaited(_submit(cancelled: true));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_form.title ?? 'Form'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
              ),
              onPressed: _sending ? null : _submit,
              child: Text(
                _form.submitLabel?.isNotEmpty ?? false
                    ? _form.submitLabel!
                    : 'Submit',
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: _sending
                ? const LinearProgressIndicator(minHeight: 3)
                : const SizedBox(height: 3),
          ),
        ),
        body: NarrowPage(
          children: [
            if (intro.isNotEmpty) ...[
              Text(intro, style: text.bodyLarge),
              const SizedBox(height: Spacing.lg),
            ],
            if (_error case final error?) ...[
              Text(
                error,
                style: text.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              const SizedBox(height: Spacing.lg),
            ],
            for (final element in _form.elements) ...[
              _field(element),
              const SizedBox(height: Spacing.lg),
            ],
          ],
        ),
      ),
    );
  }

  Widget _field(DialogElement e) {
    final label =
        '${e.displayName ?? e.name}${e.optional ?? false ? ' (optional)' : ''}';
    final error = _errors[e.name];
    void set(Object? value) => setState(() {
      _values[e.name] = value;
      _errors = {..._errors}..remove(e.name);
    });
    final help = e.helpText?.isNotEmpty ?? false ? e.helpText : null;
    switch (e.type) {
      case DialogElementType.bool:
        return CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          value: _values[e.name] == true,
          onChanged: (v) => set(v ?? false),
          title: Text(label),
          subtitle: error != null || help != null
              ? Text(
                  error ?? help!,
                  style: error == null
                      ? null
                      : TextStyle(color: Theme.of(context).colorScheme.error),
                )
              : null,
        );
      case DialogElementType.radio:
        return InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            helperText: help,
            errorText: error,
            border: InputBorder.none,
          ),
          child: RadioGroup<String>(
            groupValue: _values[e.name] as String?,
            onChanged: set,
            child: Column(
              children: [
                for (final o in e.options)
                  RadioListTile<String>(
                    contentPadding: EdgeInsets.zero,
                    value: o.value,
                    title: Text(o.text),
                  ),
              ],
            ),
          ),
        );
      case DialogElementType.select when e.options.isNotEmpty:
        final current = _values[e.name] as String?;
        return DropdownMenu<String>(
          expandedInsets: EdgeInsets.zero,
          label: Text(label),
          hintText: e.placeholder,
          helperText: help,
          errorText: error,
          initialSelection: e.options.any((o) => o.value == current)
              ? current
              : null,
          onSelected: set,
          dropdownMenuEntries: [
            for (final o in e.options)
              DropdownMenuEntry(value: o.value, label: o.text),
          ],
        );
      case _:
        return TextFormField(
          initialValue: _values[e.name] as String? ?? '',
          onChanged: set,
          minLines: e.type == DialogElementType.textarea ? 3 : 1,
          maxLines: e.type == DialogElementType.textarea ? 8 : 1,
          maxLength: (e.maxLength ?? 0) > 0 ? e.maxLength : null,
          obscureText: e.subtype == 'password',
          keyboardType: switch (e.subtype) {
            'email' => TextInputType.emailAddress,
            'number' => TextInputType.number,
            'tel' => TextInputType.phone,
            'url' => TextInputType.url,
            _ => null,
          },
          decoration: InputDecoration(
            labelText: label,
            hintText: e.placeholder,
            helperText: help,
            helperMaxLines: 3,
            errorText: error,
            border: const OutlineInputBorder(),
          ),
        );
    }
  }
}
