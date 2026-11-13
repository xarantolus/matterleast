import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/websocket/dialog.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/data/actions/composer_actions.dart';
import 'package:matterleast/data/dialog_clock.dart';
import 'package:matterleast/data/live/dialogs.dart';
import 'package:matterleast/domain/dialog_dates.dart';
import 'package:matterleast/domain/dialog_rules.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/ui/clickable.dart';
import 'package:matterleast/ui/narrow_page.dart';
import 'package:matterleast/ui/picker_modes.dart';
import 'package:matterleast/ui/tokens.dart';

/// Shows the dialogs integrations open for this device while the screen
/// that calls it is visible.
void listenForDialogs(
  BuildContext context,
  WidgetRef ref, {
  required String url,
  required String channelId,
  required String teamId,
}) {
  final inbox = ref.watch(dialogInboxProvider(url)).value;
  ref.listen(openDialogsProvider(url), (_, next) {
    final dialog = next.value;
    if (dialog == null ||
        inbox == null ||
        !inbox.canOpen ||
        !(ModalRoute.of(context)?.isCurrent ?? false)) {
      return;
    }
    unawaited(
      _openOver(
        context,
        inbox,
        url: url,
        dialog: dialog,
        channelId: channelId,
        teamId: teamId,
      ),
    );
  });
}

