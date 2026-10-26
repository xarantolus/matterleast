import 'package:matterleast/api/websocket/dialog.dart';
import 'package:matterleast/domain/dialog_dates.dart';
import 'package:matterleast/domain/time_labels.dart';

/// The clock a field's dates are read on.
typedef ClockFor = DialogClock Function(DialogElement element);

/// Pure: the values [form] starts with, by element name.
Map<String, Object?> dialogInitialValues(DialogForm form, ClockFor clockFor) =>
    {
      for (final e in form.elements)
        e.name: switch (e.type) {
          DialogElementType.bool => e.defaultValue == 'true',
          DialogElementType.date ||
          DialogElementType.datetime => initialDateValue(e, clockFor(e)),
          _ => e.defaultValue ?? '',
        },
    };

/// Pure: what is wrong with [values] (by element name) for [form], as the
/// official client checks before submitting. Empty when it can be sent.
/// Times in limits are shown on a 24-hour clock unless [use24] is false.
Map<String, String> dialogErrors(
  DialogForm form,
  Map<String, Object?> values, {
  required ClockFor clockFor,
  bool use24 = true,
}) {
  final errors = <String, String>{};
  for (final element in form.elements) {
    final error = _elementError(
      element,
      values[element.name],
      clockFor(element),
      use24,
    );
    if (error != null) errors[element.name] = error;
  }
  return errors;
}

String? _elementError(
  DialogElement element,
  Object? value,
  DialogClock clock,
  bool use24,
) {
  final empty =
      value == null || value == false || (value is String && value.isEmpty);
  if (empty) {
    return element.optional ?? false ? null : 'This field is required.';
  }
  if (value is! String) return null;
  switch (element.type) {
    case DialogElementType.text || DialogElementType.textarea:
      if (element.minLength case final min? when value.length < min) {
        return 'Must be at least $min characters.';
      }
      if (element.maxLength case final max?
          when max > 0 && value.length > max) {
        return 'Must be at most $max characters.';
      }
      return switch (element.subtype) {
        'email' when !value.contains('@') => 'Must be a valid email address.',
        'number' when num.tryParse(value) == null => 'Must be a number.',
        'url' when !_isWebUrl(value) => 'Must be a valid URL.',
        _ => null,
      };
    case DialogElementType.select || DialogElementType.radio:
      final listed = element.options.any((o) => o.value == value);
      final fromServer = element.dataSource?.isNotEmpty ?? false;
      return listed || fromServer ? null : 'Pick one of the options.';
    case DialogElementType.date:
      final day = dialogDate(value, clock);
      if (day == null) return 'Pick a date.';
      final (min, max) = dateBounds(element, clock);
      String label(DateTime d) => dateLabel(d, clock.now, alwaysYear: true);
      if (min != null && day.isBefore(min)) {
        return 'Pick ${label(min)} or later.';
      }
      if (max != null && day.isAfter(max)) {
        return 'Pick ${label(max)} or earlier.';
      }
      return null;
    case DialogElementType.datetime:
      final moment = dialogMoment(value, clock);
      if (moment == null) return 'Pick a date and time.';
      final (min, max) = momentBounds(element, clock);
      if (min != null && moment.isBefore(min)) {
        return 'Pick ${dialogMomentLabel(min, clock, use24: use24)} or later.';
      }
      if (max != null && moment.isAfter(max)) {
        return 'Pick ${dialogMomentLabel(max, clock, use24: use24)} or '
            'earlier.';
      }
      return null;
    case DialogElementType.bool || DialogElementType.unknown:
      return null;
  }
}

/// Pure: a moment as a dialog shows it, on the dialog's clock:
/// "20 Oct 2026 at 14:00".
String dialogMomentLabel(
  DateTime moment,
  DialogClock clock, {
  required bool use24,
}) {
  final wall = clock.toWall(moment);
  return '${dateLabel(wall, clock.now, alwaysYear: true)} at '
      '${timeLabel(wall, use24: use24)}';
}

bool _isWebUrl(String value) {
  final uri = Uri.tryParse(value);
  return uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;
}

/// Pure: [values] as the integration expects them: numbers for number
/// fields, the rest as entered.
Map<String, Object?> dialogSubmission(
  DialogForm form,
  Map<String, Object?> values,
) => {
  for (final element in form.elements)
    if (values.containsKey(element.name))
      element.name: switch ((element.subtype, values[element.name])) {
        ('number', final String text) => num.tryParse(text) ?? text,
        (_, final value) => value,
      },
};
