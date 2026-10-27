import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:matterleast/api/api_error.dart';
import 'package:matterleast/api/websocket/dialog.dart';
import 'package:matterleast/app/composer_providers.dart';
import 'package:matterleast/data/actions/composer_actions.dart';
import 'package:matterleast/data/dialog_clock.dart';
import 'package:matterleast/domain/dialog_dates.dart';
import 'package:matterleast/domain/dialog_rules.dart';
import 'package:matterleast/domain/sign_in_problems.dart';
import 'package:matterleast/domain/time_labels.dart';
import 'package:matterleast/ui/narrow_page.dart';
import 'package:matterleast/ui/tokens.dart';
import 'package:matterleast/ui/window_bar.dart';

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
  late final Map<String, Object?> _values = dialogInitialValues(
    widget.dialog.dialog,
    clockForElement,
  );
  var _errors = const <String, String>{};
  String? _error;
  var _sending = false;

  DialogForm get _form => widget.dialog.dialog;

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
        appBar: WindowAppBar(
          title: Text(_form.title ?? 'Form'),
          actions: [
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