/// Puts [dialog] over the current screen; completes when it is closed.
Future<void> _openOver(
  BuildContext context,
  DialogInbox inbox, {
  required String url,
  required OpenDialog dialog,
  required String channelId,
  required String teamId,
}) {
  inbox.opened();
  return Navigator.of(context, rootNavigator: true)
      .push(
        MaterialPageRoute<void>(
          fullscreenDialog: true,
          builder: (_) => DialogScreen(
            url: url,
            dialog: dialog,
            channelId: channelId,
            teamId: teamId,
          ),
        ),
      )
      .whenComplete(inbox.closed);
}

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
  late OpenDialog _dialog = widget.dialog;
  late Map<String, Object?> _values = dialogInitialValues(
    _form,
    clockForElement,
  );
  var _errors = const <String, String>{};
  String? _error;
  var _sending = false;
  var _pressing = const <String>{};

  /// Changes whenever the integration sends the form again, so fields start
  /// over from their values.
  var _version = 0;

  DialogForm get _form => _dialog.dialog;

  String _problem(ApiError e) => switch (e) {
    ServerError(:final message?) when message.isNotEmpty => message,
    _ => connectionProblemText(e, hostOf(widget.url)),
  };

  Future<void> _showChild(OpenDialog child, DialogInbox inbox) async {
    await _openOver(
      context,
      inbox,
      url: widget.url,
      dialog: child,
      channelId: widget.channelId,
      teamId: widget.teamId,
    );
    if (mounted && (_form.refreshOnReturn ?? false)) await _refresh();
  }

  Future<void> _refresh() async {
    if ((_form.sourceUrl ?? '').isEmpty) return;
    setState(() => _sending = true);
    try {
      final actions = await ref.read(
        composerActionsProvider(widget.url).future,
      );
      final form = await actions.refreshDialog(
        _dialog,
        channelId: widget.channelId,
        teamId: widget.teamId,
        values: _values,
      );
      if (!mounted) return;
      setState(() {
        _sending = false;
        if (form == null) return;
        _values = keepEnteredValues(form, _values, clockForElement);
        _dialog = OpenDialog(
          triggerId: _dialog.triggerId,
          url: _dialog.url,
          dialog: form,
        );
        _errors = const {};
        _version++;
      });
    } on ApiError catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _error = _problem(e);
      });
    }
  }

  Future<void> _press(DialogElement e, DialogActionButton button) async {
    setState(() {
      _pressing = {..._pressing, e.name};
      _errors = {..._errors}..remove(e.name);
    });
    try {
      final actions = await ref.read(
        composerActionsProvider(widget.url).future,
      );
      await actions.pressDialogButton(
        button,
        channelId: widget.channelId,
        teamId: widget.teamId,
      );
    } on ApiError catch (error) {
      if (mounted) {
        setState(() => _errors = {..._errors, e.name: _problem(error)});
      }
    } finally {
      if (mounted) setState(() => _pressing = {..._pressing}..remove(e.name));
    }
  }

  Future<void> _submit({bool cancelled = false}) async {
    final navigator = Navigator.of(context);
    if (!cancelled) {
      final errors = dialogErrors(
        _form,
        _values,
        clockFor: clockForElement,
        use24: MediaQuery.alwaysUse24HourFormatOf(context),
      );
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
        _dialog,
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
        _error = _problem(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final intro = _form.introductionText ?? '';
    final inbox = ref.watch(dialogInboxProvider(widget.url)).value;
    ref.listen(openDialogsProvider(widget.url), (_, next) {
      final child = next.value;
      if (child == null ||
          inbox == null ||
          !inbox.canOpen ||
          !(ModalRoute.of(context)?.isCurrent ?? false)) {
        return;
      }
      unawaited(_showChild(child, inbox));
    });
    final buttons = submitButtonsElement(_form);
    return PopScope(
      canPop: !(_form.notifyOnCancel ?? false),
      onPopInvokedWithResult: (popped, _) {
        if (!popped && !_sending) unawaited(_submit(cancelled: true));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_form.title ?? 'Form'),
          actions: [
            if (buttons == null)
              TextButton(
                style: context.barButtonStyle,
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
            for (final element in _form.elements)
              if (element != buttons) ...[
                KeyedSubtree(
                  key: ValueKey((_version, element.name)),
                  child: _field(element),
                ),
                const SizedBox(height: Spacing.lg),
              ],
            if (buttons != null)
              for (final option in buttons.options) ...[
                FilledButton(
                  onPressed: _sending
                      ? null
                      : () {
                          _values[buttons.name] = option.value;
                          unawaited(_submit());
                        },
                  child: Text(option.text),
                ),
                const SizedBox(height: Spacing.sm),
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
        return CheckboxListTile.adaptive(
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
      case DialogElementType.actionButton:
        final button = e.actionButton;
        final pressing = _pressing.contains(e.name);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (help != null)
                  Expanded(child: Text(help))
                else
                  const Spacer(),
                FilledButton.tonal(
                  onPressed:
                      _sending ||
                          pressing ||
                          button == null ||
                          button.url.isEmpty
                      ? null
                      : () => unawaited(_press(e, button)),
                  child: pressing
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(e.displayName ?? e.name),
                ),
              ],
            ),
            if (error != null)
              Text(
                error,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
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
      case DialogElementType.date || DialogElementType.datetime:
        return _DateField(
          element: e,
          label: label,
          help: help,
          error: error,
          value: _values[e.name] as String? ?? '',
          onChanged: set,
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
            alignLabelWithHint: e.type == DialogElementType.textarea,
            errorText: error,
            border: const OutlineInputBorder(),
          ),
        );
    }
  }
}

/// A date or date-and-time field: shows the value on the field's clock and
/// picks it with the stock date and time pickers.
class _DateField extends StatelessWidget {
  const _DateField({
    required this.element,
    required this.label,
    required this.help,
    required this.error,
    required this.value,
    required this.onChanged,
  });

  final DialogElement element;
  final String label;
  final String? help;
  final String? error;
  final String value;
  final ValueChanged<String> onChanged;

  bool get _withTime => element.type == DialogElementType.datetime;

  Future<void> _pick(BuildContext context) async {
    final clock = clockForElement(element);
    final moment = _withTime ? dialogMoment(value, clock) : null;
    final wall = moment == null ? null : clock.toWall(moment);
    DateTime? day(DateTime? d) =>
        d == null ? null : DateTime(d.year, d.month, d.day);
    final (min, max) = _withTime
        ? switch (momentBounds(element, clock)) {
            (final a, final b) => (
              day(a == null ? null : clock.toWall(a)),
              day(b == null ? null : clock.toWall(b)),
            ),
          }
        : dateBounds(element, clock);
    final first = min ?? DateTime(1900);
    final last = max ?? DateTime(2200);
    var initial = day(wall) ?? dialogDate(value, clock) ?? clock.today;
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;
    final picked = await showDatePicker(
      initialEntryMode: dateEntryMode,
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last.isBefore(first) ? first : last,
    );
    if (picked == null) return;
    if (!_withTime) {
      onChanged(formatDialogDate(picked));
      return;
    }
    if (!context.mounted) return;
    final start =
        wall ?? snapToInterval(clock.toWall(clock.now), element.timeInterval);
    final time = await showTimePicker(
      initialEntryMode: timeEntryMode,
      context: context,
      initialTime: TimeOfDay(hour: start.hour, minute: start.minute),
    );
    if (time == null) return;
    var chosen = DateTime(
      picked.year,
      picked.month,
      picked.day,
      time.hour,
      time.minute,
    );
    if (!(element.datetimeConfig?.anyMinute ?? false)) {
      chosen = snapToInterval(chosen, element.timeInterval);
    }
    onChanged(formatDialogMoment(clock.fromWall(chosen)));
  }

  @override
  Widget build(BuildContext context) {
    final clock = clockForElement(element);
    final use24 = MediaQuery.alwaysUse24HourFormatOf(context);
    final String? shown;
    if (_withTime) {
      final moment = dialogMoment(value, clock);
      shown = moment == null
          ? null
          : dialogMomentLabel(moment, clock, use24: use24);
    } else {
      final day = dialogDate(value, clock);
      shown = day == null ? null : dateLabel(day, clock.now, alwaysYear: true);
    }
    final step = element.timeInterval;
    final notes = [
      ?help,
      if (_withTime && clock.zone != null) 'Times in ${clock.zone}',
      if (_withTime &&
          step > 1 &&
          !(element.datetimeConfig?.anyMinute ?? false))
        step % 60 == 0
            ? 'Times on the ${step == 60 ? 'hour' : '${step ~/ 60} hours'}'
            : 'Times in steps of $step minutes',
    ];
    final canClear = value.isNotEmpty && (element.optional ?? false);
    return InkWell(
      mouseCursor: clickCursor,
      borderRadius: BorderRadius.circular(4),
      onTap: () => _pick(context),
      child: InputDecorator(
        isEmpty: shown == null,
        decoration: InputDecoration(
          labelText: label,
          hintText:
              element.placeholder ??
              (_withTime ? 'Pick a date and time' : 'Pick a date'),
          helperText: notes.isEmpty ? null : notes.join('. '),
          helperMaxLines: 3,
          errorText: error,
          errorMaxLines: 3,
          border: const OutlineInputBorder(),
          suffixIcon: canClear
              ? IconButton(
                  tooltip: 'Clear',
                  icon: const Icon(Icons.close),
                  onPressed: () => onChanged(''),
                )
              : Icon(_withTime ? Icons.schedule : Icons.calendar_today),
        ),
        child: Text(shown ?? ''),
      ),
    );
  }
}
